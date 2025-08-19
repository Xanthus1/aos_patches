.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Soma always has slide

.org 0x0801c2d4
  ; replace r0 with 2 (after ability soul #0 is checked), so Soma always jumps even without blaze skeleton
  mov r0, 2

  ; default:
    lsl r0,r0,#0x18


.close