;===============================================================================
; binaries.s - Binary data file loader and data table symbols
;===============================================================================
; Loads all binary data files into their respective segments.
; Memory positions are defined in the linker config (c64-prg.cfg).
;
; This file also defines symbols (equates) for addresses within the memory
; regions covered by the binary files. Many of these addresses are used as
; RAM variables during gameplay, but fall within the initially-loaded binary
; data regions.
;
; To relocate a binary, change its segment offset in c64-prg.cfg.
;===============================================================================

;-------------------------------------------------------------------------------
; Character set ($4000-$445F, 1120 bytes)
; NOTE: Region $4000-$47FF is used for charset + work buffers during gameplay
;-------------------------------------------------------------------------------
        .segment "CHARSET"
        .incbin "../data/charset.bin"

; Symbols within CHARSET region ($4000-$445F)
; Many of these are work buffers that overlay the charset area
D_4000      = $4000     ; Character set base address
D_4050      = $4050     ; Entity/item data array
D_4080      = $4080     ; Memory region cleared during bonus stage
D_4087      = $4087     ; Graphics source data 1
D_408F      = $408F     ; Graphics source data 2
D_4097      = $4097     ; Graphics source data 3
D_409F      = $409F     ; Graphics source data 4
D_40A8      = $40A8     ; Level header data (8 bytes)
D_40B0      = $40B0     ; Level sidebar chars 1
D_40B8      = $40B8     ; Level sidebar chars 2
D_40C0      = $40C0     ; Level sidebar chars 3
D_40C8      = $40C8     ; Level sidebar chars 4
D_40D0      = $40D0     ; Level number display buffer (6 bytes)
D_40D6      = $40D6     ; Level display data
D_40D7      = $40D7     ; Level display data
D_40D8      = $40D8     ; Level display data (ones digit)
D_40DE      = $40DE     ; Level display data
D_40DF      = $40DF     ; Level display data
D_4100      = $4100     ; Character set page 2
D_4200      = $4200     ; Graphics work buffer
D_4210      = $4210     ; Item work buffer 1
D_4230      = $4230     ; Item work buffer 2
D_42C6      = $42C6     ; Data/flag location
D_4300      = $4300     ; Enemy template data table 1 (RAM copy)
D_43B0      = $43B0     ; Data table 1
D_43B8      = $43B8     ; Data table 2
D_43C0      = $43C0     ; Data table 3
D_4400      = $4400     ; Enemy template data table 2 (RAM copy)
D_4B00      = $4B00     ; Enemy template data table (destination)

;-------------------------------------------------------------------------------
; Early initialization code and title screen data ($4460-$47FF, 928 bytes)
; See game-init-early.s
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Graphics data ($4B00-$57FF, 3328 bytes)
; This region contains screen RAM buffers and graphics data
;-------------------------------------------------------------------------------
        .segment "GRAPHICS"
        .incbin "../data/graphics-data.bin"

