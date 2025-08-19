# Aria of Sorrow Patches by Xanthus

These patches will expand or alter various aspects of Castlevania Aria of Sorrow gameplay.
Some were initially created as part of a 2023 patch release to help test new features
for Reprise.

## Links/Other projects
### Reprise:

- RHDN Hack page: https://www.romhacking.net/hacks/8425/
- Discord: https://discord.gg/PytA9rr6nz
- Direct patch download (zipped with readme): https://www.mediafire.com/file/zidr6w06ypy69sx/AoS_Reprise_v1_0.zip/file

### Metashop
Online patcher website that can be used for races- contains most of the patches on this page, as well as some that I couldn't imagine anybody wanting to use. Also contains a weapon shuffling utility
to randomize weapons
- https://metashop-rompatcher.xanthusapps.com/

# Full Patch List:

### Gameplay Patches
- [Alucard Backdash v1](https://www.mediafire.com/file/2t1m1ygfxr02j7y/AlucardBackdash-v1.ips/file)  - Chain backdashes together, and you can always cancel attacks with backdash.
- [LCancel v1](https://www.mediafire.com/file/fh8u7dt52hjfu9k/LCancel-v1.ips/file) - Pressing your ability button (default: L) will cancel any attack or red soul use, even in midair or while crouched.
- [Hungry Mode Patch v1.2](https://www.mediafire.com/file/z1t0f35z0hfpj46/AoS_Hungrymode_v1-2.ips/file) - Drains between 1 or 2 hp a second (1 before level 10, 2 after). Candles and destructibles have a ~1/12 chance to drop a Meat Strip.
    - v1.1 decreased Meat strip chance and made hp drain proportional.
    - v1.2 HP drain is based on level
- [Classicvania Movement v1](https://www.mediafire.com/file/sxe9d31g9ywtk0b/AoS_Classicvania-Movement-v1.ips/file) - NES Style movement with no air control (except when using souls like Flying Armor and Giant Bat). You can change directions with double jump or Hippogryph, and when you walk off ledges, you'll drop almost straight down.
- [Oops All Whips](https://www.mediafire.com/file/r60qxkla5rvefl5/OopsAllWhips.ips/file) - Replaces attack animation of all weapons to Whip Sword.
- [Panic Mode v1.2](https://www.mediafire.com/file/hul5xtwp5jg4fuw/AoS_PanicMode-v1-2.ips/file) - Panic mode! The lower your HP, the faster you move.
- [Hazard Mode v1.1](https://www.mediafire.com/file/1hvbku9ql75atjg/AoS_HazardMode-v1_1.ips/file) - All candles, flames, and destructibles are replaced with damaging skulls that move in a small rectangular path.
- [Slippery Mode v1.1](https://www.mediafire.com/file/twcebfcd5jgihwb/AoS_SlipperyMode-v1_1.ips/file) - Slide on the ground, as well as introducing some midair momentum. (v1.1 - ignore during rush souls, and being hit resets slippery momentum)
- [Attack Shuffle mode v1.1](https://www.mediafire.com/file/vdjyoyq23my0el7/AoS_AttackShuffleMode-v1_1.ips/file) - Weapon and Red soul are randomized after every time your XP changes (e.g. Killing enemies and bosses except for Graham and Julius). You are forced to use the weapon and red soul combo until your next XP Change. Red souls only cost 5 MP. (fixed Yellow soul bug with v1.1)
    - TODO: Disable randomizing red soul in Graham's room, otherwise you have to keep random'ing to get soul requirements.
- HyperMode patches - These make all enemies update faster, affecting movement and attack speeds. (1.0 is now compatible with other patches, 2.0 fixes a bug where some other 'mode' patches wouldn't work together)
    - [Hyper Mode v2.0 (137%)](https://www.mediafire.com/file/j7ct347xseaunm7/AoS_Hypermode_137-v2.ips/file) - 137% enemy/boss speed
    - [Hyper Mode v1.0 (150%)](https://www.mediafire.com/file/04ubhg71qmvrbe9/AoS_Hypermode_150-v1.ips/file) - 150% enemy/boss speed
    - [Hyper Mode v1.0 (175%)](https://www.mediafire.com/file/k1hosnq3dxa5g49/AoS_Hypermode_175-v1.ips/file) - 175% enemy/boss speed
    - [Hyper Mode v1.0 (200%)](https://www.mediafire.com/file/3ji0rvzp66ibk4g/AoS_Hypermode_200-v1.ips/file) - 200% enemy/boss speed
- [Windy Mode](https://www.mediafire.com/file/x3xd3gjot8a7fyf/AoS_WindyMode.ips/file) - Windy Modifier from Reprise always active, an alternating left/right wind slowly moves Soma.
- [Low Gravity Mode](https://www.mediafire.com/file/3dxg5keviikz4sf/AoS_LowGravityMode.ips/file) - Low Gravity Modifier from Reprise is always active
- [Bouncy Mode](https://www.mediafire.com/file/r6nku6ne2mpcvzy/AoS_BouncyMode.ips/file) - Bouncy Modifier from Reprise always active. Hold jump to keep bouncing.
- [High Knockback](https://www.mediafire.com/file/j08h5s3h0550vvc/HighKnockback.ips/file) - All attacks on Player have high knockback

### Balance / Fixes / Other Patches
- [Blue Soul Damage Scale Formula Improvement](https://www.mediafire.com/file/ugqpib4zbf1fihk/BlueSoulDmgImprovement-v1.ips/file) - Changes the blue soul damage formula so that weaker souls will scale better with INT. Stronger souls should remain similar.
- [Soul Containers Don't Seek](https://www.mediafire.com/file/8sfn99vbxq2o55g/SoulContainersDontSeek.ips/file) - Changes Soul containers so that the souls they drop stand still rather than seeking towards Soma. This is useful for the randomizer so that souls that are 'flight locked' require you to be able to fly to actually obtain them.
- [LCK Plus Better Drop Rates](https://www.mediafire.com/file/d40ycj608hdvt2c/LCKpatchPlusBetterDropRate.ips/file) - LCK Fix patch (from DevAnj, https://www.romhacking.net/hacks/5645/), along with increased drop rate formula.
- [Single Jump Divekick](https://www.mediafire.com/file/wmk8jc43hpwu3op/SingleJumpDiveKick.ips/file) - Allows single jump dive kick.
- [Save The Frames](https://www.mediafire.com/file/xaa7n7b818n5nli/SaveTheFrames.ips/file) - Levelup doesn't pause the game, new soul pickup text can be dismissed almost immediately.
- [Wizard Level Up](https://www.mediafire.com/file/5rbjz63sa0hx6ua/WizardLevelUp.ips/file) - 1 Less STR on Levelup, ~1.5 More INT on levelup, 3 more MP on levelup. INT Fix patch (Red souls use INT).
- [Double MP Regen](https://www.mediafire.com/file/g4tfikrupkegs53/DoubleMPRegen.ips/file) - Restore 2 mp instead of 1 mp when it regens.
- [Pogo Divekick](https://www.mediafire.com/file/a2q2luiiafp9shs/PogoDivekick.ips/file) - You bounce VERY high when you hit a divekick. This one is kinda just for fun and as a flight-logic skip
- [Holiday Pickups v1](https://www.mediafire.com/file/x8qo0o165tr8ue3/AoS_HolidayPickups-v1.ips/file) - All equipment pickups in rooms show present graphics (their original graphics are shown in the menus). Soul canisters are replaced by Xmas trees.
- [Holiday HUD v1.1](https://www.mediafire.com/file/xk6q3sqi5i39ngb/AoS_HolidayHUD-v1-1.ips/file) - Changes the HUD with lights for the HP and MP bars, and a Snowman.

