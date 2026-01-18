; ============================================================================
; rebb64 - Reverse Engineered Bubble Bobble C64 - Master Source File
; ============================================================================
;
; This file contains the complete game as assembleable source.
; All code sections have been converted to proper, documented assembly.
;
; TO MODIFY A ROUTINE:
;   1. Find the routine by address or label in the .include files
;   2. Make your changes (ensure byte count stays same for now)
;   3. Build with: cd build && make && make verify
;
; ============================================================================

.setcpu "6502"

; ============================================================================
; SYMBOL DEFINITIONS
; ============================================================================

; --- Zero Page (C64 BASIC locations reused by game) ---
; NOTE: These addresses are used as base addresses for indexed access
; e.g., lda $00b2,y accesses player state for player Y (0 or 1)
ZP_02       = $02
ZP_03       = $03  
ZP_04       = $04
ZP_05       = $05
ZP_06       = $06
ZP_07       = $07
ENDCHR      = $08       ; Frame counter (incremented each IRQ)
TRMPOS      = $09       ; Temporary pointer (low byte)
VERCK       = $0A       ; Temporary pointer (high byte)
SUBFLG      = $10       ; Current level (1-100)
INPFLG      = $11       ; Input flag
TANSGN      = $12       ; Cell pointer high byte
ZP_15       = $15       ; Saved A register in IRQ
ZP_16       = $16       ; Saved X register in IRQ  
ZP_17       = $17       ; Saved Y register in IRQ
ZP_1C       = $1C       ; Background color 1
ZP_1D       = $1D       ; Background color temp 1
ZP_1E       = $1E       ; Background color 2
ZP_1F       = $1F       ; Background color temp 2
ZP_20       = $20       ; Split-screen mode flag
ZP_21       = $21       ; Level complete flag
INDEX1      = $22       ; Player loop counter
ZP_23       = $23       ; Level/world index
INDEX2      = $24       ; Terrain index
ZP_25       = $25       ; Player Y position / level index
RESHO       = $26       ; Random seed storage
ZP_2A       = $2A       ; Level timer (seconds)
TXTTAB      = $2B       ; Frame sub-counter  
TXTTAB1     = $2C
VARTAB      = $2D
ZP_2E       = $2E       ; CPU port save value
ARYTAB      = $2F       ; Screen pointer
STREND      = $31       ; String end pointer (BASIC)
FRETOP      = $33       ; Free string space (BASIC)
ZP_36       = $36       ; Used during spawn
MEMSIZ      = $37       ; Pause flag
MEMSIZ1     = $38       ; Animation timer storage
CURLIN      = $39       ; Temp storage for column
CURLIN1     = $3A       ; Temp storage for X position
OLDLIN      = $3B       ; Temp storage in collision detection
OLDLIN1     = $3C       ; Temp storage - current player index
OLDTXT      = $3D       ; Temp storage
ZP_3E       = $3E       ; Temp storage
DATLIN      = $3F
DATLIN1     = $40
DATPTR      = $41
DATPTR1     = $42
INPPTR      = $43
ZP_44       = $44
VARNAM      = $45       ; Variable name/temp storage
ZP_46       = $46
ZP_47       = $47
ZP_48       = $48       ; Temp storage
ZP_49       = $49       ; Temp storage
ZP_4A       = $4A       ; Enemies remaining to spawn
OPPTR       = $4B       ; Player index pointer
ZP_4C       = $4C       ; Temp storage
OPMASK      = $4D
DEFPNT      = $4E       ; Player screen position (low)
ZP_4F       = $4F       ; Temp storage
DSESSION    = $50       ; Player screen position (high)
ZP_51       = $51       ; Temp storage  
ZP_52       = $52       ; Player active flags
FOUR6       = $53       ; Special item type
ZP_54       = $54       ; Temp storage
ZP_55       = $55       ; Temp storage
ZP_56       = $56       ; Temp storage
ZP_57       = $57       ; Temp storage
ZP_58       = $58       ; Random timer seed
ZP_59       = $59       ; Temp storage
TEMPF1      = $5A       ; Temp storage
ZP_5B       = $5B       ; Temp storage
ZP_5C       = $5C       ; Temp storage
ZP_5D       = $5D       ; Player 1 bubble timer
ZP_5E       = $5E       ; Player 2 bubble timer
TEMPF2      = $5F       ; Bubble animation
ZP_60       = $60       ; Temp storage
FAC         = $61       ; Floating point accumulator (used as temp)
ZP_67       = $67       ; Animation active flag (also SESSION)
ZP_68       = $68       ; Timer storage
ZP_69       = $69       ; Score value storage (also ARG)
ZP_6A       = $6A       ; Temp storage
SESSION     = $67       ; Animation active flag
ARG         = $69       ; Score value storage
FBUFPT      = $71       ; Loader buffer read pointer
ZP_75       = $75       ; Score display buffer (3 bytes)
CHRGOT      = $79       ; BASIC get-character routine pointer
TXTPTR      = $7A       ; Text pointer / temp storage (BASIC)
STATUS      = $90       ; I/O status byte
STKEY       = $91       ; Keyboard buffer pointer (BASIC)
SVXT        = $92       ; Temp storage (used by sound engine)
BESSION     = $95       ; Temp storage used by sound engine
DFLTN       = $98       ; Default input device (used by sound engine)
TESSION     = $9B       ; Temp storage (used by sound engine)
TIME        = $9E       ; Temp storage / music data pointer
BSOUR       = $A3       ; Loader ID byte
SYESSION    = $A4       ; Loader destination address low
SHCNL       = $A5       ; Loader destination address high
BAUDOF      = $A9       ; Loader block number
RIDBE       = $AB
RIDBS       = $AC
RODBS       = $AD       ; Loader comparison byte
RODBE       = $AE
IRQTMP      = $AF       ; Loader temp/status
ZP_B0       = $B0       ; Temp storage
ZP_B1       = $B1       ; Temp storage

