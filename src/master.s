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
ZP_1C       = $1C       ; Background color 1
ZP_1D       = $1D       ; Background color temp 1
ZP_1E       = $1E       ; Background color 2
ZP_1F       = $1F       ; Background color temp 2
ZP_20       = $20       ; Split-screen mode flag
ZP_21       = $21       ; Level complete flag
ZP_2A       = $2A       ; Level timer (seconds)
TXTTAB      = $2B       ; Frame sub-counter  
TXTTAB1     = $2C
VARTAB      = $2D
STREND      = $31       ; String end pointer (BASIC)
FRETOP      = $33       ; Free string space (BASIC)
MEMSIZ      = $37       ; Pause flag
DATLIN      = $3F
DATLIN1     = $40
DATPTR      = $41
DATPTR1     = $42
INPPTR      = $43
ZP_44       = $44
VARNAM      = $45       ; Variable name/temp storage
ZP_46       = $46
ZP_47       = $47
ZP_4A       = $4A       ; Enemies remaining to spawn
OPPTR       = $4B       ; Player index pointer
OPMASK      = $4D
DEFPNT      = $4E       ; Player screen position (low)
FOUR6       = $53       ; Special item type
DSESSION    = $50       ; Player screen position (high)
ZP_52       = $52       ; Player active flags
ZP_5D       = $5D       ; Player 1 bubble timer
ZP_5E       = $5E       ; Player 2 bubble timer
TEMPF2      = $5F       ; Bubble animation
TEMPF1      = $5A       ; Temp storage
RESHO       = $26       ; Random seed storage
FBUFPT      = $71       ; Loader buffer read pointer
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
ENESSION    = $B2       ; Player 1 state
ENESSION1   = $B3       ; Player 2 state  
FA          = $BA       ; Player 1 X position
FA1         = $BB       ; Player 2 X position
ZP_BC       = $BC       ; Viewport X offset
FREKZP      = $FB       ; Temp pointer (used by memory copy routines)
ROESSION    = $BD       ; Super bonus Y position
ZP_BD       = $BD       ; Alias for ROESSION
FSESSION    = $BE       ; Super bonus state
ZP_BE       = $BE       ; Alias for FSESSION
ZP_C2       = $C2       ; Player 1 Y position
ZP_C3       = $C3       ; Player 2 Y position
PESSION     = $CA
LSXP        = $CB       ; Player 2 enemy state
BLNON       = $CC       ; Enemy type array

; --- C64 Hardware ---
R6510       = $01       ; CPU I/O port (memory banking control)
VIC_SPR0_X  = $D000     ; Sprite X positions
VIC_SPR0_Y  = $D001     ; Sprite Y positions
VIC_CTRL1   = $D011     ; VIC control register 1 (screen mode)
VIC_SPR_ENA = $D015     ; Sprite enable register
VIC_CTRL2   = $D016     ; VIC control register 2 (multicolor, etc)
VIC_MEMPTR  = $D018     ; VIC memory pointers (screen/charset location)
VIC_BORDER  = $D020     ; Border color
VIC_BG0     = $D021     ; Background color 0
VIC_BG1     = $D022     ; Background color 1
VIC_BG2     = $D023     ; Background color 2
VIC_SPR0_COL = $D027    ; Sprite colors

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
CIA1_ICR    = $DC0D     ; CIA1 interrupt control register
CIA2_PRA    = $DD00     ; CIA2 port A (VIC bank selection)
CIA2_TALO   = $DD04     ; CIA2 timer A low byte
CIA2_TAHI   = $DD05     ; CIA2 timer A high byte
CIA2_ICR    = $DD0D     ; CIA2 interrupt control register
CIA2_CRA    = $DD0E     ; CIA2 control register A
D_D800      = $D800     ; Color RAM start
D_D801      = $D801     ; Color RAM

; --- KERNAL Vectors ---
CINV        = $0314     ; IRQ vector (low byte at $0314, high at $0315)
NMINV       = $0318     ; NMI vector (low byte at $0318, high at $0319)
D_FEBC      = $FEBC     ; KERNAL IRQ exit routine

; --- Game Data Tables (in RAM, addresses fixed) ---
D_7357      = $7357     ; Data table
D_735A      = $735A     ; Data table
D_7420      = $7420     ; Data table
D_742D      = $742D     ; Data table offset
D_7430      = $7430     ; Data table offset
D_7436      = $7436     ; Data table
D_7437      = $7437     ; Data table
D_A9B1      = $A9B1     ; Hurry-up timer
D_A9B2      = $A9B2     ; Enemy state flags (18 bytes, one per enemy slot)
D_A9C4      = $A9C4     ; Enemy X sub-position (18 bytes)
D_A9D6      = $A9D6     ; Enemy direction flags (18 bytes)
D_A9E8      = $A9E8     ; Enemy AI routine indices (18 bytes)
D_A9FA      = $A9FA     ; Enemy special flags (18 bytes)
D_593F      = $593F     ; Special rendering mode flag
D_58FF      = $58FF     ; Special timer
D_5AFF      = $5AFF     ; Sprites active flag
D_5C3F      = $5C3F
D_5A7F      = $5A7F     ; Game mode flag
D_5B7F      = $5B7F     ; Active sprite mask
D_3F86      = $3F86     ; Bubble character table
D_AB41      = $AB41     ; Entity sprite page table
D_AB49      = $AB49     ; Entity sprite page high table
D_AB51      = $AB51     ; Player score offset table
D_AB52      = $AB52     ; Score value table for pickups
D_AB53      = $AB53     ; Player sprite mask table
D_AB55      = $AB55     ; Sprite enable masks
D_AB5B      = $AB5B     ; Sprite data table
D_AB5F      = $AB5F     ; Sprite routine value table
D_AB81      = $AB81     ; Score value table
D_AC01      = $AC01     ; Flying enemy pathfinding table (low)
D_AC02      = $AC02     ; Flying enemy pathfinding table (high)
D_AC03      = $AC03     ; Screen position table (low bytes)
D_AC04      = $AC04     ; Screen position table (high bytes)
D_ACB6      = $ACB6     ; Enemy animation direction table
D_AD1E      = $AD1E     ; Screen row pointer table (low bytes)
D_AD1F      = $AD1F     ; Screen row pointer table (low bytes, offset by 1)
D_AD20      = $AD20     ; Screen row pointer (offset by 2)
D_AD22      = $AD22     ; Screen row pointer table (low bytes, offset by 4)
D_AD3D      = $AD3D     ; Screen row pointer table (high bytes)
D_AD3E      = $AD3E     ; Screen row pointer table (high bytes, offset by 1)
D_AD3F      = $AD3F     ; Screen row pointer (offset by 2)
D_AD41      = $AD41     ; Screen column data
D_AD5C      = $AD5C     ; Screen column source

