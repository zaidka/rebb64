;===============================================================================
; sfx-music-data.s - Sound Effects and Music Sequence Data
;===============================================================================
; Address: $F922-$FDFF (1246 bytes)
; Originally: data/sfx-music.bin
;
; This file contains:
;   - Music track pointers (3 sequences)
;   - Sound effect index/parameter tables
;   - Sound effect parameter blocks (~20 effects)
;   - Music sequence data (notes, durations, commands)
;
; The sound engine processes this data to generate all in-game music and
; sound effects through the SID chip.
;===============================================================================

.setcpu "6502"


        .segment "SFXMUSIC"

;===============================================================================
; SECTION 1: Music Track Pointers ($F922-$F927)
;===============================================================================
; Three 16-bit pointers to music sequence data within this file.
; These are accessed by the unreachable code in music-freqs-tables.s
; and also serve as the initial bytes of the sound effect data structure.
;-------------------------------------------------------------------------------

; These three bytes form music_waveform_table pointers
music_waveform_table_lo:            ; $F922
        .byte   <music_voice0_start ; -> music_voice0_start ($FC72)
music_waveform_table_hi:            ; $F923
        .byte   >music_voice0_start
music_waveform_table:               ; $F924
        .byte   <music_voice1_start ; -> music_voice1_start ($FCA3)

; Continuation of pointer table
        .byte   >music_voice1_start ; $F925
        .byte   <music_voice2_start, >music_voice2_start ; $F926-$F927

;===============================================================================
; SECTION 2: Sound Effect Index and Parameter Tables ($F928-$F977)
;===============================================================================
; This section contains structured parameter data for sound effects.
; Format: groups of bytes with counts, pointers, and parameter values.
;-------------------------------------------------------------------------------

sfx_index_table:
; Music voice config table: 12 groups of 7 bytes (3 word pointers + step byte)
; Group 0 step byte
        .byte   $06                                              ; $F928
; Group 1 (voices -> SFXMUSIC)
        .byte   <music_seq_voice0_alt, >music_seq_voice0_alt    ; $F929: -> $FCA2
        .byte   <music_seq_voice1_alt, >music_seq_voice1_alt    ; $F92B: -> $FCCD
        .byte   <D_FDC4, >D_FDC4                                ; $F92D: -> $FDC4
        .byte   $06                                              ; $F92F
; Group 2 (voice 0 -> SFXMUSIC, voices 1-2 -> MUSICSEQ)
        .byte   <music_seq_voice0_alt, >music_seq_voice0_alt    ; $F930: -> $FCA2
        .byte   <L_70CD, >L_70CD, <L_7161, >L_7161              ; $F932
        .byte   $04                                              ; $F936
; Group 3 (voice 0 -> CODE_FE00, voices 1-2 -> MUSICSEQ)
        .byte   <D_FE40, >D_FE40                                ; $F937: -> $FE40
        .byte   <L_706D, >L_706D, <L_70B7, >L_70B7              ; $F939
        .byte   $05                                              ; $F93D
; Group 4 (all -> MUSICSEQ)
        .byte   <L_71A2, >L_71A2, <L_71B8, >L_71B8, <L_71BE, >L_71BE ; $F93E
        .byte   $06                                              ; $F944
; Group 5 (voices -> SFXMUSIC)
        .byte   <music_seq_voice0_alt, >music_seq_voice0_alt    ; $F945: -> $FCA2
        .byte   <music_seq_voice1_alt, >music_seq_voice1_alt    ; $F947: -> $FCCD
        .byte   <D_FDC4, >D_FDC4                                ; $F949: -> $FDC4
        .byte   $05                                              ; $F94B
; Groups 6-11 (voices -> MUSICSEQ / SCREEN_BUFFER)
        .byte   <L_71CE, >L_71CE, <L_71FB, >L_71FB, <L_7213, >L_7213, $03 ; $F94C
        .byte   <title_music_voice0, >title_music_voice0         ; $F953: -> Voice 0
        .byte   <title_music_voice1, >title_music_voice1         ;        -> Voice 1
        .byte   <title_music_voice2, >title_music_voice2         ;        -> Voice 2
        .byte   $03                                              ;        3 voices
        .byte   <L_7230, >L_7230, <L_723D, >L_723D, <L_723F, >L_723F, $04 ; $F95A
        .byte   <L_724A, >L_724A, <L_7262, >L_7262, <L_7268, >L_7268, $05 ; $F961
        .byte   <L_7278, >L_7278, <L_72A1, >L_72A1, <L_72A9, >L_72A9, $03 ; $F968
        .byte   <L_72C2, >L_72C2, <L_72E9, >L_72E9, <L_72F7, >L_72F7, $05 ; $F96F
