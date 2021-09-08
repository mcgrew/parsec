
.macro mac_do_nmi
    jsr wait_for_nmi
    jsr set_scroll
    jsr famistudio_update
.endm

.base $c000

FAMISTUDIO_DPCM_OFF:
.incbin music.dmc

.include famistudio_conf.asm
.include famistudio_asm6.asm

game_init:
    ; init player position
    lda #$40
    sta PLAYERX
    lda #$80
    sta PLAYERY
    lda #$50
    sta FUEL
    sta LAST_FUEL
    lda #$7F
    sta FUEL+1

    ; set up sprite 0 for split scrolling
    lda #$c7
    sta SPRITES
    lda #$88
    sta SPRITES+1
    lda #$20
    sta SPRITES+2
    lda #$f0
    sta SPRITES+3
    sta GROUND_Y

    lda #01
    sta LEVEL
    rts

game_start:
    lda #1
    ldx #<sounds
    ldy #>sounds
    jsr famistudio_sfx_init
    lda #1
    ldx #<parsec_music_data
    ldy #>parsec_music_data
    jsr famistudio_init
    lda #$ff
    sta MUSIC_TRACK
;     jsr famistudio_music_play


game_loop:
    jsr cycle_rng
    jsr read_joy
    jsr handle_sfx
    jsr handle_buttons
    jsr check_speed
    jsr check_bounds
    jsr update_enemy_pos

    ldx #$00       ; if we are on the left X boundary, fuel use should be medium
    lda PLAYERX    ; otherwise the player can hold left to avoid using fuel
    cmp bounds, x
    bne +
    lda #$04
    sta FUEL_PLUME

+   jsr check_collision

    lda HEAT       ; explode if the ship is too hot
    cmp #$e0
    bcc +
    lda #$00
    sta HEAT
    jsr player_explode

+   jsr consume_fuel
    jsr set_sprite_position

    jsr handle_hud
    mac_do_nmi
    jmp game_loop

handle_hud:
    do_wait_for_sprite_hit
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    rts

check_collision:
    lda PLAYERY
    bpl +
    cmp GROUND_Y
    bmi +
    lda #$00        ; collision with ground!
    sta FUEL
    beq player_explode
+   rts

handle_sfx:
+   lda FUEL_PLUME
    lsr
    lsr
    beq +
    ldx #FAMISTUDIO_SFX_CH1
    jsr famistudio_sfx_play
+   rts 

player_explode:
    jsr famistudio_music_stop
    dec MUSIC_TRACK
    lda SFX_EXPLODE
    ldx #FAMISTUDIO_SFX_CH1
    jsr famistudio_sfx_play
    lda #0
    sta ENEMY_COUNT
    sta FIRING

    ldx #4
-   lda PLAYERY
    sta SPRITES,x
    inx
    inx
    lda #0
    sta SPRITES,x
    inx
    lda PLAYERX
    sta SPRITES,x
    inx
    cpx #104
    bne -
    jsr clear_sprites_from_x
    lda #0
    sta COUNTDOWN+1
    lda #$7f
    sta COUNTDOWN
    jsr handle_hud

explode_loop:
    mac_do_nmi
    jsr handle_hud

    ldx #4             ; load the explosion sprites
    lda COUNTDOWN
    lsr
    lsr
    lsr
    lsr
    sta TMP
    lda #$97
    sec
    sbc TMP
-   inx
    sta SPRITES,x
    inx
    inx
    inx
    cpx #104
    bne -

    lda COUNTDOWN
    and #$07
    bne explode_loop

    ldy #9
    lda COUNTDOWN
    and #$0f
    bne +
    ldy #19
    +
