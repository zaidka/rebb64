; ============================================================================
; rebb64 - Music & Sound Effect Data Tables
; ============================================================================
; Address Range: $F2AE-$F39B (238 bytes)
;
; This file contains data tables used by the music and sound effect system.
; These are primarily lookup tables for the sound engine located in chunk3.
;
; The voice parameter blocks at $F2AE use Y-indexed addressing with offsets
; $00/$1D/$3A that span contiguously from $F2AE through $F39B.
; All this data MUST remain in a single segment to maintain contiguity.
;
; Referenced by:
;   - Music/SFX handler at $F4A4, $F4CC, $F58B, $F5BB, $F5C0, $F5CF
;   - Sound state management at $F60A, $F679, $F7A8, $F809, $F88D, $F8D9
;
; WARNING: This file contains DATA ONLY - no executable code
; Disassemblers may show "illegal opcodes" but these are data bytes
; ============================================================================

.segment "CODE_F2C4"

; ============================================================================
; SOUND EFFECT INDEX TABLE ($F2AE-$F2C3) - 22 bytes
; ============================================================================
; Start of voice parameter blocks. These extend contiguously into the data
; below. Voice blocks use Y-indexed addressing with offsets $00/$1D/$3A
; from these base addresses.
; ============================================================================
D_F2AE:                             ; Used by lda D_F2AE,y at $F607
sound_effect_table:
        .byte   $00, $00, $00, $00, $01, $00, $03, $00  ; $F2AE-$F2B5 (8 bytes)
D_F2B6:                             ; $F2B6 - Frequency pointer low byte (into MUSICTABLES)
        .byte   <D_F276                                 ; $F2B6
D_F2B7:                             ; $F2B7 - Frequency pointer high byte (into MUSICTABLES)
        .byte   >D_F276                                 ; $F2B7
        .byte   $00, $03                                ; $F2B8-$F2B9
        .byte   $00                                     ; $F2BA
D_F2BB:                             ; $F2BB
        .byte   $08                                     ; $F2BB
        .byte   $08                                     ; $F2BC
        .byte   $08                                     ; $F2BD
        .byte   $06                                     ; $F2BE
D_F2BF:                             ; $F2BF
        .byte   $05, $80, $FF, $40, $00                 ; $F2BF-$F2C3

; D_F2C4 - Sound channel data table (accessed at $F5BB)
D_F2C4:
    .byte $00                   ; $F2C4

; D_F2C5 - Sound parameter table (accessed at $F5C0)
D_F2C5:
    .byte $08                   ; $F2C5

; D_F2C6 - Sound configuration table (accessed at $F5CF)
D_F2C6:
    .byte $41                   ; $F2C6
D_F2C7:
    .byte $08                   ; $F2C7

; D_F2C8 - Extended sound data
D_F2C8:
    .byte $7B                   ; $F2C8
D_F2C9:
    .byte $03                   ; $F2C9
D_F2CA:
    .byte $32                   ; $F2CA
; Voice 1 source block (24 bytes from $F2CB, copied by SMC in sound-engine.s)
voice1_src_block:
    .byte $1E, $00, $E2         ; $F2CB-$F2CD
    .byte $FF, $1E, $00         ; $F2CE-$F2D0
    .byte $00                   ; $F2D1
    .byte $00, $04              ; $F2D2-$F2D3
    .byte $08                   ; $F2D4
    .byte $04, $00              ; $F2D5-$F2D6 (data, not "NOP D6510")
    .byte $10, $05              ; $F2D7-$F2D8 (data, not "BPL")
    .byte $00                   ; $F2D9
    .byte $00, $00, $00, $00    ; $F2DA-$F2DD

; L_F2DE - Sound effect parameter block (39 bytes)
; Contains envelope data, timing values, and waveform parameters
L_F2DE:
    .byte $00, $00, $00, $00, $00           ; $F2DE-$F2E2: Initial zeros (padding/delay?)
    .byte $29, $D7, $8D, $14                ; $F2E3-$F2E6: Control bytes (AND mask $29, values)
    .byte $64                               ; $F2E7: Timing value
