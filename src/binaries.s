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
; Character set ($4000-$445F, 1120 bytes = 140 characters)
; Source: data/charset.tga (140 hires 8x8 characters)
;
; NOTE: Region $4000-$47FF is used for charset + work buffers during gameplay.
; The first 1024 bytes ($4000-$43FF) are backed up to $4800-$4BFF at init,
; allowing this region to be reused as work RAM while preserving the charset.
; Work buffer equates (D_4050, D_4080, etc.) are defined in master.s.
;-------------------------------------------------------------------------------
        .segment "CHARSET"
charset:
        .incbin "../build/charset.bin"

;-------------------------------------------------------------------------------
; Early initialization code and title screen data ($4460-$47FF, 928 bytes)
; See game-init-early.s
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Work RAM initialization ($4B00-$57FF, 3328 bytes)
;
; This region is used as work RAM during gameplay for screen buffers,
; sprite pointer tables, and various game state. The binary file provides
; initial values that are loaded at startup.
;
; Memory layout:
;   $4B00-$4BFF: Overwritten by charset backup during init (from $4300-$43FF)
;                Exception: $4BF8-$4BFF are sprite pointers (set by game)
;   $4C00-$4FFF: Lookup tables and work buffers
;   $5000-$53FF: Screen RAM pages 0-3 (double-buffered)
;   $5400-$57FF: Color RAM buffer pages 0-3
;
; VIC configuration during gameplay:
;   Bank 1 ($4000-$7FFF), Screen at $4800, Charset at $4000
;   Sprite pointers at $4BF8 (screen + $3F8)
;-------------------------------------------------------------------------------
        .segment "GRAPHICS"
work_ram_init:
        .incbin "../data/work-ram-init.bin"

; NOTE: Symbols for work RAM region ($4B00-$57FF) are defined in master.s
; since they are RAM addresses used during gameplay, not file data offsets.

;-------------------------------------------------------------------------------
; Game sprites ($5800-$703F, 6208 bytes = 97 sprites)
; Built from data/sprites-game.tga via convert-tga.py.
;
; Memory layout:
;   $5800-$5FFF: 32 sprites (pointers $160-$17F) - players, bubbles, EXTEND
;   $6000-$703F: 65 sprites (pointers $180-$1C0) - enemies, items, animations
;
; Note: Byte 63 of each sprite (the padding byte) is used as game state
; variables during gameplay. The initial values are set in the TGA file.
;-------------------------------------------------------------------------------
        .segment "SPRITES_GAME"
sprites_game:
        .incbin "../build/sprites-game.bin"               ; 97 sprites (6208 bytes)

;-------------------------------------------------------------------------------
; Music sequence data ($7040-$7304, 709 bytes)
;-------------------------------------------------------------------------------
        .segment "MUSICSEQ"
music_sequence_7040:
        .incbin "../data/music-sequence.bin"

; Symbols within sprite region ($5800-$5FFF)
; Game state flags stored in sprite padding bytes (byte 63 of each sprite)
; These addresses are used as RAM variables during gameplay.
D_5800      = sprites_game              ; Sprite data buffer base
D_58BF      = sprites_game + 2*64 + 63  ; Global level flag (sprite 2, byte 63)
D_58FF      = sprites_game + 3*64 + 63  ; Special timer (sprite 3, byte 63)
D_593F      = sprites_game + 4*64 + 63  ; Special rendering mode flag (sprite 4, byte 63)
D_597F      = sprites_game + 5*64 + 63  ; Frame counter (sprite 5, byte 63)
D_59BF      = sprites_game + 6*64 + 63  ; Game state flag (sprite 6, byte 63)
D_59FF      = sprites_game + 7*64 + 63  ; Game state flag (sprite 7, byte 63)
D_5A7F      = sprites_game + 9*64 + 63  ; Game mode flag (sprite 9, byte 63)
D_5ABF      = sprites_game + 10*64 + 63 ; Countdown timer 2 (sprite 10, byte 63)
D_5AFF      = sprites_game + 11*64 + 63 ; Sprites active flag (sprite 11, byte 63)
D_5B3F      = sprites_game + 12*64 + 63 ; Level progression counter (sprite 12, byte 63)
D_5B7F      = sprites_game + 13*64 + 63 ; Active sprite mask (sprite 13, byte 63)
D_5BBF      = sprites_game + 14*64 + 63 ; Special item countdown (sprite 14, byte 63)
D_5BFF      = sprites_game + 15*64 + 63 ; Enemy type seed (sprite 15, byte 63)
D_5C3F      = sprites_game + 16*64 + 63 ; Game state flag (sprite 16, byte 63)