-   ldx explode_anim_c1, y
    dec SPRITES, x
    ldx explode_anim_c5, y
    inc SPRITES, x
    dey
    bpl -

    lda COUNTDOWN
    and #$1f
    bne explode_loop
    dec SPRITES+47
    dec SPRITES+12
    inc SPRITES+63
    inc SPRITES+92

    lda COUNTDOWN
    and #$2f
    bne explode_loop
    dec SPRITES+27
    dec SPRITES+67
    dec SPRITES+8
    dec SPRITES+16
    inc SPRITES+43
    inc SPRITES+83
    inc SPRITES+88
    inc SPRITES+96

    lda COUNTDOWN
    bne explode_loop

    lda #$50
    sta FUEL
    lda #$7F
    sta FUEL+1

    lda #$40
    sta PLAYERX
    lda #$80
    sta PLAYERY
    lda #$00
    sta XSPEED
    do_nmi
    jsr next_track
    ; intentional fall-through

clear_sprites:
    ldx #4
clear_sprites_from_x:
    lda #0
-   sta SPRITES,x
    inx
    bne -
    rts

consume_fuel:
IFDEF DEBUG
    lda FUEL
    cmp #$04
    bmi ++
ENDIF
    lda FUEL ; don't consue fuel if there isn't any
    bne +
    lda #$00
    sta FUEL_PLUME
    beq ++
+   lda FUEL_PLUME ; this is either 8, 4, or 0 depending on engine state
    lsr            ; consume 2, 1, or 0 fuel
    lsr
    sta TMP
    lda FUEL+1
    sec
    sbc TMP
    sta FUEL+1
    bvc ++
    dec FUEL
++  rts

check_bounds:
    lda PLAYERX
    cmp bounds ; don't go off the edge
    bcs +
    lda bounds
    sta PLAYERX
    lda #$00
    sta XSPEED
+   lda PLAYERX
    cmp bounds+1
    bcc +
    lda bounds+1
    sta PLAYERX
    dec PLAYERX
    lda #$00
    sta XSPEED

+   lda PLAYERY
    cmp bounds+2
    bcs +
    lda bounds+2
    sta PLAYERY
+   cmp bounds+3
    bcc +
    lda bounds+3
    sta PLAYERY
    dec PLAYERY
+   rts

handle_buttons:
-   lda BUTTONS
    and BTN_UP
    beq +
    dec PLAYERY
    lda BUTTONS
    and BTN_B       ; hold for slow up/down movement
    bne +
    dec PLAYERY
+   lda BUTTONS
    and BTN_DOWN
    beq +
    inc PLAYERY
    lda BUTTONS
    and BTN_B       ; hold for slow up/down movement
    bne +
    inc PLAYERY

+   lda #$04
    sta FUEL_PLUME
    lda BUTTONS
    and BTN_LEFT
    beq +
    dec XSPEED
    dec XSPEED
    lda #$00
    sta FUEL_PLUME
+   lda BUTTONS
    and BTN_RIGHT
    beq +
    inc XSPEED
    lda #$08
    sta FUEL_PLUME

+   lda BUTTONS      ; set the laser frame to $ff (invalid) if A is not pressed
    and BTN_A
    bne +
    lda #$ff
    sta LASER_FRAME
    lda #$0
    sta FIRING

+   ldx HEAT
    lda BUTTONS
    and BTN_A
    beq ++
    lda #$4
    sta FIRING
    lda LASER_FRAME ; set the laser frame if it is currently invalid and A is
    cmp $ff         ; pressed
    bne +
    lda FRAMECOUNT
    and #$07
    sta LASER_FRAME
+   lda FRAMECOUNT
    and #$07
    bne +
    txa
    pha
    lda SFX_LASER
    ldx #FAMISTUDIO_SFX_CH0
    jsr famistudio_sfx_play
    pla
    tax
    lda BUTTONS     ; only increase the heat if the player is moving
    and #$0f
    beq ++ 
    inx
    inx
++  cpx #$00
    beq +
    dex
+   stx HEAT
    lda NEW_BTNS
    and BTN_START
    beq +
    jsr spawn_enemy
+   lda NEW_BTNS
    and BTN_SELECT
    beq adjust_x_pos
    jsr next_track


