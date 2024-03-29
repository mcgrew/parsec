;this file for FamiTone2 libary generated by FamiStudio

SFX_ALERT        EQU #0
SFX_ENGINE_LOW   EQU #1
SFX_ENGINE_HIGH  EQU #2
SFX_ALERT_BOSS   EQU #3
SFX_EXPLODE      EQU #4
SFX_INCOMING     EQU #5
SFX_INCOMING_UFO EQU #6
SFX_LASER        EQU #7

sounds:
	dw @ntsc
	dw @ntsc
@ntsc:
	dw @sfx_ntsc_alert_sfx
	dw @sfx_ntsc_engine_low_sfx
	dw @sfx_ntsc_engine_high_sfx
	dw @sfx_ntsc_bynite_alert_sfx
	dw @sfx_ntsc_explode_sfx
	dw @sfx_ntsc_incoming_sfx
	dw @sfx_ntsc_incoming_ufo_sfx
	dw @sfx_ntsc_laser_sfx

@sfx_ntsc_alert_sfx:
	db $85,$00,$84,$e1,$83,$37,$89,$f0,$01,$84,$70,$83,$33,$02,$84,$e1
	db $83,$38,$01,$83,$39,$01,$84,$70,$83,$35,$02,$84,$e1,$83,$3b,$02
	db $84,$70,$83,$36,$01,$83,$37,$01,$84,$e1,$83,$3d,$02,$84,$70,$83
	db $37,$01,$00
@sfx_ntsc_bynite_alert_sfx:
	db $85,$00,$84,$9f,$83,$b2,$89,$f0,$83,$bb,$01,$83,$bf,$02,$83,$ba
	db $0f,$83,$bb,$03,$83,$ba,$05,$83,$b9,$03,$83,$b8,$02,$83,$b7,$01
	db $83,$b6,$02,$83,$b5,$01,$83,$b4,$01,$83,$b3,$01,$83,$b2,$01,$83
	db $b1,$01,$83,$b0,$10,$83,$b2,$01,$83,$bb,$01,$83,$bf,$02,$83,$ba
	db $0f,$83,$bb,$03,$83,$ba,$05,$83,$b9,$03,$83,$b8,$02,$83,$b7,$01
	db $83,$b6,$02,$83,$b5,$01,$83,$b4,$01,$83,$b3,$01,$83,$b2,$01,$83
	db $b1,$01,$83,$b0,$12,$83,$b2,$01,$83,$bb,$01,$83,$bf,$02,$83,$ba
	db $0f,$83,$bb,$03,$83,$ba,$05,$83,$b9,$03,$83,$b8,$02,$83,$b7,$01
	db $83,$b6,$02,$83,$b5,$01,$83,$b4,$01,$83,$b3,$01,$83,$b2,$01,$83
	db $b1,$01,$00
@sfx_ntsc_engine_high_sfx:
	db $8a,$0d,$89,$38,$00
@sfx_ntsc_engine_low_sfx:
	db $8a,$0d,$89,$34,$00
@sfx_ntsc_explode_sfx:
	db $8a,$0e,$89,$3e,$05,$89,$3f,$05,$89,$3e,$04,$89,$3d,$03,$89,$3c
	db $02,$89,$3b,$02,$89,$3a,$03,$89,$39,$05,$89,$38,$06,$89,$37,$03
	db $89,$36,$04,$89,$35,$04,$89,$34,$03,$89,$33,$04,$89,$32,$05,$89
	db $31,$04,$00
@sfx_ntsc_incoming_sfx:
	db $85,$03,$84,$56,$83,$b1,$89,$f0,$04,$84,$26,$83,$b2,$02,$83,$b3
	db $03,$83,$b4,$01,$84,$56,$04,$83,$b5,$02,$84,$89,$05,$84,$bf,$06
	db $84,$f8,$05,$85,$04,$84,$34,$83,$b4,$05,$84,$74,$02,$83,$b3,$03
	db $84,$b8,$01,$83,$b2,$03,$83,$b1,$02,$00
@sfx_ntsc_incoming_ufo_sfx:
	db $85,$03,$84,$56,$83,$32,$89,$f0,$83,$30,$01,$83,$38,$01,$83,$30
	db $01,$83,$3d,$01,$83,$30,$01,$83,$34,$01,$83,$30,$02,$83,$32,$01
	db $83,$30,$01,$83,$38,$01,$83,$30,$01,$83,$3d,$01,$83,$30,$01,$83
	db $34,$01,$83,$30,$02,$83,$32,$01,$83,$30,$01,$83,$38,$01,$83,$30
	db $01,$83,$3d,$01,$83,$30,$01,$83,$34,$01,$00
@sfx_ntsc_laser_sfx:
	db $82,$01,$81,$1c,$80,$b8,$89,$f0,$81,$3f,$80,$bc,$01,$81,$67,$80
	db $bf,$01,$81,$ab,$80,$ba,$01,$81,$fb,$80,$b6,$01,$82,$02,$81,$5c
	db $00