;-------------------------------------------------------------------------------
; Music command handlers inserted here ($7305-$743F, 315 bytes)
; See music-command-handlers.s
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Level data part 2 - Sprite block 1 ($7440-$7ABF, 1664 bytes)
; Bubble dragon in bubble + Grumple Gromit (left & bubble) sprites.
; 26 multicolor sprites = 1664 bytes
; Source: data/bubble-dragon-in-bubble.tga (8 sprites, 512 bytes)
;         data/grumple-gromit.tga left+bubble (18 sprites, 1152 bytes)
;-------------------------------------------------------------------------------
        .segment "LEVELS2_SPR1"
sprite_data_7440:
        .incbin "../build/bubble-dragon-in-bubble.bin"
        .incbin "../build/grumple-gromit.bin", 0, 1152

;-------------------------------------------------------------------------------
; Level data part 2 - Code block 1 ($7AC0-$7C3F)
; See level-data-part2.s for disassembled routines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Level data part 2 - Sprite block 2 ($7C40-$7E7F, 576 bytes)
; Grumple Gromit facing right sprites.
; 9 multicolor sprites = 576 bytes
; Source: data/grumple-gromit.tga right (9 sprites at offset 1152)
;-------------------------------------------------------------------------------
        .segment "LEVELS2_SPR2"
sprite_data_7C40:
        .incbin "../build/grumple-gromit.bin", 1152, 576

;-------------------------------------------------------------------------------
; Level data part 2 - Code block 2 ($7E80-$7FFF)
; See level-data-part2.s for disassembled routines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Sprite data 2 & 3 ($8000-$A427, 9256 bytes)
; This large region contains sprite graphics and is heavily used as RAM
; for entity data, collision flags, and animation arrays during gameplay
;
; Layout:
;   - $8000-$847F: Bubble masks (1152 bytes, from bubble-masks.tga)
;   - $8480-$8EFF: Entity/table data (2688 bytes, used as RAM during gameplay)
;   - $8F00-$A31F: Software sprites (5152 bytes, from software-sprites.tga)
;   - $A340-$A427: Sprite ROM data (232 bytes, from sprites-rom.tga)
;-------------------------------------------------------------------------------

; Bubble mask tables ($8000-$847F, 1152 bytes)
; 72 x 16-byte mask patterns for bubble rendering
        .segment "BUBBLE_MASKS"
bubble_masks:
        .incbin "../build/bubble-masks.bin"

; Entity/table data ($8480-$8EFF, 2688 bytes)
; Used as RAM for entity state during gameplay
        .segment "SPRITES2_TABLES"
        .incbin "../data/sprites2-tables.bin"

; Software sprites ($8F00-$A31F, 5152 bytes)
; 48-byte column-major multicolor sprites for software rendering
        .segment "SOFTWARE_SPRITES"
software_sprites_base:
        .incbin "../build/software-sprites.bin"             ; 5152 bytes

; Legacy symbol for code that references the old SPRITES_ROM location
; This points to offset 3040 within SOFTWARE_SPRITES ($8F00 + $BE0 = $9AE0)
sprites_rom = $9AE0

; Symbols for bubble mask offsets ($8000-$8210)
; These are used by sprite_gfx_ptr table entries 0-11
; Each entry is 48 bytes ($30) apart, same spacing as software sprites
bubble_mask_0x000 = bubble_masks + $000         ; $8000 - Entry 0
bubble_mask_0x030 = bubble_masks + $030         ; $8030 - Entry 1
bubble_mask_0x060 = bubble_masks + $060         ; $8060 - Entry 2
bubble_mask_0x090 = bubble_masks + $090         ; $8090 - Entry 3
bubble_mask_0x0c0 = bubble_masks + $0C0         ; $80C0 - Entry 4
bubble_mask_0x0f0 = bubble_masks + $0F0         ; $80F0 - Entry 5
bubble_mask_0x120 = bubble_masks + $120         ; $8120 - Entry 6
bubble_mask_0x150 = bubble_masks + $150         ; $8150 - Entry 7
bubble_mask_0x180 = bubble_masks + $180         ; $8180 - Entry 8
bubble_mask_0x1b0 = bubble_masks + $1B0         ; $81B0 - Entry 9
bubble_mask_0x1e0 = bubble_masks + $1E0         ; $81E0 - Entry 10
bubble_mask_0x210 = bubble_masks + $210         ; $8210 - Entry 11

