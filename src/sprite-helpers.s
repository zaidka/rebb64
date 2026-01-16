;===============================================================================
; bb-sprite-helpers.s - Sprite Helper Routines
;===============================================================================
; Address range: $3FB0-$3FFF (80 bytes)
;
; This module contains helper routines that appear to handle sprite data
; writing with conditional logic. The routines check various conditions
; and write space characters ($20) to memory via indirect addressing.
;
; These routines have similar structure, suggesting they're variants for
; different sprite processing contexts.
;===============================================================================

;-------------------------------------------------------------------------------
; Helper Routine 1 ($3FB0-$3FC2) - D_3FB0
;-------------------------------------------------------------------------------
; Conditional sprite data writer
; Checks flags and writes space character if conditions are met

.segment "CODE"

D_3FB0:
        bne     L_3FBD                              ; $3FB0 - Exit if not zero
        bit     DATPTR+1                            ; $3FB2 - Test bit 7 of $42
        bmi     L_3FBD                              ; $3FB4 - Exit if negative
        cpy     #$05                                ; $3FB6 - Check Y against 5
        beq     L_3FBD                              ; $3FB8 - Exit if equal
        lda     #$20                                ; $3FBA - Load space character
        bit     D_42C6                              ; $3FBC - BIT $42C6 (overlaps next instr)
                                                    ; When falling through: BIT D_42C6
L_3FBD = * - 2                                      ; When jumping to L_3FBD: DEC $42
        sta     (DATLIN+1),y                        ; $3FBF - Store via ($40),Y
        iny                                         ; $3FC1 - Increment Y
        rts                                         ; $3FC2

;-------------------------------------------------------------------------------
; Data Fragment and Sprite Setup 1 ($3FC3-$3FCE)
;-------------------------------------------------------------------------------
        .byte   $A8,$8D,$49,$E8                     ; $3FC3 - Data (TAY, STA $E849)

routine_3FC7:
        lda     #$B8                                ; $3FC7
        sta     D_E853                              ; $3FC9 - Set sprite routine 2
        jmp     D_3ED5                              ; $3FCC - Jump to sprite init 3

;-------------------------------------------------------------------------------
; Helper Routine 2 ($3FCF-$3FE1)
;-------------------------------------------------------------------------------
; Similar to routine 1 but positioned at different address
; Data fragment followed by actual code

        .byte   $D0,$0B,$24,$42,$30,$07,$C0,$05     ; $3FCF - Data fragment
        .byte   $F0,$03                             ; $3FD7 - Data fragment

routine_3FD9:
        lda     #$20                                ; $3FD9 - Load space character
        bit     D_42C6                              ; $3FDB - Test bits (dummy read?)
        sta     (DATLIN+1),y                        ; $3FDE - Store via ($40),Y
        iny                                         ; $3FE0 - Increment Y
        rts                                         ; $3FE1

;-------------------------------------------------------------------------------
; Data Fragment and Sprite Setup 2 ($3FE2-$3FEC)
;-------------------------------------------------------------------------------
        .byte   $8D,$49,$E8                         ; $3FE2 - Data (STA $E849)

routine_3FE5:
        lda     #$B8                                ; $3FE5
        sta     D_E853                              ; $3FE7 - Set sprite routine 2
        jmp     D_3EF3                              ; $3FEA - Jump to sprite init (invalid label)

;-------------------------------------------------------------------------------
; Helper Routine 3 ($3FED-$3FFF)
;-------------------------------------------------------------------------------
; Third variant of the sprite helper
; Data fragment followed by actual code

        .byte   $D0,$0B,$24,$42,$30,$07,$C0,$05     ; $3FED - Data fragment
        .byte   $F0,$07                             ; $3FF5 - Data fragment

routine_3FF7:
        lda     #$20                                ; $3FF7 - Load space character
        bit     D_42C6                              ; $3FF9 - Test bits (dummy read?)
        sta     (DATLIN+1),y                        ; $3FFC - Store via ($40),Y
        iny                                         ; $3FFE - Increment Y

D_3FFF:
        rts                                         ; $3FFF - Return

;===============================================================================
; End of bb-sprite-helpers.s
;===============================================================================
