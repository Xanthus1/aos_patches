.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus
; Half MP on levelup (roughly)
; Modified Levelup Settings

.org 0x80e1e08
	; mp level up uses a table of 20 values depending on your current level/5
	; default: .byte 5, 5, 6, 8, 10, 11, 12, 12, 13, 13, 13, 14, 15, 16, 16, 16, 17, 18, 19, 20
	.byte 2, 3, 3, 4, 5, 5, 6, 6, 6, 6, 6, 7, 7, 8, 8, 8, 8, 9, 9, 10

.close
