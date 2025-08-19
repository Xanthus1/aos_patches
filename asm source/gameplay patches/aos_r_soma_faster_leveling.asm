.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; level up faster

; change a factor in the formula from 9 to 6
.org 0x08033cd4
  .byte 0x6
  ; default: .byte 0x9


.close