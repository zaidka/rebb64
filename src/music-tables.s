; ============================================================================
; rebb64 - Music Command Handler Dispatch Table
; ============================================================================
; Address Range: $F240-$F2C3 (132 bytes)
;
; This file contains the music system's core data tables:
;   - Music command handler pointers (17 handlers) - Point to CODE, not music data!
;   - Music timing and control data
;   - Sound effect index table
;
; IMPORTANT: Despite the historical name "music_track_pointers", this table
; actually contains pointers to COMMAND HANDLER CODE at $7305-$743F, not
; music track data. These handlers process special music commands and control
; the SID chip.
;
; Referenced by:
;   - sound-engine.s at $F57B: jmp (D_F256) - indirect jump to handler code
;   - sound-engine.s at $F607: lda D_F2AE,y - sound effect table lookup
; ============================================================================

; ============================================================================
; MUSIC COMMAND HANDLER POINTERS ($F240-$F261) - 34 bytes
; ============================================================================
; 17 pointers to music command handler routines in the $73xx range
; These point to CODE in music-command-handlers.s, not to music data!
music_track_pointers:               ; Historical name - actually command handlers
        .word   music_handler_00    ; $F240: Handler 0 - Set music parameter
        .word   music_handler_01    ; $F242: Handler 1 - Decrement and loop
        .word   music_handler_02    ; $F244: Handler 2 - Load timing (0D)
        .word   music_handler_03    ; $F246: Handler 3 - Load timing (1C)
        .word   music_handler_04    ; $F248: Handler 4 - Set voice parameter
        .word   music_handler_05    ; $F24A: Handler 5 - Set frequency pointers
        .word   music_handler_06    ; $F24C: Handler 6 - Set filter (F7)
        .word   music_handler_07    ; $F24E: Handler 7 - Set filter (table)
        .word   music_handler_08    ; $F250: Handler 8 - Set filter (78)
        .word   music_handler_09    ; $F252: Handler 9 - Multi-step update
        .word   music_handler_10    ; $F254: Handler 10 - Complex pointer update
D_F256:                             ; Used by jmp (D_F256) at $F57B
        .word   music_handler_11    ; $F256: Handler 11 - Update pointers
        .word   music_handler_12    ; $F258: Handler 12 - Loop counter check
        .word   music_handler_13    ; $F25A: Handler 13 - Copy 16-byte block
        .word   music_handler_14    ; $F25C: Handler 14 - Set SFX end markers
        .word   $0007               ; $F25E: Handler 15 - Invalid/placeholder
        .word   $0007               ; $F260: Handler 16 - Invalid/placeholder

; ============================================================================
; MUSIC TIMING DATA ($F262-$F289) - 40 bytes
; ============================================================================
; Read-only lookup table for music timing values (likely unused/dead data)
music_timing_data:
        .byte   $03, $08, $03, $0C, $03, $08, $00, $05  ; $F262
        .byte   $09, $05, $0C, $04, $07, $00, $08, $03  ; $F26A
        .byte   $06, $0C, $02, $07, $00, $0C, $00, $0C  ; $F272
        .byte   $04, $07, $0C, $03, $07, $0C, $18, $0C  ; $F27A
        .byte   $18, $0A, $04, $07, $0C, $05, $07, $00  ; $F282

; ============================================================================
; MUSIC CONTROL PARAMETERS ($F28A-$F2AD) - 36 bytes
; ============================================================================
; Working RAM / state storage with initial values
; Accessed as indexed arrays:
;   $F28A,y - Music pointer save slots (low bytes)
;   $F28E,y - Music pointer save slots (high bytes)
;   $F292,y - Music parameter storage
music_control_data:
        .byte   $D8, $39, $00, $00, $71, $8B, $00, $00  ; $F28A
        .byte   $00, $00, $00, $00, $07, $10, $47, $00  ; $F292
        .byte   $72, $71, $71, $00, $00, $00, $00, $00  ; $F29A
        .byte   $1E, $98, $98, $00, $72, $71, $8D, $00  ; $F2A2
        .byte   $00, $01, $01, $00                      ; $F2AA

; ============================================================================
; SOUND EFFECT INDEX TABLE ($F2AE-$F2C3) - 22 bytes
; ============================================================================
D_F2AE:                             ; Used by lda D_F2AE,y at $F607
sound_effect_table:
        .byte   $00, $00, $00, $00, $01, $00, $03, $00  ; $F2AE
        .byte   $76, $F2, $00, $03, $00, $08, $08, $08  ; $F2B6
        .byte   $06, $05, $80, $FF, $40, $00            ; $F2BE