; Symbols within GRAPHICS region ($4B00-$57FF)
; Screen RAM pages and work buffers
D_4CF3      = $4CF3     ; External routine (called from sound engine)
D_4E00      = $4E00     ; Platform screen address low
D_4E48      = $4E48     ; Graphics output buffer (72 bytes)
D_4F00      = $4F00     ; Platform screen address high
D_4FF8      = $4FF8     ; Item table 2
D_5000      = $5000     ; Screen RAM page 0
D_5001      = $5001     ; Screen pointer storage
D_501E      = $501E     ; Level position data
D_501F      = $501F     ; Level position data
D_5050      = $5050     ; Level data value
D_50AF      = $50AF     ; Screen memory area for animation
D_5053      = $5053     ; Screen memory area 1
D_5100      = $5100     ; Screen RAM page 1
D_519C      = $519C     ; Sprite index table 1 (9 bytes)
D_51D3      = $51D3     ; Screen text output (self-modifying)
D_51EC      = $51EC     ; Sprite index table 2 (9 bytes)
D_5200      = $5200     ; Screen RAM page 2
D_525B      = $525B     ; Screen memory area 2
D_52AA      = $52AA     ; Screen line pointer array 1
D_52D2      = $52D2     ; Screen line pointer array 2
D_52FA      = $52FA     ; Screen line pointer array 3
D_5300      = $5300     ; Screen RAM page 3
D_5322      = $5322     ; Screen line pointer array 4
D_534A      = $534A     ; Screen line pointer array 5
D_5398      = $5398     ; Source tile table
D_53C0      = $53C0     ; Screen buffer destination
D_53C1      = $53C1     ; Screen buffer destination
D_53DE      = $53DE     ; Screen buffer alternate
D_53DF      = $53DF     ; Screen buffer alternate
D_53E4      = $53E4     ; Data/routine location
D_53F8      = $53F8     ; Screen 1 sprite pointers
D_53FA      = $53FA     ; Screen 1 sprite pointers +2
D_53FC      = $53FC     ; Screen 1 sprite pointers +4
D_5400      = $5400     ; Color RAM buffer page 0
D_5401      = $5401     ; Color RAM buffer +1
D_5500      = $5500     ; Color RAM buffer page 1
D_559C      = $559C     ; Screen 2 sprite index table 1 (9 bytes)
D_55D3      = $55D3     ; Screen text output 2 (self-modifying)
D_55EC      = $55EC     ; Screen 2 sprite index table 2 (9 bytes)
D_5600      = $5600     ; Color RAM buffer page 2
D_5700      = $5700     ; Color RAM buffer page 3
D_57D4      = $57D4     ; Game state storage / animation data
D_57E4      = $57E4     ; Data/routine location
D_57F8      = $57F8     ; Screen 2 sprite pointers
D_57FA      = $57FA     ; Screen 2 sprite pointers +2
D_57FC      = $57FC     ; Screen 2 sprite pointers +4

;-------------------------------------------------------------------------------
; Sprite data 1 ($5800-$5FFF, 2048 bytes)
; This region is used for sprite data and game state flags
;-------------------------------------------------------------------------------
        .segment "SPRITES1"
        .incbin "../data/sprites1.bin"

; Symbols within SPRITES1 region ($5800-$5FFF)
; Game state flags, timers, and counters
D_5800      = $5800     ; Sprite data buffer
D_58BF      = $58BF     ; Global level flag
D_58FF      = $58FF     ; Special timer
D_593F      = $593F     ; Special rendering mode flag
D_597F      = $597F     ; Frame counter
D_59BF      = $59BF     ; Game state flag
D_59FF      = $59FF     ; Game state flag
D_5A7F      = $5A7F     ; Game mode flag
D_5ABF      = $5ABF     ; Countdown timer 2
D_5AFF      = $5AFF     ; Sprites active flag
D_5B3F      = $5B3F     ; Level progression counter
D_5B7F      = $5B7F     ; Active sprite mask
D_5BBF      = $5BBF     ; Special item countdown
D_5BFF      = $5BFF     ; Enemy type seed
D_5C3F      = $5C3F     ; Game state flag

;-------------------------------------------------------------------------------
; Level data part 1 ($6000-$7304, 4869 bytes)
;-------------------------------------------------------------------------------
        .segment "LEVELS"
        .incbin "../data/level-data-part1.bin"

; Symbols within level-data-part1.bin
; NOTE: D_6085 is NOT executable code - it's used as a byte-encoding trick
; where "jsr D_6085" emits bytes $20 $85 $60 to create other instructions
D_6085      = $6085     ; Byte pattern for self-modifying code trick

;-------------------------------------------------------------------------------
; Music command handlers inserted here ($7305-$743F, 315 bytes)
; See music-command-handlers.s
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Sprite data 2 ($8000-$9FFF, 8192 bytes)
; This large region contains sprite graphics and is heavily used as RAM
; for entity data, collision flags, and animation arrays during gameplay
;-------------------------------------------------------------------------------
        .segment "SPRITES2"
        .incbin "../data/sprites2.bin"

; Symbols within SPRITES2 region ($8000-$9FFF)
; Entity data arrays, collision flags, animation data
; NOTE: Much of this region is overwritten and used as RAM during gameplay

