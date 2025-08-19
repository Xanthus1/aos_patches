.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus
; Wizard Levelup
; Modified Levelup Settings
; -1 to all STR levelups
; +~1.5 to all INT levelups
; + 3 MP to all levelups

.org 0x08033cea
	;health per level is 0xc (12) by default
	; .byte 12
	
.org 0x80e1e08
	; mp level up uses a table of 20 values depending on your current level/5
	; .byte 5, 5, 6, 8, 10, 11, 12, 12, 13, 13, 13, 14, 15, 16, 16, 16, 17, 18, 19, 20
	.byte 8, 8, 9, 11, 13, 14, 15, 15, 16, 16, 16, 17, 18, 19, 19, 19, 20, 21, 22, 23
	
.org 0x080e1dcc
	; str level up uses a table of 20 values depending on your current level/5
	; default: .byte 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 2, 2, 1, 1, 1, 1, 1, 1
	.byte 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0
	
.org 0x080e1de0
	; con level up uses a table of 20 values depending on your current level/5
	; defaults between 1 and 3
	; .byte 1, 1, 1, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1
	
.org 0x080e1df4
	; int level up uses a table of 20 values depending on your current level/5
	; defaults between 1 and 3
	; .byte 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 1, 1, 1, 1, 1, 1

	; alternate between +1 and +2, for an average of +1.5
	.byte 2, 3, 3, 4, 3, 4, 3, 4, 4, 5, 4, 4, 3, 4, 2, 3, 2, 3, 2, 3
	
.org 0x08033d5e
	; every third level uses this instead for Int level up I think?
	; default is 1
	.byte 2
	
.org 0x8033d64
	; Luck gets 1 added to it each level by default
	; .byte 1

.close