; --- Entity State Arrays (Zero Page, indexed access) ---
; These are accessed as base + index for entity data
; e.g., lda $00b2,y where Y = player/entity index
ESSION      = $B2       ; Entity state base (alias for ENESSION)
ENESSION    = $B2       ; Player 1 state / Entity state array base
ENESSION1   = $B3       ; Player 2 state  
ZP_B4       = $B4       ; Entity state +2 (bubble state array base)
FA          = $BA       ; Player 1 X position / Entity X array base
FA1         = $BB       ; Player 2 X position
FNADR       = $BB       ; Bubble X position (alias for FA1)
ZP_BC       = $BC       ; Viewport X offset / Entity X +2
ROESSION    = $BD       ; Super bonus Y position
ZP_BD       = $BD       ; Alias for ROESSION
FSESSION    = $BE       ; Super bonus state
ZP_BE       = $BE       ; Alias for FSESSION
ZP_C2       = $C2       ; Player 1 Y position / Entity Y array base
ZP_C3       = $C3       ; Player 2 Y position
TAPE1       = $C3       ; Bubble Y position (alias for ZP_C3)
ZP_C4       = $C4       ; Entity Y +2
ZP_C6       = $C6       ; Entity Y +4 / Timer
ZP_C7       = $C7       ; Entity Y +5 / Timer
PESSION     = $CA       ; Enemy type array base
LSXP        = $CB       ; Player 2 enemy state / Enemy type +1
BLNON       = $CC       ; Enemy type +2
ZP_DC       = $DC       ; Entity screen column array base
ZP_DE       = $DE       ; Entity X sub-position array base
ZP_EE       = $EE       ; Entity screen row array base
ZP_F0       = $F0       ; Entity Y sub-position array base
FREKZP      = $FB       ; Temp pointer (used by memory copy routines)

; --- C64 Hardware ---
R6510       = $01       ; CPU I/O port (memory banking control)
VIC_SPR0_X  = $D000     ; Sprite X positions
VIC_SPR0_Y  = $D001     ; Sprite Y positions
VIC_SPR1_X  = $D002     ; Sprite 1 X position
VIC_SPR1_Y  = $D003     ; Sprite 1 Y position
VIC_SPR2_X  = $D004     ; Sprite 2 X position
VIC_SPR2_Y  = $D005     ; Sprite 2 Y position
VIC_SPR3_X  = $D006     ; Sprite 3 X position
VIC_SPR3_Y  = $D007     ; Sprite 3 Y position
VIC_SPR4_X  = $D008     ; Sprite 4 X position
VIC_SPR4_Y  = $D009     ; Sprite 4 Y position
VIC_SPR5_X  = $D00A     ; Sprite 5 X position
VIC_SPR5_Y  = $D00B     ; Sprite 5 Y position
VIC_SPR6_X  = $D00C     ; Sprite 6 X position
VIC_SPR6_Y  = $D00D     ; Sprite 6 Y position
VIC_SPR7_X  = $D00E     ; Sprite 7 X position
VIC_SPR7_Y  = $D00F     ; Sprite 7 Y position
VIC_SPR_XMSB = $D010    ; Sprite X MSB (high bit of X for all sprites)
VIC_CTRL1   = $D011     ; VIC control register 1 (screen mode)
VIC_RASTER  = $D012     ; Raster line register
VIC_SPR_ENA = $D015     ; Sprite enable register
VIC_CTRL2   = $D016     ; VIC control register 2 (multicolor, etc)
VIC_MEMPTR  = $D018     ; VIC memory pointers (screen/charset location)
VIC_BORDER  = $D020     ; Border color
VIC_BG0     = $D021     ; Background color 0
VIC_BG1     = $D022     ; Background color 1
VIC_BG2     = $D023     ; Background color 2
VIC_IRQ     = $D019     ; VIC interrupt register
VIC_ICTRL   = $D01A     ; VIC interrupt control register
VIC_SPR_PRI = $D01B     ; Sprite priority register (0=sprite in front)
VIC_SPR0_COL = $D027    ; Sprite colors
VIC_SPR1_COL = $D028    ; Sprite 1 color
VIC_SPR2_COL = $D029    ; Sprite 2 color
VIC_SPR4_COL = $D02B    ; Sprite 4 color (also sprites 4-7 base)

