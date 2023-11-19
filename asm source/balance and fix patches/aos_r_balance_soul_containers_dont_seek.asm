
.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus

; Soul containers drop souls that don't seek to Soma
.org 0x080448f0
  ; default: .byte 0x0
  .byte 0x01
  