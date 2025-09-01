.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

; By Xanthus
; This will change the game so that Skula/Undine are additional Ability souls.
; Will replace yellow containers contianing Undine/Skula with Ability soul containers
; Also allows jumping underwater without Malphas.
; Note: If you want to re-use Undine/Skula as other new Abilities, you would need to disable this code

; Overwrites some French text for new text / functions.

.ifndef FuncCheckAbilitySoul
  .definelabel FuncCheckAbilitySoul, 0x08032ab8
.endif

.ifndef FuncSpawnSoulContainer
  .definelabel FuncSpawnSoulContainer, 0x08044980
.endif

.ifndef PlayerStateFlags
	.definelabel PlayerStateFlags, 0x20004e4+0x10
.endif

; Change Text ID offset for Ability soul names to new location (0x410 instead of 0x156)
.org 0x0804baca
  mov r1, 0x82
  lsl r1, 0x3

; Change Text ID offset for Ability soul descriptions to new location (0x418 instead of 0x257)
.org 0x0804bbf0
  .word 0x418

; Change number of ability souls to 8
.org 0x0804BA26
  .byte 0x8

; change text ID offset for Ability soul name on pickup (0x410 instead of 0x156)
.org 0x0800e790
  mov r2, 0x82
  lsl r2, 0x3

; Change Text ID offset for Ability soul descriptions on pickup to new location (0x418 instead of 0x257)
.org 0x0800e6e4
  .word 0x418

; UNDINE SECTION
; Change Code in Soma's movement to detect whether Undine as a grey soul is active in 02013396 (0x40 bitflag set)
; rather than checking player passive effects (02013260)
.org 0x08014c14
  ;default: .word 0x00013260
  ; gets added to 0x02000000 to point to the RAM address to load bitflag
  .word 0x02013396-0x2000000

; load only the Byte from 0x02013396 (active grey souls)
; this value in r0 will get ANDED with the value in the above address.
; change so that r0 will be 0x40 (undine ability soul)
.org 0x08014ace
  ; default:
    ; ldr r1, [r0, 0x0]
    ; mov r0, 0x80
    ; lsl r0, r0, 0x7
  ldrb r1, [r0, 0x0]
  mov r0, 0x40
  nop


; SKULA SECTION
; 1. Change Code in Soma's movement to detect whether Skula as a grey soul is active in 02013396 (0x40 bitflag set)
; rather than checking player passive effects (02013260)
.org 0x080151a4
  ;default: .word 0x00013260
  ; gets added to 0x02000000 to point to the RAM address to load bitflag
  .word 0x02013396-0x2000000

; load only the Byte from 0x02013396 (active grey souls)
; this value in r1 will get ANDED with the value in the above address.
; change so that r1 will be 0x80 (Skula ability soul)
.org 0x0801517e
  ; default:
    ; ldr r0, [r0, 0x0]
    ; mov r1, 0x80
    ; lsl r1, r1, 0x8
  ldrb r0, [r0, 0x0]
  mov r1, 0x80
  nop

; 2. Change Code in Soma's movement to detect whether Skula as a grey soul is active in 02013396 (0x40 bitflag set)
; rather than checking player passive effects (02013260)
.org 0x08015278
  ;default: .word 0x00013260
  ; gets added to 0x02000000 to point to the RAM address to load bitflag
  .word 0x02013396-0x2000000

; load only the Byte from 0x02013396 (active grey souls)
; this value in r1 will get ANDED with the value in the above address.
; change so that r1 will be 0x80 (Skula ability soul)
.org 0x08015250
  ; default:
    ; ldr r0, [r0, 0x0]
    ; mov r1, 0x80
    ; lsl r1, r1, 0x8
  ldrb r0, [r0, 0x0]
  mov r1, 0x80
  nop


; replace SpawnSoulContainer in Load_Entity call with new function call
.org 0x0800f3b2
  ; default: bl FuncSpawnSoulContainer
  bl func_spawn_soul_container_skula_undine_wrapper

// replace Soma's double jump check for malphas
// to also check for underwater with skula
.org 0x0801930e
  bl func_double_jump_with_skula