; --- Sprite mask tables ($8000-$82FF) ---
D_8000      = $8000     ; Sprite mask background bits 1
D_8010      = $8010     ; Sprite mask background bits 2
D_8020      = $8020     ; Sprite mask background bits 3
D_8240      = $8240     ; Sprite mask table 1
D_8250      = $8250     ; Sprite mask table 2
D_8260      = $8260     ; Sprite mask table 3

; --- Entity data arrays ($8488-$85FF) ---
D_8488      = $8488     ; Entity data array 3
D_84B0      = $84B0     ; Entity data array 2
D_84D8      = $84D8     ; Entity data array 1
D_8500      = $8500     ; Entity data array source
D_8501      = $8501     ; Screen wrap permission table (bottom)
D_850A      = $850A     ; Spawn point 0 availability (top left)
D_8514      = $8514     ; Spawn point 1 availability (top right)
D_8520      = $8520     ; Player mapping table
D_8522      = $8522     ; Item index storage
D_8548      = $8548     ; Sprite colors
D_854A      = $854A     ; Item timer array
D_8570      = $8570     ; Data table
D_8572      = $8572     ; Game state flag
D_8598      = $8598     ; Sprite base pointers
D_859A      = $859A     ; Sprite character data
D_859B      = $859B     ; Sprite Y position array
D_85C0      = $85C0     ; Fall counter
D_85C2      = $85C2     ; Bubble collision flags
D_85E8      = $85E8     ; Joystick port A data
D_85E9      = $85E9     ; Joystick port B data
D_85EA      = $85EA     ; Entity direction/movement data

; --- Player/entity state arrays ($8610-$87FF) ---
D_8610      = $8610     ; Player data array
D_8638      = $8638     ; Player animation timer
D_8639      = $8639     ; Player animation timer +1
D_863A      = $863A     ; Bubble deactivation flags
D_8660      = $8660     ; Direction change timer
D_8662      = $8662     ; Entity animation array 1
D_8688      = $8688     ; Player state flags
D_868A      = $868A     ; Entity animation array 2
D_86B0      = $86B0     ; Current direction index
D_86D8      = $86D8     ; Player collision data
D_8700      = $8700     ; Player movement data
D_8702      = $8702     ; Special bubble data
D_8728      = $8728     ; Player sprite data
D_8729      = $8729     ; Player sprite offset
D_872A      = $872A     ; Special sprite flags
D_8750      = $8750     ; Player target direction
D_8752      = $8752     ; Entity sprite pointer array
D_8778      = $8778     ; Animation frame mask array
D_877A      = $877A     ; Entity sprite pointer array -1
D_87A0      = $87A0     ; Collision flags array
D_87A2      = $87A2     ; Collision flags array (alternate)
D_87C8      = $87C8     ; Collision flags array
D_87CA      = $87CA     ; Collision flags array (alternate)
D_87F0      = $87F0     ; Collision flags array
D_87F2      = $87F2     ; Collision flags array (alternate)

; --- Animation/item arrays ($8818-$89FF) ---
D_8818      = $8818     ; Animation frame data
D_881A      = $881A     ; Item animation array
D_8840      = $8840     ; Saved item types array
D_8842      = $8842     ; Saved item types
D_8868      = $8868     ; Player movement flags
D_886A      = $886A     ; Item movement array
D_8890      = $8890     ; Target Y positions
D_8892      = $8892     ; Item counter array
D_88C0      = $88C0     ; Entity data array base
D_88C1      = $88C1     ; Screen wrap permission table (top)
D_88C9      = $88C9     ; Credits array 1 (18 bytes)
D_88CA      = $88CA     ; Spawn point 2 availability (bottom left)
D_88D4      = $88D4     ; Spawn point 3 availability (bottom right)
D_88E8      = $88E8     ; Entity data array 1
D_88F1      = $88F1     ; Credits array 2 (18 bytes)
D_8910      = $8910     ; Entity data array 2
D_8919      = $8919     ; Credits array 3 (18 bytes)
D_8938      = $8938     ; Entity data array 3
D_8941      = $8941     ; Credits array 4 (18 bytes)

