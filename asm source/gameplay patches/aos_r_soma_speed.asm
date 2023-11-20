.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Edit Soma's Speed

.definelabel SomaSpeed, 0x20000
; default SomaSpeed is 0x18000
; JuliusSpeed: 0x20000
; MIN: 0x400 (barely move)
; MAX: 0x3FC00 (lol zoom)

.org 0x0801BA98
    ; default instructions for default movement speed:
    ; mov r2, 0xC0
    ; lsl r2, 0x9
    mov r2, SomaSpeed/0x400      ; lsl r2, 0xA  will multiply this value by 0x400.
    lsl r2, 0xA

.org 0x0801B0E6
  ; default:
  ; mov r0, 0xC0
  ; lsl r0, r0, 0x9
  mov r0, SomaSpeed/0x400      ; lsl r0, 0xA  will multiply this value by 0x400.
  lsl r0, 0xA

.close
