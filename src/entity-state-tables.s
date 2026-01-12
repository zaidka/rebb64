;===============================================================================
; bb-entity-state-tables.s - Entity State Data and Initialization
;===============================================================================
; Address range: $3CB2-$3D2C (123 bytes)
;
; This module contains data tables used by entity state machines and a
; routine that initializes entity sprite/display parameters.
;
; Key functions:
; - Data tables for entity state transitions
; - Sprite initialization routine with multiple entry points
;===============================================================================

;-------------------------------------------------------------------------------
; Data Tables ($3CB2-$3CD5)
;-------------------------------------------------------------------------------
; These appear to be fragments of entity state machine code or jump table data
; They are referenced by code in bb-screen-scroll.s

D_3CB2:
        .byte   $B5,$CA,$38,$E9,$18                 ; $3CB2
        .byte   $4A,$A8,$BD                         ; $3CB7

D_3CBB:
        .byte   $42                                 ; $3CBB

D_3CBB_continued:
        .byte   $AA,$99,$22,$85                     ; $3CBB+1
        lda     #$00                                ; $3CBF
        sta     D_872A,y                            ; $3CC1

D_3CC4:
        lda     D_AA0C,x                            ; $3CC4 - Entity X positions
        sta     $00BC,y                             ; $3CC7
        lda     D_AA1E,x                            ; $3CCA - Entity Y positions

D_3CCD:
        sta     $00C4,y                             ; $3CCD
        jmp     D_E968                              ; $3CD0 - Continue entity processing

        .byte   $F6,$CA,$F6                         ; $3CD3 - Data fragment

D_3CD6:
        .byte   $CA                                 ; $3CD6 - Entry point data

;-------------------------------------------------------------------------------
; Sprite/Entity Initialization Routine ($3CD7-$3D2C)
;-------------------------------------------------------------------------------
; This routine initializes sprite display parameters for entities.
; It has multiple entry points ($3CD7, $3CDB, $3CDF, $3CE5) that load
; different base values before setting up the sprite pointers.
;
; The routine writes sprite pointer addresses to $E849-$E861 (likely self-
; modifying code for sprite display routines).
;
; Entry points:
;   $3CD7: Load #$00 and branch to common setup at $3CE5
;   $3CDB: Load #$40 and set PESSION,x
;   $3CDF: Load #$38 and set PESSION,x  
;   $3CE5: Main initialization (accumulator contains offset)

routine_3CD7:
        lda     #$00                                ; $3CD7
        beq     @common_setup                       ; $3CD9 - Always branches

        lda     #$40                                ; $3CDB - Entry point 2
        bne     @set_pession                        ; $3CDD - Always branches

        lda     #$38                                ; $3CDF - Entry point 3
@set_pession:
        sta     PESSION,x                           ; $3CE1
        lda     #$04                                ; $3CE3

@common_setup:                                      ; $3CE5 - Main entry point
        stx     DATLIN                              ; $3CE5 - Save entity index
        ora     D_A9C4,x                            ; $3CE7 - Combine with level data
        tay                                         ; $3CEA - Use as table index
        
        lda     D_A9D6,x                            ; $3CEB - Load entity type/flags
        sta     OLDTXT                              ; $3CEE - Store flags
        
        ; Set up first sprite pointer (at $E84C-$E84D)
        lda     D_AB41,y                            ; $3CF0 - Get sprite page low
        sta     D_E84C                              ; $3CF3 - Store at sprite ptr 1
        ldx     D_AB49,y                            ; $3CF6 - Get sprite page high
        stx     D_E84D                              ; $3CF9 - Store at sprite ptr 1 high
        
        ; Set up second sprite pointer (at $E856-$E857)
        adc     #$10                                ; $3CFC - Add offset
        sta     D_E856                              ; $3CFE - Store at sprite ptr 2
        bcc     @no_carry1                          ; $3D01
        inx                                         ; $3D03 - Increment high byte
        clc                                         ; $3D04

@no_carry1:
        stx     D_E857                              ; $3D05
        
        ; Set up third sprite pointer (at $E860-$E861)
        adc     #$10                                ; $3D08 - Add another offset
        sta     D_E860                              ; $3D0A
        bcc     @no_carry2                          ; $3D0D
        inx                                         ; $3D0F
        clc                                         ; $3D10

@no_carry2:
        stx     D_E861                              ; $3D11
        
        ; Initialize sprite control bytes
        lda     #$60                                ; $3D14 - RTS instruction opcode
        sta     D_E849                              ; $3D16 - Set sprite routine 1
        sta     D_E853                              ; $3D19 - Set sprite routine 2
        sta     D_E85D                              ; $3D1C - Set sprite routine 3
        
        lda     #$82                                ; $3D1F - STX $nn,Y instruction opcode
        sta     D_E84A                              ; $3D21 - Modify sprite code 1
        sta     D_E854                              ; $3D24 - Modify sprite code 2
        sta     D_E85E                              ; $3D27 - Modify sprite code 3
        
        jmp     D_E7CF                              ; $3D2A - Jump to sprite display

;===============================================================================
; End of bb-entity-state-tables.s
;===============================================================================
