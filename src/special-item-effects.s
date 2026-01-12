; ==============================================================================
; bb-special-item-effects.s
; ==============================================================================
; Memory range: $2D65-$2DD6 (114 bytes)
;
; Special item effect dispatch tables and power-up handlers
; - D_2D65: Low byte table for special effect routines (35 bytes)
; - D_2D88: High byte table for special effect routines (35 bytes)
; - Effect handlers for various special items
;
; NOTE: This section contains data tables that look like code with illegal
; opcodes. Using .byte directives to ensure byte-perfect accuracy.
; ==============================================================================

; Special effect routine address table (low bytes)
; Indexed by special item type (0-34)
D_2D65:
.byte   $f1, $8a, $95, $ab, $b2, $cd, $4d, $53  ; $2d65
.byte   $d7, $be, $c7, $cc, $5f, $62, $65, $68  ; $2d6d
.byte   $7d, $83, $89                           ; $2d75

; Data/code fragment (appears to be part of table continuation)
.byte   $20, $a4, $8d                           ; $2d78 - JSR D_8DA4
.byte   $a7, $98                                ; $2d7b - LAX DFLTN (illegal)
.byte   $a0, $fa                                ; $2d7d - LDY #$fa
.byte   $02                                     ; $2d7f - KIL (illegal opcode)
.byte   $0a, $a7, $b0                           ; $2d80
.byte   $20, $20, $21                           ; $2d83 - JSR D_2120
.byte   $37, $3c                                ; $2d86 - RLA OLDLIN+1,x (illegal)

; Special effect routine address table (high bytes)
; Indexed by special item type (0-34)
D_2D88:
.byte   $7f, $34, $34                           ; $2d88 - RRA D_3434,x (illegal)
.byte   $2d, $2d, $2d                           ; $2d8b - AND D_2D2D
.byte   $a6, $a6                                ; $2d8e - LDX $a6
.byte   $2d, $2d, $2d                           ; $2d90 - AND D_2D2D
.byte   $2e, $2f, $2f                           ; $2d93 - ROL D_2F2F
.byte   $2f, $2f, $2f                           ; $2d96 - RLA D_2F2F (illegal)
.byte   $2f, $2f, $36                           ; $2d99 - RLA D_362F (illegal)
.byte   $7f, $34, $7f                           ; $2d9c - RRA D_7F34,x (illegal)
.byte   $34, $34                                ; $2d9f - NOP (non-canonical)
.byte   $34, $35                                ; $2da1 - NOP (non-canonical)
.byte   $35, $35                                ; $2da3 - AND FRESPC,x
.byte   $35, $36                                ; $2da5 - AND FRESPC+1,x
.byte   $36, $36                                ; $2da7 - ROL FRESPC+1,x
.byte   $7c, $7c, $a9                           ; $2da9 - NOP (non-canonical)

; Special item effect handler
; Called via self-modifying JSR from level setup code
D_2DAC:
.byte   $03, $9d                                ; $2dac - SLO (PTR2,x) (illegal)
.byte   $7b, $a7, $d0                           ; $2dae - RRA D_D0A7,y (illegal)

        jsr     D_8CA9                  ; 20 a9 8c     $2db1
        sta     D_A77D,x                ; 9d 7d a7     $2db4
        lda     #$ff                    ; a9 ff        $2db7
        sta     D_A77F,x                ; 9d 7f a7     $2db9
        bne     L_2DD2                  ; d0 14        $2dbc

        jsr     D_2F5F                  ; 20 5f 2f     $2dbe
        jsr     D_2F62                  ; 20 62 2f     $2dc1
        jsr     D_2F65                  ; 20 65 2f     $2dc4
        jsr     D_2DAB                  ; 20 ab 2d     $2dc7 - Call helper routine
        jsr     D_2DB2                  ; 20 b2 2d     $2dca - Call setup routine

        lda     #$ff                    ; a9 ff        $2dcd
        sta     D_A781,x                ; 9d 81 a7     $2dcf

L_2DD2:
        lda     #$05                    ; a9 05        $2dd2
        sta     $b0                     ; 85 b0        $2dd4 - Set effect flag
        rts                             ; 60           $2dd6

D_2DAB      = $2DAB                     ; Helper routine entry point
D_2DB2      = $2DB2                     ; Setup routine entry point