; --- Level/screen buffers ($8B00-$8EFF) ---
D_8B00      = $8B00     ; Level decompression buffer
D_8B02      = $8B02     ; Level decompression buffer +2
D_8B03      = $8B03     ; Level decompression buffer +3
D_8B04      = $8B04     ; Level decompression buffer +4
D_8B63      = $8B63     ; Level decompression buffer +$63
D_8C00      = $8C00     ; Level layout data
D_8C9C      = $8C9C     ; Baron sprite data source 1
D_8CA9      = $8CA9     ; Item setup routine
D_8CEC      = $8CEC     ; Baron sprite data source 2
D_8D00      = $8D00     ; Screen buffer page 2
D_8E00      = $8E00     ; Screen buffer page 3

; --- Enemy template ROM tables ($9AE0-$9FFF) ---
D_9AE0      = $9AE0     ; Enemy template ROM table 1
D_9BE0      = $9BE0     ; Enemy template ROM table 2
D_9CE0      = $9CE0     ; Enemy template ROM table 3
D_9DE0      = $9DE0     ; Enemy template ROM table 4
D_9EE0      = $9EE0     ; Enemy template ROM table 5

;-------------------------------------------------------------------------------
; Sprite data 3 ($A000-$A427, 1064 bytes)
;-------------------------------------------------------------------------------
        .segment "SPRITES3"
        .incbin "../data/sprites3.bin"

; Symbols within SPRITES3 region ($A000-$A427)
D_A420      = $A420     ; Additional data table (8 bytes)

;-------------------------------------------------------------------------------
; Sprite patterns ($A47E-$A59F, 290 bytes)
;-------------------------------------------------------------------------------
        .segment "SPRPAT"
        .incbin "../data/sprite-patterns.bin"

; No symbols defined within SPRPAT region ($A47E-$A59F)

;-------------------------------------------------------------------------------
; Game tables ($A632-$B0EF, 2750 bytes)
;-------------------------------------------------------------------------------
        .segment "GAMETABLES"
        .incbin "../data/game-tables.bin"

; Symbols within game-tables.bin ($A632-$B0EF)
; These are read-only lookup tables used throughout the game

; --- Sprite/Graphics Tables ($A632-$A6FF) ---
D_A632      = $A632     ; Sprite Y position table
D_A634      = $A634     ; Pointer table (high bytes)
D_A637      = $A637     ; Pointer table (low bytes)
D_A63C      = $A63C     ; Temp storage (Y register)
D_A63D      = $A63D     ; Temp storage (X register)
D_A660      = $A660     ; Level data source table

; --- Position/Spawn Tables ($A710-$A7FF) ---
D_A710      = $A710     ; Position table 1
D_A722      = $A722     ; Position table 2
D_A735      = $A735     ; Respawn X positions
D_A737      = $A737     ; Death animation frames
D_A74B      = $A74B     ; Item X positions (11 bytes)
D_A74C      = $A74C     ; Item X positions (offset by 1)
D_A754      = $A754     ; Item position data
D_A755      = $A755     ; Item movement direction
D_A756      = $A756     ; Item Y positions (11 bytes)
D_A757      = $A757     ; Item Y positions (offset by 1)
D_A75F      = $A75F     ; Item data
D_A760      = $A760     ; Item data
D_A761      = $A761     ; Player sprite column positions (5 bytes)
D_A766      = $A766     ; Player sprite row positions (5 bytes)
D_A76B      = $A76B     ; Player sprite data indices (5 bytes)
D_A770      = $A770     ; Player sprite active flags (5 bytes)
D_A775      = $A775     ; Animation timer array
D_A777      = $A777     ; Entity spawn X position table
D_A779      = $A779     ; Entity spawn Y position table
D_A77B      = $A77B     ; Entity attribute table
D_A77D      = $A77D     ; Entity attribute table
D_A77F      = $A77F     ; Entity attribute table
D_A781      = $A781     ; Entity attribute table
D_A790      = $A790     ; Enemy death bonus item indices (6 bytes at $A791)
D_A79A      = $A79A     ; Item score value table
D_A7B0      = $A7B0     ; Super bonus X positions (normal)
D_A7B6      = $A7B6     ; Super bonus Y positions (normal)
D_A7BC      = $A7BC     ; Super bonus X positions (expanded)
D_A7C2      = $A7C2     ; Super bonus Y positions (expanded)
D_A7E2      = $A7E2     ; Sprite data storage
D_A7EE      = $A7EE     ; Sprite data pointer
D_A7F0      = $A7F0     ; Bonus display character 1
D_A7F1      = $A7F1     ; Bonus display character 2
D_A7F7      = $A7F7     ; Player display offset table

