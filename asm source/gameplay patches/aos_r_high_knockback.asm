.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; High knockback

; left knockback speed to
.org 0x0801b8b8
  .word 0xFFFB8000
  ; default: .word 0xFFFE8000


; right knockback speed to 48000
.org 0x0801b9a4
  mov r0, 0x90
  lsl r0, r0, 11
  ; default: 18000
  ; mov        r0,#0xc0
  ; lsl        r0,r0,#0x9

; increase height on knockback
.org 0x0801ba34
  .word 0xFFFC0000
  ; default: .word 0xFFFE0000

; always act as if you were hit in the air (for knockback)
.org 0x0801b5c0
  nop
  ; default: beq 0x0801b5c4


.close