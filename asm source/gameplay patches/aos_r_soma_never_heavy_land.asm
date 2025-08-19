.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Soma never heavy lands

; increase the value that is checked against vertical speed
; to detect hard landing
.org 0x08016748
  lsl r0, r0, 0xd
  ; default: lsl r0,r0,0xb


.close