; --- Level/Spawn Data Tables ($A804-$A8FF) ---
D_A804      = $A804     ; Player bonus data location
D_A80D      = $A80D     ; "EXTEND" character table
D_A813      = $A813     ; Spawn data table
D_A814      = $A814     ; Spawn data table + 1
D_A815      = $A815     ; Level data pointer table (low bytes)
D_A81A      = $A81A     ; Level data pointer table (high bytes)
D_A81F      = $A81F     ; Large bonus sprite colors (5 bytes: cupcake, melon, yellow/blue/purple diamond)
D_A824      = $A824     ; Entity state table
D_A825      = $A825     ; Player 2 invincibility timer
D_A826      = $A826     ; Sprite data table
D_A82A      = $A82A     ; Sprite data table (offset +4)
D_A82E      = $A82E     ; Item offsets table
D_A83C      = $A83C     ; Digit graphics pointer table (low bytes)
D_A848      = $A848     ; Digit graphics pointer table (high bytes)
D_A854      = $A854     ; Level data source
D_A877      = $A877     ; Screen data source table
D_A892      = $A892     ; Points item char block indices (47 bytes)
D_A8C1      = $A8C1     ; Powerup item char block indices (35 bytes)
D_A8E4      = $A8E4     ; Points item color indices (47 bytes, lower nibble only)

; --- Score/Item Tables ($A913-$A9FF) ---
D_A913      = $A913     ; Powerup item color indices (35 bytes, lower nibble only)
D_A936      = $A936     ; Enemy score value table
D_A965      = $A965     ; Special item score value table
D_A988      = $A988     ; Enemy state temporary storage
D_A9A8      = $A9A8     ; Graphics composite dest 1 (9 bytes)
D_A9AE      = $A9AE     ; Level tens digit storage
D_A9AF      = $A9AF     ; Level ones digit storage
D_A9B0      = $A9B0     ; Graphics mode flag
D_A9B1      = $A9B1     ; Hurry-up timer
D_A9B2      = $A9B2     ; Enemy state flags (18 bytes, one per enemy slot)
D_A9C4      = $A9C4     ; Enemy X sub-position (18 bytes)
D_A9C6      = $A9C6     ; Projectile state array 1
D_A9D6      = $A9D6     ; Enemy direction flags (18 bytes)
D_A9D8      = $A9D8     ; Projectile state array 2
D_A9E8      = $A9E8     ; Enemy AI routine indices (18 bytes)
D_A9FA      = $A9FA     ; Enemy special flags (18 bytes)
D_A9FC      = $A9FC     ; Projectile state array 3