sfx_voice_config_0:                 ; $F976 - SFX voice config block 0
        .byte   $BC, $02                                         ; $F976

;===============================================================================
; SECTION 3: Sound Effect Parameter Blocks ($F978-$FC51)
;===============================================================================
; Each block contains ADSR envelope, waveform, and frequency parameters.
; Structure per block (~30-40 bytes):
;   - Control flags
;   - ADSR: Attack, Decay, Sustain, Release
;   - Waveform settings (triangle/sawtooth/pulse/noise)
;   - Frequency and sweep parameters
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; SFX_PARAMS_00: Unknown sound effect 00
; Address: $F978
;-------------------------------------------------------------------------------
sfx_params_00:
        .byte   $70, $FE, $00, $00, $00, $00, $02, $02          ; $F978
        .byte   $00, $00, $00, $05, $00, $00, $00, $04          ; $F980
        .byte   $00, $00, $00, $00, $00, $04, $49, $07          ; $F988

;-------------------------------------------------------------------------------
; SFX_PARAMS_01: Bubble pop or capture sound
; Address: $F990
;-------------------------------------------------------------------------------
sfx_params_01:
        .byte   $FA, $23, $23, $2B                               ; $F990
sfx_voice_config_1:                 ; $F994
        .byte   $D5, $FB, $01, $00                               ; $F994
        .byte   $A0, $0F, $00, $00, $06, $03, $03, $00          ; $F998
        .byte   $02, $04, $02, $02, $00, $05, $40, $00          ; $F9A0

;-------------------------------------------------------------------------------
; SFX_PARAMS_02: Unknown sound effect 02
; Address: $F9A8
;-------------------------------------------------------------------------------
sfx_params_02:
        .byte   $C0, $FF, $00, $08, $49, $07, $F9, $17          ; $F9A8
        .byte   $28, $4A                                         ; $F9B0
sfx_voice_config_2:                 ; $F9B2
        .byte   $30, $F8, $38, $FF, $06, $FF                    ; $F9B2
        .byte   $00, $00, $01, $02, $01, $00, $04, $04          ; $F9B8
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $F9C0

;-------------------------------------------------------------------------------
; SFX_PARAMS_03: Unknown sound effect 03
; Address: $F9C8
;-------------------------------------------------------------------------------
sfx_params_03:
        .byte   $00, $00, $89, $07, $FA, $2D, $1E, $2E          ; $F9C8
sfx_voice_config_3:                 ; $F9D0
        .byte   $00, $00, $00, $00, $01, $00, $05, $00          ; $F9D0
        .byte   $ED, $F9, $00, $07, $00, $0D, $00, $00          ; $F9D8
        .byte   $00, $00, $00, $00, $00, $00                    ; $F9E0

;-------------------------------------------------------------------------------
; SFX_PARAMS_04: Game start or transition
; Address: $F9E6
;-------------------------------------------------------------------------------
sfx_params_04:
        .byte   $00, $08, $49, $07, $FB, $23, $29, $3C          ; $F9E6
        .byte   $40, $40, $40, $40, $43, $3E, $41               ; $F9EE
sfx_voice_config_4:                 ; $F9F5
        .byte   $90                                              ; $F9F5
        .byte   $01, $00, $00, $00, $00, $00, $00, $1E          ; $F9F6
        .byte   $00, $00, $00, $00, $05, $04                    ; $F9FE

;-------------------------------------------------------------------------------
; SFX_PARAMS_05: Unknown sound effect 05
; Address: $FA04
;-------------------------------------------------------------------------------
sfx_params_05:
        .byte   $04, $00, $05, $F0, $01, $10, $FE, $00          ; $FA04
        .byte   $08, $49, $07, $FB, $32, $32, $14               ; $FA0C
sfx_voice_config_5:                 ; $FA13
        .byte   $00                                              ; $FA13
        .byte   $00, $00, $00, $01, $00, $05, $00, $30          ; $FA14
        .byte   $FA, $00, $07, $00, $0D, $00                    ; $FA1C

