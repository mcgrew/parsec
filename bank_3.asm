
.base $C000

irq:
nmi:
    inc FRAMECOUNT
    lda #$00
    sta PPUMASK     ; disable rendering
    jsr read_joy

    lda #$00
    sta SPRITES+2
    sta SPRITES+6
    sta SPRITES+10
    ldx #$01
    stx SPRITES+1
    inx
    stx SPRITES+5
    inx
    stx SPRITES+9

-   lda BUTTONS1
    and #%00001000  ; up
    beq +
    dec SPRITES
    dec SPRITES
+   lda BUTTONS1
    and #%00000100  ; down
    beq +
    inc SPRITES
    inc SPRITES
+   lda BUTTONS1
    and #%00000010  ; left
    beq +
    dec SPRITES+3
    dec SPRITES+3
+   lda BUTTONS1
    and #%00000001  ; right
    beq +
    inc SPRITES+3
    inc SPRITES+3

+   lda SPRITES
    sta SPRITES+4
    sec
    sbc #$08
    sta SPRITES+8

    lda SPRITES+3
    sta SPRITES+11
    clc
    adc #$08
    sta SPRITES+7


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

    lda #$00
    sta OAMADDR
    sta OAMADDR
    lda #SPRITES / $100
    sta OAMDMA

    lda #%00011010
    sta PPUMASK     ; enable rendering
    rti

read_joy:
    ; read the joypads
    ldx #$01
--  ldy #$08
    lda #$01
    sta JOY1,x
    lsr a
    sta JOY1,x
-   lda JOY1,x
    lsr a
    rol BUTTONS1,x
    dey
    bne -
    dex
    bpl --
    rts

reset:
    sei
    cld
    lda #$00
    sta PPUCTRL
    ldx #$ff
    txs            ; set up the stack
-   lda PPUSTATUS
    and #$80
    beq -
-   lda PPUSTATUS
    bpl -

;   sei        ; ignore IRQs
;   cld        ; disable decimal mode
;   lda #$10
;   sta PPUCTRL
;   ldx #$ff
;   txs
;   ldx #$40
;   stx $4017  ; disable APU frame IRQ
;   ldx #$ff
;   txs        ; Set up stack
    inx        ; now X = 0
    stx PPUCTRL   ; disable NMI
;   stx PPUMASK   ; disable rendering
    stx DMC_FREQ  ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    bit PPUSTATUS

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized

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
   
@vblankwait2:
    bit $2002
    bpl @vblankwait2
    jsr load_pal
    jsr load_text

    lda #%10010000
    sta $2000       ; enable NMI
    lda #%00011010
    sta $2001      ; enable rendering
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

load_text:
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
    ldx #$40
    lda #$20
-   sta PPUDATA
    dex
    bne -
    ldy #$04
--  ldx #$00
-   lda bkground,x
    sta PPUDATA
    inx
    bne -
    dey
    bpl --
    rts

wait_for_nmi:
    lda #$80
-   bit PPUSTATUS
    bne -
    rts 

.pad $fffa,$ff

.word nmi
.word reset
.word irq

