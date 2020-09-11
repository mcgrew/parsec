
.base $C000

irq:
nmi:
    inc FRAMECOUNT
    lda #$00
    sta PPUMASK     ; disable rendering
    jsr read_joy

-   lda BUTTONS
    and #%00001000  ; up
    beq +
    dec PLAYERY
    dec PLAYERY
+   lda BUTTONS
    and #%00000100  ; down
    beq +
    inc PLAYERY
    inc PLAYERY

+   lda #$04
    sta FUEL_PLUME

    lda BUTTONS
    and #%00000010  ; left
    beq +
    dec XSPEED
    lda #$00
    sta FUEL_PLUME
+   lda BUTTONS
    and #%00000001  ; right
    beq +
    inc XSPEED
    lda #$08
    sta FUEL_PLUME

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


++  clc ; set the new player position

    lda XSPEED
    and #$f8
    bpl ++
    rol
    bcs +
    dec PLAYERX
+   adc X_SUBPIXEL
    sta X_SUBPIXEL
    lda PLAYERX 
    sbc #$00
    sta PLAYERX
    jmp +++
++  rol
    adc X_SUBPIXEL
    sta X_SUBPIXEL
    lda PLAYERX
    adc #$00
    sta PLAYERX

+++ ldx #$00
    cmp bounds,x ; don't go off the edge
    bcs +
    lda bounds,x
    sta PLAYERX
    lda #$00
    sta XSPEED
+   inx
    cmp bounds,x
    bcc +
    lda bounds,x
    sta PLAYERX
    dec PLAYERX
    lda #$00
    sta XSPEED

+   inx
    lda PLAYERY
    cmp bounds,x
    bcs +
    lda bounds,x
    sta PLAYERY
+   inx
    cmp bounds,x
    bcc +
    lda bounds,x
    sta PLAYERY
    dec PLAYERY

+   jsr set_position

    lda #$00
    sta OAMADDR
    sta OAMADDR
    lda #SPRITES / $100
    sta OAMDMA

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

    lda #%00011010
    sta PPUMASK     ; enable rendering
    rti

set_position:
    ldy #$05
    ldx #$00
-   lda PLAYERY
    clc
    adc player_sprite,x
    sta SPRITES,x
    inx
    lda player_sprite,x
    sta SPRITES,x
    inx
    lda player_sprite,x
    sta SPRITES,x
    inx
    lda PLAYERX
    clc
    adc player_sprite,x
    sta SPRITES,x
    inx
    dey
    bne -

    ldx FUEL_PLUME
    lda FRAMECOUNT
    and #$04
    beq +
    inx
+   lda plume,x
    sta SPRITES+13
    inx
    inx
    lda plume,x
    sta SPRITES+17

read_joy:
    ; read the joypads
    ldx #$01
--  ldy #$08
    lda #$01
    sta JOY,x
    lsr a
    sta JOY,x
-   lda JOY,x
    lsr a
    rol BUTTONS,x
    dey
    bne -
    dex
    bpl --
    rts

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
    ; init player position
    lda #$40
    sta PLAYERX
    lda #$80
    sta PLAYERY

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
    lda #$d0
    sta SPRITES-4
    ; init prng
    sta PRNG_SEED+1
   
   ; wait for vblank
-   bit $2002
    bpl -

    jsr load_pal
    jsr load_bg

    lda #%10000000
    sta PPUCTRL     ; enable NMI
    lda #%00011010
    sta PPUMASK    ; enable rendering
-   jsr wait_for_nmi
    jmp -

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
    ldy #$03
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
    inx
    bne -
    dey
    bne --

    ; create the surface
    lda #$22
    sta PPUADDR
    lda #$e0
    sta PPUADDR
    ldx #$00
-   lda surface_tiles,x
    sta PPUDATA
    inx
    cpx #$c0
    bne -

    ; PPU attribute table
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR
    ldx #$00
-   lda ppu_attr,x
    sta PPUDATA
    inx
    cpx #$40
    bne -
    rts

wait_for_nmi:
    lda #$80
-   bit PPUSTATUS
    bne -
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

.pad $fffa,$ff

.word nmi
.word reset
.word irq