; Symbols for sprite graphics within software sprites region
; These are used by sprite_gfx_ptr table entries 12-57
; Named by offset within software-sprites.tga for easy cross-reference
soft_spr_0x000 = software_sprites_base + $000   ; $8F00 - Entries 48-51
soft_spr_0x180 = software_sprites_base + $180   ; $9080 - Entries 12-14
soft_spr_0x240 = software_sprites_base + $240   ; $9140 - Entries 15-19
soft_spr_0x300 = software_sprites_base + $300   ; $9200 - Entries 20-23 (lightning bubble)
soft_spr_0x400 = software_sprites_base + $400   ; $9300 - Entries 52-55
soft_spr_0x580 = software_sprites_base + $580   ; $9480 - Entries 24-26
soft_spr_0x610 = software_sprites_base + $610   ; $9510 - Entries 27-31
soft_spr_0x700 = software_sprites_base + $700   ; $9600 - Entries 32-37
soft_spr_0x820 = software_sprites_base + $820   ; $9720 - Entries 38-42
soft_spr_0x910 = software_sprites_base + $910   ; $9810 - Entry 43
soft_spr_0x940 = software_sprites_base + $940   ; $9840 - Entries 56-57

; Bonus cake sprites + unused data ($A320-$A427, 264 bytes)
; Layout:
;   $A320-$A41F: 256 bytes - 4 cake sprites from bonus-sprites.tga
;   $A420-$A427: 8 bytes - bonus stage 1 pattern data (patch B)
        .segment "BONUS_CAKE"
bonus_cake_sprites:
        .incbin "../build/bonus-sprites.bin", 0, 256        ; 256 bytes - cake
; Bonus stage 1 pattern B - 8 bytes copied to $7D76 during stage 1 init
; Creates a small decorative element (pillar/stripe pattern) in the level buffer
; Used alongside bonus_stage1_pattern_a which is copied to $7D37
; This data is the top left of the melon sprite from bonus-sprites.tga
bonus_stage1_pattern_b:
        .incbin "../build/bonus-sprites.bin", 256, 8        ; 8 bytes - melon top left

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



;-------------------------------------------------------------------------------
; Bonus melon sprites + padding ($A47E-$A51F, 162 bytes)
; Layout:
;   $A47E-$A495: 24 bytes - zero padding
;   $A496-$A49F: 10 bytes - melon top right (from bonus-sprites.tga)
;   $A4A0-$A51F: 128 bytes - 2 melon sprites from bonus-sprites.tga
;-------------------------------------------------------------------------------
        .segment "BONUS_MELON"
bonus_melon_padding:
        .byte   $00, $00, $00, $00, $00, $00, $00, $00      ; 24 bytes - zero padding
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .incbin "../build/bonus-sprites.bin", 264, 10       ; 10 bytes - melon top right
bonus_melon_sprites:
        .incbin "../build/bonus-sprites.bin", 274, 128      ; 128 bytes - melon sprites 4 & 5

;-------------------------------------------------------------------------------
; Bonus diamond sprites ($A520-$A59F, 128 bytes)
; 2 diamond sprites from bonus-sprites.tga
;-------------------------------------------------------------------------------
        .segment "BONUS_DIAMOND"
bonus_diamond_sprites:
        .incbin "../build/bonus-sprites.bin", 402, 128      ; 128 bytes - diamond



