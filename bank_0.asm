
.base $8000

bg_pal:
    .hex 0f 11 16 15 ; Background colors                         ;;
    .hex 0f 30 0f 0f                                             ;;
    .hex 0f 2c 15 30                                             ;;
    .hex 0f 28 30 30                                             ;;
sprite_pal:
    .hex 0f 2a 12 0f ; Sprite colors                             ;;
    .hex 0f 30 12 0f                                             ;;
    .hex 0f 24 18 17                                             ;;
    .hex 0f 28 15 14

laser_colors:
    .hex 2b 24 2a 22 2c 26 21 38

bounds:
    .hex 20 e0 18 e0

player_sprite:
    ; y_offset, sprite, attributes, x_offset, ...
    .hex f8 a0 00 00  f8 a1 00 08  f0 a2 00 00
    .hex f8 00 00 f0  f8 00 00 f8

enemy_max_speed:
    .hex 08

enemy_sprites:
    ; y_offset, sprite, attributes, x_offset, ...
    .hex 00 04 02 f8  00 08 02 00
    .hex 00 05 02 f8  00 09 02 00
    .hex 00 06 02 f8  00 0a 02 00

boss_sprite:
    ; y_offset, sprite, attributes, x_offset, ...
    .hex f8 0c 01 f8  f8 0d 01 00
    .hex 00 0c 81 f8  00 0d 81 00

enemy_pattern_x:
    .hex 00 00 00 00
enemy_pattern_y:
    .hex 04 03 02 01

explode_anim_c1:
    .db 7, 27, 47, 67, 87 ; column 1 X
explode_anim_r1:
    .db 4, 8, 12, 16, 20 ; row 1 Y
explode_anim_c2:
    .db 11, 31, 51, 71, 91 ; column 2 X
explode_anim_r2:
    .db 24, 28, 32, 36, 40 ; row 2 Y
explode_anim_c5:
    .db 23, 43, 63, 83, 103 ; column 5 X
explode_anim_r5:
    .db 84, 88, 92, 96, 100 ; row 5 Y
explode_anim_c4:
    .db 19, 39, 59, 79, 99 ; column 4 X
explode_anim_r4:
    .db 64, 68, 72, 76, 80 ; row 4 Y
explode_anim_extra_dec:
    .db 47, 12, 27, 67, 8, 16
explode_anim_extra_inc:
    .db 63, 92, 43, 83, 8, 96

plume:
    .hex 20 20 20 20 20 20 1a 1b 1c 1d 1e 1f

surface_tiles:
    .hex 20 20 20 20 84 85 20 20 20 20 20 20 20 20 20 20
    .hex 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
    .hex 82 83 20 20 86 87 20 20 06 0a 20 20 04 08 20 20
    .hex 82 83 82 83 82 83 20 20 05 09 20 20 82 83 82 83
    .hex 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88
hud:
    .hex 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88
    .db "  FUEL"
    .hex 0e 18 18 18 18 18 18 18 18 18 18 0f 20 89 8a 8a 8b
    .db " 000000 "
    .hex 20 20 20 03 20 03 20 03 20 03 20 20 20 20 20 20
    .hex 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
    .db "   ",$01,$02,$01,$02,$01,$02,$01,$02," LIFT 1   TOP 000000  "

; ppu_attr:
;     .hex ff ff ff ff ff ff ff ff
;     .hex ff ff ff ff ff ff ff ff
;     .hex ff ff ff ff ff ff ff ff
;     .hex ff ff ff ff ff ff ff ff
;     .hex ff ff ff ff ff ff ff ff
;     .hex ff ff ff ff ff ff ff ff
;     .hex af af af af af af 5f 5f
;     .hex aa aa aa aa aa aa 55 55

ppu_attr_sm:
    .hex 30 ff 06 af 02 5f 06 aa 02 55 00

; APU period tables
; period_table_lo:
;     .hex f1 7f 13 ad 4d f3 9d 4c 00 b8 74 34 f8 bf 89 56
;     .hex 26 f9 ce a6 80 5c 3a 1a fb df c4 ab 93 7c 67 52
;     .hex 3f 2d 1c 0c fd ef e1 d5 c9 bd b3 a9 9f 96 8e 86
;     .hex 7e 77 70 6a 64 5e 59 54 4f 4b 46 42 3f 3b 38 34
;     .hex 31 2f 2c 29 27 25 23 21 1f 1d 1b 1a 18 17 15 14
; period_table_hi:
;     .hex 07 07 07 06 06 05 05 05 05 04 04 04 03 03 03 03
;     .hex 03 02 02 02 02 02 02 02 01 01 01 01 01 01 01 01
;     .hex 01 01 01 01 00 00 00 00 00 00 00 00 00 00 00 00
;     .hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;     .hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

.include sfx.asm
.include music.asm

.org  $c000

