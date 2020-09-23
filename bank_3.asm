
.base $C000

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs            ; set up the stack
    inx
    stx PPUCTRL   ; disable NMI
    stx DMC_FREQ  ; disable DMC IRQs
    lda #$06
    sta PPUMASK   ; disable rendering

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that vblankwait1
    ; does not exit immediately.
    bit PPUSTATUS

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized

; vblankwait1
-   bit PPUSTATUS
    bpl -

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS.  Conveniently, X is still 0.
    txa

@clrmem:
    sta $00,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne @clrmem

    ; Other things you can do between vblank waits are set up audio
    ; or set up other mapper registers.

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

    ; init prng
    sta PRNG_SEED+1

    jsr init_apu

   ; wait for vblank
-   bit $2002
    bpl -

    jsr load_pal
    jsr load_bg

    lda #%10000000
    sta PPUCTRL     ; enable NMI
    lda #%00011010
    sta PPUMASK    ; enable rendering

game_loop:
    jsr read_joy
    jsr handle_buttons
    jsr check_speed
    jsr check_bounds

    ldx #$00       ; if we are on the left X boundary, fuel use should be medium
    lda PLAYERX    ; otherwise the player can hold left to avoid using fuel
    cmp bounds, x
    bne +
    lda #$04
    sta FUEL_PLUME

+   jsr check_collision
    jsr consume_fuel
    jsr engine_sound
    jsr set_sprite_position

    jsr handle_hud
    jsr wait_for_nmi
    jsr set_scroll
    jmp game_loop

handle_hud
-   bit PPUSTATUS   ; wait for end of blank
    bvs -
-   bit PPUSTATUS   ; wait for sprite 0 hit
    bvc -
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

player_explode:
    lda #$00
    sta FRAMECOUNT
    lda #$f
    sta NOISE_VOL
    lda #$e
    sta NOISE_PER
    lda #$8
    sta NOISE_LEN

explode_loop:
    ldx #4             ; load the explosion sprites
    lda FRAMECOUNT
    lsr
    lsr
    sta TMP
-   lda PLAYERY
;     pha
;     txa
;     and #$3
;     beq +
;     pla
;     clc
;     adc TMP
; +   txa
;     and #$3


    sta SPRITES,x
    inx
    lda #$8c
    sta SPRITES,x
    inx
    lda #0
    sta SPRITES,x
    inx
    lda PLAYERX
    cpx #16
    bpl +
    sec
    sbc TMP
    cpx #28
    bmi +
    clc
    adc TMP
+   sta SPRITES,x
    inx
    cpx #40
    bne -

    lda #0
-   sta SPRITES,x
    inx
    bne -

    jsr handle_hud
    jsr wait_for_nmi
    jsr set_scroll
    lda FRAMECOUNT
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
    ; intentional fall-through

clear_sprites:
    ldx #4
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

engine_sound:
    lda FUEL_PLUME
    lsr
+   ora #$30
    sta NOISE_VOL

    lda #$d
    sta NOISE_PER

    lda #$f0
    sta NOISE_LEN
    rts

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
    and #$08        ; up
    beq +
    dec PLAYERY
    lda BUTTONS
    and #$40        ; B button - hold for slow up/down movement
    bne +
    dec PLAYERY
+   lda BUTTONS
    and #$04        ; down
    beq +
    inc PLAYERY
    lda BUTTONS
    and #$40        ; B button - hold for slow up/down movement
    bne +
    inc PLAYERY

+   lda #$04
    sta FUEL_PLUME
    lda BUTTONS
    and #$02        ; left
    beq +
    dec XSPEED
    dec XSPEED
    lda #$00
    sta FUEL_PLUME
+   lda BUTTONS
    and #$01        ; right
    beq +
    inc XSPEED
    lda #$08
    sta FUEL_PLUME

+   lda BUTTONS
    and #$20        ; select
    beq adjust_x_pos
    jmp player_explode
;     jsr release_enemy


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

read_joy:
    jsr get_joy_buttons
-   lda BUTTONS
    pha
    jsr get_joy_buttons
    pla
    cmp BUTTONS
    bne -
    rts

get_joy_buttons:
    ldx #$01
    stx JOY
    dex
    stx JOY
    inx
--  lda #$01
    sta BUTTONS,x
    lsr a        ; now A is 0
-   lda JOY,x
    lsr a	     ; bit 0 -> Carry
    rol BUTTONS,x  ; Carry -> bit 0; bit 7 -> Carry
    bcc -
    dex
    beq --
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
-   jsr prng
    lda PRNG_SEED
    and #$fc
    beq +
    lda #$20
    bne ++
+   lda PRNG_SEED
    and #$01
    ora #$80
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

wait_for_nmi:
    lda #$00
    sta VBLANK
-   lda VBLANK
    beq -
    rts

prng:
    pha
    tya
    pha
    ldy #8     ; iteration count (8 bits)
    lda PRNG_SEED

-   asl        ; shift the register
    rol PRNG_SEED+1
    bcc +
    eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out

+   dey
    bne -
    sta PRNG_SEED
    pla
    tay
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
    lda #$00
    sta PPUMASK     ; disable rendering

+   lda #$00
    sta OAMADDR
    sta OAMADDR
    lda #>SPRITES
    sta OAMDMA
    lda FUEL
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


IFDEF DEBUG
    lda #$23
    sta PPUADDR
    lda #$98
    sta PPUADDR
    lda #$00
    sta TMP2
    lda #BUTTONS
    sta TMP
    jsr show_mem
    lda #PLAYERX
    sta TMP
    jsr show_mem
    lda #PLAYERY
    sta TMP
    jsr show_mem
    lda #>GROUND_Y
    sta TMP2
    lda #<GROUND_Y
    sta TMP
    jsr show_mem
ENDIF

    lda #$20
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
    ldy #$00
    lda (TMP),y
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
    lda (TMP),y
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

init_apu:
    ; Init $4000-4013
    ldy #$13
-   lda @regs,y
    sta SQ1_VOL,y
    dey
    bpl -

    ; We have to skip over $4014 (OAMDMA)
    lda #$0f
    sta SND_CHN
    lda #$40
    sta $4017
    rts

@regs:
    .hex 30 08 00 00
    .hex 30 08 00 00
    .hex 80 00 00 00
    .hex 30 00 00 00
    .hex 00 00 00 00

.pad $fffa,$ff

.word nmi
.word reset
.word irq