; Sprite masking tables
D_8000      = $8000     ; Sprite mask background bits 1
D_8010      = $8010     ; Sprite mask background bits 2
D_8020      = $8020     ; Sprite mask background bits 3
D_8240      = $8240     ; Sprite mask table 1
D_8250      = $8250     ; Sprite mask table 2
D_8260      = $8260     ; Sprite mask table 3

D_854A      = $854A     ; Item timer array
D_8520      = $8520     ; Player mapping table
D_8570      = $8570     ; Data table
D_8610      = $8610     ; Player data array
D_8638      = $8638     ; Player animation timer
D_8688      = $8688     ; Player state flags
D_86D8      = $86D8     ; Player collision data
D_8700      = $8700     ; Player movement data
D_8728      = $8728     ; Player sprite data
D_8729      = $8729     ; Player sprite offset
D_8750      = $8750     ; Player target direction
D_87A0      = $87A0     ; Collision flags array
D_87C8      = $87C8     ; Collision flags array
D_87F0      = $87F0     ; Collision flags array
D_8818      = $8818     ; Animation frame data
D_8868      = $8868     ; Player movement flags
D_863A      = $863A     ; Bubble deactivation flags
D_85C2      = $85C2     ; Bubble collision flags
D_8702      = $8702     ; Special bubble data
D_87A2      = $87A2     ; Collision flags array (alternate)
D_87CA      = $87CA     ; Collision flags array (alternate)
D_87F2      = $87F2     ; Collision flags array (alternate)
D_85E8      = $85E8     ; Joystick port A data
D_85E9      = $85E9     ; Joystick port B data
D_8840      = $8840     ; Saved item types array
D_8842      = $8842     ; Saved item types
D_886A      = $886A     ; Item movement array
D_881A      = $881A     ; Item animation array
SESSION     = $67       ; Animation active flag
CURLIN      = $39       ; Temp storage for column
CURLIN1     = $3A       ; Temp storage for X position
MEMSIZ1     = $38       ; Animation timer storage
FNADR       = $BB       ; Bubble X position
TAPE1       = $C3       ; Bubble Y position

; --- Spawn Point Data ---
D_850A      = $850A     ; Spawn point 0 availability (top left)
D_8514      = $8514     ; Spawn point 1 availability (top right)
D_88CA      = $88CA     ; Spawn point 2 availability (bottom left)
D_88D4      = $88D4     ; Spawn point 3 availability (bottom right)
D_5BFF      = $5BFF     ; Enemy type seed
D_5BBF      = $5BBF     ; Special item countdown
D_597F      = $597F     ; Frame counter
D_872A      = $872A     ; Special sprite flags
D_8892      = $8892     ; Item counter array
D_0193      = $0193     ; Player-captured-by flags (18 bytes)
D_0181      = $0181     ; Enemy row positions (18 bytes)
D_015D      = $015D     ; Enemy column positions (18 bytes)
D_A756      = $A756     ; Item Y positions (11 bytes)
D_A74B      = $A74B     ; Item X positions (11 bytes)
D_A74C      = $A74C     ; Item X positions (offset by 1)
D_A754      = $A754     ; Item position data
D_A755      = $A755     ; Item movement direction
D_A757      = $A757     ; Item Y positions (offset by 1)
D_A75F      = $A75F     ; Item data
D_A760      = $A760     ; Item data
D_A82E      = $A82E     ; Item offsets table
D_A5B8      = $A5B8     ; Super bonus capture flag
D_2922      = $2922     ; Joystick data storage
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
D_119F      = $119F     ; Saved game state
D_A761      = $A761     ; Player sprite column positions (5 bytes)
D_A766      = $A766     ; Player sprite row positions (5 bytes)
D_A76B      = $A76B     ; Player sprite data indices (5 bytes)
D_A770      = $A770     ; Player sprite active flags (5 bytes)
D_A735      = $A735     ; Respawn X positions
D_A737      = $A737     ; Death animation frames
D_A775      = $A775     ; Animation timer array
D_A813      = $A813     ; Spawn data table
D_A826      = $A826     ; Sprite data table
D_A82A      = $A82A     ; Sprite data table (offset +4)
D_ACBD      = $ACBD     ; Sprite character data table
D_8548      = $8548     ; Sprite colors
D_859A      = $859A     ; Sprite character data
D_8598      = $8598     ; Sprite base pointers
D_53F8      = $53F8     ; Screen 1 sprite pointers
D_57F8      = $57F8     ; Screen 2 sprite pointers
D_8890      = $8890     ; Target Y positions
D_85C0      = $85C0     ; Fall counter
D_3AB8      = $3AB8     ; Hurry-up handler
D_045C      = $045C     ; Check player state routine
D_47F8      = $47F8     ; Item table 1
D_4FF8      = $4FF8     ; Item table 2
D_58BF      = $58BF     ; Global level flag
D_7BA6      = $7BA6     ; Screen setup routine
D_7BC8      = $7BC8     ; Wait routine with delay
D_7D00      = $7D00     ; Level data destination
D_A854      = $A854     ; Level data source
D_4300      = $4300     ; Enemy template data table 1 (RAM copy)
D_4400      = $4400     ; Enemy template data table 2 (RAM copy)
D_4460      = $4460     ; Main game code entry point
D_4500      = $4500     ; Enemy template data table 3 (RAM copy)
D_4600      = $4600     ; Platform Y position table / Enemy template data table 4
D_4E00      = $4E00     ; Platform screen address low
D_4F00      = $4F00     ; Platform screen address high
D_5053      = $5053     ; Screen memory area 1
D_525B      = $525B     ; Screen memory area 2
D_A63C      = $A63C     ; Temp storage (Y register)
D_A63D      = $A63D     ; Temp storage (X register)
D_D853      = $D853     ; Color RAM area 1
D_DA5B      = $DA5B     ; Color RAM area 2
D_A7E2      = $A7E2     ; Sprite data storage
D_A7EE      = $A7EE     ; Sprite data pointer
D_A7F0      = $A7F0     ; Bonus display character 1
D_A7F1      = $A7F1     ; Bonus display character 2
D_A7F7      = $A7F7     ; Player display offset table
D_E42A      = $E42A     ; Sprite/entity update routine
D_E494      = $E494     ; Wait one frame
D_E49B      = $E49B     ; Game loop continuation
ARYTAB      = $2F       ; Screen pointer
EVAL        = $A7E4     ; Sprite data pointer
INPFLG      = $11       ; Input flag
TANSGN      = $12       ; Cell pointer high byte

