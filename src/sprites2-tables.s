; ============================================================================
; sprites2-tables.s - Entity State Arrays, Bubble Masks & Title Screen Music
; ============================================================================
;
; This file contains two segments:
;
; SPRITES2_TABLES (relocatable, 1664 bytes):
;   Region 1 ($8480-$895F): Entity state arrays (40-byte stride parallel arrays)
;      Each 40-byte group has an 8-byte metadata header + 32 bytes of
;      level tile data ($80 = solid, $00 = empty).
;   Region 2 ($8960-$8AFF): Bubble animation mask data (multicolor pixel patterns)
;      16-byte mask patterns used for software sprite compositing.
;
; SCREEN_BUFFER (pinned at $8B00, 1024 bytes):
;   Region 3 ($8B00-$8EFF): Title screen music data + screen buffers
;      Music data is played by the SFX engine during the title screen.
;      This region is overwritten as a 4-page screen backup buffer
;      during gameplay ($8B00-$8EFF).
;      The screen buffer address is fixed by VIC hardware constraints,
;      so this segment must remain at $8B00 regardless of other
;      segment positions.
;
; NOTE: The title music data at $8B00+ contains instrument address references
; that use label expressions for relocatability (sfx_instr_* symbols).
; Screen buffer labels (D_8B00, D_8C00, etc.) are defined as fixed
; constants in master.s since they represent hardware-dependent addresses.
; ============================================================================

        .setcpu "6502"

        .segment "SPRITES2_PREAMBLE"

; ============================================================================
; Region 1a: Entity State Array Copies ($8480-$84FF)
; ============================================================================
;
; Working copies of the entity data arrays (groups 0-2) plus the 8-byte
; header for the source array (group 3). At runtime, entity-spawn.s copies
; data from D_8500 into D_84D8/D_84B0/D_8488.
;
; This preamble is in a separate segment from SPRITES2_TABLES so that
; D_8500 (the start of SPRITES2_TABLES) can be page-aligned via the
; linker config, regardless of where the segments are placed.
; ============================================================================

; --- Group 0: $8480-$84A7 ---
; 8-byte header (unused padding) + 32-byte entity data array 3
        .byte   $00, $00, $00, $00, $00, $00, $00, $00  ; $8480: unused padding (8 bytes)
D_8488:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80  ; $8488: level tile data (all $80 = solid)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80

; --- Group 1: $84A8-$84CF ---
; 8-byte header + 32-byte entity data array 2
        .byte   $00, $04, $00, $00, $00, $00, $04, $00  ; $84A8: wrap/spawn metadata
D_84B0:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80  ; $84B0: level tile data (all $80 = solid)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80

; --- Group 2: $84D0-$84F7 ---
; 8-byte header + 32-byte entity data array 1
        .byte   $00, $04, $00, $00, $00, $00, $04, $00  ; $84D0: wrap/spawn metadata
D_84D8:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80  ; $84D8: level tile data (all $80 = solid)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80

; --- Group 3 header ($84F8-$84FF) ---
; 8-byte header for the source array. Never accessed directly by address.
        .byte   $00, $04, $00, $00, $00, $00, $04, $00  ; $84F8: wrap/spawn metadata

