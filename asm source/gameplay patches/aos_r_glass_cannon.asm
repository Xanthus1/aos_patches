.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Glass cannon

; increase starting strength
.org 0x08033dc2
  mov r0, 0xa+20
  ; default:
    ; mov r0, 0xa


;  decrease starting CON
; r0 is strength's value.
; subracting 0x20 undoes the strength buff above
; subtracting 0xa-0xC would bring it back to 0xC, the default
; finally, subtracting an additional 20 would bring it 20 below default
.org 0x08033dc6
  sub r0, (0xa-0xC)+20+20
  ;default:
    ; mov r0, 0xC

.close