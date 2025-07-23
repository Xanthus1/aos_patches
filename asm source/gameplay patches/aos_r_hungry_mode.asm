.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

.definelabel CurrentRNG, 0x2000008	; current RNG Seed
.definelabel GameTime, 0x20000AC ; GameTime address
.definelabel PlayerHP, 0x201327a				; 2 bytes (signed?)
.definelabel PlayerInputLocked, 0x200001B						; has (0x3 or 0x4 or 0x8)? set if inputs are locked (cutscenes, walking through bossdoor, etc.)
.definelabel PlayerLevel, 0x2013279   ; 1 byte

; XanHook Update 8
.definelabel HookIndex, 8
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_hungry_mode_update | 1

.org 0x87D0100+0x200*(HookIndex-1)
  ; drain hp over time, once a second
  func_hungry_mode_update:
  push {r0-r4}

  ; only active when player isn't locked out of controls (cutscenes, boss doors, etc.)
  ldr r0, =PlayerInputLocked
  ldrb r0, [r0]
  cmp r0, 0
  bne @@return

  ldr r4, =PlayerHP
  mov r0, 0
  ldrsh r2, [r4, r0]

  ; don't trigger if player is already dead
  cmp r2, 0
  ble @@return

  ldr r0, =GameTime
  ldr r0, [r0]
  mov r1, 60
  swi 0x6 ; divide , r0 will have quotient, r1 will have modulo
  cmp r1, 0
  bne @@return

  ; subtract hp based on current Level.
  ; <10 : 1 hp
  ; 10+ : 2 hp
  mov r1, 1 ; default of 1 damage

  ldr r0, =PlayerLevel
  ldrb r0, [r0]
  cmp r0, 10
  blt @@skip_min_2
  mov r1, 2     ; take 2 damage
  @@skip_min_2:

  sub r2, r1
  cmp r2, 0
  bgt @@skip_death
  ; Set player damaged flag so death will trigger
  ldr r1, =0x020131d6     ; Player Damaged Flag
  mov r0, 1
  strb r0, [r1]
  @@skip_death:

  ; save new HP
  strh r2, [r4, 0]

  @@return:
  pop {r0-r4}
  bx lr
  .pool

; replace code that checks Julius mode and changes non-hearts drops to hearts
; Change it to a chance that this will drop a meat strip instead
.org 0x08045fd0
  .area 20
  ldr r0, =CurrentRNG
  ; Use a middle byte of the RNG seed, the lowest byte doesn't seem to be
  ; as randomly disbtributed due to how it's generated (though it might've just been chance)
  ldrb r0, [r0, 0x2]
  cmp r0, 0xE8          ; if byte is >= 0xE8  (~1/12 chance)
  blt 0x08045fe6
  mov r6, 3         ; Change Drop Consumable Item ID to 3
  mov r5, 2         ; Change Drop type to Consumable Item type

  b 0x08045fe6      ; jump to after the pool below (containing CurrentRNG location)
  .pool
  .endarea


; make all breakables (candles, destructables, flames) always drop Meat Strips
; .org 0x08045fa6
;   mov r6, 3       ; Change Drop Consumable Item ID to 3
; .org 0x08045faa
;   mov r5, 2       ; Change Drop type to Consumable Item type


.close
