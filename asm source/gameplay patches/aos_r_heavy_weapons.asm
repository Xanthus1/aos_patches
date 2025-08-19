.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; No weapons cancel on landing

; always do heavy weapon logic (return a 1 from the function, don't check weapon flag)
.org 0x08023450
  nop
  mov r0, 1
  ; default: bne 0x0802345c
    ; mov r0, 0



.close