adjust_x_pos:
    ; set the new x position
    lda XSPEED
    and #$f8
    bpl +
    dec PLAYERX
+   asl
    adc X_SUBPIXEL
    sta X_SUBPIXEL
    lda PLAYERX
    adc #$00
    sta PLAYERX

    rts

spawn_enemy:
    ldx ENEMY_COUNT
    cpx #2
    beq ++
    inc ENEMY_COUNT
    lda RANDOM
    and #$0f
    ora #$e0
    sta ENEMY_X,x
    lda #1
    sta ENEMY_Y,x
    sta ENEMY_SPEED,x
    lda RANDOM
    and #$30
    sta ENEMY_STEP,x

    lda SFX_INCOMING
    ldx #FAMISTUDIO_SFX_CH0
    jsr famistudio_sfx_play
++  rts

update_enemy_pos:
    ldx ENEMY_COUNT
    dex
    bmi ++
-   lda ENEMY_SPEED+8,x
    clc
    adc #1
    sta ENEMY_SPEED+8,x
    lda ENEMY_SPEED,x
    adc #0
    sta ENEMY_SPEED,x
    cmp enemy_max_speed
    bmi +
    dec ENEMY_SPEED,x
+   lda ENEMY_X,x
    sec
    sbc ENEMY_SPEED,x
    sta ENEMY_X,x
    lda ENEMY_STEP,x
    cmp #$40
    beq ++
    lsr
    lsr
    lsr
    lsr
    tay
    lda ENEMY_Y,x
    clc
    adc enemy_pattern_y,y
    sta ENEMY_Y,x
    inc ENEMY_STEP,x
    dex
    bpl -

++  lda ENEMY_COUNT
    tay
    asl
    asl
    asl
    tax
    dex
-   dey
    lda enemy_sprites,x
    clc
    adc ENEMY_X
    sta SPRITES+$80,x
    dex
    lda enemy_sprites,x
    sta SPRITES+$80,x
    dex
    lda enemy_sprites,x
    sta SPRITES+$80,x
    dex
    lda enemy_sprites,x
    clc
    adc ENEMY_Y
    sta SPRITES+$80,x
    dex
    bpl -
    rts

check_speed:
+   lda XSPEED ; enforce speed limit
    beq ++
    bpl +
    cmp #-$7e
    bcs +
    lda #-$7e
    sta XSPEED
+   lda XSPEED
    bmi ++
    cmp #$7e
    bcc ++
    lda #$7e
    sta XSPEED
++  rts



set_sprite_position:
    ldy #$05
    ldx #$00
-   lda PLAYERY
    clc
    adc player_sprite,x
    sta SPRITES+4,x
    inx
    lda player_sprite,x
    sta SPRITES+4,x
    inx
    lda player_sprite,x
    sta SPRITES+4,x
    inx
    lda PLAYERX
    clc
    adc player_sprite,x
    sta SPRITES+4,x
    inx
    dey
    bne -

    ldx FUEL_PLUME
    lda FRAMECOUNT
    and #$04
    beq +
    inx
+   lda plume,x
    sta SPRITES+17
    inx
    inx
    lda plume,x
    sta SPRITES+21

    lda FRAMECOUNT
    and #$08
    bne +
    lda #$00
    beq ++
+   lda #$01
++  sta SPRITES+18
    sta SPRITES+22
    rts

load_pal:
    lda PPUSTATUS
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR
    ldx #$00

-   lda pal1, x
    sta PPUDATA
    inx
    cpx #$20
    bne -
    rts

load_bg:
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; create a random starfield
    ldy #$02
--  ldx #$00
-   lda #$20
++  sta PPUDATA
    dex
    bne -
    dey
    bmi +    ; this will trigger on our final write loop
    bne --
    ldx #$a0 ; start the final write loop
    bne -

+   lda #$40 ; create two lines of empty space
    tax
