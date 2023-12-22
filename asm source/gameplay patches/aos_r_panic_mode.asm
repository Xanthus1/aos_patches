.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

.ifndef GameTime
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
  .definelabel PlayerInputLocked, 0x200001B						; has (0x3 or 0x4 or 0x8)? set if inputs are locked (cutscenes, walking through bossdoor, etc.)
  .definelabel PlayerPassiveEffects, 0x02013260				; player passive effect flags

	.definelabel JuliusMode, 0x2013266	; 0 for Soma, 1 for Julius Mode.
	.definelabel PlayerEntity, 0x20004E4
.endif

; XanHook Update 5
.definelabel HookIndex, 5
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_update_panic_rush | 1

.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_update_panic_rush:
    ; move the player faster based on missing HP
    push {r0-r4}
    push {lr}

    @@panic_rush:
      ; todo: make the handling of this better if possible (when the player should be able to move)
      ; currently checking various player flags at different places, may be able to simplify this.

      ; this code didn't work, this code runs before the PlayerInputLocked is set, or after it's cleared
      ; ignore when player inputs are locked
      ; ldr r1, =PlayerInputLocked
      ; ldrb r1,[r1]
      ; cmp r1, 0
      ; bne @@end_of_panic_rush

      ; if these aren't equal, player input is locked
      ldr r1, =0x2000014    ; playerInput
      ldr r2, [r1]
      ldr r1, =0x200001C    ; AppliedPlayerInput
      ldr r3, [r1]
      cmp r2, r3
      bne @@end_of_panic_rush

      ; player in state 01, or 2 (walking around, attacking, or using soul/ability)
      ldr r1, =PlayerEntity
      ldrb r3, [r1, 0xA]
      cmp r3, 2
      bgt @@end_of_panic_rush

      ; if in julius mode, don't add speed if attacking on-ground
      ldr r2, =JuliusMode
      ldrb r2, [r2]
      cmp r2, 1 
      bne @@skip_julius
      cmp r3, 1       ; attacking state
      bne @@skip_julius
      ldrb r3, [r1, 0x12]   ; has 0x10 bit set if on the ground
      mov r2, 0x10
      and r3, r2
      cmp r3, 0
      bne @@end_of_panic_rush
      @@skip_julius:

      ; see if player is not attacking or backdashing (causes speed glitch issues)
      ; for some reason with book of return, 0x40 gets set and doesn't clear.
      ldrb r3, [r1, 0x13]
      mov r2, 0xBF        ; ignore 0x40
      and r3, r2       
      mov r2, 0x10        ; backdashing
      and r3, r2
      cmp r3, 0x10        
      beq @@end_of_panic_rush
      ; not crouching or using red soul (0x04 is set at [player, 0x11] if crouching, 0x2 with armor soul, 0x1 if red soul)
      ; ignore red soul because some that change momentum can cause weird speed (werejaguar, balore, etc.)
      ldrb r3, [r1, 0x11]
      mov r2, 0x5
      and r3, r2
      cmp r3, 0x0 
      bne @@end_of_panic_rush

      ; check panther/bat status flag (too fast with panther, can zip)
      ldr r3, =PlayerPassiveEffects
      ldr r3, [r3]
      ldr r2, =0x600    ; panther or bat flag
      and r2, r3
      cmp r2, 0
      bne @@end_of_panic_rush

      ldrb r3, [r1, 0x10] 
      cmp r3, 0x20        ; attacking on ground is 0x20. midiar has 0x02 and/or 0x04 bit set.
      beq @@end_of_panic_rush

      ; increase player speed based on direction being held
      ldr r2, =PlayerButtons
      ldrh r2, [r2]           ; 0x10 for right, 0x20 for left
      mov r3, 0x30
      and r2, r3
      cmp r2, 0
      beq @@end_of_panic_rush

      ; Increase speed based on amount of HP missing (up to 200% speed)
      bl @func_missing_hp_16ths
      ldr r3, [r1, 0x48]        ; Load X Speed
      asr r4, r3, 4             ; make r4 1/16th speed
      mul r4, r0                ; multiply by missing HP factor      
      add r4, r3                ; add to Speed
      str r4, [r1, 0x48]

      ; only increase animation timer if not attacking
      ldr r1, =PlayerEntity
      ldrb r3, [r1, 0xA]      ; load player state
      cmp r3, 1               ; attacking state
      beq @@end_of_panic_rush

      ; increase animation timer (0x6F) based on GameTime and Missing HP factor
      ; (occurs more often the higher missing HP is)
      ldr r2, =GameTime
      ldr r2, [r2]
      mov r3, 0x7
      and r2, r3
      lsl r0, 1
      cmp r0, r2
      blt @@end_of_panic_rush
      
      mov r2, r1
      add r2, 0x6f
      ldrb r3, [r2]
      add r3, 1
      strb r3, [r2]
    @@end_of_panic_rush:

    @@return:
    pop {r0}
    mov lr, r0
    pop {r0-r4}
    bx lr

    @func_missing_hp_16ths:
      push {r1, r2}
      ; returns value in r0 proportional to missing HP.
      ; equivalent to (missingHP)/(1/16th MaxHP)
      ldr r1, =PlayerHP
      ldrh r1, [r1]
      ldr r2, =PlayerMaxHP
      ldrh r2, [r2]
      sub r1, r2, r1      ; r1 is now missing HP
      asr r2, 4           ; make r2 1/16th max hp

      ; divide missing hp by fraction of hp 
      mov r0, r1  
      mov r1, r2
      swi 0x6     ; divide r0/r1. r0 quotient, r1 remainder
      ; value in r0 will be factor 

      pop {r1, r2}
      bx lr
      .pool

    .pool
  .endarea
  

.close