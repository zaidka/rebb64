; ============================================================================
; MUSIC COMMAND HANDLER POINTERS ($F240-$F261) - 34 bytes
; ============================================================================
; 17 pointers to music command handler routines in the $73xx range
; These point to CODE in music-command-handlers.s, not to music data!
.segment "MUSICPTRS"

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
D_F25E:                             ; Referenced as embedded pointer in sfx_instr_21
        .word   $0007               ; $F25E: Handler 15 - Invalid/placeholder
        .byte   $07                 ; $F260: Handler 16 low byte
D_F261:                             ; Referenced by $8A cmd in credits music voice 1
        .byte   $00                 ; $F261: Handler 16 high byte
