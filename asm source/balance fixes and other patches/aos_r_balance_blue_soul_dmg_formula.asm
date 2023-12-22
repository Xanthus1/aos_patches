.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus

; default formula:  SoulAP + (SoulAP/8 * Int/2). 
; This will only scale with INT per 8 points of Soul AP, so weaker souls don't scale well.

; new formula: SoulAP + (SoulAP * Int) / 16

.org 0x080215ea
  mov r2, r1      ; replaces SoulAP/8  (make r2 equal to SoulAP instead)

.org 0x080215f2
  ; replaces Int/2 * [previously calculated SoulAP/8 term in r2]
  mov r0, r0      ; keep INT the same   
  mul r0, r2
  asr r0, 0x4

.close