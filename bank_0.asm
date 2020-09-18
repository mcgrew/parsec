
.base $8000

pal1:
    .hex 0f 11 16 15 ; Background colors                         ;;
    .hex 0f 30 0f 0f                                             ;;
    .hex 0f 2c 15 30                                             ;;
    .hex 0f 28 30 30                                             ;;
    .hex 0f 1A 12 11 ; Sprite colors                             ;;
    .hex 0f 30 1B 1A                                             ;;
    .hex 0f 19 18 17                                             ;;
    .hex 0f 0f 15 14

bounds:
    .hex 20 e0 20 c0

player_sprite:
    .hex 00 01 00 00 00 02 00 08 f8 03 00 00
    .hex 00 00 00 f0 00 00 00 f8

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
period_table_lo:
    .hex f1 7f 13 ad 4d f3 9d 4c 00 b8 74 34 f8 bf 89 56
    .hex 26 f9 ce a6 80 5c 3a 1a fb df c4 ab 93 7c 67 52
    .hex 3f 2d 1c 0c fd ef e1 d5 c9 bd b3 a9 9f 96 8e 86
    .hex 7e 77 70 6a 64 5e 59 54 4f 4b 46 42 3f 3b 38 34
    .hex 31 2f 2c 29 27 25 23 21 1f 1d 1b 1a 18 17 15 14
period_table_hi:
    .hex 07 07 07 06 06 05 05 05 05 04 04 04 03 03 03 03
    .hex 03 02 02 02 02 02 02 02 01 01 01 01 01 01 01 01
    .hex 01 01 01 01 00 00 00 00 00 00 00 00 00 00 00 00
    .hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .hex 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; sfx(pulse) - channel, length, note, volume, length, note, volume, ...
;    channel should be 00 (SQ1), 04 (SQ2), or 08 (TRI)
; laser_sfx:
;     .hex 04 10 30 bf 00

; incoming_sfx:
;     .hex 30 bf 60 b0 bf 30

    .pad $c000,$ff

