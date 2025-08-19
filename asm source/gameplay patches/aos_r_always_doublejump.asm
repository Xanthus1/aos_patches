.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; soma always has double jump

.org 0x08019312
  ; replace r0 with 2 (after ability soul #2 is checked), so Soma always jumps even without malphas
  mov r0, 2

  ; default:
    lsl r0,r0,#0x18


.close