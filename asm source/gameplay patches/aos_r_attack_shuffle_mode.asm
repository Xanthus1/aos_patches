.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

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
.definelabel PlayerXP, 0x0201328C				; 4 bytes
.definelabel PlayerMaxMP, 0x02013280		; 2 bytes
.definelabel PlayerPassiveEffects, 0x02013260				; player passive effect flags
.definelabel PlayerWeapon, 0x02013268		; 1 byte index
.definelabel PlayerRedSoul, 0x02013269	; 1 byte index. current equipped red soul
.definelabel CurrentYellowSoulEntity, 0x02013164	; Contains pointer to eyllow soul entity
.definelabel CurrentWeaponEntity, 0x201311c     ; pointer to current active weapon entity
.definelabel RedSoulEntityCount, 0x020131be     ; number of active red soul entities

.definelabel JuliusMode, 0x2013266	; 0 for Soma, 1 for Julius Mode.
.definelabel PlayerEntity, 0x20004E4

.definelabel ChaosMPCost, 5

; XanHook Update 6
.definelabel HookIndex, 6
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_chaos_mode_update | 1

.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_chaos_mode_update:
  push {r0-r6}
  push {lr}

  ; store data here
  ldr r5, =0x203E000+(HookIndex-1)*0x10
  .definelabel Offset_Prev_PlayerXP, 0x0      ; 4 bytes
  .definelabel Offset_Prev_PlayerState, 0x4   ; 1 byte
  .definelabel Offset_Prev_PlayerMP, 0x8      ; 2 byte

  ; update weapon / souls to this every frame
  .definelabel Offset_Current_Weapon, 0xA     ; 1 byte
  .definelabel Offset_Current_RedSoul, 0xB     ; 1 byte
  .definelabel Offset_Initialized, 0xC        ; 1 Byte

  ; see if this has been initialized.
  ; if not, store current weapon and redsoul as the starting.
  ; This will keep the same weapon and soul after saving and loading, as well as
  ; at the very beginning of the game
  ldrb r1, [r5, Offset_Initialized]
  cmp r1, 1
  beq @@skip_intialize
  ; set intialized state
  mov r1, 0x1
  strb r1, [r5, Offset_Initialized]

  ; set intial weapon / redsoul / XP
  ldr r4, =PlayerWeapon
  ldrb r1, [r4]
  strb r1, [r5, Offset_Current_Weapon]
  ldrb r1, [r4, 0x1]    ; Load red soul
  strb r1, [r5, Offset_Current_RedSoul]
  ldr r4, =PlayerXP
  ldr r6, [r4]                    ; Load current XP
  b @@save_xp
  @@skip_intialize:

  ldr r4, =PlayerXP
  ; compare current XP to previous
  ldr r6, [r4]          ; load current xp
  ldr r2, [r5, Offset_Prev_PlayerXP]     ; load previous XP
  cmp r6, r2
  bgt @@randomize_weapon_soul
  b @@save_xp     ; this also handles when XP is less than previous (switching to a second game)

  @@randomize_weapon_soul:
  ; randomize to a different weapon
  ldr r1, =0x08000a90 | 1         ; Randomize function
  bl call_func_in_r1
  ; now RNG is in r0
  mov r1, 0x3A + 1                ; There are 0x3A weapons. Add 1 because clamping to max isn't inclusive.
  ldr r2, =0x080daa00 | 1         ; RandClampToMax
  bl call_func_in_r2
  ; new value is in r0
  strb r0, [r5, Offset_Current_Weapon]   ; Save to keep player with this soul equipped

  ; randomize to a different soul
  ldr r1, =0x08000a90 | 1         ; Randomize function
  bl call_func_in_r1
  ; now RNG is in r0
  ; There are 0x37 Red Souls. Don't add 1 yet, because actual range is from 1-0x37 (0 means no soul equipped). Add 1 after randomizing.
  mov r1, 0x37               
  ldr r2, =0x080daa00 | 1         ; RandClampToMax
  bl call_func_in_r2
  ; new value is in r0
  add r0, 1                       ; Add 1 to get value from 1 to 0x37
  strb r0, [r5, Offset_Current_RedSoul]   ; Save to keep player with this soul equipped

  @@save_xp:
  ; save current XP as previous
  str r6, [r5, Offset_Prev_PlayerXP]

  ; if you just used red soul,
  ; set MP equal to previous MP - ChaosMPCost (overwrite the actual soul cost)
  ; see if soul was used (current player state is 2, and previous state wasn't 2)
  ldr r4, =PlayerEntity
  ldrb r6, [r4, 10]         ; load player state (0x2 is using a red soul)
  cmp r6, 2
  bne @@save_previous_state

  ; see if previous state was using a red soul
  ldrb r1, [r5, Offset_Prev_PlayerState]
  cmp r1, 2
  beq @@save_previous_state

  ; this is the first frame of using a red soul.
  ; Set MP to ChaosMPCost lower than it was last frame.
  ldr r4, =PlayerMP
  ldrh r3, [r5, Offset_Prev_PlayerMP]
  sub r3, ChaosMPCost
  strh r3, [r4]

  @@save_previous_state:
  ldr r4, =PlayerEntity
  strb r6, [r5, Offset_Prev_PlayerState]
  ; save previous MP
  ldr r4, =PlayerMP
  ldrh r4, [r4]
  strh r4, [r5, Offset_Prev_PlayerMP]

  ; keep Player with specific weapon / soul equipped until it swaps
  ; Wait until current weapon is no longer active
  ldr r0, =CurrentWeaponEntity
  ldr r0, [r0]
  cmp r0, 0
  bne @@skip_save_weapon
  ldrb r0, [r5, Offset_Current_Weapon]
  ldr r4, =PlayerWeapon
  ldrb r1, [r4]                   ; load current weapon to see if it has changed
  cmp r0, r1
  beq @@skip_save_weapon
  strb r0, [r4]                   ; store new weapon
  ; Update Player Stats (from switching weapons).
  ; Note: This will over-write Yellow soul stat (which occur earlier during this frame)
  ldr r1, =0x0804ad9c | 1       ; UpdatePlayerStats function
  bl call_func_in_r1
  ; re-run code for yellow soul , if it exists
  ldr r1, =CurrentYellowSoulEntity
  ldr r0, [r1]      ; load pointer to yellow soul entity
  cmp r0, 0
  beq @@skip_save_weapon
  ldr r1, [r0]      ; load code pointer on yellow soul entity
  cmp r1, 0
  beq @@skip_save_weapon
  bl call_func_in_r1
  @@skip_save_weapon:

  ; always keep soul
  ; (doesn't matter if it changes while previous red soul entities are active,
  ; Can't be used until previous soul entities are gone)
  ldrb r0, [r5, Offset_Current_RedSoul]
  ldr r4, =PlayerRedSoul
  strb r0, [r4]                   ; store new soul

  pop {r1}
  mov lr, r1
  pop {r0-r6}
  bx lr
  .pool
  .endarea
  
; change MP requirement to always be ChaosMPCost (compare to current MP)
.org 0x08019522
  ; ldrsh      r1,[r7,r2]
  mov r1, ChaosMPCost

; change MP cost to always be ChaosMPCost
; can't use this because of conflict with Reprise hook
; Using the update hook to act as if the MP cost was ChaosMPCost for red souls.
// .org 0x08019570
//   ldrh       r1,[r7,#0x6]
//   ; mov r1, ChaosMPCost

.close