; --- SID Chip (Sound Interface Device) ---
SID_V1_FREQ_LO = $D400  ; Voice 1 frequency low byte
SID_V1_FREQ_HI = $D401  ; Voice 1 frequency high byte
SID_V1_PW_LO   = $D402  ; Voice 1 pulse width low byte
SID_V1_PW_HI   = $D403  ; Voice 1 pulse width high byte
SID_V1_CTRL    = $D404  ; Voice 1 control register
SID_FILT_LO    = $D415  ; Filter cutoff frequency low bits
SID_FILT_HI    = $D416  ; Filter cutoff frequency high byte
SID_VOL        = $D418  ; Volume and filter mode control

CIA1_PRA    = $DC00     ; Joystick port 2
CIA1_PRB    = $DC01     ; Joystick port 1
CIA1_TBLO   = $DC06     ; CIA1 timer B low byte (used for RNG entropy)
CIA1_ICR    = $DC0D     ; CIA1 interrupt control register
CIA2_PRA    = $DD00     ; CIA2 port A (VIC bank selection)
CIA2_TALO   = $DD04     ; CIA2 timer A low byte
CIA2_TAHI   = $DD05     ; CIA2 timer A high byte
CIA2_ICR    = $DD0D     ; CIA2 interrupt control register
CIA2_CRA    = $DD0E     ; CIA2 control register A
D_D800      = $D800     ; Color RAM start
D_D801      = $D801     ; Color RAM
D_D900      = $D900     ; Color RAM page 1
D_D99C      = $D99C     ; Color RAM baron position 1
D_D9EC      = $D9EC     ; Color RAM baron position 2
D_DA00      = $DA00     ; Color RAM page 2
D_DB00      = $DB00     ; Color RAM page 3

; --- KERNAL Vectors ---
CINV        = $0314     ; IRQ vector (low byte at $0314, high at $0315)
CINV_HI     = $0315     ; IRQ vector high byte
NMINV       = $0318     ; NMI vector (low byte at $0318, high at $0319)
NMINV_HI    = $0319     ; NMI vector high byte
ISTOP       = $0312     ; BASIC stop key check routine vector
D_033C      = $033C     ; Cassette buffer (192 bytes)
NMI_VEC     = $FFFA     ; Hardware NMI vector low byte
NMI_VEC_HI  = $FFFB     ; Hardware NMI vector high byte
IRQ_VEC     = $FFFE     ; Hardware IRQ vector low byte
IRQ_VEC_HI  = $FFFF     ; Hardware IRQ vector high byte
D_FEBC      = $FEBC     ; KERNAL IRQ exit routine

; --- Game Data Tables (in RAM, addresses fixed) ---
D_0107      = $0107     ; Stack page temp buffer
D_0108      = $0108     ; Stack page temp buffer
D_010F      = $010F     ; Stack page temp buffer
D_0117      = $0117     ; Stack page temp buffer
D_011F      = $011F     ; Stack page temp buffer
D_0200      = $0200     ; Level pointer table (low bytes, 100 entries)
D_0300      = $0300     ; Level pointer table (high bytes, 100 entries)
; D_7305-$7429: Music command handlers - now defined in music-command-handlers.s
; D_742A-$743F: Music data tables - now defined in music-command-handlers.s
D_3F86      = $3F86     ; Bubble character table

; Sprite masking tables


