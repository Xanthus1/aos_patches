.gba
.relativeinclude on
.erroronwarning on

.include "aos_r_xan_hook_update.asm"
.open "ftc/rom.gba", 08000000h

.definelabel CurrentRNG, 0x2000008	; current RNG Seed

; Note: To make this more useful, I'd suggest changing Meatstrip to 50 HP
; and updating it's description from 29 HP in DSVEdit. Or changing
; this to Tasty Meat instead (see comment/code below).

; replace code that checks Julius mode and changes non-hearts drops to hearts
; Change it to a chance that this will drop a meat strip instead
.org 0x08045fd0
  .area 20
  ldr r0, =CurrentRNG
  ; Use a middle byte of the RNG seed, the lowest byte doesn't seem to be
  ; as randomly disbtributed due to how it's generated (though it might've just been chance)
  ldrb r0, [r0, 0x2]
  cmp r0, 0xFF          ; if byte is >= 0xFF  (~1/256 chance)
  blt 0x08045fe6
  mov r6, 3         ; Change Drop Consumable Item ID to 3 (Meat Strip). Change to 4 for Tasty Meat instead.
  mov r5, 2         ; Change Drop type to Consumable Item type

  b 0x08045fe6      ; jump to after the pool below (containing CurrentRNG location)
  .pool
  .endarea

.close
