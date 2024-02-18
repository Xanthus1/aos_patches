.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; Note: This requires having the ICON graphic that's currently added by the patch.

; Change All weapon item icons to present icon
.org 0x0804417a
  ; default: ldrb r0,[r7,#0x2]
  mov r0, 0x9C

; change Soul container palette to 0x7 for better tree palette
.org 0x080449ce
  ; default: 0x8
  .byte 0x6

.close