; --- Spawn Point Data ---
D_0193      = $0193     ; Player-captured-by flags (18 bytes)
D_0195      = $0195     ; Projectile direction array (18 bytes)
D_0181      = $0181     ; Enemy row positions (18 bytes)
D_016F      = $016F     ; Enemy screen position temp (18 bytes)
D_015D      = $015D     ; Enemy column positions (18 bytes)
D_014B      = $014B     ; Enemy render state (18 bytes)
D_A5B8      = $A5B8     ; Super bonus capture flag
D_2922      = $2922     ; Joystick data storage
D_119F      = $119F     ; Saved game state
D_3AB8      = $3AB8     ; Hurry-up handler
D_3AF0      = $3AF0     ; Self-modifying code target (screen scroll)
D_3BA1      = $3BA1     ; Self-modifying code target (screen scroll)
D_3BFA      = $3BFA     ; Self-modifying code target (screen scroll)
D_3D1E      = $3D1E     ; Screen scroll output buffer 2
D_3CB2      = $3CB2     ; Screen scroll data buffer 1
D_3CBB      = $3CBB     ; Screen scroll color buffer
D_3CC4      = $3CC4     ; Screen scroll saved data 1
D_3CCD      = $3CCD     ; Screen scroll saved data 2
D_3CD6      = $3CD6     ; Screen scroll output buffer 1
; D_3F84 defined as label in sprite-init.s
D_47F0      = $47F0     ; Sprite/charset data buffer
D_045C      = $045C     ; Check player state routine
D_47F8      = $47F8     ; Item table 1
; D_7BA6 - now defined as label in level-data-part2.s
; D_7AE3 - now defined as label in level-data-part2.s
; D_7BC8 - now defined as label in level-data-part2.s
D_7D00      = $7D00     ; Level data destination / screen buffer 1
D_7D80      = $7D80     ; Screen buffer 2
D_7E00      = $7E00     ; Screen buffer 3
; D_48D0 defined as label in init-routines.s
; D_4460 defined as label in game-init-early.s (Main game code entry point)
D_4500      = $4500     ; Enemy template data table 3 (RAM copy)
D_4600      = $4600     ; Platform Y position table / Enemy template data table 4
D_4648      = $4648     ; Graphics work buffer (72 bytes)
D_0100      = $0100     ; Stack page (used for temp storage)
D_0A38      = $0A38     ; Entity spawn result storage
; D_0C9C defined as label in collision.s
D_0CC2      = $0CC2     ; Self-modifying code target (entity spawn)
D_0DC7      = $0DC7     ; Level number storage (credits handler)
D_1200      = $1200     ; Temp data buffer
D_D853      = $D853     ; Color RAM area 1
D_D9D3      = $D9D3     ; Color RAM text output (self-modifying)
D_DA5B      = $DA5B     ; Color RAM area 2
D_E200      = $E200     ; High memory restore target
D_E42A      = $E42A     ; Sprite/entity update routine
D_E494      = $E494     ; Wait one frame
D_E49B      = $E49B     ; Game loop continuation
EVAL        = $A7E4     ; Sprite data pointer
ADRAY1      = $03       ; Address high byte (used in level complete)
ADRAY2      = $05       ; Address high byte alternate
CHARONE     = $07       ; Character/color pointer

; --- Forward References (subroutines defined later in file) ---
; These are in the [BYTES] section but we call them from [CODE] sections

; --- Forward References (subroutines defined later in file) ---
; NOTE: Only include labels that are used BEFORE they are defined
; Labels defined as "D_XXXX:" in include files don't need equates here

; Game variable area
entry_0400  = $0400     ; Game variable area (used by special enemies)
D_040A      = $040A     ; Score byte +1
D_0400      = $0400     ; Score data / game variables base
D_0406      = $0406     ; High score storage (3 bytes)
D_040B      = $040B     ; Player name/initials storage
D_049D      = $049D     ; Self-modifying code target (L_049D)
D_0717      = $0717     ; IRQ handler continuation routine
; D_0CF2 - now defined as label in enemy-ai.s

; Forward references for routines called from master.s before their definition
; These are needed because master.s code calls these before the includes
; D_0F73 - now defined as label in enemy-ai.s
D_F073      = $F073     ; Self-modifying code target (high address)
; D_105B - now defined as label in enemy-ai.s
D_1319      = $1319     ; Update player sprites
; D_13BE - now defined as label in player-sprites.s
D_1578      = $1578     ; Update bubbles physics
D_1677      = $1677     ; Skip timer continuation (in .byte section)
D_16E4      = $16E4     ; Continue game routine
D_16EF      = $16EF     ; Continue flag
; D_17BE - now defined as label in bubbles-sprites.s
D_1805      = $1805     ; Update player sprite positions
D_18D6      = $18D6     ; Self-modifying code storage
D_18D8      = $18D8     ; Self-modifying code storage
D_18DF      = $18DF     ; Self-modifying code storage
D_1929      = $1929     ; Self-modifying code storage
D_1CA0      = $1CA0     ; Player falling handler (in bb-level-complete.s)
D_1CBD      = $1CBD     ; Game update routine (called from IRQ)
D_2020      = $2020     ; Unknown routine
D_30A9      = $30A9     ; Data table (possibly invalid address)
D_3BF1      = $3BF1     ; Self-modifying code target in screen scroll
D_3EF3      = $3EF3     ; Sprite init continuation (in bb-sprite-init.s)
; L_0D4A - now defined as label in enemy-ai.s
; D_CF2 - now defined as label in enemy-ai.s

; $7Bxx - Level/screen routines - NOW IN level-data-part2.s
; D_05AD defined as label in master.s (code section)
; D_7BB3 - now defined as label in level-data-part2.s
; D_7BC3 - now defined as label in level-data-part2.s
; D_7BE8 - now defined as label in level-data-part2.s
; D_7BFE - now defined as label in level-data-part2.s

; $7Cxx - Score/collision routines - NOW IN level-data-part2.s
; D_7C21 - now defined as label in level-data-part2.s
D_7C26      = $7C26     ; Add score routine (alias for D_7C24)

