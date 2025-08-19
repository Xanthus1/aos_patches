.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Double mp regen

.org 0x08021bf2
  .byte 0x2
  ; default: .byte 0x1

.close