; --- Enemy/Entity Tables ($AA0C-$ABFF) ---
D_AA0C      = $AA0C     ; Enemy X positions (18 bytes)
D_AA0E      = $AA0E     ; Enemy X positions (offset by 2)
D_AA1E      = $AA1E     ; Enemy Y positions (18 bytes)
D_AA20      = $AA20     ; Enemy Y positions (offset by 2)
D_AA30      = $AA30     ; Bubble type storage
D_AA42      = $AA42     ; Saved enemy type during capture
D_AA44      = $AA44     ; Enemy data
D_AA54      = $AA54     ; Sprite graphics pointer table (low)
D_AA8E      = $AA8E     ; Sprite graphics pointer table (high)
D_AAC8      = $AAC8     ; Sprite graphics pointer table 2 (low)
D_AB02      = $AB02     ; Sprite graphics pointer table 2 (high)
D_AB41      = $AB41     ; Entity sprite page table
D_AB49      = $AB49     ; Entity sprite page high table
D_AB51      = $AB51     ; Player score offset table
D_AB52      = $AB52     ; Score value table for pickups
D_AB53      = $AB53     ; Player sprite mask table
D_AB55      = $AB55     ; Sprite enable masks
D_AB5B      = $AB5B     ; Sprite data table
D_AB5F      = $AB5F     ; Sprite routine value table
D_AB61      = $AB61     ; Entity animation frame table
D_AB69      = $AB69     ; Entity sprite data table
D_AB71      = $AB71     ; Entity animation offset table
D_AB79      = $AB79     ; Entity sprite index table
D_AB81      = $AB81     ; Score value table
D_AB89      = $AB89     ; Animation offset table
D_ABA5      = $ABA5     ; Loader completion check

; --- Pathfinding/Screen Tables ($AC01-$ACFF) ---
D_AC01      = $AC01     ; Flying enemy pathfinding table (low)
D_AC02      = $AC02     ; Flying enemy pathfinding table (high)
D_AC03      = $AC03     ; Screen position table (low bytes)
D_AC04      = $AC04     ; Screen position table (high bytes)
D_AC09      = $AC09     ; Data pointer table low
D_AC0A      = $AC0A     ; Data pointer table high
D_ACB6      = $ACB6     ; Enemy animation direction table
D_ACBD      = $ACBD     ; Sprite character data table
D_ACC4      = $ACC4     ; Direction table
D_ACCB      = $ACCB     ; Direction storage
D_ACCD      = $ACCD     ; Fall speed table
D_ACDD      = $ACDD     ; Movement table
D_ACED      = $ACED     ; Jump table

; --- Screen Layout Tables ($AD15-$AEFF) ---
D_AD15      = $AD15     ; Graphics composite dest 2 (9 bytes)
D_AD1E      = $AD1E     ; Screen row pointer table (low bytes)
D_AD1F      = $AD1F     ; Screen row pointer table (low bytes, offset by 1)
D_AD20      = $AD20     ; Screen row pointer (offset by 2)
D_AD22      = $AD22     ; Screen row pointer table (low bytes, offset by 4)
D_AD3D      = $AD3D     ; Screen row pointer table (high bytes)
D_AD3E      = $AD3E     ; Screen row pointer table (high bytes, offset by 1)
D_AD3F      = $AD3F     ; Screen row pointer (offset by 2)
D_AD41      = $AD41     ; Screen column data
D_AD5C      = $AD5C     ; Screen column source
D_ADB1      = $ADB1     ; Character mask table 1
D_ADF9      = $ADF9     ; Character mask table 2
D_AE41      = $AE41     ; Sprite/charset source data

;-------------------------------------------------------------------------------
; Game data ($B0F0-$DFFF, 12048 bytes)
; NOTE: $D800-$DBFF is hardware Color RAM, not part of this binary
;-------------------------------------------------------------------------------
        .segment "GAMEDATA"
        .incbin "../data/game-data.bin"

; Symbols within game-data.bin ($B0F0-$DFFF)
; These include level data, item positions, and various lookup tables
; NOTE: Color RAM addresses ($D800-$DBFF) are hardware, not in this binary

; --- Item Spawn Position Tables ($B569-$B6FF) ---
D_B569      = $B569     ; Item spawn positions A (100 bytes) - 5-bit packed coords
D_B5CD      = $B5CD     ; Item spawn positions B (100 bytes) - 5-bit packed coords
D_B631      = $B631     ; Item spawn positions C (upper nibble) + bubble spawns (lower nibble, 100 bytes)

; --- Handler/Callback Routines ($C085-$C6FF) ---
D_C085      = $C085     ; Far routine
D_C2B5      = $C2B5     ; Handler routine
D_C58E      = $C58E     ; Level hole/bubble current metadata (100 bytes)
D_C6D0      = $C6D0     ; Loader callback routine

; --- Animation/Update Routines ($DE85) ---
D_DE85      = $DE85     ; Animation update routine

