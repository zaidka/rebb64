; ============================================================================
; rebb64 - Final Data Section
; ============================================================================
; Address Range: $FE00-$FFFA (507 bytes)
;
; This section contains:
;   - Music sequence data continuation ($FE00-$FE8E)
;   - Digit font graphics for score display ($FE8F-$FF2F)
;   - Data tables ($FF30-$FFFA)
;
; NOTE: This is DATA ONLY - disassemblers show "illegal opcodes" but these
; are false positives from interpreting data bytes as instructions.
; ============================================================================

; ============================================================================
; MUSIC SEQUENCE DATA ($FE00-$FE8E)
; ============================================================================
; Continuation of music sequence data from sfx-music.bin
; Format: note/command bytes with duration values
; Pattern: [note, duration, note, duration, ...]
; Special bytes: $80/$82 = commands, $96/$98 = sequence control

.segment "CODE_FE00"

D_FE00:
    .byte $C4, $FD               ; $FE00 - Sequence pointer/reference
    .byte $80, $02               ; $FE02 - Command
    .byte $11, $02               ; $FE04 - Note sequence
    .byte $13, $02               ; $FE06
    .byte $14, $02               ; $FE08
    .byte $80, $02               ; $FE0A - Command
    .byte $15, $02               ; $FE0C
    .byte $21, $02               ; $FE0E
    .byte $82                    ; $FE10 - Command marker
    .byte $15, $02               ; $FE11
    .byte $11, $02               ; $FE13
    .byte $13, $02               ; $FE15
    .byte $15, $02               ; $FE17
    .byte $80, $02               ; $FE19 - Command
    .byte $16, $02               ; $FE1B
    .byte $22, $02               ; $FE1D
    .byte $82                    ; $FE1F - Command marker
    .byte $16, $02               ; $FE20
    .byte $82                    ; $FE22 - Command marker
    .byte $16, $02               ; $FE23
    .byte $18, $02               ; $FE25
    .byte $1A, $02               ; $FE27
    .byte $80, $04               ; $FE29 - Command (longer duration)
    .byte $1B, $02               ; $FE2B
    .byte $27, $02               ; $FE2D
    .byte $82                    ; $FE2F - Command marker
    .byte $80, $04               ; $FE30 - Command
    .byte $1A, $02               ; $FE32
    .byte $26, $02               ; $FE34
    .byte $82                    ; $FE36 - Command marker
    .byte $18, $02               ; $FE37
    .byte $24, $02               ; $FE39
    .byte $18, $02               ; $FE3B
    .byte $24, $02               ; $FE3D
    .byte $98                    ; $FE3F - Sequence control
    .byte $60, $02               ; $FE40
    .byte $86                    ; $FE42 - Command marker

; NMI_MAIN label from reference - but this is actually music data
D_FE43:
    .byte $3D, $FB               ; $FE43 - Sequence reference
    .byte $30, $02               ; $FE45
    .byte $34, $02               ; $FE47
    .byte $37, $02               ; $FE49
    .byte $3C, $02               ; $FE4B
    .byte $40, $02               ; $FE4D
    .byte $3C, $02               ; $FE4F
    .byte $37, $02               ; $FE51
    .byte $34, $02               ; $FE53
    .byte $32, $02               ; $FE55
    .byte $35, $02               ; $FE57
    .byte $39, $02               ; $FE59
    .byte $3E, $02               ; $FE5B
    .byte $41, $02               ; $FE5D
    .byte $3E, $02               ; $FE5F
    .byte $39, $02               ; $FE61
    .byte $35, $02               ; $FE63
    .byte $34, $02               ; $FE65
    .byte $37, $02               ; $FE67
    .byte $3B, $02               ; $FE69
    .byte $40, $02               ; $FE6B
    .byte $43, $02               ; $FE6D
    .byte $40, $02               ; $FE6F
    .byte $3B, $02               ; $FE71
    .byte $37, $02               ; $FE73
    .byte $32, $02               ; $FE75
    .byte $35, $02               ; $FE77
    .byte $39, $02               ; $FE79
    .byte $3E, $02               ; $FE7B
    .byte $41, $02               ; $FE7D
    .byte $3E, $02               ; $FE7F
    .byte $39, $02               ; $FE81
    .byte $35, $02               ; $FE83
    .byte $96                    ; $FE85 - Sequence control (loop back)
    .byte $45, $FE               ; $FE86 - Loop target address low/high
    .byte $EF, $FF               ; $FE88 - Terminator/marker
    .byte $A6                    ; $FE8A
    .byte $5D, $FF               ; $FE8B
    .byte $FF, $EF               ; $FE8D
    .byte $FF                    ; $FE8F

