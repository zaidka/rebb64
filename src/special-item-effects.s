; ==============================================================================
; SPECIAL ITEM EFFECTS ($2D65-$2DD6)
; ==============================================================================
; Memory range: $2D65-$2DD6 (114 bytes)
;
; Special item effect dispatch tables and power-up handlers.
; Contains jump tables for special item effects plus handler routines.
;
; Jump tables:
;   D_2D65: Low byte table for special effect routines (35 entries)
;   D_2D88: High byte table for special effect routines (35 entries)
;
; These tables are indexed by special item type (0-34) to dispatch to
; the appropriate effect handler routine.
;
; Code routines:
;   D_2DAB: Set item type to 3
;   D_2DB2: Set item effect to $8C
;   D_2DBE: Chain multiple effect calls
;   D_2DD2: Set effect flag and return
; ==============================================================================

; --- Special effect routine address table (low bytes) ---
; Indexed by special item type (0-34)
; Used at level-setup.s:365 - lda D_2D65,y
D_2D65:
        .byte   $F1                     ; Entry 0:  $7FF1
        .byte   $8A                     ; Entry 1:  $348A
        .byte   $95                     ; Entry 2:  $3495
        .byte   $AB                     ; Entry 3:  $2DAB -> D_2DAB
        .byte   $B2                     ; Entry 4:  $2DB2 -> D_2DB2
        .byte   $CD                     ; Entry 5:  $2DCD
        .byte   $4D                     ; Entry 6:  $A64D
        .byte   $53                     ; Entry 7:  $A653
        .byte   $D7                     ; Entry 8:  $2DD7
        .byte   $BE                     ; Entry 9:  $2DBE
        .byte   $C7                     ; Entry 10: $2DC7
        .byte   $CC                     ; Entry 11: $2ECC
        .byte   $5F                     ; Entry 12: $2F5F
        .byte   $62                     ; Entry 13: $2F62
        .byte   $65                     ; Entry 14: $2F65
        .byte   $68                     ; Entry 15: $2F68
        .byte   $7D                     ; Entry 16: $2F7D
        .byte   $83                     ; Entry 17: $2F83
        .byte   $89                     ; Entry 18: $2F89
        .byte   $20                     ; Entry 19: $8D20
        .byte   $A4                     ; Entry 20: $A7A4
        .byte   $8D                     ; Entry 21: $988D
        .byte   $A7                     ; Entry 22: $FAA7
        .byte   $98                     ; Entry 23: $A098
        .byte   $A0                     ; Entry 24: $02A0
        .byte   $FA                     ; Entry 25: $0AFA
        .byte   $02                     ; Entry 26: $A702
        .byte   $0A                     ; Entry 27: $B00A
        .byte   $A7                     ; Entry 28: $20A7
        .byte   $B0                     ; Entry 29: $20B0
        .byte   $20                     ; Entry 30: $2120
        .byte   $20                     ; Entry 31: $3720
        .byte   $21                     ; Entry 32: $3C21
        .byte   $37                     ; Entry 33: $7F37
        .byte   $3C                     ; Entry 34: $343C

; --- Special effect routine address table (high bytes) ---
; Indexed by special item type (0-34)
; Used at level-setup.s:367 - lda D_2D88,y
D_2D88:
        .byte   $7F                     ; Entry 0:  $7FF1
        .byte   $34                     ; Entry 1:  $348A
        .byte   $34                     ; Entry 2:  $3495
        .byte   $2D                     ; Entry 3:  $2DAB -> D_2DAB
        .byte   $2D                     ; Entry 4:  $2DB2 -> D_2DB2
        .byte   $2D                     ; Entry 5:  $2DCD
        .byte   $A6                     ; Entry 6:  $A64D
        .byte   $A6                     ; Entry 7:  $A653
        .byte   $2D                     ; Entry 8:  $2DD7
        .byte   $2D                     ; Entry 9:  $2DBE
        .byte   $2D                     ; Entry 10: $2DC7
        .byte   $2E                     ; Entry 11: $2ECC
        .byte   $2F                     ; Entry 12: $2F5F
        .byte   $2F                     ; Entry 13: $2F62
        .byte   $2F                     ; Entry 14: $2F65
        .byte   $2F                     ; Entry 15: $2F68
        .byte   $2F                     ; Entry 16: $2F7D
        .byte   $2F                     ; Entry 17: $2F83
        .byte   $2F                     ; Entry 18: $2F89
        .byte   $36                     ; Entry 19: $3620
        .byte   $7F                     ; Entry 20: $7FA4
        .byte   $34                     ; Entry 21: $348D
        .byte   $7F                     ; Entry 22: $7FA7
        .byte   $34                     ; Entry 23: $3498
        .byte   $34                     ; Entry 24: $34A0
        .byte   $34                     ; Entry 25: $34FA
        .byte   $35                     ; Entry 26: $3502
        .byte   $35                     ; Entry 27: $350A
        .byte   $35                     ; Entry 28: $35A7
        .byte   $35                     ; Entry 29: $35B0
        .byte   $36                     ; Entry 30: $3620
        .byte   $36                     ; Entry 31: $3620
        .byte   $36                     ; Entry 32: $3621
        .byte   $7C                     ; Entry 33: $7C37
        .byte   $7C                     ; Entry 34: $7C3C

; ==============================================================================
; SPECIAL ITEM EFFECT HANDLERS
; ==============================================================================

.segment "CODE"

; --- Set item type to 3 ($2DAB) ---
; Sets basic item properties
; Input: X = entity index
D_2DAB:
        lda     #$03                    ; Item type 3
        sta     $A77B,x                 ; Store item type
        bne     L_2DD2                  ; Always branch to finish

; --- Set item effect to $8C ($2DB2) ---
; Sets item visual effect
; Input: X = entity index
D_2DB2:
        lda     #$8C                    ; Effect value
        sta     $A77D,x                 ; Store effect type
        lda     #$FF                    ; Flag value
        sta     $A77F,x                 ; Store flag
        bne     L_2DD2                  ; Always branch to finish

; --- Chain multiple effect calls ($2DBE) ---
; Calls multiple sub-effect routines in sequence
; Input: X = entity index
D_2DBE:
        jsr     D_2F5F                  ; Call effect 1
        jsr     D_2F62                  ; Call effect 2
        jsr     D_2F65                  ; Call effect 3
        jsr     D_2DAB                  ; Call set item type
        jsr     D_2DB2                  ; Call set effect
        lda     #$FF                    ; Flag value
        sta     $A781,x                 ; Store additional flag

; --- Set effect flag and return ($2DD2) ---
; Common exit point for effect handlers
L_2DD2:
        lda     #$05                    ; Effect flag value
        sta     ZP_B0                   ; Set effect active flag
        rts
