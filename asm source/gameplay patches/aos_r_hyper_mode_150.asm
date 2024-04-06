.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

.definelabel GameTime, 0x20000AC

; XanHook Update 4
.definelabel HookIndex, 4
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_update_hyper_enemies | 1

.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_update_hyper_enemies:
    ; v1.0 - All enemies, bosses, and hazards at 150%.
    ; TODO: optimize Great Armors?
    .definelabel QuetzUpdateFunction, 0x08077CBD
    .definelabel QuetzTailUpdateFunction, 0x8078319
    .definelabel ManEaterTentrilsUpdateFunction, 0x080ba37c | 1
    .definelabel FuncBaloreGiantBatUpdate, 0x80b60ec
    .definelabel FuncBaloreLittleBatsUpdate, 0x080b5f1c
    .definelabel NeedlesUpdateFunction, 0x080CB855
    .definelabel ChaosOrbUpdateFunction, 0x080A537c | 1

    push {r0-r6}
    push {lr}

    ; 1/2 of the time, re-run updates
    ; Note: Reprise will run double updates on frames 0-2 for the Hyper Enemies Room Modifier,
    ; so run double updates on 4-7 to avoid running triple updates (and potential lag)
    ; on a single frame when combining this patch with Reprise.
    ldr r4, =GameTime
    ldr r3, [r4]
    mov r1, 0x7
    and r3, r1
    cmp r3, 0x4
    blt @@end_loop_enemies

    ; room entities start at  0x1B * 0x84
    ldr r1, =0x020004E4+(0x1B*0x84)
    ; end at 0x48* 0x21
    ldr r2, =0x020004E4+(0x48*0x84)
    @@loop_enemies:
        cmp r1, r2
        bge @@end_loop_enemies

        ldr r3, [r1]                ; load update function
        cmp r3, 0
        beq @@continue

        ; any entity with HP (with certain exceptions) should have extra update call.
        mov r5, 0x34
        ldrsh r3, [r1, r5]         ; load Current HP
        cmp r3, 0
        bgt @@speed_update

        ; hyper update for certain entities that don't have HP

        ldr r3, [r1]
        ; skull spike that moves in rectangle
        ldr r5, =0x08053d10 | 1   ; SkullSpikeUpdate
        cmp r3, r5
        beq @@speed_update

        ; graham hands
        ldr r5, =0x080d374c | 1   ; GrahamHandsUpdate
        cmp r3, r5
        beq @@speed_update

        ; balore hands
        ldr r5, =0x080b4c7c | 1   ; BaloreHandsUpdate
        cmp r3, r5
        beq @@speed_update

        ldr r5, =0x080b69b8 | 1   ; BaloreGiantBatUpdate
        cmp r3, r5
        beq @@speed_update

        ; NOTE: I had to change code so that ChaoOrbs are created in the same
        ; entity space that this loop runs in. They're normally created in particle space.
        ldr r5, =ChaosOrbUpdateFunction
        cmp r3, r5
        beq @@speed_update

        b @@continue

        @@speed_update:
        ; TODO: Ignore certain entities, update using speed changes instead
        ; e.g. Man Eater
        ; Bone dragon should be ignored (head desync's slightly)
            ; Or Run double update on bone dragon sub components

        ; Optimize: wrapper around certain functions to reduce lag? so that functions that run here don't
        ; do certain code? Like checkcollisions again, or rotation functions

        ; For Quetz: modify speed with wrapper every frame, rather than running update twice
        ; Otherwise all the pieces will get desynced because they have different speeds when they run twice.
        ldr r5, =QuetzUpdateFunction
        ldr r3, [r1]
        cmp r3, r5
        beq @@wrap_quetz_update

        ldr r5, =func_hyper_quetz_wrapper| 1
        cmp r3, r5
        beq @@continue

        ; ignore maneater tentrils updating double (they'll move with maneater). Causes lag and doesn't add much.
        ldr r5, =ManEaterTentrilsUpdateFunction
        cmp r3, r5
        beq @@continue

        ; ignore needles
        ldr r5, =NeedlesUpdateFunction
        cmp r3, r5
        beq @@continue

        ; ignore graham fireballs: Changing speed manually instead of double update, due to lag
        ldr r5, =0x080d5454 | 1   ; GrahamSpinningFireballsUpdate
        cmp r3, r5
        beq @@continue

        push {r1, r2, r4, r5, r6}
        mov r0, r1              ; move entity address to r0 for update function call
        ldr r1, [r1]            ; load update function to r1
        bl call_func_in_r1
        pop {r1, r2, r4, r5, r6}
        b @@continue

        @@wrap_quetz_update:
            ldr r3, =func_hyper_quetz_wrapper | 1
            str r3, [r1]        ; store on entity at R1
            b @@continue

        @@continue:
        add r1, 0x84        ; iterate to next entity
        b @@loop_enemies

    @@end_loop_enemies:

    pop {r1}
    mov lr, r1
    pop {r0-r6}
    bx lr
    .pool

  func_hyper_quetz_wrapper:
    push {r1-r4}
    push {lr}

    mov r4, r0

    ; Ensure speeds are at 150% speeds
    ldr r1, [r4, 0x48]     ; load X Velocity
    ldr r2, =0x20000        ; Quetz X velocity (to the right))
    cmp r1, r2
    beq @@set_hyper_speed
    ldr r2, =-0x20000        ; Quetz X velocity (to the left)
    cmp r1, r2
    bne @@skip_set_hyper_speed

    @@set_hyper_speed:
    ; need additional gravity, otherwise hyper quetz jumps higher / further
    ; I somewhat trial and error'd the gravity until it felt similar to vanilla spacing, just faster.
    ldr r2, [r4, 0x54]
    asl r2, 1
    asr r3, r2, 3
    add r2, r3
    str r2, [r4, 0x54]      ; store new grav

    ldr r2, [r4, 0x4C]      ; load Y velocity
    asr r3, r2, 1           ; r3 is 1/2
    add r2, r3
    str r2, [r4, 0x4C]

    ldr r2, [r4, 0x48]      ; load X velocity
    asr r3, r2, 1           ; r3 is 1/2
    add r2, r3
    str r2, [r4, 0x48]

    @@skip_set_hyper_speed:
    ; run update after
    mov r0, r4
    ldr r1, =QuetzUpdateFunction
    bl call_func_in_r1

    pop {r1}
    mov lr, r1
    pop {r1-r4}
    bx lr
    .pool
  .endarea


; Change the entity space that Chaos orbs are created in,
; so that hypermode will re-run ChaosOrbUpdateFunction
.org 0x080a5284
    ;default: .byte 0x49
    .byte 0x1B
.org 0x080a5286
    ; default: .byte 0xCF
    .byte 0x48

; includes certain tweaks so that Hyper Enemies Modifiers doesn't lag as much
; (e.g. reducing particles that spawn on certain bosses/ enemies)

; Graham fireball particles
; reverting old fireball code, found better change
.org 0x080d5698
  ; comparison for particles
  ; default:
  mov r1, 0x20
; makes fireball particles only spawn at the beginning
.org 0x080d5690
  ; default: mov r0, 0xF
  mov r0, 0xEF

; Death scythe particles (introduces some lag)
; reduces flame particle spawning.  Only execute particle spawning when
; timer on death has 0x3 bits all set.
.org 0x80BCDAC
  mov r1, 0x3
  and r0, r1
  cmp r0, 0
  bne 0x80BCE0E

.org 0x080b6842
  ; replace creating Balore's little bat entities, act as if
  ; GetEntity function call returned 0 instead.
  mov r0, 0
  nop

; reduce Balore particles during laser attack
.org 0x080b5344
  ; replace creating flame Particles, act as if
  ; GetEntity function call returned 0 instead.
  mov r0, 0
  nop


; Fix spawners (if code runs twice, it can cause an extra decrement on the spawn counter, replacing 1 enemy with two)
; This replaces code that makes sure to not decrement below 0 to 0xFF. It checks instead for if r4 is equal to r5,
; which isn't true when the update hook is running the update for the entity.

; Zombie
.org 0x0807aaa6
  cmp r4, r5
  bne 0x807ab94

; Merman
.org 0x08070c4e
  cmp r4, r5
  bne 0x8070d24

; medusa head
.org 0x080937de
  cmp r4, r5
  bne 0x80938d4

.close
