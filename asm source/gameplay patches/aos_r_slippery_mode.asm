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
.definelabel PlayerMaxMP, 0x02013280		; 2 bytes
.definelabel PlayerInputLocked, 0x200001B						; has (0x3 or 0x4 or 0x8)? set if inputs are locked (cutscenes, walking through bossdoor, etc.)
.definelabel PlayerPassiveEffects, 0x02013260				; player passive effect flags

.definelabel JuliusMode, 0x2013266	; 0 for Soma, 1 for Julius Mode.
.definelabel PlayerEntity, 0x20004E4

; XanHook Update 7
.definelabel HookIndex, 7
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_slippery | 1



.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_slippery:
      push {r1-r6}

      ; store data here
      ldr r0, =0x203E000+(HookIndex-1)*0x10
      .definelabel Offset_Initialized, 0x0      ; 1 byte (not needed)
      .definelabel Offset_Prev_Player_Jumpstate, 0x1      ; 1byte
      .definelabel Offset_Prev_Speed, 0x4   ; 4 bytes

      ; store player jumpstate to [0x10]
      ; store initialized to [0x11]
      ; store previous player speed to [0x30]

      ldr r4, =PlayerEntity

      ; Don't apply during cutscenes or door transitions
      ; if these aren't equal, player input is locked. Can't directly check PlayerInputLocked because it's reset by the time this code runs.
      ldr r1, =0x2000014    ; playerInput
      ldr r2, [r1]
      ldr r1, =0x200001C    ; AppliedPlayerInput
      ldr r3, [r1]
      cmp r2, r3
      beq @@continue_slippery
      ; save 0 as speed / jumpstate
      mov r3, 0
      str r3, [r0, Offset_Prev_Speed]          ; save previous x speed

      mov r2, 0
      strb r2, [r0, Offset_Prev_Player_Jumpstate]         ; save previous jumpstate
      b @@return

      @@continue_slippery:
      ldrb r2, [r4, 0x10]
      mov r3, 0xF
      and r2, r3                  ; r2 is 0 if player is on ground
      mov r6, 4                   ; if on the ground, shift difference right by this amount
      ; Extra Slippery Mode with even more reduced friction: mov r6, 6

      ; if player was onground previously and still on the ground, set X speed
      ldrb r1, [r0, Offset_Prev_Player_Jumpstate]         ; r1 is 0 is player on ground
      cmp r1, 0
      bne @@air_slide
      cmp r2, 0
      bne @@air_slide
      ; give more friction slidekicking, otherwise you get stuck in slide-corners (slide speed is only applied 1 frame)
      ldrb r1, [r4, 0xA]
      cmp r1, 3                   ; player state is 3 if sliding
      bne @@after_slidekick
      mov r6, 1                   ; sliding friction reduction
      b @@after_friction_set

      @@after_slidekick:
      ; if not sliding, but onground and crouching, do slightly more friction for better stopping
      ldrb r1, [r4, 0x11]         ; 4 bit is set if crouching
      mov r3, 0x4
      and r1, r3
      cmp r1, r3
      bne @@after_crouching
      mov r6, 3                   ; crouching friction reduction
      b @@after_friction_set

      @@after_crouching:
      ; give a little more friction for backdash
      ldrb r1, [r4, 0x13]         ; backdash has 0x10 bit set
      mov r3, 0x10
      and r1, r3
      cmp r1, r3
      bne @@after_friction_set
      mov r6, 3                   ; backdash friction reduction
      ldrb r1, [r4, 0x13]
      sub r1, 0x10
      strb r1, [r4, 0x13]
      b @@after_friction_set

      @@air_slide:
      mov r6, 3                   ; slide very slightly in air to reduce control a bit
      ; unless you're divekicking! speed is only applied first frame, so reduce friction even less for divekicking
      ldrb r1, [r4, 0xA]
      cmp r1, 7                   ; player state is 7 if divekicking
      bne @@after_friction_set
      mov r6, 1

      @@after_friction_set:

      ; override player X speed with mostly old speed, with some new speed added
      ldr r1, [r0, Offset_Prev_Speed]
      ldr r3, [r4, 0x48]
      sub r3, r1
      asr r3, r6
      add r1, r3
      str r1, [r4, 0x48]

      ; save current stats to previous stats for next tick.
      ; save speed
      ldr r3, [r4, 0x48]          ; load Player x speed into r3
      str r3, [r0, Offset_Prev_Speed]          ; save previous x speed

      strb r2, [r0, Offset_Prev_Player_Jumpstate]         ; save previous jumpstate

      @@return:
      pop {r1-r6}
      bx lr
      .pool
  .endarea


.close