; ============================================================================
; Region 1b: Entity State Source Array + Game Tables ($8500-$895F)
; ============================================================================
;
; ALIGNMENT: D_8500 must be page-aligned ($xx00) because the level renderer
; and collision code use page arithmetic (adc #>D_8500) with row offset
; tables (D_AD3D) to address the 4-page entity data region ($8500-$88FF).
; The linker config enforces this with align=$100 on SPRITES2_TABLES.
; ============================================================================

        .segment "SPRITES2_TABLES"

D_8500:
        .byte   $80
D_8501:                                 ; Screen wrap permission table (bottom)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80
D_850A:                                 ; Spawn point 0 availability (top left)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
D_8514:                                 ; Spawn point 1 availability (top right)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80

; --- $8520-$8547 ---
D_8520:
        .byte   $0b, $04
D_8522:
        .byte   $00, $00, $00, $00, $04, $00  ; D_8520=$0b, D_8522=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8548-$856F ---
D_8548:
        .byte   $05, $03
D_854A:
        .byte   $0d, $0d, $0d, $0d, $0c, $0c  ; D_8548=$05, D_854A=$0d
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8570-$8597 ---
D_8570:
        .byte   $05, $03
D_8572:
        .byte   $0a, $0a, $0a, $0a, $0a, $0a  ; D_8570=$05, D_8572=$0a
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8598-$85BF ---
D_8598:
        .byte   <__SPRITE_PTR_BASE__, <__SPRITE_PTR_BASE__
D_859A:
        .byte   $00
D_859B:
        .byte   $00, $00, $00, $00, $00  ; D_8598=$60, D_859A=$00, D_859B=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $85C0-$85E7 ---
D_85C0:
        .byte   $ff, $ff
D_85C2:
        .byte   $00, $00, $00, $00, $00, $00  ; D_85C0=$ff, D_85C2=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $85E8-$860F ---
D_85E8:
        .byte   $7b
D_85E9:
        .byte   $ff
D_85EA:
        .byte   $09, $0a, $06, $05, $01, $02  ; D_85E8=$7b, D_85E9=$ff, D_85EA=$09
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8610-$8637 ---
D_8610:
        .byte   $04, $c8, $01, $01, $00, $00, $01, $01  ; D_8610=$04
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8638-$865F ---
D_8638:
        .byte   $00
D_8639:
        .byte   $00
D_863A:
        .byte   $28, $28, $28, $a8, $80, $80  ; D_8638=$00, D_8639=$00, D_863A=$28
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8660-$8687 ---
D_8660:
        .byte   $00, $00
D_8662:
        .byte   $0f, $20, $27, $2e, $24, $15  ; D_8660=$00, D_8662=$0f
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8688-$86AF ---
D_8688:
        .byte   $00, $00
D_868A:
        .byte   $0f, $20, $27, $2e, $2e, $37  ; D_8688=$00, D_868A=$0f
        .byte   $80, $80, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $80
        .byte   $80, $00, $00, $00, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $80, $80

; --- $86B0-$86D7 ---
D_86B0:
        .byte   $00, $01, $02, $03, $04, $05, $06, $07  ; D_86B0=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $86D8-$86FF ---
D_86D8:
        .byte   $00, $00, $00, $00, $00, $00, $00, $00  ; D_86D8=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8700-$8727 ---
D_8700:
        .byte   $00, $00
D_8702:
        .byte   $00, $00, $00, $00, $00, $00  ; D_8700=$00, D_8702=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8728-$874F ---
D_8728:
        .byte   $00
D_8729:
        .byte   $00
D_872A:
        .byte   $00, $00, $00, $00, $00, $00  ; D_8728=$00, D_8729=$00, D_872A=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8750-$8777 ---
D_8750:
        .byte   $00, $00
D_8752:
        .byte   $04, $04, $04, $84, $84, $84  ; D_8750=$00, D_8752=$04
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8778-$879F ---
D_8778:
        .byte   $00, $00
D_877A:
        .byte   $03, $03, $03, $03, $03, $03  ; D_8778=$00, D_877A=$03
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $87A0-$87C7 ---
D_87A0:
        .byte   $ff, $ff
D_87A2:
        .byte   $ff, $ff, $ff, $ff, $ff, $ff  ; D_87A0=$ff, D_87A2=$ff
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $87C8-$87EF ---
D_87C8:
        .byte   $ff, $ff
D_87CA:
        .byte   $ff, $ff, $ff, $ff, $ff, $ff  ; D_87C8=$ff, D_87CA=$ff
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $87F0-$8817 ---
D_87F0:
        .byte   $ff, $ff
D_87F2:
        .byte   $ff, $ff, $ff, $ff, $ff, $ff  ; D_87F0=$ff, D_87F2=$ff
        .byte   $80, $80, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $80
        .byte   $80, $00, $00, $00, $00, $00, $00, $00, $80, $80, $00, $00, $00, $00, $80, $80

; --- $8818-$883F ---
D_8818:
        .byte   $02, $ff
D_881A:
        .byte   $ff, $ff, $ff, $ff, $ff, $ff  ; D_8818=$02, D_881A=$ff
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8840-$8867 ---
D_8840:
        .byte   $00, $01
D_8842:
        .byte   $00, $00, $00, $00, $01, $00  ; D_8840=$00, D_8842=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8868-$888F ---
D_8868:
        .byte   $00, $00
D_886A:
        .byte   $00, $00, $00, $00, $00, $00  ; D_8868=$00, D_886A=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $8890-$88B7 ---
D_8890:
        .byte   $00, $00
D_8892:
        .byte   $00, $00, $00, $00, $00, $00  ; D_8890=$00, D_8892=$00
        .byte   $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80

; --- $88B8-$88DF ---
; Transition area between entity array families
        .byte   $00, $00, $00, $00, $00, $00, $00, $00  ; $88B8: padding/metadata

; --- $88C0-$88E7 (Second family source array) ---
; Master copy for the second set of entity data arrays.
; D_88C1 = Screen wrap permission table (top)
; D_88C9 = Credits array 1 (18 bytes)
; D_88CA = Spawn point 2 availability (bottom left)
; D_88D4 = Spawn point 3 availability (bottom right)
D_88C0:
        .byte   $80
D_88C1:                                 ; Screen wrap permission table (top)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
D_88C9:                                 ; Credits array 1 (18 bytes)
        .byte   $80
D_88CA:                                 ; Spawn point 2 availability (bottom left)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
D_88D4:                                 ; Spawn point 3 availability (bottom right)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00

; --- $88E8-$890F (Second family copy 1) ---
D_88E8:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80  ; $88E8: entity data
        .byte   $80
D_88F1:                                 ; Credits array 2 (18 bytes)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00

; --- $8910-$8937 (Second family copy 2) ---
D_8910:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80  ; $8910: entity data
        .byte   $80
D_8919:                                 ; Credits array 3 (18 bytes)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00

; --- $8938-$895F (Second family copy 3) ---
D_8938:
        .byte   $80, $80, $80, $80, $80, $80, $80, $80  ; $8938: entity data
        .byte   $80
D_8941:                                 ; Credits array 4 (18 bytes)
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00


; ============================================================================
; Region 2: Bubble Animation Mask Data ($8960-$8AFF)
; ============================================================================
;
; Multicolor pixel mask patterns for software sprite compositing.
; 26 blocks of 16 bytes each. Values are 2-bit pixel pair combinations
; in C64 multicolor mode ($00, $03, $0C, $30, $C0, $0F, $3F, $F0, $FC).
; ============================================================================

bubble_anim_masks:
        .res    16, $00             ; $8960: empty (all transparent)
        .res    16, $00             ; $8970: empty (all transparent)
        .byte   $00, $0c, $00, $30, $00, $c0, $00, $c0, $00, $c0, $00, $c0, $00, $30, $00, $03  ; $8980
        .byte   $c0, $00, $0c, $00, $03, $00, $03, $00, $03, $00, $03, $00, $0c, $00, $30, $00  ; $8990
        .res    16, $00             ; $89A0: empty (all transparent)
        .byte   $00, $03, $00, $0c, $00, $30, $00, $30, $00, $30, $00, $30, $00, $0c, $00, $00  ; $89B0
        .byte   $30, $00, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $0c, $c0  ; $89C0
        .byte   $00, $00, $00, $00, $c0, $00, $c0, $00, $c0, $00, $c0, $00, $00, $00, $00, $00  ; $89D0
        .byte   $00, $00, $00, $03, $00, $0c, $00, $0c, $00, $0c, $00, $0c, $00, $03, $00, $00  ; $89E0
        .byte   $0c, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $30  ; $89F0
        .byte   $00, $00, $c0, $00, $30, $00, $30, $00, $30, $00, $30, $00, $c0, $00, $00, $00  ; $8A00
        .byte   $00, $00, $00, $00, $00, $03, $00, $03, $00, $03, $00, $03, $00, $00, $00, $00  ; $8A10
        .byte   $03, $30, $00, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $0c  ; $8A20
        .byte   $00, $00, $30, $00, $0c, $00, $0c, $00, $0c, $00, $0c, $00, $30, $00, $c0, $00  ; $8A30
        .byte   $00, $00, $00, $0c, $00, $c0, $00, $00, $30, $fc, $30, $00, $00, $30, $00, $03  ; $8A40
        .byte   $00, $c0, $00, $0c, $3f, $0c, $c0, $00, $00, $03, $00, $c0, $00, $0c, $00, $00  ; $8A50
        .res    16, $00             ; $8A60: empty (all transparent)
        .byte   $00, $00, $00, $03, $00, $30, $00, $00, $0c, $3f, $0c, $00, $00, $0c, $00, $00  ; $8A70
        .byte   $00, $30, $00, $03, $0f, $03, $30, $00, $00, $00, $00, $30, $00, $03, $00, $c0  ; $8A80
        .byte   $00, $00, $00, $00, $c0, $00, $00, $00, $00, $c0, $00, $00, $00, $00, $00, $00  ; $8A90
        .byte   $00, $00, $00, $00, $00, $0c, $00, $00, $03, $0f, $03, $00, $00, $03, $00, $00  ; $8AA0
        .byte   $00, $0c, $00, $c0, $03, $00, $0c, $00, $00, $c0, $00, $0c, $00, $00, $00, $30  ; $8AB0
        .byte   $00, $00, $00, $c0, $f0, $c0, $00, $00, $00, $30, $00, $00, $00, $c0, $00, $00  ; $8AC0
        .byte   $00, $00, $00, $00, $00, $03, $00, $00, $00, $03, $00, $00, $00, $00, $00, $00  ; $8AD0
        .byte   $00, $03, $00, $30, $00, $00, $03, $00, $c0, $f0, $c0, $03, $00, $c0, $00, $0c  ; $8AE0
        .byte   $00, $00, $00, $30, $fc, $30, $00, $00, $00, $0c, $00, $00, $00, $30, $00, $00  ; $8AF0


; ============================================================================
; Region 3: Title Screen Music Data ($8B00-$8EFF)
; ============================================================================
;
; Three-voice music data played by the SFX engine during the title screen.
; Voice start addresses (from sfx_index_table group 7 at $F953):
;   Voice 0: $8B00 (title_music_voice0)
;   Voice 1: $8BDC (title_music_voice1)
;   Voice 2: $8CBF (title_music_voice2)
;
; Music command format:
;   $00-$5E: Note value (frequency table index), followed by duration byte
;   $5F:     Rest/silence, followed by duration byte
;   $60:     End-of-pattern / stop voice
;   $80 nn:  Set loop counter to nn
;   $82:     Decrement loop counter; if >0, loop back
;   $84 lo hi: Load 14-byte instrument block from address
;   $86 lo hi: Load 29-byte instrument block from address
;   $88 nn:  Set transpose value
;   $8A nn:  Set frequency table pointer (low byte)
;   $8C:     Set SID filter cutoff = $F7 (bright)
;   $8D:     Separator (not a valid command - used as data delimiter)
;   $8E:     Set SID filter from per-voice table
;   $90:     Set SID filter cutoff = $78 (mid), mode = 3
;   $92 nn lo hi: Set transpose + call subroutine
;   $94 lo hi: Call music subroutine
;   $98:     Return from subroutine / end voice
;
; NOTE: $86/$84 instrument address operands use label references for
; relocatability (sfx_instr_* symbols from the SFXMUSIC segment).
;
; NOTE: Screen buffer labels (D_8B00, D_8C00, D_8D00, D_8E00, etc.) are
; defined as fixed constants in master.s. The labels below (title_music_voice0,
; etc.) are segment-relative and will relocate with this segment.
; ============================================================================

        .segment "SCREEN_BUFFER"

; --- Voice 0: Title screen music ($8B00) ---
; Segment placement guaranteed by start = __SCREEN_BACKUP__ in c64-prg.cfg
title_music_voice0:
; Voice 0 ($8B00)
        .byte   $86                     ; $8B00: LOAD_INSTR_29B
        .byte   <sfx_instr_12           ; $8B01: -> sfx_instr_12 (lo)
        .byte   >sfx_instr_12           ; $8B02: -> sfx_instr_12 (hi)
        .byte   $60
        .byte   $02, $4e, $04, $49, $04, $44, $04, $49, $04, $44, $04, $3f, $04, $44, $04  ; $8B03
        .byte   $3f, $04, $3a, $04, $3f, $04, $3a, $04, $36, $04, $86, $a8, $8d, $80, $08, $5f  ; $8B13
        .byte   $10, $82, $80, $04, $35, $18, $35, $04, $34, $20, $5f, $04, $82, $86  ; $8B23
        .byte   <sfx_instr_2, >sfx_instr_2
                                        ; $8B31: $86 cmd -> sfx_instr_2
        .byte   $8a, <D_F279, $80, $02, $80, $20, $30, $04, $82, $82, $80, $08, $35, $04, $82, $8a  ; $8B33
        .byte   <D_F27C, $80, $08, $32, $04, $82, $8a, <D_F279, $80, $08, $37, $04, $82, $80, $08, $30  ; $8B43
        .byte   $04, $82, $80, $08, $35, $04, $82, $8a, <D_F27C, $80, $06, $32, $04, $82, $34, $04  ; $8B53
        .byte   $34, $04, $8a, <D_F283, $32, $04, $32, $04, $8a, <D_F27C, $34, $04, $34, $04, $8a, <D_F279  ; $8B63
        .byte   $35, $04, $35, $04, $36, $04, $36, $04, $80, $08, $37, $04, $82, $80, $10, $30  ; $8B73
        .byte   $04, $82, $35, $04, $35, $04, $35, $04, $35, $04, $37, $04, $37, $04, $37, $04  ; $8B83
        .byte   $37, $04, $8a, <D_F27C, $80, $08, $34, $04, $82, $8a, <D_F279, $80, $10, $30, $04, $82  ; $8B93
        .byte   $35, $04, $35, $04, $35, $04, $35, $04, $37, $04, $37, $04, $37, $04, $37, $04  ; $8BA3
        .byte   $8a, <D_F27C, $34, $04, $34, $04, $39, $04, $39, $04, $8a, <D_F279, $37, $04, $37, $04  ; $8BB3
        .byte   $37, $04, $37, $04, $30, $04, $5f, $1c, $5f, $20, $86, $a8, $8d, $80, $03, $35  ; $8BC3
        .byte   $18, $35, $04, $34, $20, $5f, $04, $82, $98  ; $8BD3

; --- Voice 1: Title screen music ($8BDC) ---
title_music_voice1:
; Voice 1 ($8BDC)
        .byte   $60, $02, $86  ; $8BDC
        .byte   <sfx_instr_12, >sfx_instr_12
                                        ; $8BDF: $86 cmd -> sfx_instr_12
        .byte   $5f, $02, $4b, $04, $46, $04, $42, $04, $46, $04, $42, $04, $3d, $04, $42, $04  ; $8BE1
        .byte   $3d, $04, $38, $04, $3d, $04, $38, $04, $33, $02, $86, $a8, $8d, $84  ; $8BF1
        .byte   <sfx_instr_21           ; $8BFF: $84 cmd -> sfx_instr_21 (lo)
        .byte   >sfx_instr_21           ; $8C00: -> sfx_instr_21 (hi)
        .byte   $80, $08, $5f, $10, $82, $80, $04, $3c, $18, $3c, $04, $3c, $20, $5f, $04, $82  ; $8C01
        .byte   $84, $a8, $8d, $80, $02, $34, $10, $34, $04, $35, $04, $37, $04, $3c, $0c, $37  ; $8C11
        .byte   $08, $35, $08, $37, $04, $34, $1c, $86  ; $8C21
        .byte   <sfx_instr_1, >sfx_instr_1
                                        ; $8C29: $86 cmd -> sfx_instr_1
        .byte   $84  ; $8C2B
        .byte   <sfx_instr_22, >sfx_instr_22
                                        ; $8C2C: $84 cmd -> sfx_instr_22
        .byte   $3c, $04, $3c, $08, $3c, $04, $8a, <D_F26C, $3c, $08, $8a, <D_F273, $3c, $04, $8a, <D_F26C  ; $8C2E
        .byte   $3c, $0c, $86, $a8, $8d, $82, $39, $10, $34, $04, $35, $04, $37, $04, $35, $10  ; $8C3E
        .byte   $5f, $14, $37, $10, $32, $04, $34, $04, $35, $04, $34, $10, $5f, $14, $39, $10  ; $8C4E
        .byte   $34, $04, $35, $04, $37, $04, $35, $10, $5f, $0c, $34, $08, $32, $08, $34, $08  ; $8C5E
        .byte   $35, $08, $36, $08, $37, $14, $37, $04, $39, $04, $80, $02, $3c, $08, $3c, $04  ; $8C6E
        .byte   $3b, $08, $39, $04, $3b, $08, $82, $5f, $04, $35, $10, $37, $0c, $34, $18, $37  ; $8C7E
        .byte   $04, $39, $04, $80, $02, $3c, $08, $3c, $04, $3b, $08, $39, $04, $3b  ; $8C8E
        .byte   $08, $82                ; $8C9C
        .byte   $5f, $04, $35, $10, $37, $0c, $34, $0c, $39, $08, $3b  ; $8C9E
        .byte   $08, $37, $08, $3c, $20 ; $8CA9
        .byte   $5f, $20, $84  ; $8CAE
        .byte   <sfx_instr_21, >sfx_instr_21
                                        ; $8CB1: $84 cmd -> sfx_instr_21
        .byte   $80, $03, $3c, $18, $3c, $04, $3c, $20, $5f, $04, $82, $98  ; $8CB3

; --- Voice 2: Title screen music ($8CBF) ---
title_music_voice2:
; Voice 2 ($8CBF)
        .byte   $60, $01, $90, $86  ; $8CBF
        .byte   <sfx_instr_12, >sfx_instr_12
                                        ; $8CC3: $86 cmd -> sfx_instr_12
        .byte   $60, $01, $5a, $02, $57, $02, $55, $02, $54, $02, $50, $02, $4e, $02, $55, $02  ; $8CC5
        .byte   $54, $02, $50, $02, $4e, $02, $4b, $02, $49  ; $8CD5

; --- Voice 2 continued: Note sequence ($8CDE) ---
        .byte   $02, $50, $02, $4e, $02, $4b, $02, $49, $02, $46, $02, $44, $02, $4b  ; $8CDE
        .byte   $02, $49                ; $8CEC
        .byte   $02, $46, $02, $44, $02, $42, $02, $3f, $02, $94, <L_7048, >L_7048, $80, $17, $18, $04  ; $8CEE
        .byte   $18, $04                ; $8CFE
        .byte   $18, $04, $18, $04, $82, $18, $04, $18, $04, $94, <L_7040, >L_7040, $1f, $04  ; $8D00
        .byte   $21, $04, $80, $08, $92, $00, $8d, $8d, $82, $92, $05, $8d, $8d, $92, $02, $8d  ; $8D0E
        .byte   $8d, $92, $04, $8d, $8d, $92, $00, $8d, $8d, $92, $05, $8d, $8d, $92, $02, $8d  ; $8D1E
        .byte   $8d, $88, $00, $1a, $04, $26, $04, $1c, $04, $28, $04, $1d, $04, $29, $04, $1e  ; $8D2E
        .byte   $04, $2a, $04, $92, $07, $8d, $8d, $80, $02, $92, $00, $8d, $8d, $82, $92, $05  ; $8D3E
        .byte   $9a, $8d, $92, $07, $9a, $8d, $92, $04, $8d, $8d, $80, $02, $92, $00, $8d, $8d  ; $8D4E
        .byte   $82, $92, $05, $9a, $8d, $92, $07, $9a, $8d, $88, $00, $1c, $08, $21, $08, $23  ; $8D5E
        .byte   $08, $1f, $08, $94, <L_7048, >L_7048, $80, $0c, $18, $04, $18, $04, $18, $04, $18, $04  ; $8D6E
        .byte   $82, $94, <L_7040, >L_7040, $18, $10, $21, $04, $1f, $04, $21, $04, $18, $0c, $98, $18  ; $8D7E
        .byte   $08, $86, $c5, $8d, $90, $38, $04, $94, <L_7040, >L_7040, $18, $04, $18, $08, $86, $c5  ; $8D8E
        .byte   $8d, $90, $38, $04, $94, <L_7040, >L_7040, $18, $04, $98  ; $8D9E

; --- Title screen music: SFX parameter data ($8DA8) ---
        .byte   $23, $00, $dd, $ff, $23, $00, $00, $00, $02, $04, $02, $00, $02, $05, $3c, $3c  ; $8DA8
        .byte   $00, $05, $20, $00, $e0, $ff, $00, $01, $41, $07, $cc, $1e, $5a, $a0, $0f, $c0  ; $8DB8
        .byte   $e0, $40, $1f, $60, $f0, $02, $02, $02, $02, $01, $05, $00, $00, $00, $00, $00  ; $8DC8
        .byte   $00, $00, $00, $00, $00, $81, $06, $f9  ; $8DD8

; --- Post-music padding ($8DE0) ---
        .byte   $03, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00  ; $8DE0
        .res    16, $00             ; $8DF0

; --- Screen buffer page 3 ($8E00) ---
        .res    16, $00             ; $8E00
        .res    16, $00             ; $8E10
        .res    16, $00             ; $8E20
        .res    16, $00             ; $8E30
        .res    16, $00             ; $8E40
        .res    16, $00             ; $8E50
        .res    16, $00             ; $8E60
        .res    16, $00             ; $8E70
        .res    16, $20             ; $8E80: spaces
        .res    16, $20             ; $8E90: spaces
        .res    16, $20             ; $8EA0: spaces
        .res    16, $20             ; $8EB0: spaces
        .res    16, $20             ; $8EC0: spaces
        .res    16, $20             ; $8ED0: spaces
        .res    16, $20             ; $8EE0: spaces
        .byte   $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $d9, $da, $db, $dc, $dd, $de  ; $8EF0