;-------------------------------------------------------------------------------
; Game tables ($A632-$AE50, 2079 bytes)
; Lookup tables for sprites, positions, items, etc.
; Enemy spawn data has been moved to ENEMY_SPAWNS segment (generated)
;
; Structure:
;   $A632-$A814: game-tables-part1a.bin (483 bytes) - lookup tables
;   $A815-$A823: Bonus stage pointer tables (15 bytes) - source code below
;   $A824-$A853: game-tables-part1b.bin (48 bytes) - lookup tables
;   $A854-$A877: diamond-sprite.bin (36 bytes) - from diamond-sprite.tga
;   $A878-$AD74: game-tables-part2.bin (1277 bytes) - lookup tables
;   $AD75-$ADB0: digit-font.bin (60 bytes) - from digit-font.tga
;   $ADB1-$AE50: game-tables-part3.bin (160 bytes) - lookup tables
;-------------------------------------------------------------------------------
        .segment "GAMETABLES"
        .incbin "../data/game-tables-part1a.bin"    ; $A632-$A814 (483 bytes)

; Bonus stage data pointer tables ($A815-$A823)
; These point to data areas used during bonus round initialization
; 256 bytes are copied from the pointed address to buffer $7D00
; Index 0: Cake bonus - copies cake sprite data directly
; Index 1: Special stage - copies from $A420, then clears first 128 bytes,
;          then patches in bonus_stage1_pattern_a at $7D37 and
;          bonus_stage1_pattern_b at $7D76
; Index 2-4: Melon bonus - copies melon sprite data directly
bonus_data_ptr_lo:
        .byte   <bonus_cake_sprites         ; Index 0: $A320
        .byte   <bonus_stage1_pattern_b     ; Index 1: $A420
        .byte   <bonus_melon_sprites        ; Index 2: $A4A0
        .byte   <bonus_melon_sprites        ; Index 3: $A4A0
        .byte   <bonus_melon_sprites        ; Index 4: $A4A0
bonus_data_ptr_hi:
        .byte   >bonus_cake_sprites         ; Index 0: $A320
        .byte   >bonus_stage1_pattern_b     ; Index 1: $A420
        .byte   >bonus_melon_sprites        ; Index 2: $A4A0
        .byte   >bonus_melon_sprites        ; Index 3: $A4A0
        .byte   >bonus_melon_sprites        ; Index 4: $A4A0
bonus_sprite_colors:
        .byte   $07                         ; Index 0: Yellow (cake)
        .byte   $05                         ; Index 1: Green
        .byte   $07                         ; Index 2: Yellow (melon)
        .byte   $0E                         ; Index 3: Light blue (diamond)
        .byte   $04                         ; Index 4: Purple (diamond)

        .incbin "../data/game-tables-part1b.bin"    ; $A824-$A853 (48 bytes)
        .incbin "../build/diamond-sprite.bin"       ; $A854-$A877 (36 bytes)
        .incbin "../data/game-tables-part2a.bin", 0, 476   ; $A878-$AA53 (476 bytes)

