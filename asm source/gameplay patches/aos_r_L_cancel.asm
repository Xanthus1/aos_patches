.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

; By Xanthus
; Combo / Interrupt weapon and red soul attacks into themselves
; Jump cancels all attacks.

.definelabel GameTime, 0x20000AC
.definelabel PlayerButtons, 0x2000014
.definelabel PlayerButtonsJustPressed, PlayerButtons+2		; two bytes
.definelabel PlayerButtonConfigAttack, 0x02013398		; two bytes
.definelabel PlayerButtonConfigJump, 0x201339A			; two bytes
.definelabel PlayerButtonConfigAbility, 0x0201339C	; two bytes
.definelabel PlayerButtonConfigGuardian, 0x0201339E ; two bytes
.definelabel PlayerMaxHP, 0x0201327E		; 2 bytes
.definelabel PlayerHP, 0x201327a				; 2 bytes
.definelabel PlayerMP, 0x0201327C				; 2 bytes
.definelabel PlayerMaxMP, 0x02013280		; 2 bytes
.definelabel PlayerPassiveEffects, 0x02013260				; player passive effect flags
.definelabel FuncUseSoul, 0x8019478 | 1					; Uses soul ability
.definelabel FuncUseWeapon, 0x080197b4 | 1			; Use weapon

.definelabel JuliusMode, 0x2013266	; 0 for Soma, 1 for Julius Mode.
.definelabel PlayerEntity, 0x20004E4

; XanHook Update 3
.definelabel HookIndex, 3
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_update_turbo_attack | 1

.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_update_turbo_attack:
    ; always able to cancel attacks (for Soma)
    push {r0-r4}
    push {lr}

    ldr r1, =JuliusMode
    ldrb r1, [r1]
    cmp r1, 1
    beq @@return

    ; Update previous player state. Used to determine if this is the first frame of an attack
    ldr r0, =0x203E000+(HookIndex-1)*0x10
    ldrb r3, [r0]   ; load previous state into r3
    ldr r4, =PlayerEntity
    ldrb r2, [r4, 0xA]  ; load current state
    strb r2, [r0]       ; store to previous state

    // ldr r1, =PlayerButtonsJustPressed
    // ldrh r1, [r1]
    // ldr r2, =PlayerButtonConfigAttack
    // ldrh r2, [r2]

    // and r1, r2
    // cmp r1, 0
    // bne @@continue

    ldr r1, =PlayerButtonsJustPressed
    ldrh r1, [r1]
    ldr r2, =PlayerButtonConfigAbility
    ldrh r2, [r2]
    and r1, r2
    cmp r1, 0
    beq @@return

    @@continue:
    ; compare previous state. If it's 0, this is the first frame of an attack and shouldn't be cancelled.
    cmp r3, 0
    beq @@return

    ; Attack is pressed after the initial attack: check current state 
    ldrb r2, [r4, 0xA]    
    cmp r2, 0x1
    blt @@return
    cmp r2, 0x2
    bgt @@return

    ; reset everything to be able to attack again
    ; set player state to 0
    mov r2, 0
    strb r2, [r4, 0xA]

    ; clear player attack state flag
    ldrb r2, [r4, 0x10]
    mov r3, 0x0F
    and r2, r3
    strb r2, [r4, 0x10]

    ; clear player soul attack state flag
    ldrb r2, [r4, 0x11]
    mov r3, 0xF4      ; keep crouch (0x04)
    and r2, r3
    strb r2, [r4, 0x11]

    ; clear player attack-backdash flag (so that you can chain attack cancels together)
    ldrb r2, [r4, 0x13]
    mov r3, 0xEF      ; removes 0x10
    and r2, r3
    strb r2, [r4, 0x13]

    ; see if attack was pressed, if so, do UseSoul or UseWeapon
    ldr r1, =PlayerButtonsJustPressed
    ldrh r1, [r1]
    ldr r2, =PlayerButtonConfigAttack
    ldrh r2, [r2]

    and r1, r2
    cmp r1, 0
    beq @@return

    ; delete weapon
    ldr r0, =0x0201311c       ; current weapon pointer
    ldr r0, [r0]
    cmp r0, 0
    beq @@skip_weapon_delete
    ldr r2, [r0]    ; load weapon update function
    bl call_func_in_r2    ; this should delete the weapon since player state has been changed

    ; clear current weapon pointer
    ldr r3, =0x0201311c       ; current weapon pointer
    mov r1, 0
    str r1, [r3]
    @@skip_weapon_delete:

    ; if up is held, UseSoul. Otherwise, UseWeapon
    ldr r2, =0x200001C
    ldrh r2, [r2]
    mov r3, 0x40
    and r2, r3
    cmp r2, 0
    beq @@use_weapon

    mov r0, r4
    mov r1, 0
    ldr r2, =FuncUseSoul
    bl call_func_in_r2
    b @@return
    
    @@use_weapon:
    
    ; set player animation to 0 
    mov r1, r4
    add r1, 0x6E
    mov r2, 0
    strh r2, [r1]

    mov r0, r4
    ldr r2, =FuncUseWeapon
    bl call_func_in_r2 
    b @@return

    @@return:
    pop {r0}
    mov lr, r0
    pop {r0-r4}
    bx lr

    .pool
  .endarea
  

.close