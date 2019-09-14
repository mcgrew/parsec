
irq:
nmi:
    inc framecount
    ; read the joypad
    lda #$01
    sta JOYPAD1
    sta buttons2  ; player 2's buttons double as a ring counter
    lsr a         ; now A is 0
    sta JOYPAD1
-   lda JOYPAD1
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol buttons1    ; Carry -> bit 0; bit 7 -> Carry
    lda JOYPAD2     ; Repeat
    and #%00000011
    cmp #$01
    rol buttons2    ; Carry -> bit 0; bit 7 -> Carry
    bcc -
    rti

reset:
    ldx #$ff
    txs
    sei        ; ignore IRQs
    cld        ; disable decimal mode
    ldx #$40
    stx $4017  ; disable APU frame IRQ
    ldx #$ff
    txs        ; Set up stack
    inx        ; now X = 0
    stx $2000  ; disable NMI
    stx $2001  ; disable rendering
    stx $4010  ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    bit $2002

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized
@vblankwait1:  
    bit $2002
    bpl @vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS.  Conveniently, X is still 0.
    txa
@clrmem:
    sta $000,x
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
   
@vblankwait2:
    bit $2002
    bpl @vblankwait2
    jsr loadpal

    lda #%10010000
    sta $2000       ; enable NMI
    lda #%00011010
    sta $2001      ; enable rendering
-   jsr wait_for_nmi
    jmp -

loadpal:
    lda $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00

-   lda pal1, x
    sta $2007
    inx
    cpx #$20
    bne -
    lda #$20
    sta $2006
    lda #$00
    sta $2006

load_text:
    ldx #$40
    lda #$20
-   sta $2007
    dex
    bne -
    ldx #$00
-   lda text1,x
    sta $2007
    inx
    bne-
-   lda text2,x
    sta $2007
    inx
    bne-
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