; --- Zero Page Variables ---
ZP_23       = $23       ; Level/world index
ZP_25       = $25       ; Player Y position / level index
INDEX1      = $22       ; Player loop counter
OLDLIN      = $3B       ; Temp storage in collision detection
OLDTXT      = $3D       ; Temp storage
ZP_3E       = $3E       ; Temp storage
ADRAY1      = $03       ; Address high byte (used in level complete)
ADRAY2      = $05       ; Address high byte alternate
CHARONE     = $07       ; Character/color pointer

; --- Forward References (subroutines defined later in file) ---
; These are in the [BYTES] section but we call them from [CODE] sections
entry_0400  = $0400     ; Game variable area (used by special enemies)
L_0D4A      = $0D4A     ; Enemy AI loop continuation
D_105B      = $105B     ; Check bubble collision
D_1677      = $1677     ; Skip timer continuation (in .byte section)
D_16E4      = $16E4     ; Continue game routine
D_16EF      = $16EF     ; Continue flag
D_1805      = $1805     ; Update player sprite positions
D_18D6      = $18D6     ; Self-modifying code storage
D_18D8      = $18D8     ; Self-modifying code storage
D_18DF      = $18DF     ; Self-modifying code storage
D_1929      = $1929     ; Self-modifying code storage
D_1CA0      = $1CA0     ; Player falling handler (in bb-level-complete.s)
; D_2162 defined in bb-entity-interaction.s
; D_2985 defined in bb-spawn-handlers.s
D_2020      = $2020     ; Unknown routine
D_30A9      = $30A9     ; Data table (possibly invalid address)
D_53E4      = $53E4     ; Data/routine location
D_57E4      = $57E4     ; Data/routine location
D_3EF3      = $3EF3     ; Sprite init continuation (in bb-sprite-init.s)
D_42C6      = $42C6     ; Data/flag location
D_6085      = $6085     ; Handler routine
D_C2B5      = $C2B5     ; Handler routine
D_ACDD      = $ACDD     ; Movement table
D_ACED      = $ACED     ; Jump table
L_EB0F      = $EB0F     ; Default state handler
D_EB34      = $EB34     ; Alternate state handler
D_EBB8      = $EBB8     ; Jump state handler
D_ED12      = $ED12     ; Handle right input
D_ED18      = $ED18     ; Handle left input
D_EE4A      = $EE4A     ; State handler
D_EE62      = $EE62     ; Jump handler
D_EFEA      = $EFEA     ; Freed state handler
INDEX2      = $24       ; Terrain index
D_7BB3      = $7BB3     ; Bank RAM under I/O
D_7BC3      = $7BC3     ; Wait for frame sync
D_7BE8      = $7BE8     ; Game over sequence
D_7BFE      = $7BFE     ; Terrain check routine
D_7C21      = $7C21     ; Collision handler routine
D_7C26      = $7C26     ; Add score routine
D_7E80      = $7E80     ; Unknown routine (called from platform collision)
D_7F53      = $7F53     ; Player death handler
D_E3A7      = $E3A7     ; Update sprite data
D_E758      = $E758     ; Entity cleanup routine
D_E7CF      = $E7CF     ; Sprite display routine
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
D_E90E      = $E90E     ; Update game state
D_E968      = $E968     ; Entity processing continuation
D_E97A      = $E97A     ; Entity handler continuation
D_E9B8      = $E9B8     ; Get sprite animation frame
D_E9EA      = $E9EA     ; Random number generator (RNG)
D_E966      = $E966     ; Self-modifying: sprite frame offset
D_E96F      = $E96F     ; Entity loop continuation
D_E6CD      = $E6CD     ; State change handler
D_EB3F      = $EB3F     ; Falling through floor handler
D_8778      = $8778     ; Animation frame mask array
D_EB94      = $EB94     ; Self-modifying: jump instruction
D_EBB5      = $EBB5     ; Self-modifying: jump target low
D_EBB6      = $EBB6     ; Self-modifying: jump target high
D_EBC4      = $EBC4     ; Reset velocities handler
D_EBD9      = $EBD9     ; Platform physics handler
D_ECDF      = $ECDF     ; Movement handler bit 0
D_ED1E      = $ED1E     ; Movement handler bit 1
D_ED3B      = $ED3B     ; Normal entity handler
D_EDCD      = $EDCD     ; Update entity position
D_EC87      = $EC87     ; Continue processing after descent
L_EC0C      = $EC0C     ; Next section continuation
D_EC2C      = $EC2C     ; Alternate movement table load
D_EC3C      = $EC3C     ; Platform collision check after climb
D_EC7C      = $EC7C     ; Exit climbing state
D_A9C6      = $A9C6     ; Projectile state array 1
D_A9D8      = $A9D8     ; Projectile state array 2
L_EDC7      = $EDC7     ; Abort spawn / return point
D_EEB4      = $EEB4     ; Entity movement handler
D_EEDF      = $EEDF     ; Leftward movement handler
D_EEEB      = $EEEB     ; Check platforms for left movement
D_EF15      = $EF15     ; Self-modified RTS
D_EF1E      = $EF1E     ; Rightward movement handler
D_EF3B      = $EF3B     ; Right movement platform check
D_EF4C      = $EF4C     ; Inverted vertical movement
D_EFA0      = $EFA0     ; Normal vertical movement
D_EEC8      = $EEC8     ; Position update after movement
L_EE49      = $EE49     ; Exit point for attack logic
D_A9FC      = $A9FC     ; Projectile state array 3
D_88C1      = $88C1     ; Screen wrap permission table (top)
D_8501      = $8501     ; Screen wrap permission table (bottom)
D_8660      = $8660     ; Direction change timer
D_86B0      = $86B0     ; Current direction index
D_4985      = $4985     ; Unknown routine
L_EFBC      = $EFBC     ; Next section start (platform check)
D_E3D9      = $E3D9     ; Display text line routine
D_7EB3      = $7EB3     ; Read joystick/keyboard input
D_0409      = $0409     ; Score/stat value array
D_57D4      = $57D4     ; Game state storage
D_8572      = $8572     ; Game state flag
D_A632      = $A632     ; Sprite Y position table
D_A634      = $A634     ; Pointer table (high bytes)
D_A637      = $A637     ; Pointer table (low bytes)
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
L_F201      = $F201     ; Music selection
L_F20A      = $F20A     ; Credits handler return
; D_F20B, D_F211, D_F217 are now defined in credits-handler-partial.s
D_F256      = $F256     ; Music data (in music-tables.bin)
D_F2AE      = $F2AE     ; Music data (in music-tables.bin)
D_F3B9      = $F3B9     ; Frequency data (in music-freqs.bin)
D_F418      = $F418     ; Frequency data (in music-freqs.bin)
D_4CF3      = $4CF3     ; External routine (called from sound engine)
L_F846      = $F846     ; Forward reference within sound code flow
D_F4BD      = $F4BD     ; Sound init routine
D_F53C      = $F53C     ; Sound update routine (called every frame)
D_F887      = $F887     ; Music/mode initialization routine
ESSION      = $B2       ; Player state variable

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
D_A77B      = $A77B     ; Entity attribute table
D_A77D      = $A77D     ; Entity attribute table
D_A77F      = $A77F     ; Entity attribute table
D_A781      = $A781     ; Entity attribute table
D_A824      = $A824     ; Entity state table
D_ACC4      = $ACC4     ; Direction table
D_ACCB      = $ACCB     ; Direction storage
D_ACCD      = $ACCD     ; Fall speed table
D_DE85      = $DE85     ; Animation update routine
FAC         = $61       ; Floating point accumulator (used as temp)