;-------------------------------------------------------------------------------
; SFX_PARAMS_06: Unknown sound effect 06
; Address: $FA22
;-------------------------------------------------------------------------------
sfx_params_06:
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FA22
        .byte   $08, $49, $07, $FA, $28, $29, $45, $41          ; $FA2A
        .byte   $41, $41, $41, $41, $45, $41                      ; $FA32
sfx_instr_4:                        ; $FA38 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $70, $FE                                         ; $FA38
        .byte   $C8, $00, $00, $00, $00, $00, $01, $02          ; $FA3A
        .byte   $00, $00, $00, $04, $08                         ; $FA42

;-------------------------------------------------------------------------------
; SFX_PARAMS_07: Player death or damage
; Address: $FA47
;-------------------------------------------------------------------------------
sfx_params_07:
        .byte   $08, $06, $05, $80, $FF, $40, $00, $00          ; $FA47
        .byte   $08, $41, $08, $7B, $03, $32                    ; $FA4F
sfx_instr_5:                        ; $FA55 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $1E, $00                                         ; $FA55
        .byte   $E2, $FF, $1E, $00, $00, $00, $04, $08          ; $FA57
        .byte   $04, $00, $10, $05, $00, $00, $00, $00          ; $FA5F
        .byte   $00, $00, $00, $00, $00, $00, $29, $D7          ; $FA67

;-------------------------------------------------------------------------------
; SFX_PARAMS_08: Unknown sound effect 08
; Address: $FA6F
;-------------------------------------------------------------------------------
sfx_params_08:
        .byte   $8D, $14, $64                                    ; $FA6F
sfx_instr_6:                        ; $FA72 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $00, $00, $00, $00, $00                          ; $FA72
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FA77
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FA7F

;-------------------------------------------------------------------------------
; SFX_PARAMS_09: Unknown sound effect 09
; Address: $FA87
;-------------------------------------------------------------------------------
sfx_params_09:
        .byte   $00, $00, $08, $41, $09, $79, $07, $3C          ; $FA87
sfx_instr_7:                        ; $FA8F - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $0F, $00, $F1, $FF, $0F, $00, $00, $00          ; $FA8F
        .byte   $03, $06, $03, $00, $0A, $05, $00, $00          ; $FA97
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FA9F
        .byte   $15, $02, $DA, $03                              ; $FAA7

;-------------------------------------------------------------------------------
; SFX_PARAMS_10: Unknown sound effect 10
; Address: $FAAB
;-------------------------------------------------------------------------------
sfx_params_10:
        .byte   $0F                                              ; $FAAB
sfx_instr_0:                        ; $FAAC - Instrument data (referenced by $86 cmd)
        .byte   $55, $00, $AB, $FF, $55, $00, $00               ; $FAAC
        .byte   $00, $02, $04, $02, $00, $10, $05, $00          ; $FAB3
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FABB
        .byte   $00, $29, $37, $F8                              ; $FAC3

;-------------------------------------------------------------------------------
; SFX_PARAMS_11: Unknown sound effect 11
; Address: $FAC7
;-------------------------------------------------------------------------------
sfx_params_11:
        .byte   $07, $5A                                         ; $FAC7
sfx_instr_8:                        ; $FAC9 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $F4, $FF, $0C, $00, $F4, $FF                    ; $FAC9
        .byte   $00, $00, $02, $04, $02, $00, $08, $05          ; $FACF
        .byte   $08, $08, $05, $05                              ; $FAD7

;-------------------------------------------------------------------------------
; SFX_PARAMS_12: Unknown sound effect 12
; Address: $FADB
;-------------------------------------------------------------------------------
sfx_params_12:
        .byte   $C0, $FF, $30, $00, $00, $0C, $41, $09          ; $FADB
        .byte   $FB, $09, $5A                                    ; $FAE3
sfx_instr_9:                        ; $FAE6 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $00, $00, $00, $00, $00                          ; $FAE6
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FAEB
        .byte   $00, $04, $04, $02, $05, $C0                    ; $FAF3

;-------------------------------------------------------------------------------
; SFX_PARAMS_13: Unknown sound effect 13
; Address: $FAF9
;-------------------------------------------------------------------------------
sfx_params_13:
        .byte   $FF, $40, $00, $00, $0D, $41, $09, $08          ; $FAF9
        .byte   $08, $28                                         ; $FB01