; Sprite graphics pointer table - low bytes ($AA54-$AA8D, 58 bytes)
; Combined with sprite_gfx_ptr_hi to form full addresses for sprite graphics
; Entries 0-11: bubble masks ($8000-$8210)
; Entries 12-43: software sprites ($9080-$9810)
; Entries 44-47: null ($0000)
; Entries 48-57: software sprites ($8F00-$9870)
sprite_gfx_ptr_lo:
        .byte   <bubble_mask_0x000                        ; Entry 0
        .byte   <bubble_mask_0x030                        ; Entry 1
        .byte   <bubble_mask_0x060                        ; Entry 2
        .byte   <bubble_mask_0x090                        ; Entry 3
        .byte   <bubble_mask_0x0c0                        ; Entry 4
        .byte   <bubble_mask_0x0f0                        ; Entry 5
        .byte   <bubble_mask_0x120                        ; Entry 6
        .byte   <bubble_mask_0x150                        ; Entry 7
        .byte   <bubble_mask_0x180                        ; Entry 8
        .byte   <bubble_mask_0x1b0                        ; Entry 9
        .byte   <bubble_mask_0x1e0                        ; Entry 10
        .byte   <bubble_mask_0x210                        ; Entry 11
        .byte   <soft_spr_0x180                           ; Entry 12
        .byte   <(soft_spr_0x180 + $30)                   ; Entry 13
        .byte   <(soft_spr_0x180 + $60)                   ; Entry 14
        .byte   <(soft_spr_0x240 - $30)                   ; Entry 15
        .byte   <soft_spr_0x240                           ; Entry 16
        .byte   <(soft_spr_0x240 + $30)                   ; Entry 17
        .byte   <(soft_spr_0x240 + $60)                   ; Entry 18
        .byte   <(soft_spr_0x240 + $90)                   ; Entry 19
        .byte   <soft_spr_0x300                           ; Entry 20 (lightning bubble)
        .byte   <(soft_spr_0x300 + $30)                   ; Entry 21 (lightning bubble)
        .byte   <(soft_spr_0x300 + $60)                   ; Entry 22 (lightning bubble)
        .byte   <(soft_spr_0x300 + $90)                   ; Entry 23 (lightning bubble)
        .byte   <soft_spr_0x580                           ; Entry 24
        .byte   <(soft_spr_0x580 + $30)                   ; Entry 25
        .byte   <(soft_spr_0x580 + $60)                   ; Entry 26
        .byte   <soft_spr_0x610                           ; Entry 27
        .byte   <(soft_spr_0x610 + $30)                   ; Entry 28
        .byte   <(soft_spr_0x610 + $60)                   ; Entry 29
        .byte   <(soft_spr_0x610 + $90)                   ; Entry 30
        .byte   <(soft_spr_0x610 + $C0)                   ; Entry 31
        .byte   <soft_spr_0x700                           ; Entry 32
        .byte   <(soft_spr_0x700 + $30)                   ; Entry 33
        .byte   <(soft_spr_0x700 + $60)                   ; Entry 34
        .byte   <(soft_spr_0x700 + $90)                   ; Entry 35
        .byte   <(soft_spr_0x700 + $C0)                   ; Entry 36
        .byte   <(soft_spr_0x700 + $F0)                   ; Entry 37
        .byte   <soft_spr_0x820                           ; Entry 38
        .byte   <(soft_spr_0x820 + $30)                   ; Entry 39
        .byte   <(soft_spr_0x820 + $60)                   ; Entry 40
        .byte   <(soft_spr_0x820 + $90)                   ; Entry 41
        .byte   <(soft_spr_0x820 + $C0)                   ; Entry 42
        .byte   <soft_spr_0x910                           ; Entry 43
        .byte   $00, $00, $00, $00                        ; Entries 44-47: null
        .byte   <soft_spr_0x000                           ; Entry 48
        .byte   <(soft_spr_0x000 + $30)                   ; Entry 49
        .byte   <(soft_spr_0x000 + $60)                   ; Entry 50
        .byte   <(soft_spr_0x000 + $90)                   ; Entry 51
        .byte   <soft_spr_0x400                           ; Entry 52
        .byte   <(soft_spr_0x400 + $30)                   ; Entry 53
        .byte   <(soft_spr_0x400 + $60)                   ; Entry 54
        .byte   <(soft_spr_0x400 + $90)                   ; Entry 55
        .byte   <soft_spr_0x940                           ; Entry 56
        .byte   <(soft_spr_0x940 + $30)                   ; Entry 57

