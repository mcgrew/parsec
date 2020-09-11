

;  MMIO
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
        NOISE_LO   EQU $400e
        NOISE_HI   EQU $400f
        DMC_FREQ   EQU $4010
        DMC_RAW    EQU $4011
        DMC_START  EQU $4012
        DMC_LEN    EQU $4013
        OAMDMA     EQU $4014
        SND_CHN    EQU $4015
        JOY        EQU $4016
        JOY2       EQU $4017

        FRAMECOUNT EQU $7f
        BUTTONS    EQU $80

        PRNG_SEED  EQU $1b ; 2 bytes
        SCROLLX    EQU $1d
        SCROLLY    EQU $1f
        PLAYERX    EQU $00
        PLAYERY    EQU $01
        X_SUBPIXEL EQU $02
        XSPEED     EQU $03
        FUEL_PLUME EQU $04
        SPRITES    EQU $204