; --- Player Movement Forward References ---
; D_272F, D_273D, D_2782 are defined in bb-player-movement.s
; D_1A6F is defined in bb-render-screen.s
; D_1E87 is defined in bb-player-animation.s
; D_1E2E is defined in bb-joystick-input.s
D_277F      = $277F     ; Temp storage
D_AB89      = $AB89     ; Animation offset table

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
D_ABA5      = $ABA5     ; Loader completion check
D_C085      = $C085     ; Far routine
D_C6D0      = $C6D0     ; Loader callback routine
D_A790      = $A790     ; Enemy type table
D_A892      = $A892     ; Enemy attribute table
D_A8E4      = $A8E4     ; Enemy color table
D_A79A      = $A79A     ; Item score value table

; --- Item Collision Forward References ---
; D_29BC, D_29C0 are defined in bb-item-collision.s

; --- Super Bonus Forward References ---
; D_2A3F, D_2AA2 are defined in bb-super-bonus.s
L_069B      = $069B     ; Clear entities routine
D_4700      = $4700     ; Special item type data
D_4710      = $4710     ; Special item X positions
D_4720      = $4720     ; Special item Y positions
D_4730      = $4730     ; Special item attributes
D_A7B0      = $A7B0     ; Super bonus X positions (normal)
D_A7B6      = $A7B6     ; Super bonus Y positions (normal)
D_A7BC      = $A7BC     ; Super bonus X positions (expanded)
D_A7C2      = $A7C2     ; Super bonus Y positions (expanded)
D_8522      = $8522     ; Item index storage
ARG         = $69       ; Score value storage
VIC_SPR_YEXP = $D017    ; VIC sprite Y expansion register
VIC_SPR_XEXP = $D01D    ; VIC sprite X expansion register

; --- Level Setup Forward References ---
; D_2B31, D_2BBD, D_2C32, D_2C8C, D_2C9F, D_2CB7 are defined in bb-level-setup.s
D_B569      = $B569     ; Level scroll/wrap attributes (100 bytes)
D_B5CD      = $B5CD     ; Level tileset pointer low (100 bytes)
D_B631      = $B631     ; Level tileset pointer high (100 bytes)
D_AC09      = $AC09     ; Data pointer table low
D_AC0A      = $AC0A     ; Data pointer table high
D_5B3F      = $5B3F     ; Level progression counter
D_A913      = $A913     ; Special item color table
D_A8C1      = $A8C1     ; Special item data index
D_4210      = $4210     ; Item work buffer 1
D_4230      = $4230     ; Item work buffer 2
D_4A10      = $4A10     ; Item work buffer 3
D_4A30      = $4A30     ; Item work buffer 4
D_0A39      = $0A39     ; Bonus level data
D_0A3A      = $0A3A     ; Bonus level data
D_7F83      = $7F83     ; Bonus level handler
D_A936      = $A936     ; Enemy score value table
D_A965      = $A965     ; Special item score value table
D_7C3C      = $7C3C     ; Bonus level score handler

; --- Special Item Effects Forward References ---
; D_2D65, D_2D88, D_2DAB, D_2DB2, D_2DAC are defined in bb-special-item-effects.s
; D_2F5F, D_2F62, D_2F65 are defined in bb-level-transition.s

; --- Level Start Forward References ---
; D_2FAC, D_3080, D_311E, D_312E are defined in bb-level-start.s

; --- Platform Collision Forward References ---
; D_3169, D_3193, D_31A2, D_3266, D_3293 are defined in bb-platform-collision.s

; --- EXTEND Bonus Forward References ---
; D_32C1, D_3421, D_344A are defined in bb-extend-bonus.s
D_4080      = $4080     ; Memory region cleared during bonus stage

