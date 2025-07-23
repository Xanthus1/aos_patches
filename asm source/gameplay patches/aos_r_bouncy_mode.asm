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

; XanHook Update 9
.definelabel HookIndex, 9
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_bouncy_mode_update | 1

.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
    func_bouncy_mode_update:
      ; monitors player state and speed
      ; If you land, creates a bounce entity and pass it players previous speed (because it's currently 0 from landing)
      push {r1-r4}
      push {lr}

      ; store data here
      ldr r0, =0x203E000+(HookIndex-1)*0x10
      .definelabel Offset_Prev_Player_Grounded, 0x0      ; 1 byte
      .definelabel Offset_Prev_YSpeed, 0x4   ; 4 bytes
      mov r4, r0 ; keep data pointer in r4

      ldr r1, =PlayerEntity
      ldrb r2, [r1, 0x10]
      mov r3, 0xF
      and r2, r3                  ; r2 is 0 if player is on ground

      cmp r2, 0x0
      bne @@skip_bounce           ; currently in air, skip bounce

      ; currently on ground, see if player was previously in air
      ldr r3, [r4, Offset_Prev_Player_Grounded]
      cmp r3, 0x0
      beq @@skip_bounce

      ; player just landed, restore player's previous speed and create bounce entity
      ldr r1, =PlayerEntity
      ldr r3, [r4, Offset_Prev_YSpeed]  ; load player previous Y speed
      str r3, [r1, 0x4C]  ; overwrite players Y Speed
      ; reset state if hard landing (0x4 state)
      ldrb r3, [r1, 0xA]   ; load player state
      cmp r3, 0x4
      ; b @@skip_bounce   ; TODO: having this here doesn't break
      bne @@skip_reset_hard_landing
      ; b @@skip_bounce   ; TODO: having this here breaks.
      mov r3, 0
      strb r3, [r1, 0xA]  ; reset player state (to cancel hard landings)
      @@skip_reset_hard_landing:
      ; reset player damage state? [r1, 0x10] has 0x80 bit set. Can do some weird animations without this
      ldrb r3, [r1, 0x10]
      mov r0, 0xF0
      and r0, r3
      cmp r0, 0x80
      bne @@skip_reset_player_hurt_state
      sub r3, 0x80
      strb r3, [r1, 0x10]
      @@skip_reset_player_hurt_state:
      bl func_create_bounce

      ; set player y velocity to 0 to prevent landing again when player updates next frame
      mov r3, 0
      str r3, [r1, 0x4C]

      @@skip_bounce:
      ; store player grounded/jump state and speed
      str r2, [r4, Offset_Prev_Player_Grounded]
      ldr r1, =PlayerEntity
      ldr r3, [r1, 0x4C]  ; load player Y speed
      str r3, [r4, Offset_Prev_YSpeed]

      pop {r1}
      mov lr, r1
      pop {r1-r4}
      bx lr
      .pool

    func_create_bounce:
        ; creates an entity which will launch the player into the air.
        ; required because my landing hook is followed by code that forces
        ; to land / resets Y velocity
        ; params:
        ;   r0 - whether the player's attack animation should be cancelled (0 - cancel, 1 - keep)
        ; returns:
        ;   r0 - entity created
        push {r1-r5}
        push {lr}

        mov r4, r0
        mov r4, 1   ; test: always keep attack, no longer in landing hook

        ; if holding jump, set players Y velocity for a minimum bounce amount
        ldr r1, =0x201339A  ; Jump config button
        ldrh r1, [r1]
        ldr r2, =0x200001c  ; Button pressed
        ldrh r2, [r2]
        and r1, r2
        cmp r1, 0
        beq @@skip_min_bounce

        ; setting this min bounce results in height similar to normal jump height
        ldr r1, =PlayerEntity
        ldr r3, [r1, 0x4C]
        ldr r2, =0x30000
        cmp r2, r3
        blt @@skip_min_bounce
        str r2, [r1, 0x4C]
        @@skip_min_bounce:

         ; use current player velocity to determine if / how much of a bounce to do
        ldr r1, =PlayerEntity
        ldr r1, [r1, 0x4C] ; y velocity
        lsr r1, 0x10
        cmp r1, 2       ; < 2 px per second, no bounce
        blt @@return
        mov r2, 0
        ; set player velocity to 0 so there isn't a hard landing
        str r2, [r1, 0x4C]
        lsl r1, 2       ; rise for 4 frames per speed in pixels
        sub r1, 6
        mov r5, r1      ; store in r5 for use after getting entity

        mov r0, ENTITY_NORMAL
        bl func_get_entity_slot
        ldr r1, =func_bounce_update | 1
        str r1, [r0]
        str r5, [r0, 0x30]      ; store amount of frames to bounce

        ldr r1, =PlayerEntity
        cmp r4, 0
        beq @@cancel_attack
        ; set player state to single jump, keep attack state (&f2)
        ; TODO/FIX: this will show the player with a standing attack animation in midair.
        mov r2, 0xF2
        ldrb r3, [r1, 0x10]
        and r3, r2
        strb r3, [r1, 0x10]
        b @@return

        @@cancel_attack:
        ; set player state to cancel attack.
        ; 0x20 - attack
        ; low nibble should be 0x2 for single jump
        mov r2, 0xF2 ^ 0x20
        ldrb r3, [r1, 0x10]
        and r3, r2
        strb r3, [r1, 0x10]

        @@return:
        pop {r1}
        mov lr, r1
        pop {r1-r5}
        bx lr
        .pool

    func_bounce_update:
        push {r1-r3}
        push {lr}

        ; keeps player rising for X Frames (depends on speed)
        ; Timer in [r0, 0x14]

        ; stop if player is teleporting
        ldr r1, =PlayerEntity
        ldrb r1, [r1, 0xA]  ; load player state
        cmp r1, 0x11        ; teleporting state
        beq @@delete_entity

        ; Some type of issue bouncing with Stone status.
        ; Player state flag 0x80 is being removed somehow when the room modifier calls func_create_bounce,
        ; but not if Quetz calls it.
        ; for now, just ignore bounce with stone state
        cmp r1, 0x0F            ; Stone state
        beq @@delete_entity

        ; increase timer
        ldrb r1, [r0, 0x14]
        add r1, 1
        ldr r2, [r0, 0x30]
        cmp r1, r2
        beq @@delete_entity
        strb r1, [r0, 0x14]
        ; skip cancelling the first frame (velocity is probably still 0 from landing)
        cmp r1, 2
        blt @@skip_cancel

        ; cancel the bounce if something else changes vertical momentum
        ; note: basing this on player y velocity was a bit tricky, so handling separate cases

        ; cancel bounce if you hit your head ( 0x20004E4+0x13 has 0x20 bit set if touching a ceiling)
        ldr r1, =PlayerEntity
        ldrb r2, [r1, 0x13]
        mov r3, 0x20
        and r3, r2
        cmp r3, 0x20
        beq @@delete_entity
        ; cancel bounce if player jump kicks or hippogryph
        ldrb r1, [r1, 0xA]
        cmp r1, 0x7     ; jump kick
        beq @@delete_entity
        cmp r1, 0x5     ; hippogryph
        beq @@delete_entity
        ; cancel bounce if player is damaged
        ldr r1, =0x020131d6
        ldrb r1, [r1]
        cmp r1, 0
        bne @@delete_entity
        ; cancel if medusa head is used (0x20 effect, , replaced with 0x02)
        ldr r1, =0x020131b8     ; (Player disabled bitfield)
        ldrb r1, [r1]
        mov r2, 0x02    ; mov r2, 0x20  ; this was changed when I buffed medusa
        and r1, r2
        cmp r1, r2
        beq @@delete_entity

        @@skip_cancel:
        ; set player Y velocity
        ldr r1, =PlayerEntity
        ldr r2, =-0x40000
        str r2, [r1, 0x4C]  ; Y velocity

        ; set player state to single jump (02 bit set, not 06)
        ldrb r3, [r1, 0x10]
        mov r2, 0x02
        orr r3, r2
        strb r3, [r1, 0x10]
        // mov r2, 0x10
        // strb r3, [r1, 0x11]
        b @@return

        @@delete_entity:
        ldr r1, =0x08000e14 | 1 ; DeleteEntity
        bl call_func_in_r1

        @@return:
        pop {r1}
        mov lr, r1
        pop {r1-r3}
        bx lr
        .pool
    func_get_entity_slot:
        ; TODO: refactor/cleanup code by using this function instead to simplify GetEntitySlot calls
            ; also pass in R1 as initial update/create function, mov it to r2 for GetEntitySlot call.
        ; Calls GetEntitySlot based on r0 for different entity memory spaces
        ; r0 can be 0, 1, or 2.
        ;   0 For restricted entity space (hp display, levelup animation, etc.). These might not be deleted when transitioning rooms
        ;   1 for normal entity space (room entities like enemies, candles)
        ;   2 for particle entity space (particles, etc.)
        ;   3 for red souls
        .definelabel ENTITY_RESTRICTED, 0
        .definelabel ENTITY_NORMAL, 1
        .definelabel ENTITY_PARTICLE, 2
        .definelabel ENTITY_REDSOUL, 3

        push {r1-r3}
        push lr

        cmp r0, 2
        beq @entity_slot_2
        cmp r0, 1
        beq @entity_slot_1
        cmp r0, 3
        beq @entity_slot_3

        @entity_slot_0:
        mov r0, 0x16
        mov r1, 0x19
        b @call_get_entity

        @entity_slot_1:
        mov r0, 0x1B
        mov r1, 0x48
        b @call_get_entity

        @entity_slot_2:
        mov r0, 0x49
        mov r1, 0xCF
        b @call_get_entity

        @entity_slot_3:
        mov r0, 0x2
        mov r1, 0x10
        b @call_get_entity

        ; r2 should be pointer to function that will run on entity (create / update)
        ; until I refactor calls to this function, make r2 a do-nothing function
        ; update functions should be set afterward
        ldr r2, =func_do_nothing | 1

        @call_get_entity:
        ldr r3, =0x8000dA0 | 1  ; GetEntitySlot
        bl call_func_in_r3

        pop r1
        mov lr, r1
        pop {r1-r3}
        bx lr

        .pool

    func_do_nothing:
      bx lr

  .endarea
.close
