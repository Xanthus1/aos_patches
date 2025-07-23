.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

.definelabel XanUpdateHooksList, 0x87D0040  ; Start of update hooks list. Current Length of 0x30 (12 entries)
.definelabel XanUpdateFunctionCode, 0x87D0100 ; function code exists at this location + 0x200*(HookIndex-1)
.definelabel XanOtherFunctionCode, 0x87D2000 ; Other random functions (candle hazards, etc)
  ; Other random function 0 - Destructible to Hazard function

; Xan Hook - Update
; This patch should be included for any update hook patch
; This will excecute any function pointers located in XanUpdateHooksList.
; XanUpdateHooksList + 0x0 through 0x20 are reserved for Xanthus Mode patches
; 0x28-0x2C Are currently free

; Important: Any Hook shouldn't overwrite r4-r6

; HookIndex. Function offset - Function name
; 1. 0x0 - No Air Control / Classicvania Movement Mode
; 2. 0x4 - Hypermode
; 3. 0x8 - Turbo Attack Mode ( L Cancel patch )
; 4. 0xC - Hyper mode
; 5. 0x10 - Panic Mode
; 6. 0x14 - Attack Shuffle Mode / Weapon Shuffle Mode
; 7. 0x18 - Slippery Mode / Extra Slippery Mode
; 8. 0x1C - Hungry Mode
; 9. 0x20 - Bouncy Mode
; 10. 0x24 - Windy Mode
; 11. 0x28 - Free
; 12. 0x2C - Free

.org 0x08043104
  ; pointer to HP display update function
  ; default: 0x0804306D
  .word 0x87D0001

.org 0x87D0000
  .area 0x40
  
  push {r4-r6}
  push {lr}
  
  ldr r4, =0x0804306D   ; hp display update
  bl call_func_in_r4

  ldr r4, =XanUpdateHooksList
  mov r5, 0
  @@loop_update_hooks:
    cmp r5, 0x30
    beq @@end_update_hooks

    ldr r6, [r4, r5]
    cmp r6, 0
    beq @@next_update_hook

    bl call_func_in_r6

    @@next_update_hook:
    add r5, 4
    b @@loop_update_hooks
  
  @@end_update_hooks:

  pop {r4}
  mov lr, r4
  pop {r4-r6}
  bx lr
  .pool

  call_func_in_r1:
    bx r1
  
  call_func_in_r2:
    bx r2

  call_func_in_r3:
    bx r3

  call_func_in_r4:
    bx r4

  call_func_in_r6:
    bx r6

  .endarea

.close