sfx_instr_10:                       ; $FB03 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $F4, $FF, $0C, $00, $F4, $FF                    ; $FB03
        .byte   $00, $00, $02, $04, $02, $00, $08, $05          ; $FB09
        .byte   $08, $08, $00, $05, $E0, $FF                    ; $FB11

;-------------------------------------------------------------------------------
; SFX_PARAMS_14: Unknown sound effect 14
; Address: $FB17
;-------------------------------------------------------------------------------
sfx_params_14:
        .byte   $20, $00, $80, $0C, $49, $09, $F7, $03          ; $FB17
        .byte   $5A                                              ; $FB1F
sfx_instr_11:                       ; $FB20 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $F4, $FF, $0C, $00, $F4, $FF, $00               ; $FB20
        .byte   $00, $02, $04, $02, $00, $08, $05, $08          ; $FB27
        .byte   $08, $00, $04, $D0, $FF, $30                    ; $FB2F

;-------------------------------------------------------------------------------
; SFX_PARAMS_15: Unknown sound effect 15
; Address: $FB35
;-------------------------------------------------------------------------------
sfx_params_15:
        .byte   $00, $00, $0D, $49, $09, $F7, $03, $5A          ; $FB35
sfx_instr_1:                        ; $FB3D - Instrument data (referenced by $86 cmd)
        .byte   $23, $00, $DD, $FF, $23, $00, $00, $00          ; $FB3D
        .byte   $02, $04, $02, $00, $00, $05, $10, $10          ; $FB45
        .byte   $02, $05                                        ; $FB4D

;-------------------------------------------------------------------------------
; SFX_PARAMS_16: Unknown sound effect 16
; Address: $FB4F
;-------------------------------------------------------------------------------
sfx_params_16:
        .byte   $80, $FF, $80, $00, $01, $08, $41, $07          ; $FB4F
        .byte   $BA, $07, $32                                    ; $FB57
sfx_instr_12:                       ; $FB5A - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $38, $FF, $64, $00, $9C                          ; $FB5A
        .byte   $FF, $64, $00, $02, $03, $02, $03, $04          ; $FB5F
        .byte   $05, $00, $00, $00, $04, $00, $00, $00          ; $FB67
        .byte   $00, $00                                        ; $FB6F

;-------------------------------------------------------------------------------
; SFX_PARAMS_17: Unknown sound effect 17
; Address: $FB71
;-------------------------------------------------------------------------------
sfx_params_17:
        .byte   $08, $41, $07, $8B, $07, $32                    ; $FB71
sfx_instr_13:                       ; $FB77 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $00, $00                                         ; $FB77
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FB79
        .byte   $00, $00, $00, $00, $00, $00, $00, $00          ; $FB81
        .byte   $00, $00, $00, $00                              ; $FB89

;-------------------------------------------------------------------------------
; SFX_PARAMS_18: Unknown sound effect 18
; Address: $FB8D
;-------------------------------------------------------------------------------
sfx_params_18:
        .byte   $80, $0C, $49, $06, $98, $03, $0F               ; $FB8D
sfx_instr_14:                       ; $FB94 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $48                                              ; $FB94
        .byte   $F4, $58, $02, $90, $01, $00, $00, $01          ; $FB95
        .byte   $01, $14, $00, $02, $05, $08, $08, $04          ; $FB9D
        .byte   $04, $90, $00, $90, $00, $00, $03, $49          ; $FBA5
        .byte   $16                                             ; $FBAD

;-------------------------------------------------------------------------------
; SFX_PARAMS_19: Unknown sound effect 19
; Address: $FBAE
;-------------------------------------------------------------------------------
sfx_params_19:
        .byte   $F8, $04, $08                                    ; $FBAE
sfx_instr_15:                       ; $FBB1 - Instrument data (referenced by $86 cmd from MUSICSEQ)
        .byte   $48, $F4, $58, $02, $90                          ; $FBB1
        .byte   $01, $00, $00, $01, $01, $14, $00, $02          ; $FBB6
        .byte   $05, $00, $00, $00, $04, $00, $00, $00          ; $FBBE
        .byte   $00, $00, $02, $49                              ; $FBC6

;-------------------------------------------------------------------------------
; SFX_PARAMS_20: Unknown sound effect 20
; Address: $FBCA
;-------------------------------------------------------------------------------
sfx_params_20:
        .byte   $16, $F8, $04, $08                               ; $FBCA
