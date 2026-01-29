; ============================================================================
; rebb64 - Music Command Handler Dispatch Table
; ============================================================================
; Address Range: $F262-$F2AD (76 bytes)
;
; This file now contains only the music timing and control data tables:
;   - Music timing data (used by $8A command to set frequency pointers)
;   - Music control parameters (state storage for music pointers and parameters)
;   - (Sound effect index table is in music-sound-data.s)
;
; Referenced by:
;   - sound-engine.s at $F57B: jmp (D_F256) - indirect jump to handler code
;   - sound-engine.s at $F607: lda D_F2AE,y - sound effect table lookup
; ============================================================================

.segment "MUSICTABLES"

; ============================================================================
; MUSIC TIMING DATA ($F262-$F289) - 40 bytes
; ============================================================================
; Frequency pointer target table - used by $8A music commands to set the
; frequency table pointer (D_F2B6/D_F2B7) for voice parameter blocks.
; Each address in this table is referenced as a pointer target by the
; $8A command handler (music_handler_05).
music_timing_data:
        .byte   $03, $08, $03      ; $F262
D_F265:                             ; Referenced by $8A cmd in credits music
        .byte   $0C, $03, $08      ; $F265
D_F268:                             ; Referenced by $8A cmd in credits music
        .byte   $00, $05           ; $F268
        .byte   $09, $05           ; $F26A
D_F26C:                             ; Referenced by $8A cmd in title music voice 1
        .byte   $0C, $04, $07      ; $F26C
D_F26F:                             ; Referenced by $8A cmd in credits music
        .byte   $00, $08, $03      ; $F26F
        .byte   $06                ; $F272
D_F273:                             ; Referenced by $8A cmd in title music voice 1
        .byte   $0C, $02, $07      ; $F273
D_F276:                             ; Referenced as embedded pointer in voice parameter blocks
        .byte   $00, $0C, $00      ; $F276
D_F279:                             ; Referenced by $8A cmd in title/credits music
        .byte   $0C                ; $F279
        .byte   $04, $07           ; $F27A
D_F27C:                             ; Referenced by $8A cmd in title music voice 0
        .byte   $0C, $03, $07      ; $F27C
D_F27F:                             ; Referenced as embedded pointer in sfx_instr_3
        .byte   $0C, $18, $0C      ; $F27F
        .byte   $18                ; $F282
D_F283:                             ; Referenced by $8A cmd in title music voice 0
        .byte   $0A, $04, $07      ; $F283
D_F286:                             ; Referenced as embedded pointer in sfx_instr_22
        .byte   $0C, $05, $07, $00 ; $F286

; ============================================================================
; MUSIC CONTROL PARAMETERS ($F28A-$F2AD) - 36 bytes
; ============================================================================
; Working RAM / state storage with initial values
; Accessed as indexed arrays:
;   D_F28A,y - Music pointer save slots (low bytes)
;   D_F28E,y - Music pointer save slots (high bytes)
;   D_F292,y - Music parameter storage
music_control_data:
D_F28A:                             ; Music pointer save slots (low bytes)
        .byte   $D8, $39, $00, $00
D_F28E:                             ; Music pointer save slots (high bytes)
        .byte   $71, $8B, $00, $00
D_F292:                             ; Music parameter storage
        .byte   $00, $00, $00, $00, $07, $10, $47, $00  ; $F292
        .byte   $72, $71, $71, $00, $00, $00, $00, $00  ; $F29A
        .byte   $1E, $98, $98, $00, $72, $71, $8D, $00  ; $F2A2
        .byte   $00, $01, $01, $00                      ; $F2AA

; Sound effect index table ($F2AE-$F2C3) moved to music-sound-data.s
; (must be contiguous with CODE_F2C4 voice parameter blocks)
