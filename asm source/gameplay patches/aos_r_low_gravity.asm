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

; XanHook Update 11
.definelabel HookIndex, 11
.org XanUpdateHooksList+0x4*(HookIndex-1)
  .word func_low_gravity | 1



.org 0x87D0100+0x200*(HookIndex-1)
  .area 0x200
  func_low_gravity:
    push {r1-r3}
      ; don't affect while swimming
      ; 0x40 when 'swimming' with skula. contains other bits in other swimming states (like on ground)
      ldr r0, =PlayerEntity
      ldrb r1, [r0, 0x12]
      mov r2, 0xF0
      and r1, r2
      cmp r1, 0x40
      beq @@return

      ; keeps falling speed maxed at alternating between 0 and one step after 0 (0x400)
      ldr r1, =PlayerEntity
      add r1, 0x54			; Y accelleration/ gravity (subpixels)
      ldr r2, [r1]
      cmp r2, 0
      blt @@return

      ; reset accelleration (increases by 0x400 each step in player code)
      ldr r2, =0-0x2000
      str r2, [r1]
      ; reduce velocity if > 0
      sub r1, 0x8
      ldr r2, [r1]
      cmp r2, 0
      ble @@return
      ldr r3, =0x2000
      sub r2, r3
      str r2, [r1]

      @@return:
      pop {r1-r3}
      bx lr

      .pool
  .endarea


.close