
.base $8000

pal1:
    .hex 0f 11 16 15 ; Background colors                         ;;
    .hex 0f 11 1B 11                                             ;;
    .hex 0f 31 15 30                                             ;;
    .hex 0f 28 30 30                                             ;;
    .hex 0f 1A 12 11 ; Sprite colors                             ;;
    .hex 0f 30 1B 1A                                             ;;
    .hex 0f 19 18 17                                             ;;
    .hex 0f 0f 15 14

bounds:
    .hex 20 e0 20 c0

player_sprite:
    .hex 00 00 00 00 00 01 00 08 f8 02 00 00
    .hex 00 00 00 f0 00 00 00 f8

plume:
    .hex 20 20 20 20 20 20 1a 1b 1c 1d 1e 1f

surface_tiles:
    .hex 20 20 20 20 84 85 20 20 20 20 20 20 20 20 20 20
    .hex 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
    .hex 82 83 20 20 86 87 20 20 05 09 20 20 03 07 20 20
    .hex 82 83 82 83 82 83 20 20 04 08 20 20 82 83 82 83
    .hex 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88
hud:
    .hex 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88 88
    .db "   FUEL",$0e,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$0f,"     000000 "
    .db "   ",$02,$20,$02,$20,$02,$20,$02,$20,"                     "
    .db "   ",$00,$01,$00,$01,$00,$01,$00,$01,"  LIFT 1  TOP 000000 "

ppu_attr:
    .hex ff ff ff ff ff ff ff ff
    .hex ff ff ff ff ff ff ff ff
    .hex ff ff ff ff ff ff ff ff
    .hex ff ff ff ff ff ff ff ff
    .hex ff ff ff ff ff ff ff ff
    .hex ff ff ff ff ff ff ff ff
    .hex af af af af af af af af
    .hex aa aa aa aa aa aa aa aa

    .pad $c000,$ff