; ============================================================================
; DATA TABLES ($FF30-$FFFA)
; ============================================================================
; These are lookup tables, jump vectors, or game state data
; The patterns suggest indexed data tables rather than code

.segment "CODE_FF30"

; Level background color metadata table (100 bytes)
D_FF30:
    .byte $21, $87, $27, $9D     ; $FF30 - bgColors table starts here
    .byte $5D, $98, $63, $C1     ; $FF34
    .byte $87, $63, $BF, $63     ; $FF38
    .byte $21, $63, $BF          ; $FF3C
    .byte $41, $97, $27, $41     ; $FF3F
    .byte $C1, $6E, $63, $BF     ; $FF43
    .byte $63, $87, $BF, $87     ; $FF47
    .byte $41, $6E, $BF, $87     ; $FF4B
    .byte $E1, $41, $41, $C1     ; $FF4F
    .byte $63, $CF, $27, $87     ; $FF53
    .byte $27, $61, $41, $87     ; $FF57
    .byte $41, $27, $87, $BF     ; $FF5B
    .byte $63, $BF, $6E, $27     ; $FF5F
    .byte $2F, $6E, $C1, $41     ; $FF63
    .byte $BF, $41, $63, $21     ; $FF67
    .byte $C1, $87, $61, $BF     ; $FF6B
    .byte $61, $BF, $C1, $51     ; $FF6F
    .byte $5D, $87, $71, $41     ; $FF73
    .byte $C1, $87, $27, $27     ; $FF77
    .byte $21, $63, $21, $27     ; $FF7B
    .byte $41, $41, $27, $BF     ; $FF7F
    .byte $27, $A1, $27, $21     ; $FF83
    .byte $87, $C1, $24, $F1     ; $FF87
    .byte $C1, $E1, $C1, $63     ; $FF8B
    .byte $BF, $6E, $27, $87     ; $FF8F
    .byte $27                    ; $FF93

; Level symmetry/sidebar index metadata table (100 bytes)
; NOTE: No padding byte - D_FF94 starts immediately after D_FF87
D_FF94:
    .byte $FF, $80, $81, $FF     ; $FF94 - symmetry/sidebarIndex table starts here
    .byte $02, $03, $84, $85     ; $FF98
    .byte $86, $87, $88, $89     ; $FF9C
    .byte $0A, $0B, $0C, $8D     ; $FFA0
    .byte $0E, $8F               ; $FFA4
    .byte $FF                    ; $FFA6
    .byte $10, $91, $92, $93     ; $FFA7
    .byte $14, $15, $96, $97     ; $FFAB
    .byte $98, $7F, $99, $1A     ; $FFAF
    .byte $FF, $7F, $1B, $7F     ; $FFB3
    .byte $1C, $7F, $FF, $9D     ; $FFB7
    .byte $FF, $1E, $FF, $7F     ; $FFBB
    .byte $7F, $7F, $7F, $9F     ; $FFBF
    .byte $7F, $FF, $FF, $A0     ; $FFC3
    .byte $A1, $FF, $FF, $FF     ; $FFC7
    .byte $7F, $A2, $23, $24     ; $FFCB
    .byte $7F, $FF, $A5, $A6     ; $FFCF
    .byte $7F, $A7, $FF, $A8     ; $FFD3
    .byte $A9, $7F, $7F, $FF     ; $FFD7
    .byte $7F, $2A, $AB, $7F     ; $FFDB
    .byte $FF, $AC, $2D, $AE     ; $FFDF
    .byte $7F, $AF, $FF, $B0     ; $FFE3
    .byte $B1, $32, $7F, $7F     ; $FFE7
    .byte $B3, $FF, $7F, $34     ; $FFEB
    .byte $7F, $7F, $35, $B6     ; $FFEF
    .byte $B7, $38, $39, $7F     ; $FFF3
    .byte $BA, $29, $00          ; $FFF7

; Note: The PRG file ends at $FFFA, not $FFFB
; $FFFA would normally be the NMI vector on a C64, but this game
; doesn't extend that far in the PRG file
D_FFFA:
    .byte $FF                    ; $FFFA - Final byte