; Replaces French from 0x410-0x41F for Ability soul name / descriptions,
; and func_double_jump_with_skula function
; overwrite Data in French Text
.org 0x80FABD8
  @AbilityName1:
  // Each string starts with 0x1, 0x0, ends with 0x6, 0xA
  // 0x6 is Newline
  .definelabel NEWLINE, 0x6
  // 0xA is ending string / Term.
  // 0xB-0x12 : BUTTON [B A L R UP DOWN RIGHT LEFT]
  .definelabel BUTTON_B, 0xB
  .definelabel BUTTON_A, 0xC
  .definelabel BUTTON_L, 0xD
  .definelabel BUTTON_R, 0xE
  .definelabel BUTTON_UP, 0xF
  .definelabel BUTTON_DOWN, 0x10
  .definelabel BUTTON_RIGHT, 0x11
  .definelabel BUTTON_LEFT, 0x12
  .ascii 0x1, 0x0, "Grave Keeper", NEWLINE, 0xA
  @AbilityName2:
  .ascii 0x1, 0x0, "Skeleton Blaze", NEWLINE, 0xA
  @AbilityName3:
  .ascii 0x1, 0x0, "Malphas", NEWLINE, 0xA
  @AbilityName4:
  .ascii 0x1, 0x0, "Kicker Skeleton", NEWLINE, 0xA
  @AbilityName5:
  .ascii 0x1, 0x0, "Hippogryph", NEWLINE, 0xA
  @AbilityName6:
  .ascii 0x1, 0x0, "Galamoth", NEWLINE, 0xA
  @AbilityName7:
  .ascii 0x1, 0x0, "Undine", NEWLINE, 0xA
  @AbilityName8:
  .ascii 0x1, 0x0, "Skula", NEWLINE, 0xA
  @AbilityDescription1:
  .ascii 0x1, 0x0, "Backdash by pressing ",BUTTON_L,".", NEWLINE, 0xA  // {BUTTON L}
  @AbilityDescription2:
  .ascii 0x1, 0x0, "Slide by pressing ", BUTTON_DOWN, " + ", BUTTON_A,". ", NEWLINE, 0xA
  /* Reprise Description
  .ascii 0x1, 0x0, "Slide by pressing ", BUTTON_DOWN, " + ", BUTTON_A,". ", NEWLINE, \
    "~Faster and shorter.", NEWLINE, 0xA
  */
  @AbilityDescription3:
  .ascii 0x1, 0x0, "Jump again in mid-jump.", NEWLINE, 0xA
  @AbilityDescription4:
    .ascii 0x1, 0x0, "Kick during any jump by pressing ", NEWLINE, \
    BUTTON_DOWN, " + ", BUTTON_A, ".", NEWLINE, 0xA
  /* Reprise Description
  .ascii 0x1, 0x0, "Kick during any jump by pressing ", NEWLINE, \
    BUTTON_DOWN, " + ", BUTTON_A, ". Can bounce on candles.", NEWLINE, 0xA
  */
  @AbilityDescription5:
  .ascii 0x1, 0x0, "Perform a high jump by pressing", NEWLINE, \
    BUTTON_L, " in mid-jump.", NEWLINE, 0xA
  @AbilityDescription6:
  .ascii 0x1, 0x0, "Recognize places in which time", NEWLINE, \
    "has been stopped.", NEWLINE, 0xA
  /* Reprise Description
  .ascii 0x1, 0x0, "Resist time magic. ~Crouch+", BUTTON_L, NEWLINE, \
    "quickswitch last equipment/souls", NEWLINE, 0xA
  */
  @AbilityDescription7:
  .ascii 0x1, 0x0, "Walk on water surfaces.", NEWLINE, 0xA
  @AbilityDescription8:
  .ascii 0x1, 0x0, "Allows you to walk while", NEWLINE, \
    "underwater.", NEWLINE, 0xA

  .align
  func_double_jump_with_skula:
    push {lr}
    ; r0 - which ability soul to check
    bl FuncCheckAbilitySoul
    cmp r0, 0
    bne @@return

    // Soma doesn't have Malphas
    // check if Soma is underwater with skula
    ldr r0, =PlayerStateFlags+3   // the fourth byte has 0x01 set when underwater (even partially at the top)
    ldrb r0, [r0]
    mov r1, 0x01
    and r0, r1
    cmp r0, 0
    beq @@return

    // check skula ability soul equipped (#7)
    mov r0, 0x7
    bl FuncCheckAbilitySoul

    @@return:
    pop {r1}
    bx r1
    .pool
  func_spawn_soul_container_skula_undine_wrapper:
    push {lr}
    ; r0 - X ( 4 bytes)
    ; r1 - Y ( 4 bytes)
    ; r2 - Set to Entity's Subtype Minus 5 (so Red soul container would be 0)
    ; r3 - Set to VarB / Yellow Soul ID minus 1

    ; skula/Undine would be 7(yellow soul candle) - 5 = 2 for r2
    cmp r2, 0x2
    bne @@return_spawn_container

    ; Skula r3 would be 2-1=1 (VarB / Yellow Soul ID)
    cmp r3, 1
    bne @@check_undine_spawn

    ; Spawn Skula as ability Soul instead
    ; Subtype should be 8-5 = 3 for r2, and 8-1=7 for r3 (Abiilty soul ID)
    mov r2, 3
    mov r3, 7
    b @@return_spawn_container

    @@check_undine_spawn:
    ; undine r3 would be 1-1=0 (VarB / Yellow Soul ID)
    cmp r3, 0
    bne @@return_spawn_container

    ; replace undine with ability soul
    ; Subtype should be 8-5 = 3 for r2, and 7-1=6 for r3 (Abiilty soul ID)
    mov r2, 3
    mov r3, 6

    @@return_spawn_container:
    bl FuncSpawnSoulContainer
    pop {r1}
    bx r1

.definelabel TextPointerList, 0x08506B38    ; List of pointers to each text entry.

.org TextPointerList+(0x4)*(0x410)
  .word @AbilityName1, \
    @AbilityName2, \
    @AbilityName3, \
    @AbilityName4, \
    @AbilityName5, \
    @AbilityName6, \
    @AbilityName7, \
    @AbilityName8, \
    @AbilityDescription1, \
    @AbilityDescription2, \
    @AbilityDescription3, \
    @AbilityDescription4, \
    @AbilityDescription5, \
    @AbilityDescription6, \
    @AbilityDescription7, \
    @AbilityDescription8



.close