; --- Bonus Round Forward References ---
; D_348A, D_3495, D_34A0, D_34FA, D_3502, D_350A, D_350C, D_3517, D_35A8 are defined in bb-bonus-round.s
D_2AE9      = $2AE9     ; Configuration byte storage
D_40A8      = $40A8     ; Final level layout data
D_5ABF      = $5ABF     ; Countdown timer 2
D_7D37      = $7D37     ; Special data area 1 (8 bytes)
D_7D76      = $7D76     ; Special data area 2 (8 bytes)
D_A420      = $A420     ; Additional data table (8 bytes)
D_A814      = $A814     ; Spawn data table + 1
D_A815      = $A815     ; Level data pointer table (low bytes)
D_A81A      = $A81A     ; Level data pointer table (high bytes)
D_A81F      = $A81F     ; Configuration table for bonus stages

; --- Bonus Stage Extended Forward References ---
; D_35B0, D_35C0, D_3621, D_362F, D_370C, D_3771, D_3794 are defined in bb-bonus-stage-extended.s
D_37C9      = $37C9     ; Routine defined later (after $37C6)
D_392A      = $392A     ; Routine defined later (after this module)
D_4050      = $4050     ; Entity/item data array
D_40D0      = $40D0     ; Level number display buffer (6 bytes)
D_40D6      = $40D6     ; Level display data
D_40D7      = $40D7     ; Level display data
D_40D8      = $40D8     ; Level display data (ones digit)
D_40DE      = $40DE     ; Level display data
D_40DF      = $40DF     ; Level display data
D_4880      = $4880     ; Level layout buffer 2
D_5000      = $5000     ; Screen pointer storage
D_5001      = $5001     ; Screen pointer storage
D_501E      = $501E     ; Level position data
D_501F      = $501F     ; Level position data
D_5050      = $5050     ; Level data value
D_5398      = $5398     ; Source tile table
D_53C0      = $53C0     ; Screen buffer destination
D_53C1      = $53C1     ; Screen buffer destination
D_53DE      = $53DE     ; Screen buffer alternate
D_53DF      = $53DF     ; Screen buffer alternate
D_A83C      = $A83C     ; Digit graphics pointer table (low bytes)
D_A848      = $A848     ; Digit graphics pointer table (high bytes)
D_A9AE      = $A9AE     ; Level tens digit storage
D_A9AF      = $A9AF     ; Level ones digit storage
D_43B0      = $43B0     ; Data table 1
D_43B8      = $43B8     ; Data table 2
D_43C0      = $43C0     ; Data table 3
D_4850      = $4850     ; Temporary item data storage
D_52AA      = $52AA     ; Screen line pointer array 1
D_52D2      = $52D2     ; Screen line pointer array 2
D_52FA      = $52FA     ; Screen line pointer array 3
D_5322      = $5322     ; Screen line pointer array 4
D_534A      = $534A     ; Screen line pointer array 5
D_7D3E      = $7D3E     ; Screen buffer 1 offset $3E
D_7DBC      = $7DBC     ; Screen buffer 1 offset $BC
D_7DC2      = $7DC2     ; Screen buffer 1 offset $C2
D_7E40      = $7E40     ; Screen buffer 2 offset $40
D_859B      = $859B     ; Sprite Y position array
D_8C00      = $8C00     ; Level layout data
D_A660      = $A660     ; Level data source table
D_A710      = $A710     ; Position table 1
D_A722      = $A722     ; Position table 2
D_A877      = $A877     ; Screen data source table
D_E09B      = $E09B     ; Engine routine
D_E189      = $E189     ; Engine routine
D_E2C3      = $E2C3     ; Engine routine with pointer
D_E740      = $E740     ; Engine routine
D_F192      = $F192     ; Level data index table
D_F19F      = $F19F     ; Level data value table

D_9AE0      = $9AE0     ; Enemy template ROM table 1
D_9BE0      = $9BE0     ; Enemy template ROM table 2
D_9CE0      = $9CE0     ; Enemy template ROM table 3
D_9DE0      = $9DE0     ; Enemy template ROM table 4
D_9EE0      = $9EE0     ; Enemy template ROM table 5
D_A804      = $A804     ; Player bonus data location
D_A80D      = $A80D     ; "EXTEND" character table
D_A988      = $A988     ; Enemy state temporary storage
D_E374      = $E374     ; Unknown routine
D_E658      = $E658     ; Unknown routine
D_7B53      = $7B53     ; Unknown routine
D_7BC6      = $7BC6     ; Wait for frame variant
L_A474      = $A474     ; READY label
D_8CA9      = $8CA9     ; Item setup routine

; ============================================================================
; CODE START - $0400
; ============================================================================
.segment "CODE"
.org $0400

; ============================================================================
; [DATA] GAME VARIABLES ($0400-$045B)
; ============================================================================
; Score storage, lives, game state. Keep as bytes.

game_variables:
        .byte   $00,$00,$00,$00,$00,$00,$00,$20  ; $0400 - Score area  
        .byte   $00,$00,$00,$13,$79,$E7,$79,$E7  ; $0408
        .byte   $79,$E7,$79,$E7,$79,$E7,$79,$E7  ; $0410
        .byte   $79,$E7,$79,$E7,$79,$E7,$79,$E7  ; $0418
        .byte   $79,$E7,$D4,$7B,$B2,$3C,$B2,$3C  ; $0420
        .byte   $B2,$3C,$B2,$3C,$B2,$3C,$B2,$3C  ; $0428
        .byte   $58,$E7,$94,$3E,$FD,$3E,$52,$E7  ; $0430
        .byte   $D4,$3E,$67,$E7,$67,$E7,$77,$3E  ; $0438
        .byte   $2D,$3D,$DB,$7B,$A9,$3D,$77,$3D  ; $0440
        .byte   $D3,$3C,$DB,$3C,$DF,$3C,$68,$E9  ; $0448
        .byte   $FD,$3E,$28,$3F,$68,$E9,$68,$E9  ; $0450
        .byte   $88,$3F                          ; $0458 (2 bytes, rest is lives)

