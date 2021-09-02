
.include defs.asm
.include macros.asm

; *** VARIABLES ***
.enum $00
    ENEMY_X     .dsb 8
    ENEMY_Y     .dsb 8
    ENEMY_SPEED .dsb 16
    ENEMY_STEP  .dsb 8
    ENEMY_COUNT .dsb 1
    PLAYERX     .dsb 1
    PLAYERY     .dsb 1
    X_SUBPIXEL  .dsb 1
    XSPEED      .dsb 1
    FUEL_PLUME  .dsb 1
    LIVES       .dsb 1
    HEAT        .dsb 1
    SCROLLX     .dsb 2
    SCROLLY     EQU #0   ; Y scroll is always 0
    FUEL        .dsb 2
    LAST_FUEL   .dsb 1
    FRAMECOUNT  .dsb 1
    COUNTDOWN   .dsb 2
    GROUND_Y    .dsb 1
    LASER_FRAME .dsb 1
    LEVEL       .dsb 1
    MUSIC_TRACK .dsb 1
.ende
.enum $200
    SPRITES    .dsb 256
.ende

; *** PRG ROM ***
.include bank_0.asm
.include bank_3.asm

; *** CHR ROM ***
.incbin chr_rom.chr