; $7Exx - Input/pause routines - NOW IN level-data-part2.s
; D_7E80 - now defined as label in level-data-part2.s
; D_7EB3 - now defined as label in level-data-part2.s
; D_7EC1 - now defined as label in level-data-part2.s

; $7Fxx - Player death routines - NOW IN level-data-part2.s
; D_7F53 - now defined as label in level-data-part2.s

; $87xx - Animation data

; $C2xx - Handler routines

; --- $E000+ High Memory Routines (forward references) ---
; Many of these are defined in include files, but some are in binary data

; $E0xx - Level renderer
D_E000      = $E000     ; Level renderer main entry

; $E1xx - Screen rendering
D_E189      = $E189     ; Screen rendering routine

; Entity-related forward references
D_E3A7      = $E3A7     ; Update sprite data
D_E3D9      = $E3D9     ; Display text line routine
D_E374      = $E374     ; Screen setup routine
D_E4C5      = $E4C5     ; Entity setup routine
D_E4DA      = $E4DA     ; Entity update routine
D_E554      = $E554     ; Line drawing routine
D_E658      = $E658     ; Unknown routine
D_E6CD      = $E6CD     ; State change handler
D_E740      = $E740     ; Screen/sprite update routine
D_E758      = $E758     ; Entity cleanup routine
D_E7CF      = $E7CF     ; Sprite display routine

; $E8xx - Sprite pointers (self-modifying code targets)
D_E849      = $E849     ; Sprite routine pointer 1
D_E84A      = $E84A     ; Sprite routine pointer 1 instruction
D_E84C      = $E84C     ; Sprite pointer 1 low
D_E84D      = $E84D     ; Sprite pointer 1 high
D_E853      = $E853     ; Sprite routine pointer 2
D_E854      = $E854     ; Sprite routine pointer 2 instruction
D_E856      = $E856     ; Sprite pointer 2 low
D_E857      = $E857     ; Sprite pointer 2 high
D_E85D      = $E85D     ; Sprite routine pointer 3
D_E85E      = $E85E     ; Sprite routine pointer 3 instruction
D_E860      = $E860     ; Sprite pointer 3 low
D_E861      = $E861     ; Sprite pointer 3 high

; $E9xx - Entity/RNG routines
D_E90E      = $E90E     ; Update game state
D_E966      = $E966     ; Self-modifying: sprite frame offset
; D_E968 now defined as label in sprite-composer.s
D_E96F      = $E96F     ; Entity loop continuation
; D_E97A now defined as label in sprite-composer.s
D_E9B8      = $E9B8     ; Get sprite animation frame
D_E9EA      = $E9EA     ; Random number generator (RNG)

; $EBxx - Entity state handlers
; L_EB0F now defined as label in entity-bubble-handler.s
D_EB34      = $EB34     ; Alternate state handler
D_EB3F      = $EB3F     ; Falling through floor handler
D_EB94      = $EB94     ; Self-modifying: jump instruction
D_EBB5      = $EBB5     ; Self-modifying: jump target low
D_EBB6      = $EBB6     ; Self-modifying: jump target high
D_EBB8      = $EBB8     ; Jump state handler
D_EBC4      = $EBC4     ; Reset velocities handler
D_EBD9      = $EBD9     ; Platform physics handler

; $ECxx - Entity movement
; L_EC0C now defined as label in entity-movement.s
D_EC2C      = $EC2C     ; Alternate movement table load
D_EC3C      = $EC3C     ; Platform collision check after climb
D_EC7C      = $EC7C     ; Exit climbing state
; D_EC87 now defined as label in entity-movement.s
; D_ECDF now defined as label in entity-movement.s

; $EDxx - Entity input handlers
; D_ED12 now defined as label in entity-movement.s
; D_ED18 now defined as label in entity-movement.s
; D_ED1E now defined as label in entity-movement.s
; D_ED3B now defined as label in entity-movement.s
; L_EDC7 now defined as label in entity-ai.s
; D_EDCD now defined as label in entity-ai.s

; $EExx - Entity movement continued
; L_EE49 now defined as label in entity-ai.s
; D_EE4A now defined as label in entity-ai.s
; D_EE62 now defined as label in entity-ai.s
D_EEB4      = $EEB4     ; Entity movement handler
; D_EEC8 now defined as label in entity-ai.s
; D_EEDF now defined as label in entity-ai.s
; D_EEEB now defined as label in entity-ai.s

