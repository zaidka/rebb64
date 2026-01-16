; ============================================================================
; rebb64 - Music & Sound Effect Data Tables
; ============================================================================
; Address Range: $F2C4-$F39B (216 bytes)
;
; This file contains data tables used by the music and sound effect system.
; These are primarily lookup tables for the sound engine located in chunk3.
;
; Referenced by:
;   - Music/SFX handler at $F4A4, $F4CC, $F58B, $F5BB, $F5C0, $F5CF
;   - Sound state management at $F60A, $F679, $F7A8, $F809, $F88D, $F8D9
;
; ⚠️  WARNING: This file contains DATA ONLY - no executable code
; ⚠️  Disassemblers may show "illegal opcodes" but these are data bytes
; ============================================================================

; D_F2C4 - Sound channel data table (accessed at $F5BB)
.segment "CODE_F2C4"

    .byte $00                   ; $F2C4

; D_F2C5 - Sound parameter table (accessed at $F5C0)
    .byte $08                   ; $F2C5

; D_F2C6 - Sound configuration table (accessed at $F5CF)
    .byte $41, $08              ; $F2C6-$F2C7

; D_F2C8 - Extended sound data
D_F2C8:
    .byte $7B, $03, $32         ; $F2C8-$F2CA
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
    .byte $64, $F4, $FF, $0C                ; $F2E7-$F2EA: Timing/frequency values
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
    .byte $01, $01              ; $F305-$F306: Voice 1 state (2 bytes)
    .byte $01, $01              ; $F307-$F308: Voice 2 state (2 bytes)
    .byte $01, $01              ; $F309-$F30A: Voice 3 state (2 bytes)

; D_F30B - Sound control flags
    .byte $D8                   ; $F30B (data, not "CLD")
    .byte $FF, $00, $00         ; $F30C-$F30E (data)
    .byte $00                   ; $F30F
    .byte $00, $00, $00, $08    ; $F310-$F313
    .byte $00, $00, $00, $06    ; $F314-$F317
    .byte $04, $0E, $06         ; $F318-$F31A

; D_F31B - Sound effect index/offset table (accessed at $F60A, $F809, $F8D9)
    .byte $00                   ; $F31B
    .byte $00                   ; $F31C
    .byte $00                   ; $F31D
    .byte $00                   ; $F31E
    .byte $01, $00              ; $F31F-$F320
    .byte $03                   ; $F321
    .byte $00                   ; $F322

; D_F323 - Sound frequency/pitch table (accessed at $F679, $F7A8, $F91B)
    .byte $76                   ; $F323
    .byte $F2                   ; $F324
    .byte $2D                   ; $F325
    .byte $03                   ; $F326
    .byte $01                   ; $F327
    .byte $08                   ; $F328
    .byte $08                   ; $F329
    .byte $08                   ; $F32A
    .byte $00                   ; $F32B
    .byte $05                   ; $F32C
    .byte $80                   ; $F32D
    .byte $FF                   ; $F32E
    .byte $40                   ; $F32F
    .byte $00                   ; $F330
    .byte $00                   ; $F331
    .byte $08                   ; $F332

; D_F333 - Sound envelope/pattern data
    .byte $B0, $0E              ; $F333-$F334 (data, not "BCS")
    .byte $41, $00              ; $F335-$F336 (data, not "EOR")
    .byte $20, $00, $03         ; $F337-$F339 (data, not "JSR IERROR")
    .byte $03, $00              ; $F33A-$F33B (data)
    .byte $00                   ; $F33C
    .byte $01, $1E, $00, $E2, $FF, $1E ; $F33D-$F342

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
    .byte $29, $00, $03, $04    ; $F35A-$F35D
    .byte $00, $00, $00, $F4    ; $F35E-$F361
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
    .byte $5A                   ; $F37D (data byte)
    .byte $01, $04              ; $F37E-$F37F (data, not "ORA")
    .byte $02                   ; $F380 (data, not "KIL")
    .byte $00, $00, $07         ; $F381-$F383

; D_F384 - Extended sound configuration
    .byte $D8, $FF, $00, $00    ; $F384-$F387
    .byte $00, $00, $00, $00    ; $F388-$F38B

; D_F38C - Sound channel register offset table (14 bytes)
; Maps sound channels to SID chip register offsets
; SID voice registers: Voice 1 = $D400-$D406, Voice 2 = $D407-$D40D, Voice 3 = $D40E-$D414
    .byte $08, $00, $00, $00    ; $F38C-$F38F: Offsets for voice/parameter 0-3
    .byte $06, $04, $0E         ; $F390-$F392: Offsets $06, $04, $0E (maybe freq hi/lo, control)
    .byte $06, $0E, $06         ; $F393-$F395: Pattern repeats: $06, $0E, $06
    .byte $08, $00, $00, $00    ; $F396-$F399: Pattern repeats: $08, $00, $00, $00

; D_F39A - Multiplication-by-5 lookup table (partial, first 2 entries)
; Full table: multiply_by_5[n] = n * 5 (for n = 1, 2, 3, ...)
; Used to quickly calculate array offsets for 5-byte structures
; Only first 2 bytes in this section; continues in music-freqs.bin with:
;   $0F(15), $14(20), $19(25), $1E(30), $23(35), $28(40), $2D(45), $32(50)...
    .byte $05, $0A              ; $F39A-$F39B: [1*5=5, 2*5=10]
    ; Remaining bytes ($0F, $14, $19, ...) are in music-freqs.bin