; Lives counter - EASILY MODDABLE!
D_045A:
lives_p1:   .byte   $00                          ; $045A - Player 1 lives
lives_p2:   .byte   $00                          ; $045B - Player 2 lives

; ============================================================================
; [CODE] CHECK_PLAYER_STATE ($045C)
; ============================================================================
; Checks player states, handles death and respawn.
; 
; MODIFICATION POINTS:
; - For infinite lives: change "dec D_045A,x" to NOPs
; - For more starting lives: modify check_join_game

; .org $045C (removed - should be contiguous)
check_player_state:
        ldx     #$01                ; a2 01 - Start with player 2
        ldy     #$00                ; a0 00
L_0460:
        lda     ENESSION,x          ; b5 b2 - Get player state
        cmp     #$0F                ; c9 0f - Dying?
        beq     L_04A0              ; f0 3a - Yes, handle death
L_0466:
        dex                         ; ca
        bpl     L_0460              ; 10 f7
        tya                         ; 98
        bpl     L_049D              ; 10 31
L_046C:
D_046C = L_046C                     ; Alias for external references
        lda     #$51                ; a9 51
        ldy     #$39                ; a0 39
        ldx     #$00                ; a2 00
        jsr     D_047B              ; 20 7b 04
        lda     #$52                ; a9 52
        ldy     #$51                ; a0 51
        ldx     #$01                ; a2 01
D_047B:
        sty     DATLIN1             ; 84 40
        sty     DATPTR1             ; 84 42
        sta     DATPTR              ; 85 41
        ora     #$04                ; 09 04
        sta     INPPTR              ; 85 43
        lda     D_045A,x            ; bd 5a 04
        bmi     L_049D              ; 30 13
        tax                         ; aa
        ldy     #$06                ; a0 06
L_048D:
        lda     #$20                ; a9 20
        cpx     #$00                ; e0 00
        beq     L_0496              ; f0 03
        lda     #$1D                ; a9 1d
        dex                         ; ca
L_0496:
        sta     (DATLIN1),y         ; 91 40
        sta     (DATPTR1),y         ; 91 42
        dey                         ; 88
        bpl     L_048D              ; 10 f0
L_049D:
        jmp     check_join_game     ; 4c 2a 05

L_04A0:
        jsr     D_7F53              ; 20 53 7f
        lda     D_5C3F              ; ad 3f 5c
        cmp     #$20                ; c9 20
        bcc     L_04BB              ; 90 11
        cmp     #$4A                ; c9 4a
        beq     L_04BB              ; f0 0d
        stx     DATLIN1             ; 86 40
        sty     DATPTR              ; 84 41
        ldy     #$0B                ; a0 0b
        jsr     D_05AD              ; 20 ad 05
        ldx     DATLIN1             ; a6 40
        ldy     DATPTR              ; a4 41
L_04BB:
        lda     D_AB53,x            ; bd 53 ab
        eor     #$FF                ; 49 ff
        and     D_5B7F              ; 2d 7f 5b
        sta     D_5B7F              ; 8d 7f 5b
        lda     D_A737,x            ; bd 37 a7
        sta     D_8520,x            ; 9d 20 85
        lda     #$FF                ; a9 ff
        sta     D_87A0,x            ; 9d a0 87
        sta     D_87C8,x            ; 9d c8 87
        sta     D_87F0,x            ; 9d f0 87
        dey                         ; 88
        
; ============================================================================
; *** LIVES DECREMENT - PATCH POINT ***
; Change these 3 bytes to EA EA EA (NOP) for infinite lives
; ============================================================================
lives_decrement:
        dec     D_045A,x            ; de 5a 04 - DECREMENT LIVES
        
        bmi     L_04F0              ; 30 13 - Game over if negative
        lda     #$DD                ; a9 dd
        sta     ZP_C2,x             ; 95 c2
        lda     D_A735,x            ; bd 35 a7
        sta     FA,x                ; 95 ba
        lda     #$4A                ; a9 4a - 74 frames invincibility
        sta     D_8688,x            ; 9d 88 86
        lda     D_5A7F              ; ad 7f 5a
        bne     L_0502              ; d0 12
L_04F0:
        sty     DATPTR              ; 84 41
        lda     SUBFLG              ; a5 10
        sta     $0409,x             ; 9d 09 04
        jsr     D_7BE8              ; 20 e8 7b
        ldy     DATPTR              ; a4 41
        lda     #$00                ; a9 00
        sta     FA,x                ; 95 ba
D_0500:
        sta     ZP_C2,x             ; 95 c2
L_0502:
        sta     ENESSION,x          ; 95 b2
        lda     TXTTAB              ; a5 2b
        bmi     L_0514              ; 30 0c
        lda     VARTAB              ; a5 2d
        bmi     L_0514              ; 30 08
        lda     #$00                ; a9 00
        sta     VARTAB              ; 85 2d
        lda     TXTTAB1             ; a5 2c
D_0512:
        sta     ZP_2A               ; 85 2a
L_0514:
        lda     ZP_4A               ; a5 4a
        cmp     #$02                ; c9 02
        bcc     L_0527              ; 90 0d
        stx     DATLIN1             ; 86 40
        inc     D_16EF              ; ee ef 16
D_051F:
        jsr     D_16E4              ; 20 e4 16
        dec     D_16EF              ; ce ef 16
        ldx     DATLIN1             ; a6 40
L_0527:
        jmp     L_0466              ; 4c 66 04

; ============================================================================
; [CODE] CHECK_JOIN_GAME ($052A)  
; ============================================================================
; Checks if inactive player presses fire to join.
;
; MODIFICATION POINTS:
; - Starting lives: change "lda #$04" to desired value

; .org $052A (removed - should be contiguous)
check_join_game:
        ldx     #$01                ; a2 01
L_052C:
        lda     ENESSION,x          ; b5 b2
        bne     L_05A6              ; d0 76
        lda     CIA1_PRA,x          ; bd 00 dc - Read joystick
        and     #$10                ; 29 10    - Fire button
        bne     L_05A6              ; d0 6f    - Not pressed

