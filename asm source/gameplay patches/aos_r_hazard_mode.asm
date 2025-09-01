.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

.definelabel XanOtherFunctionCode, 0x87D2000 ; Other MISC functions (candle hazards, etc)
.definelabel CamX, 0x0200A09A		; 2 bytes, Cam X position (in pixels)
.definelabel CamY, 0x0200A09E		; 2 bytes, Cam Y position (in pixels)

.definelabel XanOtherFunctionCodeIndex, 0   ; this is the first function in this section
.definelabel XanOtherFunctionCodeSize, 0x100  ; code size allocated for each "other function"

; replaces initCandle function call with hook in LoadEntity
.org 0x0800f334
  .area 0xA
  ldr r0, =candle_to_hazard_hook | 1
  bx r0
  .align
  .pool
  .endarea

.org XanOtherFunctionCode+(XanOtherFunctionCodeIndex*XanOtherFunctionCodeSize)
  ; first function in XanOtherFunctionCode
  .area 0x100
  candle_to_hazard_hook:

  ; before candle create, set varA (width of path)
  mov r0, r4
  mov r1, 0x10
  strh r1, [r0, 0x30]

  ; Var B [Entity, 0x32] is  0 for clockwise, 1 for counter-clockwise.
  ; Rotate towards the center of the room. This helps prevent unavoidable
  ; damage when entering a room with a candle next to an entrance (like in many clock tower)
  ldr r2, =0x200A0A8  ; Current room width (in pixels)
  ldrh r2, [r2]
  lsr r2, 1           ; get mid-point of room
  ldr r3, =CamX
  ldrh r3, [r3]
  mov r1, 0x42        ; relative X position (pixels)
  ldrsh r1, [r0, r1]
  add r1, r3          ; get absolute x position in room
  cmp r1, r2
  blt @@counter_clockwise
  ; set varB to counter clockwise
  mov r1, 0x1
  strh r1, [r0, 0x32]
  b @@after_varB

  @@counter_clockwise:
  mov r1, 0x0
  strh r1, [r0, 0x32]

  @@after_varB:


  ldr r0, =0x08053d10 | 1   ; rectangle skull update
  str r0, [r4, 0x0]          ; set update function on entity (r4)
  ldr r1, =0x08053bfc | 1   ; rectangle skull create
  mov r0, r4                ; move entity to r0 for create function call
  bl call_func_in_r1

  ldr r0, =0x0800f33e | 1   ; After candle create function call
  bx r0
  .pool
  call_func_in_r1:
  bx r1
  .endarea

; Change Desctructible and Flame pointers to use
; the hook for creating (to set VarA/B),
; and use rectangle skull update function.

; change 0xE destructible pointers
.org 0x084f0f10    ; update
  .word 0x08053d10+1  ; rectangle skull update
.org 0x084f0e30   ; create
  .word candle_to_hazard_hook | 1


; change 0xF flame pointers to rectangle skull
.org 0x084f0f14    ; update
  .word 0x08053d10+1   ; rectangle skull update
.org 0x084f0e34   ; create
  .word candle_to_hazard_hook | 1

.close