-   sta PPUDATA
    dex
    bne -

    ; create the surface
    ldx #$00
-   lda surface_tiles,x
    sta PPUDATA
    inx
    cpx #$c0
    bne -
    ; fill in the rest with space
    tax          ; A should be #$20, which is what we need in A and X
-   sta PPUDATA
    dex
    bne -

    ; PPU attribute table - $23c0
    ldx #$00
    ; uncompressed ppu attributes
; -   lda ppu_attr,x
;     sta PPUDATA
;     inx
;     cpx #$40
;     bne -
    ; compressed ppu attributes
--  ldy ppu_attr_sm,x
    beq +
    inx
    lda ppu_attr_sm,x
    inx
-   sta PPUDATA
    dey
    bne -
    beq --
+   rts

draw_laser:
    clc
    lda #$20
    sta LASER_POS+1
    lda PLAYERY ; load the player Y position
    sec
    sbc #3
    asl         ; multiply by 4 to get the vertical ppu position
    bcc +
    inc LASER_POS+1
    inc LASER_POS+1
+   asl
    bcc +
    inc LASER_POS+1
+   and #$E0
    sta LASER_POS
    lda #8
    clc
    adc PLAYERX ; get the X position
    adc SCROLLX
    lsr         ; divide by 8 to get the horizontal position
    lsr
    lsr
    clc
    adc LASER_POS
    sta LASER_POS
    and #$1f
    tay
+   lda LASER_POS+1
    sta PPUADDR
    lda LASER_POS
    sta PPUADDR
    lda #$ff
    sbc PLAYERX
    lsr
    lsr
    lsr
    tax
    dex
    dex
    stx LASER_LEN
    lda PLAYERY
    sec
    sbc #3
    and #7           ; pick the right background tile based on Y position
    clc
    adc #$98
-   sta PPUDATA
    iny
    cpy #$20
    bne + ;   we overflowed the line - fix the ppu address
    jsr fix_ppu_addr
+   dex
    bpl -
    rts

clear_laser:
    ldx LASER_LEN
    beq ++
    lda LASER_POS+1
    sta PPUADDR
    lda LASER_POS
    sta PPUADDR
    and #$1f
    tay
    lda #$20
-   sta PPUDATA
    iny
    cpy #$20
    bne + ;   we overflowed the line - fix the ppu address
    jsr fix_ppu_addr
+   dex
    bpl -
    inx
    stx LASER_LEN
++  rts

fix_ppu_addr:
    pha
    lda LASER_POS+1
    sta PPUADDR
    lda LASER_POS
    and #$E0
    sta PPUADDR
    pla
    rts

irq:
nmi:
    php
    pha ; store the current register state on the stack
    txa
    pha
    tya
    pha
    inc VBLANK
    inc FRAMECOUNT
    lda COUNTDOWN  ; decrement countdown if it's not zero
    ora COUNTDOWN+1
    beq +
    lda COUNTDOWN
    sec
    sbc #1
    sta COUNTDOWN
    lda COUNTDOWN+1
    sbc #0

+   lda #$00
    sta PPUMASK     ; disable rendering

    lda #$90        ; update the LIFT number
    sta PPUADDR
    lda #$23
    sta PPUADDR
    lda LEVEL
    adc #$30
    sta PPUDATA

    ; update the laser color
    lda FRAMECOUNT
    and #$0f
    beq +
    lda FRAMECOUNT
    and #$70
    lsr
    lsr
    lsr
    lsr
    pha
    lda #$3f
    sta PPUADDR
    lda #$0f
    sta PPUADDR
    pla
    tax
    lda laser_colors, x
    sta PPUDATA

    ; draw a laser if needed
+   jsr clear_laser
    lda FRAMECOUNT
    and FIRING
    beq +
    jsr draw_laser

    ; update all sprites
+   lda #$00
    sta OAMADDR
    sta OAMADDR
    lda #>SPRITES
    sta OAMDMA

