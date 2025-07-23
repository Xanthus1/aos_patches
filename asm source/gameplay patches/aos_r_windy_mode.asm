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
.definelabel PlayerEntity, 0x20004E4

; XanHook Update 10
.definelabel HookIndex, 10
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_windy_mode_update | 1

.org 0x87D0100+0x200*(HookIndex-1)
  func_windy_mode_update:
      ; store data here
      ldr r0, =0x203E000+(HookIndex-1)*0x10
      .definelabel Offset_Prev_Player_Grounded, 0x0      ; 1 byte
      .definelabel Offset_Prev_YSpeed, 0x4   ; 4 bytes

      push {r1-r5}
      push {lr}

      ; ignore while using rush soul
      ldr r4, =PlayerEntity
      ldrh r2, [r4, 10]           ; load player state and substate
      ldr r3, =0x0309             ; player state is 9, substate is 0x3 if rush soul is active
      cmp r2, r3
      beq @@return

      ; make wind less effective on ground (0x4000 is too much for friction and will make you slide)
      ldr r5, =0x3000
      ldr r1, =PlayerEntity       ; [Player Entity, 0x10] has &2 bit set in midair
      ldrb r2, [r1, 0x10]
      mov r3, 0x2
      and r2, r3
      cmp r2, r3
      bne @@skip_faster_wind
      ldr r5, =0x4A00
      @@skip_faster_wind:

      ; wind even less effective if player is crouching / sliding [Player Entity, 0x11 has 0x4 bit set]
      ; or in hitstun [Player Entity,0x10] has 0x80 bit
      ldrb r2, [r1, 0x11]
      mov r3, 0x4
      and r2, r3
      cmp r2, r3
      bne @@skip_slower_wind
      ldr r5, =0x1000
      @@skip_slower_wind:
      ldrb r2, [r1, 0x10]
      mov r3, 0x80
      and r2, r3
      cmp r2, r3
      bne @@skip_slower_wind2
      ldr r5, =0x2000
      @@skip_slower_wind2:


      ; cycle between left, No wind, right , no wind
      ; 5 seconds per wind, 2 seconds per no wind.
      ; use [r0, 0x10] for wind timer
      ldr r1, [r0, 0x10]
      add r1, 1
      str r1, [r0, 0x10]

      ldr r2, =60*5
      cmp r1, r2
      blt @@wind_left
      ldr r2, =60*7
      cmp r1, r2
      blt @@return
      ldr r2, =60*12
      cmp r1, r2
      blt @@wind_right
      ldr r2, =60*14
      cmp r1, r2
      blt @@return

      ; reset cycle
      mov r2, 0
      str r2, [r0, 0x10]
      b @@return

      ; wind moving left
      @@wind_left:
      ; create particle every 16 frames
      ldr r4, =GameTime
      ldr r4, [r4]
      mov r0, 0xF
      and r4, r0
      cmp r4, r0
      bne @@skip_left_particle
      ; testing left particle
      ldr r4, =PlayerEntity
      ldr r0, [r4, 0x40]
      ldr r1, [r4, 0x44]
      ldr r3, =0x160000
      sub r1, r3      ; move particle up
      add r0, r3      ; move particle to the right
      mov r2, 4       ; 4 is dust
      mov r3, 6
      ldr r4, =0x08045cec | 1 ; ParticleCreate(X, Y, Sprite, Palette)
      bl call_func_in_r4
      ; set x velocity on particle
      ldr r1, =-0x30000
      str r1, [r0, 0x48]
      @@skip_left_particle:


      ldr r1, =PlayerEntity
      ldr r2, =0x48   ; X velocity
      add r1, r2
      ldr r2, [r1]
      ldr r3, =-0x20000
      cmp r2, r3
      blt @@skip_left_wind
      sub r2, r5
      str r2, [r1]
      @@skip_left_wind:
      b @@return

      ; wind moving right
      @@wind_right:
      ; create particle every 16 frames
      ldr r4, =GameTime
      ldr r4, [r4]
      mov r0, 0xF
      and r4, r0
      cmp r4, r0
      bne @@skip_right_particle
      ; Right particle
      ldr r4, =PlayerEntity
      ldr r0, [r4, 0x40]
      ldr r1, [r4, 0x44]
      ldr r3, =0x160000
      sub r1, r3      ; move particle up
      sub r0, r3      ; move particle to the left
      mov r2, 4
      mov r3, 6
      ldr r4, =0x08045cec | 1 ; ParticleCreate(X, Y, Sprite, Palette)
      bl call_func_in_r4
      ; set x velocity on particle
      ldr r1, =0x30000
      str r1, [r0, 0x48]
      @@skip_right_particle:


      ldr r1, =PlayerEntity
      ldr r2, =0x48   ; X velocity
      add r1, r2
      ldr r2, [r1]
      ldr r3, =0x20000    ; max speed to move
      cmp r2, r3
      bgt @@skip_right_wind
      add r2, r5
      str r2, [r1]
      @@skip_right_wind:

      @@return:
      pop {r1}
      mov lr, r1
      pop {r1-r5}
      bx lr

      .pool

.close