; $EFxx - Entity physics
D_EF15      = $EF15     ; Self-modified RTS
; D_EF1E now defined as label in entity-ai.s
D_EF3B      = $EF3B     ; Right movement platform check
; D_EF4C now defined as label in entity-ai.s
D_EFA0      = $EFA0     ; Normal vertical movement
; L_EFBC now defined as label in entity-physics-cont.s
; D_EFEA now defined as label in entity-physics-cont.s
D_4985      = $4985     ; Unknown routine
D_0409      = $0409     ; Score/stat value array
D_D8AF      = $D8AF     ; State array
D_F005      = $F005     ; Title screen initialization (referenced recursively)
D_F0F0      = $F0F0     ; Title screen text data
D_F0F3      = $F0F3     ; Title screen text data (BUBBLE)
D_F0FC      = $F0FC     ; Title screen text data
D_F0FE      = $F0FE     ; Title screen text data
D_F0FF      = $F0FF     ; Title screen text data
D_F100      = $F100     ; Title screen text data
L_F1A8      = $F1A8     ; Title screen data (appears as illegal opcodes)
D_F1AC      = $F1AC     ; Credits/score check routine
; L_F201 now defined as label in credits-handler-partial.s
; L_F20A now defined as label in credits-handler-partial.s
; D_F20B, D_F211, D_F217 are now defined in credits-handler-partial.s
; D_F256 and D_F2AE are now defined as labels in music-tables.s

; Frequency tables - defined in music-freqs.s (relocatable)
; D_F3B9 and D_F418 are now aliases to FREQ_TABLE_LO and FREQ_TABLE_HI
; which are labels defined within the MUSICFREQS segment
; L_F846 now defined as label in sound-engine.s
D_F477      = $F477     ; Initialize sound tables
D_F4BD      = $F4BD     ; Sound init routine
D_F53C      = $F53C     ; Sound update routine (called every frame)
; D_F887 now defined as label in sound-engine.s

; --- Music & Sound Data Forward References ---
; These labels are defined in bb-music-sound-data.s and referenced by sound engine
D_F2C4      = $F2C4     ; Sound channel data table
D_F2C5      = $F2C5     ; Sound parameter table
D_F2C6      = $F2C6     ; Sound configuration table
D_F2C7      = $F2C7     ; Sound/music data byte
D_F2C9      = $F2C9     ; Sound/music data byte
D_F2CA      = $F2CA     ; Sound/music data byte
D_F305      = $F305     ; Sound channel state array (3 channels)
D_F306      = $F306     ; Sound/music data byte
D_F307      = $F307     ; Sound/music data byte
D_F308      = $F308     ; Sound/music data byte
D_F309      = $F309     ; Sound/music data byte
D_F30A      = $F30A     ; Sound/music data byte
D_F30B      = $F30B     ; Sound/music data byte
D_F31B      = $F31B     ; Sound effect index/offset table
D_F31C      = $F31C     ; Sound/music data byte
D_F31D      = $F31D     ; Sound/music data byte
D_F31E      = $F31E     ; Sound/music data byte
D_F31F      = $F31F     ; Sound/music data byte
D_F320      = $F320     ; Sound/music data byte
D_F321      = $F321     ; Sound/music data byte
D_F322      = $F322     ; Sound/music data byte
D_F323      = $F323     ; Sound frequency/pitch table
D_F324      = $F324     ; Sound/music data byte
D_F325      = $F325     ; Sound/music data byte
D_F326      = $F326     ; Sound/music data byte
D_F327      = $F327     ; Sound/music data byte
D_F328      = $F328     ; Sound/music data byte
D_F329      = $F329     ; Sound/music data byte
D_F32A      = $F32A     ; Sound/music data byte
D_F32B      = $F32B     ; Sound/music data byte
D_F32C      = $F32C     ; Sound/music data byte
D_F32D      = $F32D     ; Sound/music data byte
D_F32E      = $F32E     ; Sound/music data byte
D_F32F      = $F32F     ; Sound/music data byte
D_F330      = $F330     ; Sound/music data byte
D_F331      = $F331     ; Sound/music data byte
D_F332      = $F332     ; Sound/music data byte
D_F333      = $F333     ; Sound/music data byte
D_F334      = $F334     ; Sound/music data byte
D_F335      = $F335     ; Sound/music data byte
D_F336      = $F336     ; Sound/music data byte
D_F337      = $F337     ; Sound/music data byte
D_F338      = $F338     ; Sound/music data byte
D_F339      = $F339     ; Sound/music data byte
D_F33A      = $F33A     ; Sound/music data byte
D_F33B      = $F33B     ; Sound/music data byte
D_F33C      = $F33C     ; Sound/music data byte
D_F33D      = $F33D     ; Sound/music data byte
D_F35A      = $F35A     ; Sound effect configuration block
D_F37D      = $F37D     ; Sound/music data byte
D_F384      = $F384     ; Extended sound configuration
D_F38C      = $F38C     ; Sound channel register offsets
D_F38D      = $F38D     ; Sound/music data byte
D_F38E      = $F38E     ; Sound/music data byte
D_F38F      = $F38F     ; Sound/music data byte
D_F391      = $F391     ; Sound/music data byte
D_F392      = $F392     ; Sound/music data byte
D_F393      = $F393     ; Sound/music data byte
D_F394      = $F394     ; Sound/music data byte
D_F395      = $F395     ; Sound/music data byte
D_F396      = $F396     ; Sound/music data byte
D_F397      = $F397     ; Sound/music data byte
D_F398      = $F398     ; Sound/music data byte
D_F399      = $F399     ; Sound/music data byte
D_F39A      = $F39A     ; Sound index multiplication table (partial)
D_F57C      = $F57C     ; Sound engine subroutine
D_F608      = $F608     ; Sound engine subroutine
D_F60B      = $F60B     ; Sound engine subroutine