; Sprite graphics pointer table - high bytes ($AA8E-$AAC7, 58 bytes)
; Combined with sprite_gfx_ptr_lo to form full addresses for sprite graphics
sprite_gfx_ptr_hi:
        .byte   >bubble_mask_0x000                        ; Entry 0
        .byte   >bubble_mask_0x030                        ; Entry 1
        .byte   >bubble_mask_0x060                        ; Entry 2
        .byte   >bubble_mask_0x090                        ; Entry 3
        .byte   >bubble_mask_0x0c0                        ; Entry 4
        .byte   >bubble_mask_0x0f0                        ; Entry 5
        .byte   >bubble_mask_0x120                        ; Entry 6
        .byte   >bubble_mask_0x150                        ; Entry 7
        .byte   >bubble_mask_0x180                        ; Entry 8
        .byte   >bubble_mask_0x1b0                        ; Entry 9
        .byte   >bubble_mask_0x1e0                        ; Entry 10
        .byte   >bubble_mask_0x210                        ; Entry 11
        .byte   >soft_spr_0x180                           ; Entry 12
        .byte   >(soft_spr_0x180 + $30)                   ; Entry 13
        .byte   >(soft_spr_0x180 + $60)                   ; Entry 14
        .byte   >(soft_spr_0x240 - $30)                   ; Entry 15
        .byte   >soft_spr_0x240                           ; Entry 16
        .byte   >(soft_spr_0x240 + $30)                   ; Entry 17
        .byte   >(soft_spr_0x240 + $60)                   ; Entry 18
        .byte   >(soft_spr_0x240 + $90)                   ; Entry 19
        .byte   >soft_spr_0x300                           ; Entry 20 (lightning bubble)
        .byte   >(soft_spr_0x300 + $30)                   ; Entry 21 (lightning bubble)
        .byte   >(soft_spr_0x300 + $60)                   ; Entry 22 (lightning bubble)
        .byte   >(soft_spr_0x300 + $90)                   ; Entry 23 (lightning bubble)
        .byte   >soft_spr_0x580                           ; Entry 24
        .byte   >(soft_spr_0x580 + $30)                   ; Entry 25
        .byte   >(soft_spr_0x580 + $60)                   ; Entry 26
        .byte   >soft_spr_0x610                           ; Entry 27
        .byte   >(soft_spr_0x610 + $30)                   ; Entry 28
        .byte   >(soft_spr_0x610 + $60)                   ; Entry 29
        .byte   >(soft_spr_0x610 + $90)                   ; Entry 30
        .byte   >(soft_spr_0x610 + $C0)                   ; Entry 31
        .byte   >soft_spr_0x700                           ; Entry 32
        .byte   >(soft_spr_0x700 + $30)                   ; Entry 33
        .byte   >(soft_spr_0x700 + $60)                   ; Entry 34
        .byte   >(soft_spr_0x700 + $90)                   ; Entry 35
        .byte   >(soft_spr_0x700 + $C0)                   ; Entry 36
        .byte   >(soft_spr_0x700 + $F0)                   ; Entry 37
        .byte   >soft_spr_0x820                           ; Entry 38
        .byte   >(soft_spr_0x820 + $30)                   ; Entry 39
        .byte   >(soft_spr_0x820 + $60)                   ; Entry 40
        .byte   >(soft_spr_0x820 + $90)                   ; Entry 41
        .byte   >(soft_spr_0x820 + $C0)                   ; Entry 42
        .byte   >soft_spr_0x910                           ; Entry 43
        .byte   $00, $00, $00, $00                        ; Entries 44-47: null
        .byte   >soft_spr_0x000                           ; Entry 48
        .byte   >(soft_spr_0x000 + $30)                   ; Entry 49
        .byte   >(soft_spr_0x000 + $60)                   ; Entry 50
        .byte   >(soft_spr_0x000 + $90)                   ; Entry 51
        .byte   >soft_spr_0x400                           ; Entry 52
        .byte   >(soft_spr_0x400 + $30)                   ; Entry 53
        .byte   >(soft_spr_0x400 + $60)                   ; Entry 54
        .byte   >(soft_spr_0x400 + $90)                   ; Entry 55
        .byte   >soft_spr_0x940                           ; Entry 56
        .byte   >(soft_spr_0x940 + $30)                   ; Entry 57

        .incbin "../data/game-tables-part2b.bin"    ; $AAC8-$AD74 (685 bytes)
        .incbin "../build/digit-font.bin"           ; $AD75-$ADB0 (60 bytes)
        .incbin "../data/game-tables-part3.bin"     ; $ADB1-$AE50 (160 bytes)

; Symbols within game-tables-static.bin ($A632-$AE50)
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
D_A815      = bonus_data_ptr_lo   ; Level data pointer table (low bytes)
D_A81A      = bonus_data_ptr_hi   ; Level data pointer table (high bytes)
D_A81F      = bonus_sprite_colors ; Large bonus sprite colors (5 bytes: cupcake, melon, yellow/blue/purple diamond)
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
D_A9A8      = $A9A8     ; "ROUND" text indices (9 bytes: R O U N D spc + level digits)
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
D_AA54      = sprite_gfx_ptr_lo ; Sprite graphics pointer table (low)
D_AA8E      = sprite_gfx_ptr_hi ; Sprite graphics pointer table (high)
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
D_AD15      = $AD15     ; "READY!" text indices (9 bytes: R E A D Y spc ! spc spc)
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
; Enemy Spawn Data ($AE51-$B568, 1816 bytes)
; Position and type data for enemy spawns on all 100 levels
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "ENEMY_SPAWNS"
enemy_spawns:
        .incbin "../build/enemy-spawns.bin"

