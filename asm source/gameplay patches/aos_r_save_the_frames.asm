.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus
; levelup animation doesn't pause
; new soul pickup text can be dismissed almost imediately

; this value gets orr'd with global flags at 200a074
; which pauses the player
.org 0x080454ec
	.byte 0x00
	; default: .byte 0x01

; number of frames before a new soul pickup
; text can be dismissed
.org 0x08045c78
	.byte 0x02
	; default: .byte 0x40


.close
