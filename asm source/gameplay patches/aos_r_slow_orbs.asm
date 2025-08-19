.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus
; slow orbs

; change org starting speed
.org 0x0804467c
	.byte 0x05
	; default: .byte 0xc0

; orb barely gets faster over time
.org 0x08044712
	.byte 0x01
	; default: .byte 0xc0

; don't disappear (don't countdown timer)
.org 0x080447fa
	.byte 0x00
	; default: .byte 0x01

.close