; Voice 2 source block (24 bytes from $F2E8, copied by SMC in sound-engine.s)
voice2_src_block:
    .byte $F4, $FF, $0C                     ; $F2E8-$F2EA: Timing/frequency values
    .byte $00, $F4, $FF, $00                ; $F2EB-$F2EE: More parameters
    .byte $00, $02, $04, $02, $00           ; $F2EF-$F2F3: Envelope shape? (0,2,4,2,0 triangle)
    .byte $08                               ; $F2F4: Duration or counter
    .byte $05, $08                          ; $F2F5-$F2F6: Step values
    .byte $08, $00                          ; $F2F7-$F2F8: More parameters
    .byte $05, $E0, $FF                     ; $F2F9-$F2FB: Values (note: $E0 = 224, $FF = 255)
    .byte $20, $00, $80                     ; $F2FC-$F2FE: Pointer-like values ($2000, $80)
    .byte $0C, $49, $09                     ; $F2FF-$F301: More control bytes
    .byte $F7, $03                          ; $F302-$F303: Values
    .byte $5A                               ; $F304: Final parameter

; D_F305 - Sound channel state array (6 bytes total for 3 SID voices)
; Heavily accessed by sound engine at $F4A4, $F4CC, $F58B, $F88D
; Initial values all set to $01 (enabled/ready state)
D_F305:
    .byte $01                   ; $F305: Voice 1 state byte 1
D_F306:
    .byte $01                   ; $F306: Voice 1 state byte 2
D_F307:
    .byte $01                   ; $F307: Voice 2 state byte 1
D_F308:
    .byte $01                   ; $F308: Voice 2 state byte 2
D_F309:
    .byte $01                   ; $F309: Voice 3 state byte 1
D_F30A:
    .byte $01                   ; $F30A: Voice 3 state byte 2

; D_F30B - Sound control flags
D_F30B:
    .byte $D8                   ; $F30B (data, not "CLD")
    .byte $FF, $00, $00         ; $F30C-$F30E (data)
    .byte $00                   ; $F30F
    .byte $00, $00, $00, $08    ; $F310-$F313
    .byte $00, $00, $00, $06    ; $F314-$F317
    .byte $04, $0E, $06         ; $F318-$F31A

; D_F31B - Sound effect index/offset table (accessed at $F60A, $F809, $F8D9)
D_F31B:
    .byte $00                   ; $F31B
D_F31C:
    .byte $00                   ; $F31C
D_F31D:
    .byte $00                   ; $F31D
D_F31E:
    .byte $00                   ; $F31E
D_F31F:
    .byte $01                   ; $F31F
D_F320:
    .byte $00                   ; $F320
D_F321:
    .byte $03                   ; $F321
D_F322:
    .byte $00                   ; $F322

; D_F323 - Sound frequency/pitch table (accessed at $F679, $F7A8, $F91B)
D_F323:                             ; Frequency pointer low byte (copy of D_F2B6 for voice 1 dest)
        .byte   <D_F276               ; $F323
D_F324:                             ; Frequency pointer high byte (copy of D_F2B7 for voice 1 dest)
        .byte   >D_F276               ; $F324
D_F325:
    .byte $2D                   ; $F325
D_F326:
    .byte $03                   ; $F326
D_F327:
    .byte $01                   ; $F327
D_F328:
    .byte $08                   ; $F328
D_F329:
    .byte $08                   ; $F329
D_F32A:
    .byte $08                   ; $F32A
D_F32B:
    .byte $00                   ; $F32B
D_F32C:
    .byte $05                   ; $F32C
D_F32D:
    .byte $80                   ; $F32D
D_F32E:
    .byte $FF                   ; $F32E
D_F32F:
    .byte $40                   ; $F32F
D_F330:
    .byte $00                   ; $F330
D_F331:
    .byte $00                   ; $F331
D_F332:
    .byte $08                   ; $F332

; D_F333 - Sound envelope/pattern data
D_F333:
    .byte $B0                   ; $F333 (data, not "BCS")
D_F334:
    .byte $0E                   ; $F334
D_F335:
    .byte $41                   ; $F335 (data, not "EOR")
