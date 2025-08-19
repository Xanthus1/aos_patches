.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; No weapons cancel on landing

; skip check for weapon flag. Always do 'light' weapon logic
.org 0x08023450
  nop
  ; default: bne 0x0802345c



.close