; ============================================================================
; *** STARTING LIVES - PATCH POINT ***
; Change $04 to desired starting lives (e.g., $09 for 9 lives)
; ============================================================================
starting_lives:
        lda     #$04                ; a9 04 - 4 STARTING LIVES
        
        sta     D_045A,x            ; 9d 5a 04
        lda     #$0F                ; a9 0f
        sta     ENESSION,x          ; 95 b2
D_0540:
        lda     #$00                ; a9 00
        ldy     D_AB51,x            ; bc 51 ab
        sta     $0400,y             ; 99 00 04
        dey                         ; 88
        sta     $0400,y             ; 99 00 04
        dey                         ; 88
        sta     $0400,y             ; 99 00 04
        sta     RIDBS,x             ; 95 ac
        iny                         ; c8
        tya                         ; 98
        sta     RODBE,x             ; 95 ae
        dec     D_53E4              ; ce e4 53
        dec     D_57E4              ; ce e4 57
        dec     RIDBE               ; c6 ab
        bpl     L_0565              ; 10 05
        lda     #$60                ; a9 60
        sta     L_049D              ; 8d 9d 04
L_0565:
        lda     #$E9                ; a9 e9
        ldy     #$50                ; a0 50
        cpx     #$01                ; e0 01
        bne     L_0571              ; d0 04
        lda     #$01                ; a9 01
        iny                         ; c8
        iny                         ; c8
L_0571:
        sta     ZP_02               ; 85 02
        sty     ZP_03               ; 84 03
        sta     ZP_04               ; 85 04
        sta     ZP_06               ; 85 06
        tya                         ; 98
        ora     #$04                ; 09 04
        sta     ZP_05               ; 85 05
        eor     #$8C                ; 49 8c
D_0580:
        sta     ZP_07               ; 85 07
        ldy     #$06                ; a0 06
L_0584:
        tya                         ; 98
        clc                         ; 18
        adc     #$50                ; 69 50
        tay                         ; a8
        lda     #$20                ; a9 20
        sta     (ZP_02),y           ; 91 02
        sta     (ZP_04),y           ; 91 04
        lda     D_8570,x            ; bd 70 85
        sta     (ZP_06),y           ; 91 06
        tya                         ; 98
        clc                         ; 18
        adc     #$28                ; 69 28
        tay                         ; a8
        lda     #$20                ; a9 20
        sta     (ZP_02),y           ; 91 02
        sta     (ZP_04),y           ; 91 04
        tya                         ; 98
D_05A0:
        sec                         ; 38
        sbc     #$79                ; e9 79
        tay                         ; a8
        bpl     L_0584              ; 10 de
L_05A6:
        dex                         ; ca
        bmi     L_05AC              ; 30 03
        jmp     L_052C              ; 4c 2c 05
L_05AC:
        rts                         ; 60

; ============================================================================
; [BYTES] Remaining code from $05AD onwards
; ============================================================================
; These sections contain game logic as raw bytes.
; See the converted .s files for documented examples of game routines.

; .org $05AD (removed - should be contiguous)
D_05AD:
        .byte   $20,$94,$E4,$8C,$3F,$5C,$20,$77  ; $05AD
        .byte   $F4,$4C,$3C,$F5                  ; $05B5
D_05B9:
        .byte   $30,$01,$04,$10  ; $05B9
        .byte   $20,$30,$40,$50,$60,$70,$80,$90  ; $05BD
D_05C5:
        .byte   $A2,$03,$8E,$49,$85,$E8,$8E,$21  ; $05C5
        .byte   $85,$E8,$8E,$48,$85,$AD,$29,$87  ; $05CD
        .byte   $48,$AD,$28,$87,$48,$A0,$0B,$A5  ; $05D5
        .byte   $10,$C9,$63,$D0,$03,$A0,$12,$2C  ; $05DD
        .byte   $AD,$3F,$5C,$C9,$12,$90,$07,$C9  ; $05E5
        .byte   $4A,$F0,$03,$20,$AD,$05,$A2,$07  ; $05ED
        .byte   $A9,$FF,$9D,$A0,$87,$9D,$C8,$87  ; $05F5
        .byte   $9D,$F0,$87,$9D,$18,$88,$A9,$00  ; $05FD
        .byte   $9D,$D8,$86,$9D,$00,$87,$9D,$28  ; $0605
        .byte   $87,$8A,$9D,$B0,$86,$CA,$10,$E0  ; $060D
        .byte   $68,$8D,$28,$87,$68,$8D,$29,$87  ; $0615
        .byte   $8A,$A2,$11,$95,$CA,$CA,$10,$FB  ; $061D
        .byte   $20,$A6,$7B,$8A,$A2,$23,$95,$DC  ; $0625
        .byte   $CA,$10,$FB,$8D,$20,$85,$85,$21  ; $062D
        .byte   $85,$46,$85,$47,$8D,$FF,$58,$8D  ; $0635
        .byte   $3F,$59,$8D,$BF,$58,$85,$67,$85  ; $063D
        .byte   $68,$85,$69,$85,$B1,$85,$B0,$A2  ; $0645
        .byte   $48,$9D,$5D,$01,$CA,$10,$FA,$A2  ; $064D
        .byte   $05,$95,$61,$CA,$10,$FB,$8E,$83  ; $0655
        .byte   $A7,$8E,$84,$A7,$8E,$15,$D0,$86  ; $065D
        .byte   $6A,$A9,$10,$8D,$7F,$5A,$A9,$0A  ; $0665
        .byte   $8D,$BF,$5A,$20,$17,$F2,$AD,$BF  ; $066D
        .byte   $59,$C5,$10,$D0,$18,$6D,$FF,$59  ; $0675
        .byte   $8D,$BF,$59,$EE,$FF,$59,$A5,$10  ; $067D
        .byte   $0A,$69,$09,$C9,$2F,$90,$04,$E9  ; $0685
        .byte   $2E,$D0,$F8,$85,$68,$A5,$10,$C9  ; $068D
        .byte   $63,$D0,$03,$4C,$E3,$7A,$A2,$00  ; $0695
        .byte   $8A,$9D,$00,$7D,$9D,$80,$7D,$9D  ; $069D
        .byte   $00,$7E,$E8,$10,$F4,$60          ; $06A5