sfx_instr_2:                        ; $FBCE - Instrument data (referenced by $86 cmd)
        .byte   $00, $00, $00, $00                               ; $FBCE
        .byte   $01, $00, $01, $00, $DD, $DD, $00, $03          ; $FBD2
        .byte   $00, $08, $08, $00, $00, $04, $C0, $FF          ; $FBDA
        .byte   $00, $00, $00, $0D, $41, $06, $7A, $09          ; $FBE2

;-------------------------------------------------------------------------------
; SFX_PARAMS_21: Unknown sound effect 21
; Address: $FBEA
;-------------------------------------------------------------------------------
sfx_params_21:
        .byte   $1E                                              ; $FBEA
sfx_instr_3:                        ; $FBEB - Instrument data (referenced by $86 cmd)
        .byte   $00, $00, $00, $00, $01, $00, $03               ; $FBEB
        .byte   $00, <D_F27F, >D_F27F, $00, $03, $00, $08, $00  ; $FBF2
        .byte   $00, $00, $04, $00, $00, $00, $00, $00          ; $FBFA
        .byte   $08, $41, $09, $49                              ; $FC02

;-------------------------------------------------------------------------------
; SFX_PARAMS_22: Unknown sound effect 22
; Address: $FC06
;-------------------------------------------------------------------------------
sfx_params_22:
        .byte   $09, $1E                                         ; $FC06
sfx_instr_16:                       ; $FC08 - Instrument data (referenced by $9A cmd from MUSICSEQ)
        .byte   $3C, $00, $EC, $FF, $FB, $FF                    ; $FC08
        .byte   $00, $00, $06, $12, $64, $00, $01, $04          ; $FC0E
        .byte   $B0, $04                                        ; $FC16

;-------------------------------------------------------------------------------
; SFX_PARAMS_23: Unknown sound effect 23
; Address: $FC18
;-------------------------------------------------------------------------------
sfx_params_23:
sfx_instr_17:                       ; $FC18 - Instrument data (referenced by $9A cmd from MUSICSEQ)
        .byte   $EE, $02, $ED, $FE, $E7, $FF, $00, $00          ; $FC18
        .byte   $01, $03, $04, $00, $02, $04, $E8, $03          ; $FC20
sfx_instr_18:                       ; $FC28 - Instrument data (referenced by $9A cmd from MUSICSEQ)
        .byte   $D8, $FF, $00, $00, $00, $00, $00, $00          ; $FC28
        .byte   $08, $00, $00, $00, $06, $04                    ; $FC30

;-------------------------------------------------------------------------------
; SFX_PARAMS_24: Unknown sound effect 24
; Address: $FC36
;-------------------------------------------------------------------------------
sfx_params_24:
        .byte   $0E, $06                                         ; $FC36
sfx_instr_19:                       ; $FC38 - Instrument data (referenced by $9A cmd from MUSICSEQ)
        .byte   $C8, $00, $9C, $FF, $E7, $FF                    ; $FC38
        .byte   $32, $00, $01, $04, $04, $04, $01, $05          ; $FC3E
        .byte   $78, $05                                         ; $FC46
sfx_instr_20:                       ; $FC48 - Instrument data (referenced by $84 cmd from MUSICSEQ)
        .byte   $D8, $FF, $28, $00, $D8, $FF                    ; $FC48
        .byte   $00, $00, $03, $06, $03, $00                    ; $FC4E

;-------------------------------------------------------------------------------
; SFX_PARAMS_25: Unknown sound effect 25
; Address: $FC54
;-------------------------------------------------------------------------------
sfx_params_25:
        .byte   $02, $05                                         ; $FC54
sfx_instr_21:                           ; $FC56 - Instrument data (referenced by $84 cmd from title music)
        .byte   $00, $00, $00, $00, $01, $00          ; $FC56
        .byte   $02, $00, <D_F25E, >D_F25E, $00, $03, $00, $0D  ; $FC5C
sfx_instr_22:                           ; $FC64 - Instrument data (referenced by $84 cmd from title music)
        .byte   $00, $00, $00, $00, $01, $00, $01, $00          ; $FC64
        .byte   <D_F286, >D_F286, $00, $03, $00, $0D            ; $FC6C
music_voice0_start:                 ; $FC72 - Voice 0 music start (END + duration)
        .byte   $60, $02                                         ; $FC72

