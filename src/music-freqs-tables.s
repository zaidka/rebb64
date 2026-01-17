;===============================================================================
; music-freqs-tables.s - Music frequency tables and related code
;===============================================================================
; Originally from data/music-freqs.bin (288 bytes) + RTS from sound-engine.s
; Located at $F39C-$F4BC (289 bytes total when including final RTS)
;
; This file contains:
;   - Note offset table (29 bytes)
;   - Frequency table low bytes (95 bytes)
;   - Frequency table high bytes (95 bytes)
;   - Music initialization code (69 bytes)
;   - Final RTS (1 byte) - moved from sound-engine.s
;===============================================================================

.setcpu "6502"

;===============================================================================
; Data Tables
;===============================================================================

;-------------------------------------------------------------------------------
; Note offset table ($F39C-$F3B8, 29 bytes)
; Maps note values to frequency table offsets
;-------------------------------------------------------------------------------
        .segment "MUSICFREQS"

note_offset_table:
        .byte   $0F, $14, $19, $1E, $23, $28, $2D, $32
        .byte   $37, $3C, $41, $46, $4B, $50, $55, $5A
        .byte   $5F, $64, $69, $6E, $73, $78, $7D, $82
        .byte   $87, $8C, $91, $96, $9B

;-------------------------------------------------------------------------------
; Frequency table - Low bytes ($F3B9-$F417, 95 bytes)
; SID frequency values for musical notes (low byte)
;-------------------------------------------------------------------------------
FREQ_TABLE_LO:
        .byte   $A0, $28, $3C, $4B, $60, $74, $8B, $A4
        .byte   $BC, $D4, $F2, $11, $31, $51, $72, $98
        .byte   $BF, $EA, $16, $45, $78, $AD, $E5, $20
        .byte   $5F, $9F, $E6, $32, $80, $D4, $2E, $8A
        .byte   $EF, $5A, $CA, $3E, $BC, $3F, $CD, $64
        .byte   $00, $A9, $5A, $16, $DE, $B0, $8F, $7C
        .byte   $79, $81, $9B, $C6, $02, $53, $B4, $2B
        .byte   $BA, $5F, $1F, $F8, $ED, $05, $35, $8A
        .byte   $01, $A1, $67, $57, $74, $BF, $3F, $F1
        .byte   $DE, $04, $6C, $15, $06, $44, $CF, $AD
        .byte   $E8, $7E, $7E, $E5, $BA, $0A, $D7, $2E
        .byte   $0D, $84, $9D, $5C, $CE, $00, $00

;-------------------------------------------------------------------------------
; Frequency table - High bytes ($F418-$F476, 95 bytes)
; SID frequency values for musical notes (high byte)
;-------------------------------------------------------------------------------
FREQ_TABLE_HI:
        .byte   $01, $01, $01, $01, $01, $01, $01, $01
        .byte   $01, $01, $01, $02, $02, $02, $02, $02
        .byte   $02, $02, $03, $03, $03, $03, $03, $04
        .byte   $04, $04, $04, $05, $05, $05, $06, $06
        .byte   $06, $07, $07, $08, $08, $09, $09, $0A
        .byte   $0B, $0B, $0C, $0D, $0D, $0E, $0F, $10
        .byte   $11, $12, $13, $14, $16, $17, $18, $1A
        .byte   $1B, $1D, $1F, $20, $22, $25, $27, $29
        .byte   $2C, $2E, $31, $34, $37, $3A, $3E, $41
        .byte   $45, $4A, $4E, $53, $58, $5D, $62, $68
        .byte   $6E, $75, $7C, $83, $8B, $94, $9C, $A6
        .byte   $B0, $BA, $C5, $D1, $DD, $EB, $00

;===============================================================================
; Music Initialization Code ($F46C-$F4BC, 81 bytes)
;===============================================================================
; Initializes music system with waveforms and frequency tables
; References external symbols at $F922-$F924 (in sfx-music.bin)
; NOTE: This code appears to be unreachable - not called by the game
;
; First 11 bytes ($F46C-$F476) appear to be additional frequency table values
; or padding before the actual executable code starts at $F477
;-------------------------------------------------------------------------------

; External references to music waveform tables at $F922-$F924
; These are defined in binaries.s and exported there
; (No .import needed since binaries.s is included before this file)

music_init_code:
        lda     music_waveform_table,y          ; $F477: B9 24 F9
        sta     smc_adc_operand                 ; $F47A: 8D B3 F4 (self-mod)
        ldx     #$02                            ; $F47D: A2 02
        
@loop1:
        lda     music_waveform_table_lo,y       ; $F47F: B9 22 F9
        sta     $8A,x                           ; $F482: 95 8A
        lda     music_waveform_table_hi,y       ; $F484: B9 23 F9
        sta     $8D,x                           ; $F487: 95 8D
        sty     $9E                             ; $F489: 84 9E
        lda     #$00                            ; $F48B: A9 00
        ldy     D_742D,x                        ; $F48D: BC 2D 74
        sta     $87,x                           ; $F490: 95 87
        sta     D_F2BB,y                        ; $F492: 99 BB F2
        sta     D_F2BF,y                        ; $F495: 99 BF F2
        lda     D_7433,x                        ; $F498: BD 33 74
        sta     $82,x                           ; $F49B: 95 82
        lda     #$01                            ; $F49D: A9 01
        sta     $A0,x                           ; $F49F: 95 A0
        sta     D_F308,x                        ; $F4A1: 9D 08 F3
        sta     D_F305,x                        ; $F4A4: 9D 05 F3
        ldy     $9E                             ; $F4A7: A4 9E
        dey                                     ; $F4A9: 88
        dey                                     ; $F4AA: 88
        dex                                     ; $F4AB: CA
        bpl     @loop1                          ; $F4AC: 10 D1
        
        clc                                     ; $F4AE: 18
        lda     #$00                            ; $F4AF: A9 00
        tax                                     ; $F4B1: AA
        
loop2:
smc_adc_operand := * + 1                        ; $F4B3: Self-modified by $F47A (operand of ADC)
        adc     #$05                            ; $F4B2: 69 05
        sta     D_F39A,x                        ; $F4B4: 9D 9A F3
        inx                                     ; $F4B7: E8
        cpx     #$20                            ; $F4B8: E0 20
        bcc     loop2                           ; $F4BA: 90 F6
        
        rts                                     ; $F4BC: 60
