
FILLVALUE $ff

; *** HEADER ***

.db "NES", $1a
.db 2  ; PRG ROM banks
.db 1  ; CHR ROM banks
.db $01 ; No Mapper, vertical mirroring
.db $00
.db $00
.db $00
.db $00
.db 0,0,0,0,0

; *** MMIO ***
PPUCTRL    EQU $2000
PPUMASK    EQU $2001
PPUSTATUS  EQU $2002
OAMADDR    EQU $2003
OAMDATA    EQU $2004
PPUSCROLL  EQU $2005
PPUADDR    EQU $2006
PPUDATA    EQU $2007
SQ1_VOL    EQU $4000
SQ1_SWEEP  EQU $4001
SQ1_LO     EQU $4002
SQ1_HI     EQU $4003
SQ2_VOL    EQU $4004
SQ2_SWEEP  EQU $4005
SQ2_LO     EQU $4006
SQ2_HI     EQU $4007
TRI_LINEAR EQU $4008
TRI_LO     EQU $400a
TRI_HI     EQU $400b
NOISE_VOL  EQU $400c
NOISE_PER  EQU $400e
NOISE_LEN  EQU $400f
DMC_FREQ   EQU $4010
DMC_RAW    EQU $4011
DMC_START  EQU $4012
DMC_LEN    EQU $4013
OAMDMA     EQU $4014
SND_CHN    EQU $4015
JOY        EQU $4016
JOY2       EQU $4017

; *** CONSTANTS ***
BTN_RIGHT  EQU #$01
BTN_LEFT   EQU #$02
BTN_DOWN   EQU #$04
BTN_UP     EQU #$08
BTN_START  EQU #$10
BTN_SELECT EQU #$20
BTN_B      EQU #$40
BTN_A      EQU #$80

