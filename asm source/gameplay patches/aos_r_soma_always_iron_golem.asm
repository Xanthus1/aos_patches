.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; never take knockback (always have iron golem effect)

; change comparison to having iron golem effect to do nothing:
; always do iron golem effect logic
.org 0x0801b546
  nop
  ;default: bne        LAB_0801b584


.close