+   lda FUEL
    cmp #$50
    bne +
    cmp LAST_FUEL
    beq ++
    sta LAST_FUEL
    lda #$23      ; refill the fuel meter
    sta PPUADDR
    lda #$47
    sta PPUADDR
    lda #$18
    ldx #10
-   sta PPUDATA
    dex
    bne -
    beq ++

+   cmp LAST_FUEL
    beq ++
    lda LAST_FUEL ; set up the x register to clear any extra fuel tiles
    sbc FUEL
    lsr
    lsr
    lsr
    tax
    lda #$23    ; update the fuel meter
    sta PPUADDR
    lda FUEL
    lsr
    lsr
    lsr
    clc
    adc #$47
    sta PPUADDR
    lda FUEL
    and #$7
    adc #$10
-   sta PPUDATA
    lda #$10   ; clear any uncleared fuel tiles to the right
    dex
    bpl -
    lda FUEL
    sta LAST_FUEL

    ; check Y position of the ground below the ship
++  lda #%10000100
    sta PPUCTRL     ; set PPUADDR to increment by 32
    lda #$22
    sta TMP2
    lda PLAYERX
    adc SCROLLX
    lsr             ; divide by 8 to get the tile address
    lsr
    lsr
    adc #$e0
    bne +
    lda #$e0
+   sta TMP
    lda TMP2
    sta PPUADDR
    lda TMP
    sta PPUADDR
    lda #22
    sta GROUND_Y
    lda PPUDATA     ; read once to update
-   inc GROUND_Y
    lda PPUDATA     ; read tile data from below the ship
    cmp #$20
    beq -
    asl GROUND_Y
    asl GROUND_Y
    asl GROUND_Y
    lda #%10000000
    sta PPUCTRL     ; set PPUADDR to increment by 1

    ldx #$1a        ; green
    lda HEAT        ; flash the ship if the laser is hot
    cmp #$40
    bcc +
    lda FRAMECOUNT
    and #$10
    beq +
    ldx #$15        ; red

+   lda #$3f        ; overwrite the ship color (palette 4, byte 1)
    sta PPUADDR
    lda #$11
    sta PPUADDR
    stx PPUDATA


IFDEF DEBUG
    lda #$23
    sta PPUADDR
    lda #$98
    sta PPUADDR
;     lda BUTTONS
;     jsr show_mem
    lda PLAYERX
    jsr show_mem
    lda SCROLLX
    jsr show_mem
;     lda PLAYERY
;     jsr show_mem
;     lda GROUND_Y
;     jsr show_mem
    lda LASER_POS+1
    jsr show_mem
    lda LASER_POS
    jsr show_mem
ENDIF

    lda #$20        ; reset the PPU address
    sta PPUADDR
    lda #00
    sta PPUADDR
    lda #%00011010
    sta PPUMASK     ; enable rendering
    pla ; restore the register state from the stack
    tay
    pla
    tax
    pla
    plp
    rti

IFDEF DEBUG
show_mem:
    pha
    lsr
    lsr
    lsr
    lsr
    cmp #10
    bmi +
    clc
    adc #$7
+   adc #$30
    sta PPUDATA
    pla
    and #$f
    cmp #10
    bmi +
    clc
    adc #$7
+   adc #$30
    sta PPUDATA
    rts
ENDIF


set_scroll:
    lda SCROLLX+1
    clc
    adc #$40
    sta SCROLLX+1
    lda SCROLLX
    adc #$00
    sta SCROLLX
    sta PPUSCROLL
    lda SCROLLY
    sta PPUSCROLL
    rts

next_track:
    inc MUSIC_TRACK
    lda MUSIC_TRACK
    cmp parsec_music_data
    bcc +
    lda #$ff
    sta MUSIC_TRACK
    jsr famistudio_music_stop
    rts
+   sta MUSIC_TRACK
    jsr famistudio_music_play
    rts


.include base.asm