; --- Entity Interaction Forward References ---
; D_2159 is defined in bb-player-animation.s
D_37C7      = $37C7     ; Player attribute table

; --- Player Movement Forward References ---
; D_272F, D_273D, D_2782 are defined in bb-player-movement.s
; D_1A6F is defined in bb-render-screen.s
; D_1E87 is defined in bb-player-animation.s
; D_1E2E is defined in bb-joystick-input.s
D_277F      = $277F     ; Temp storage

; --- Spawn Handler Forward References ---
; D_2916, D_2996, D_2923, D_292E, D_2985, D_289A are defined in bb-spawn-handlers.s
; D_2922 is defined in bb-spawn-handlers.s (self-modifying code target)
; D_2301, D_220C, D_2162 are defined in bb-entity-interaction.s
; D_1E6C is defined in bb-player-animation.s
; D_A754, D_A75F already defined above in Spawn Point Data section
D_2970      = $2970     ; Self-modifying code target
D_2971      = $2971     ; Self-modifying code target
D_298D      = $298D     ; Self-modifying code target
D_298E      = $298E     ; Self-modifying code target

; --- Item Collision Forward References ---
; D_29BC, D_29C0 are defined in bb-item-collision.s

; --- Super Bonus Forward References ---
; D_2A3F, D_2AA2 are defined in bb-super-bonus.s
; L_069B now defined as label in master.s
D_4700      = $4700     ; Special item type data
D_4710      = $4710     ; Special item X positions
D_4720      = $4720     ; Special item Y positions
D_4730      = $4730     ; Special item attributes
; D_8522 already defined above
VIC_SPR_YEXP = $D017    ; VIC sprite Y expansion register
VIC_SPR_XEXP = $D01D    ; VIC sprite X expansion register

; --- Level Setup Forward References ---
; D_2B31, D_2BBD, D_2C32, D_2C8C, D_2C9F, D_2CB7 are defined in bb-level-setup.s
D_4A10      = $4A10     ; Item work buffer 3
D_4A30      = $4A30     ; Item work buffer 4
D_0A39      = $0A39     ; Bonus level data
D_0A3A      = $0A3A     ; Bonus level data
D_7F83      = $7F83     ; Bonus level handler
; D_7C3C - now defined as label in level-data-part2.s

; --- Special Item Effects Forward References ---
; D_2D65, D_2D88, D_2DAB, D_2DB2, D_2DAC are defined in bb-special-item-effects.s
; D_2F5F, D_2F62, D_2F65 are defined in bb-level-transition.s

; --- Level Start Forward References ---
; D_2FAC, D_3080, D_311E, D_312E are defined in bb-level-start.s

; --- Platform Collision Forward References ---
; D_3169, D_3193, D_31A2, D_3266, D_3293 are defined in bb-platform-collision.s

; --- EXTEND Bonus Forward References ---
; D_32C1, D_3421, D_344A are defined in bb-extend-bonus.s

; --- Bonus Round Forward References ---
; D_348A, D_3495, D_34A0, D_34FA, D_3502, D_350A, D_350C, D_3517, D_35A8 are defined in bb-bonus-round.s
D_2AE9      = $2AE9     ; Configuration byte storage
; D_48A8, D_48B0, D_48B8, D_48C0, D_48C8 defined in init-routines.s
D_7D37      = $7D37     ; Special data area 1 (8 bytes)
D_7D76      = $7D76     ; Special data area 2 (8 bytes)

; --- Bonus Stage Extended Forward References ---
; D_35B0, D_35C0, D_3621, D_362F, D_370C, D_3771, D_3794 are defined in bb-bonus-stage-extended.s
D_37C9      = $37C9     ; Routine defined later (after $37C6)
D_392A      = $392A     ; Routine defined later (after this module)
D_4880      = $4880     ; Level layout buffer 2
D_4850      = $4850     ; Temporary item data storage
D_7D3E      = $7D3E     ; Screen buffer 1 offset $3E
D_7DBC      = $7DBC     ; Screen buffer 1 offset $BC
D_7DC2      = $7DC2     ; Screen buffer 1 offset $C2
D_7E40      = $7E40     ; Screen buffer 2 offset $40
D_E09B      = $E09B     ; Engine routine
D_E2C3      = $E2C3     ; Engine routine with pointer
D_F192      = $F192     ; Level data index table
D_F19F      = $F19F     ; Level data value table

; D_7B53 - now defined as label in level-data-part2.s
; D_7BC6 - now defined as label in level-data-part2.s
L_A474      = $A474     ; READY label

