
.macro do_wait_for_sprite_hit
-   bit PPUSTATUS   ; wait for end of vblank
    bvs -
-   bit PPUSTATUS   ; wait for sprite 0 hit
    bvc -
.endm

.macro absa
    bpl +
    eor #$ff
    clc
    adc #1
+
.endm

.macro abs v
    bit v
    bpl +
    pha
    lda v
    eor #$ff
    clc
    adc #1
    sta v
    pla
+
.endm

.macro absx v
    bit v
    bpl +
    pha
    lda v,x
    eor #$ff
    clc
    adc #1
    sta v,x
    pla
+
.endm

.macro absy v
    bit v
    bpl +
    pha
    lda v,y
    eor #$ff
    clc
    adc #1
    sta v,y
    pla
+
.endm