D_F336:
    .byte $00                   ; $F336
D_F337:
    .byte $20                   ; $F337 (data, not "JSR IERROR")
D_F338:
    .byte $00                   ; $F338
D_F339:
    .byte $03                   ; $F339
D_F33A:
    .byte $03                   ; $F33A
D_F33B:
    .byte $00                   ; $F33B
D_F33C:
    .byte $00                   ; $F33C
D_F33D:
    .byte $01                   ; $F33D
; Voice 1 destination block (24 bytes from $F33E, target of SMC in sound-engine.s)
voice1_dst_block:
    .byte $1E, $00, $E2, $FF, $1E ; $F33E-$F342

; L_F343 - Additional sound pattern data
L_F343:
    .byte $00                   ; $F343
    .byte $00, $00, $04         ; $F344-$F346
    .byte $08                   ; $F347
    .byte $04, $00              ; $F348-$F349 (data, not "NOP D6510")
    .byte $00                   ; $F34A
    .byte $05, $00, $00, $00    ; $F34B-$F34E
    .byte $00, $00, $00, $00    ; $F34F-$F352
    .byte $00, $00, $00, $5F    ; $F353-$F356
    .byte $1D, $20, $00         ; $F357-$F359

; D_F35A - Sound effect configuration block
D_F35A:
    .byte $29, $00, $03, $04    ; $F35A-$F35D
    .byte $00, $00, $00         ; $F35E-$F360
; Voice 2 destination block (24 bytes from $F361, target of SMC in sound-engine.s)
voice2_dst_block:
    .byte $F4                   ; $F361
    .byte $FF, $0C, $00, $F4    ; $F362-$F365
    .byte $FF, $00, $00, $02    ; $F366-$F369
    .byte $04, $02, $00, $00, $05 ; $F36A-$F36E
    .byte $08                   ; $F36F
    .byte $08                   ; $F370
    .byte $00                   ; $F371
    .byte $05, $E0, $FF         ; $F372-$F374
    .byte $20, $00, $80         ; $F375-$F377 (data, not "JSR D_8000")
    .byte $0C, $AD, $03         ; $F378-$F37A (data, not "NOP")
    .byte $49, $03              ; $F37B-$F37C (data, not "EOR #$03")

; D_F37D - Sound waveform/noise data
D_F37D:
    .byte $5A                   ; $F37D (data byte)
    .byte $01, $04              ; $F37E-$F37F (data, not "ORA")
    .byte $02                   ; $F380 (data, not "KIL")
    .byte $00, $00, $07         ; $F381-$F383

; D_F384 - Extended sound configuration
D_F384:
    .byte $D8, $FF, $00, $00    ; $F384-$F387
    .byte $00, $00, $00, $00    ; $F388-$F38B

; D_F38C - Sound channel register offset table (14 bytes)
; Maps sound channels to SID chip register offsets
; SID voice registers: Voice 1 = $D400-$D406, Voice 2 = $D407-$D40D, Voice 3 = $D40E-$D414
D_F38C:
    .byte $08                   ; $F38C: Offset for voice/parameter 0
D_F38D:
    .byte $00                   ; $F38D: Offset for voice/parameter 1
D_F38E:
    .byte $00                   ; $F38E: Offset for voice/parameter 2
D_F38F:
    .byte $00                   ; $F38F: Offset for voice/parameter 3
    .byte $06                   ; $F390
D_F391:
    .byte $04                   ; $F391
D_F392:
    .byte $0E                   ; $F392
D_F393:
    .byte $06                   ; $F393
D_F394:
    .byte $0E                   ; $F394
D_F395:
    .byte $06                   ; $F395
D_F396:
    .byte $08                   ; $F396
D_F397:
    .byte $00                   ; $F397
D_F398:
    .byte $00                   ; $F398
D_F399:
    .byte $00                   ; $F399

; D_F39A - Multiplication-by-5 lookup table (first 2 entries)
; Moved to MUSICFREQS segment (music-freqs-tables.s) to keep the full
; multiply-by-5 table contiguous within a single segment.
; See note_offset_table in music-freqs-tables.s for the complete table.