; ============================================================================
; Binary data files - memory positions defined in linker config
; ============================================================================
; Included here so labels (e.g., FREQ_TABLE_LO) are defined before use
.include "binaries.s"

; ============================================================================
; CODE START - $0400
; ============================================================================

; Game variables ($0400-$045B)
.include "game-variables.s"

; Player state routines ($045C-$06AA)
.include "player-state.s"

; IRQ handlers ($06AB-$078B)
.include "irq-handlers.s"

; ============================================================================
; Include the rest of the game
; This is everything from $078C to $FFFB
; 
; NOTE: Binary data assets are now in separate .bin files:
;   Graphics:
;     - Character set: $4000-$47FF (data/charset.bin, 2KB)
;     - Sprite data 1: $5800-$5FFF (data/sprites1.bin, 2KB)
;     - Sprite data 2: $8000-$9FFF (data/sprites2.bin, 8KB)
;   Music/SFX:
;     - Music pointer tables: $F200-$F2C3 (data/music-tables.bin, 196 bytes)
;     - Frequency tables: $F39C-$F4BB (data/music-freqs.bin, 288 bytes)
;     - SFX & music data: $F900-$FDFF (data/sfx-music.bin, 1280 bytes)
;
; Converted code modules:
;   bb-sprites-init.s - Sprite management and game initialization ($078C-$08E3)
;   bb-game-loop.s    - Game start sequence and main game loop ($08E4-$0AAA)
;   bb-collision.s    - Collision detection and enemy spawning ($0AAB-$0CF1)
;   bb-enemy-ai.s     - Enemy AI update and movement logic ($0CF2-$10D2)
; ============================================================================

.include "sprites-init.s"
.include "game-loop.s"
.include "collision.s"
.include "enemy-ai.s"
.include "special-enemies.s"
.include "player-sprites.s"
.include "bubbles-sprites.s"
.include "render-screen.s"
.include "level-complete.s"
.include "joystick-input.s"
.include "player-animation.s"
.include "entity-interaction.s"
.include "player-movement.s"
.include "spawn-handlers.s"
.include "item-collision.s"
.include "super-bonus.s"
.include "level-setup.s"
.include "special-item-effects.s"
.include "level-transition.s"
.include "level-start.s"
.include "platform-collision.s"
.include "extend-bonus.s"
.include "bonus-round.s"
.include "bonus-stage-extended.s"
.include "level-display.s"
.include "entity-spawn.s"
.include "screen-scroll.s"
.include "graphics-copy.s"
.include "entity-state-tables.s"
.include "entity-collision.s"
.include "bubble-handler.s"
.include "sprite-init.s"
.include "sprite-helpers.s"

; Code section $4460-$47FF (early initialization and title screen)
.include "game-init-early.s"

; Code section $4800-$4AFF
.include "init-routines.s"
.include "loader.s"

; Game init code
.include "game-init.s"

; ============================================================================
; Code and data includes ($E000-$FFFB)
; ============================================================================

; Level renderer and screen setup
.include "level-renderer.s"

; Sprite display and animation system ($E3A7-$E553, 430 bytes)
.include "sprites-display.s"

; Line drawing and graphics routines ($E554-$E751, 510 bytes)
.include "line-draw.s"

; Sprite composition and masking ($E752-$E9FC, 682 bytes)
.include "sprite-composer.s"

; Entity bubble physics & climbing handler ($E9FD-$EC0B, 527 bytes)
.include "entity-bubble-handler.s"

; Entity movement & direction handler ($EC0C-$EDC6, 443 bytes)
.include "entity-movement.s"

; Entity AI & attack logic ($EDC7-$EFBB, 501 bytes)
.include "entity-ai.s"

; Entity physics continuation & title screen init ($EFBC-$F0ED, 306 bytes)
.include "entity-physics-cont.s"

; Title screen text data ($F0EE-$F1AB, 190 bytes)
.include "title-screen-data.s"

; Credits handler, music tables & level init ($F1AC-$F23F, 148 bytes)
.include "credits-handler-partial.s"

; Music tables ($F240-$F2C3, 132 bytes)
.include "music-tables.s"

; Level data part 2 ($7440-$7FFF, 3008 bytes)
.include "level-data-part2.s"

; Music command handlers ($7305-$743F, 315 bytes)
.include "music-command-handlers.s"

; Music & sound effect data tables
.include "music-sound-data.s"

; Music frequency tables and related code
.include "music-freqs-tables.s"

; Sound engine - SID music and effects system
.include "sound-engine.s"

; Sound Effects and Music Sequence Data
.include "sfx-music-data.s"

; Final data section
.include "final-data.s"

; ============================================================================
; END OF PRG FILE ($FFF8-$FFFA)
; ============================================================================
; These 3 bytes exist in the original PRG file but seem to serve no purpose.
; Included only to produce a byte-identical build for verification.
; ============================================================================
        .segment "FILE_PADDING"
        .byte $29, $00, $FF
