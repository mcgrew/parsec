
.include defs.asm

; *** VARIABLES ***
.enum $00
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
    COUNTDOWN   .dsb 1
    GROUND_Y    .dsb 1
    LASER_FRAME .dsb 1
    ENEMY_SPDX  .dsb 1
    ENEMY_SUBX  .dsb 1
    ENEMY_SPDY  .dsb 1
    ENEMY_SUBY  .dsb 1
    ENEMY_POSX  .dsb 1
    ENEMY_POSY  .dsb 1
    NEXT_ENEMY  .dsb 1
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

