.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; by Xanthus
; Allow Soma to always backdash on the ground

; Normal state: Removes state flag comparison for if Soma is already backdashing as to whether Soma can backdash again
; Note: If only this one is changed, then you can chain backdashes as long as you don't attack.
.org 0x0801bc0f
    ; default: .byte 0x10
    .byte 0x00

; Attack state: Removes state flag comparison for if Soma is already backdashing as to whether Soma can backdash again
.org 0x0801c68F
    ; default: .byte 0x10
    .byte 0x0

; Attack state: For fun, changing this state flag to 0 would make it so that you could backdash in midair to cancel attacks.
.org 0x0801c68c
    ; default: .byte 0x02

.close