;-------------------------------------------------------------------------------
; Item Spawn Positions ($B569-$B694, 300 bytes)
; Three 100-byte tables at offsets +0, +100, +200
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "ITEM_POSITIONS"
item_positions:
        .incbin "../build/item-positions.bin"

;-------------------------------------------------------------------------------
; Game data - Zone regions ($B695-$BC0D, variable size, original 1145 bytes)
; Generated from data/zone-data.txt by tools/zone-data-tool.py
;-------------------------------------------------------------------------------
        .segment "GAMEDATA_WIND"
        .incbin "../build/zone-data.bin"

;-------------------------------------------------------------------------------
; Sidebars ($BC0E-$C2CD, 1888 bytes)
; 59 sidebar designs × 4 characters × 8 bytes per character
; Multi-color character data for level sidebars
; Generated from data/sidebars.tga by build/convert-tga.py
;-------------------------------------------------------------------------------
        .segment "SIDEBARS"
        .incbin "../build/sidebars.bin"

;-------------------------------------------------------------------------------
; Level Tiles ($C2CE-$C58D, 800 bytes)
; Multi-color 4x8 tiles for levels 12-99
; Generated from data/level-tiles.tga by build/convert-tga.py
;-------------------------------------------------------------------------------
        .segment "LEVEL_TILES"
        .incbin "../build/level-tiles.bin"

;-------------------------------------------------------------------------------
; Physics Flags ($C58E-$C5F1, 100 bytes)
; Level hole/bubble current metadata
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "PHYSICS_FLAGS"
physics_flags:
        .incbin "../build/physics-flags.bin"

;-------------------------------------------------------------------------------
; Level Bitmaps ($C5F2-$DFFF, 6670 bytes)
;-------------------------------------------------------------------------------
; Platform layout bitmaps for all 100 levels
; Each level uses 46 bytes (symmetric) or 92 bytes (asymmetric)
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "LEVEL_BITMAPS"
level_bitmaps:
        .incbin "../build/level-bitmaps.bin"

;-------------------------------------------------------------------------------
; HUD Font ($FE90-$FF2F, 160 bytes)
;-------------------------------------------------------------------------------
; 4x8 multicolor font containing 20 characters (160 bytes total)
; Each character is 8 bytes (one byte per row, 8 rows)
; Bit pattern: 2 bits per pixel (4 pixels per byte)
;
; Character set contents:
;   Index $00-$09: Digits 0-9 (for score display, level numbers)
;   Index $0A-$13: R O U N D E A Y ! (space) - for "ROUND" and "READY!" text
;
; Usage:
;   1. Copied to $4300 during init - accessed via screen codes $60-$73
;   2. Accessed directly at $FE90 for graphics compositing (ROUND/READY text)
;
; Source: data/hud-font.tga (converted by build/convert-tga.py --format multicolor-chars)
;-------------------------------------------------------------------------------
        .segment "HUDFONT"
hud_font:
        .incbin "../build/hud-font.bin"

;-------------------------------------------------------------------------------
; Level Colors ($FF30-$FF93, 100 bytes)
;-------------------------------------------------------------------------------
; Background/platform color theme for each level (1 byte per level)
; High nibble and low nibble each encode a C64 color value
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "LEVEL_COLORS"
level_colors:
        .incbin "../build/level-colors.bin"

;-------------------------------------------------------------------------------
; Level Flags ($FF94-$FFF7, 100 bytes)
;-------------------------------------------------------------------------------
; Symmetry flag + sidebar character set index for each level
; Bit 7 = symmetry (1=symmetric/46 bytes, 0=asymmetric/92 bytes)
; Bits 0-6 = sidebar character set index
; Generated from data/levels.txt by build/convert-levels.py
;-------------------------------------------------------------------------------
        .segment "LEVEL_FLAGS"
level_flags:
        .incbin "../build/level-flags.bin"
