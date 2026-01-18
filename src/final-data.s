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