;===============================================================================
; SECTION 4: Music Sequence Data ($FC52-$FDFF)
;===============================================================================
; Music sequences use a custom format:
;   - Note values $00-$5F followed by duration byte $01-$0F
;   - Command bytes $60-$FF for control (tempo, octave, loop, etc.)
;   - Sequences are referenced by pointers in Section 1
;
; Command reference:
;   $60 = END/STOP marker
;   $70 = Duration base setting
;   $80 = Voice control
;   $86 = Jump to pattern
;   $88 = Set tempo
;   $8A = Set instrument
;   $92 = Loop start
;   $94 = Set octave
;   $96 = Loop end
;   $98 = Silence/rest
;-------------------------------------------------------------------------------

music_sequence_data:
; --- Voice 0 melody ---
        .byte   $86                                              ; $FC74: copy instrument
        .byte   <sfx_instr_0, >sfx_instr_0                      ;   -> sfx_instr_0 ($FAAC)
        .byte   $88, $0C, $33, $02, $5F, $04, $33, $04, $32, $02, $30, $04, $32                 ; $FC77
        .byte   $02, $33, $02, $35, $02, $2E, $06, $32, $04, $30, $06, $2B, $04, $2B, $02, $32 ; $FC84
        .byte   $04, $30, $07                                    ; $FC94
        .byte   $86                                              ; $FC97: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
        .byte   $29, $06, $2B, $06, $2D, $07, $88, $00          ; $FC9A
music_seq_voice0_alt:               ; $FCA2 - Alt voice 0 start
        .byte   $98                                              ; $FCA2: silence/rest
music_voice1_start:                 ; $FCA3 - Voice 1 start
        .byte   $60                                              ; $FCA3: end/stop
; --- Voice 1 melody ---
        .byte   $01                                              ; $FCA4
        .byte   $86                                              ; $FCA5: copy instrument
        .byte   <sfx_instr_2, >sfx_instr_2                      ;   -> sfx_instr_2 ($FBCE)
        .byte   $88, $0C, $8A, <D_F261, $80, $08, $2B, $02, $82, $8A, <D_F268, $80              ; $FCA8
        .byte   $08, $29, $02, $82, $8A, <D_F26F, $80, $08, $28, $02, $82, $8A, <D_F279, $29, $07, $29 ; $FCB4
        .byte   $06, $8A, <D_F265, $2B, $06, $2D, $07, $88, $00     ; $FCC4
music_seq_voice1_alt:               ; $FCCD - Alt voice 1 start (end marker)
        .byte   $60, $01                                         ; $FCCD: end/stop + duration
        .byte   $86                                              ; $FCCF: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
music_seq_loop_a:                   ; $FCD2 - Loop target A
        .byte   $94, <L_7060, >L_7060                            ; $FCD2: call subroutine -> L_7060
        .byte   $35, $02, $33, $02, $37, $02, $35, $02, $33, $01, $32, $03, $35, $06            ; $FCD5
        .byte   $94                                              ; $FCE3: call subroutine
        .byte   <music_seq_pattern_a, >music_seq_pattern_a       ;   -> music_seq_pattern_a ($FD27)
        .byte   $37, $03, $35, $02, $35, $02, $37, $02, $39, $02, $94, <L_7060, >L_7060, $35   ; $FCE6
        .byte   $01, $33, $03, $37, $02, $35, $02, $33, $01, $32, $03, $35, $06                 ; $FCF4
        .byte   $94                                              ; $FD01: call subroutine
        .byte   <music_seq_pattern_a, >music_seq_pattern_a       ;   -> music_seq_pattern_a ($FD27)
        .byte   $35, $03, $3A, $02                               ; $FD04
        .byte   $94                                              ; $FD08: call subroutine
        .byte   <music_seq_pattern_b, >music_seq_pattern_b       ;   -> music_seq_pattern_b ($FD42)
        .byte   $37, $06, $3E, $04, $3C, $0A                    ; $FD0B
        .byte   $94                                              ; $FD11: call subroutine
        .byte   <music_seq_pattern_b, >music_seq_pattern_b       ;   -> music_seq_pattern_b ($FD42)
        .byte   $35, $04, $3E, $02, $35, $02, $3E, $02, $3A, $0A, $35, $02, $37, $02, $39, $02 ; $FD14
        .byte   $96                                              ; $FD24: loop back
        .byte   <music_seq_loop_a, >music_seq_loop_a             ;   -> music_seq_loop_a ($FCD2)