; ============================================================================
; [CODE] IRQ_FRAME_UPDATE ($06AB) - Raster IRQ handler
; ============================================================================

; .org $06AB (removed - should be contiguous)
irq_frame_update:
        jsr     D_7BB3              ; 20 b3 7b - Bank in RAM
        lda     TXTTAB              ; a5 2b
        bmi     L_06CA              ; 30 18
        dec     TXTTAB              ; c6 2b
        bne     L_06CA              ; d0 14
        lda     #$32                ; a9 32 - 50 frames = 1 second
        sta     TXTTAB              ; 85 2b
        dec     ZP_2A               ; c6 2a
        lda     D_A9B1              ; ad b1 a9
        beq     L_06C6              ; f0 05
        bmi     L_06C6              ; 30 03
        dec     D_A9B1              ; ce b1 a9
L_06C6:
        dec     ZP_5D               ; c6 5d
        dec     ZP_5E               ; c6 5e
L_06CA:
        inc     ENDCHR              ; e6 08 - Frame counter++
        lda     #$4C                ; a9 4c - JMP opcode
        sta     D_077C              ; 8d 7c 07
        sta     D_0768              ; 8d 68 07
        sta     D_0786              ; 8d 86 07
        lda     MEMSIZ              ; a5 37 - Pause flag
        beq     L_06F0              ; f0 15 - Skip if paused

frame_skip_check:
        lda     ENDCHR              ; a5 08
        and     #$01                ; 29 01 - Check odd/even frame
        beq     L_06F0              ; f0 0f - Skip on even frames
        
        jsr     D_1805              ; 20 05 18
        lda     #$2C                ; a9 2c
        sta     D_077C              ; 8d 7c 07
        lda     OPMASK              ; a5 4d
        beq     L_06F0              ; f0 03
        jsr     D_1B40              ; 20 40 1b
L_06F0:
        jsr     D_F53C              ; 20 3c f5 - Update music
        lda     D_5AFF              ; ad ff 5a
        beq     L_0703              ; f0 0b
        jsr     D_07E1              ; 20 e1 07
        lda     #$2C                ; a9 2c
        sta     D_0768              ; 8d 68 07
        sta     D_0786              ; 8d 86 07
L_0703:
        lda     ZP_1C               ; a5 1c
        sta     VIC_BG1             ; 8d 22 d0
        lda     ZP_1E               ; a5 1e
        sta     VIC_BG2             ; 8d 23 d0

; Continue with remaining bytes...
        .byte   $A2,$2E,$A0,$07,$A5,$20,$D0,$02  ; $070D
        .byte   $A9,$32,$8D,$12,$D0,$8E,$FE,$FF  ; $0715
        .byte   $8C,$FF,$FF,$CE,$19,$D0,$A5,$2E  ; $071D
        .byte   $85,$01,$A4,$17,$A6,$16,$A5,$15  ; $0725
        .byte   $40,$20,$B3,$7B,$A5,$20,$F0,$26  ; $072D
        .byte   $A5,$1D,$8D,$22,$D0,$A5,$1F,$8D  ; $0735
        .byte   $23,$D0,$A9,$07,$AA,$25,$08,$D0  ; $073D
        .byte   $46,$BD,$F8,$53,$C9,$D5,$B0,$04  ; $0745
        .byte   $69,$04,$D0,$02,$E9,$04,$9D,$F8  ; $074D
        .byte   $53,$CA,$10,$ED,$30,$31,$A9,$52  ; $0755
        .byte   $A6,$2F,$E0,$48,$D0,$02,$A9,$40  ; $075D
        .byte   $8D,$18,$D0                      ; $0765
D_0768:
        .byte   $4C,$7C,$07,$A9,$95  ; $0768
        .byte   $8D,$FE,$FF,$A9,$07,$8D,$FF,$FF  ; $076D
        .byte   $A5,$BD,$69,$1E,$8D,$12,$D0      ; $0775 (7 bytes)
D_077C:
        .byte   $4C                              ; $077C
        .byte   $86,$07,$CE,$19,$D0,$58,$20,$BD  ; $077D
        .byte   $1C                              ; $0785
D_0786:
        .byte   $4C,$8C,$07,$4C,$20,$07          ; $0786

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

; Character set data ($4000-$47FF, 2048 bytes)
.incbin "../data/charset.bin"

.include "init-routines.s"
.include "loader.s"

; Graphics data ($4B00-$57FF, 3328 bytes) - screen layouts, sprite patterns
.incbin "../data/graphics-data.bin"

; Sprite data 1 ($5800-$5FFF, 2048 bytes)
.incbin "../data/sprites1.bin"

; Level data ($6000-$7FFF, 8192 bytes)
.incbin "../data/level-data.bin"

; Sprite data 2 ($8000-$9FFF, 8192 bytes)
.incbin "../data/sprites2.bin"

; Sprite data 3 ($A000-$A427, 1064 bytes) - additional sprite patterns
.incbin "../data/sprites3.bin"

.include "game-init.s"

; Game data tables ($A632-$B0EF, 2750 bytes) - various game tables, text strings, patterns
.incbin "../data/game-tables.bin"

; Game data ($B0F0-$DFFF, 12048 bytes) - enemy patterns, level data, animations
.incbin "../data/game-data.bin"

; ============================================================================
; Code and data includes ($E000-$FFFB)
; ============================================================================

; Level renderer and screen setup ($E000-$E3A6, 935 bytes)
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

; Music data tables ($F240-$F2C3, 132 bytes)
.incbin "../data/music-tables.bin"

; Music & sound effect data tables ($F2C4-$F39B, 216 bytes)
.include "music-sound-data.s"

; Frequency tables ($F39C-$F4BB, 288 bytes)
.incbin "../data/music-freqs.bin"

; Sound engine - SID music and effects system ($F4BC-$F921, 1,126 bytes)
.include "sound-engine.s"

; SFX & music data ($F900-$FDFF, 1280 bytes)
.incbin "../data/sfx-music.bin"

; Final data section - music data, digit fonts, data tables ($FE00-$FFFA, 507 bytes)
.include "final-data.s"
