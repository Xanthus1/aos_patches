.gba
.relativeinclude on
.erroronwarning on

.open "ftc/rom.gba", 08000000h

.org 0x08019320
  ; Allows single jump dive kick (even with malphas)
  ; default:  bne 0x8019386
  nop

; replace kicker patch with one that doesn't work when swimming without Skula
.org 0x08017db6
  ; default (for kick without malphas): 
    ; cmp r1, 0x4
    ; b 0x08017db8
  ; default (without) : 
    ; cmp r1, 0x4
    ; beq 0x8017dbc

  ; ensures thats [playerEntity, 0x10] &800004 == 4  (has used double jump)
  ; I want to check that it's equal to 2 (player in midair), but exclude when the player is in water without malphas [playerEntity, 0x12] has 0x80 bit set.
  ; so change the data at 08017e18 from 04 00 80 00 to 02 00 C0 00.  r1 will have 800002 if player is in water with skula, or 400000 set without
  ; update: changed it to 02 00 00 01,  01 is set if in water (even at the top of water). Otherwise you can divekick for a super-fast
  ; fall from the top .

  ; you can still dive kick if you have skula: [PlayerEntity, 0x12] has 0x50 jumping in water with Skula, 0x80 bit isn't set.

  cmp r1, 0x2
  beq 0x8017dbc

; allow divekick on first jump (0x2 player state flag, instead of 0x4 player state flag)
; don't allow while in water (0x1000000 stateflag), or with ground below (0x8000000 stateflag)
; this prevents you from divekicking from the ground when you don't have slide
.org 0x8017e18
  ; default: .byte 04, 00, 80, 00
  .byte 0x02, 0x00, 0x00, 0x01 | 0x08

.close