music_seq_pattern_a:                ; $FD27 - Pattern A subroutine
        .byte   $32, $01, $30, $01, $2E, $02, $30, $02, $32, $02, $33, $02, $30                 ; $FD27
        .byte   $02, $32, $01, $33, $03, $35, $02, $35, $02, $37, $02, $39, $01, $98            ; $FD34
music_seq_pattern_b:                ; $FD42 - Pattern B subroutine
        .byte   $35, $02                                         ; $FD42
        .byte   $37, $02, $38, $02, $39, $02                    ; $FD44
        .byte   $86                                              ; $FD4A: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
        .byte   $41, $02, $43, $02, $44, $02, $45               ; $FD4D
        .byte   $02                                              ; $FD54
        .byte   $86                                              ; $FD55: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $35, $02, $37, $02, $39, $02, $3A, $02          ; $FD58
        .byte   $86                                              ; $FD60: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
        .byte   $41                                              ; $FD63
        .byte   $02, $43, $02, $45, $02, $46, $02               ; $FD64
        .byte   $86                                              ; $FD6B: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $35, $02, $37, $02, $39, $02                    ; $FD6E
        .byte   $3C, $02                                         ; $FD74
        .byte   $86                                              ; $FD76: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
        .byte   $41, $02, $43, $02, $45, $02, $48, $02          ; $FD79
        .byte   $86                                              ; $FD81: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $35, $02, $37, $02, $39, $02, $3E, $02          ; $FD84
        .byte   $86                                              ; $FD8C: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
        .byte   $41, $02, $43, $02, $45                          ; $FD8F
        .byte   $02, $4A, $02                                    ; $FD94
        .byte   $86                                              ; $FD97: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $3A, $02, $3C, $02, $3E, $02, $3F, $02, $3F, $04                                ; $FD9A
        .byte   $3F, $04, $3E, $02, $3C, $04, $3E, $0C, $3E, $04, $3C, $06, $98                 ; $FDA4
music_voice2_start:                 ; $FDB1 - Voice 2 start
        .byte   $94, <L_7040, >L_7040                            ; $FDB1: call subroutine -> L_7040
        .byte   $1F, $10, $1D, $10, $1C, $10, $1D, $07, $1D, $06, $1F, $06, $21, $07, $60, $01 ; $FDB4
; --- Voice 2 drum pattern ---
D_FDC4:                             ; $FDC4 - Drum loop target
        .byte   $94, <L_7048, >L_7048                            ; $FDC4: call subroutine -> L_7048
        .byte   $92, $00, <L_7058, >L_7058                      ; $FDC7: set param + call -> L_7058
        .byte   $92, $FD, <L_7058, >L_7058                      ; $FDCB: set param + call -> L_7058
        .byte   $92, $00, <L_7058, >L_7058                      ; $FDCF: set param + call -> L_7058
        .byte   $80                                              ; $FDD3
        .byte   $06, $13, $02, $1F, $02, $82, $16, $02          ; $FDD4
        .byte   $94                                              ; $FDDC: call subroutine
        .word   D_FE02                                           ;   -> D_FE02 (in CODE_FE00)
        .byte   $13, $02, $1F, $02, $13                          ; $FDDF
        .byte   $02, $1F, $02                                    ; $FDE4
        .byte   $94                                              ; $FDE7: call subroutine
        .word   D_FE37                                           ;   -> D_FE37 (in CODE_FE00)
        .byte   $18, $02                                         ; $FDE9
        .byte   $94                                              ; $FDEC: call subroutine
        .word   D_FE02                                           ;   -> D_FE02 (in CODE_FE00)
        .byte   $11, $02, $18, $02, $11                          ; $FDEE
        .byte   $02, $18, $02, $16, $0A, $11, $02, $13, $02, $15, $02 ; $FDF3
        .byte   $96                                              ; $FDFF: loop back
; NOTE: The following 2 bytes serve dual purpose:
; 1. Loop target address for the $96 loop command above (points to D_FDC4)
; 2. Start of music sequence data at D_FE00 (first bytes in CODE_FE00)
; The $96 command reads these 2 bytes as its address operand.
D_FE00:
        .word   D_FDC4                                           ; -> D_FDC4 loop target

;===============================================================================
; End of sfx-music-data.s
;===============================================================================
