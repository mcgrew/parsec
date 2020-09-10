; *** HEADER ***

.db "NES", $1a
.db 4 ; = number of PRG banks * $4000
.db 2 ; = number of CHR banks * $2000
.db 18	; MMC1 SxROM
.db 0
.db 0
.db 0
.db 0
.db 0,0,0,0,0

; *** PRG ROM ***

.include alias.asm

.include bank_0.asm
.include bank_1.asm
.include bank_2.asm
.include bank_3.asm

; *** CHR ROM ***
.incbin chr_rom.chr

