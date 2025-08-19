.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; From Reprise
; Included in 'LCK Plus Better Drop rates' patch
; better chances for items / souls.

; increase drop rates for items
; increase drop rate for items (default)
.org 0x0806858e
	; if the calculated chance is lower than this value, item will spawn
	; default is .byte 4
	.byte 5
	
; increase drop rate for item (with rare ring equipped)
.org 0x0806859a
	; if the calculated chance is lower than this value, item will spawn
	; default is .byte 8
	.byte 9
	
; increase drop rates for souls
; increase drop rates for souls (Souls that you have)
.org 0x08068496
	; if the calculated chance is lower than this value, item will spawn
	; default is .byte 3
	.byte 4

; increase drop rates for souls (On Normal mode if you don't have the soul)
.org 0x080684a8
	; if the calculated chance is lower than this value, item will spawn
	; default is .byte 6
	.byte 7
	
; increase drop rates for souls (On Hard mode without having the soul)
.org 0x080684ba
	; if the calculated chance is lower than this value, item will spawn
	; default is .byte 7
	.byte 8

; increase drop rates with soul eater ring.  
.org 0x080684c6
	; default is .byte 8   (the amount having the soul eater ring will add to the number)
	.byte 9

.close
