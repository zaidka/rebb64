;===============================================================================
; music-sequence.s - Music Sequence Data (Level Music)
;===============================================================================
; Address: $7040-$7304 (709 bytes)
; Originally: data/music-sequence.bin
;
; This file contains the music sequence data for level music tracks.
; Music commands embed addresses pointing to instrument data in the
; SFXMUSIC segment, which are expressed as label references to allow
; relocation.
;===============================================================================

.setcpu "6502"

        .segment "MUSICSEQ"

L_7040:
        .byte   $86                                    ; $7040: copy instrument
        .byte   <sfx_instr_8, >sfx_instr_8                      ;   -> sfx_instr_8 ($FAC9)
        .byte   $9A                                    ; $7043: copy 16-byte block
        .byte   <sfx_instr_16, >sfx_instr_16                      ;   -> sfx_instr_16 ($FC08)
        .byte   $8E                                    ; $7046: filter from table
        .byte   $98                                    ; $7047: return
L_7048:
        .byte   $86                                    ; $7048: copy instrument
        .byte   <sfx_instr_9, >sfx_instr_9                      ;   -> sfx_instr_9 ($FAE6)
        .byte   $9A                                    ; $704B: copy 16-byte block
        .byte   <sfx_instr_17, >sfx_instr_17                      ;   -> sfx_instr_17 ($FC18)
        .byte   $8E                                    ; $704E: filter from table
        .byte   $98                                    ; $704F: return
L_7050:
        .byte   $80, $04                              ; $7050: set param $04
        .byte   $18, $02                               ; $7052: note + duration
        .byte   $24, $02                               ; $7054: note + duration
        .byte   $82                                    ; $7056: loop decrement
        .byte   $98                                    ; $7057: return
L_7058:
        .byte   $80, $08                              ; $7058: set param $08
        .byte   $16, $02                               ; $705A: note + duration
        .byte   $22, $02                               ; $705C: note + duration
        .byte   $82                                    ; $705E: loop decrement
        .byte   $98                                    ; $705F: return
L_7060:
        .byte   $3A, $02                               ; $7060: note + duration
        .byte   $39, $02                               ; $7062: note + duration
        .byte   $37, $03                               ; $7064: note + duration
        .byte   $35, $01                               ; $7066: note + duration
        .byte   $39, $02                               ; $7068: note + duration
        .byte   $37, $02                               ; $706A: note + duration
        .byte   $98                                    ; $706C: return
L_706D:
        .byte   $60, $01                               ; $706D: end/rest + duration
        .byte   $86                                    ; $706F: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $88, $F4                              ; $7072: set voice $F4
L_7074:
        .byte   $40, $02                               ; $7074: note + duration
        .byte   $3C, $02                               ; $7076: note + duration
        .byte   $40, $02                               ; $7078: note + duration
        .byte   $3C, $02                               ; $707A: note + duration
        .byte   $40, $02                               ; $707C: note + duration
        .byte   $3C, $02                               ; $707E: note + duration
        .byte   $3E, $02                               ; $7080: note + duration
        .byte   $40, $02                               ; $7082: note + duration
        .byte   $41, $02                               ; $7084: note + duration
        .byte   $3E, $02                               ; $7086: note + duration
        .byte   $41, $02                               ; $7088: note + duration
        .byte   $3E, $02                               ; $708A: note + duration
        .byte   $41, $02                               ; $708C: note + duration
        .byte   $3E, $02                               ; $708E: note + duration
        .byte   $40, $02                               ; $7090: note + duration
        .byte   $41, $02                               ; $7092: note + duration
        .byte   $43, $02                               ; $7094: note + duration
        .byte   $40, $02                               ; $7096: note + duration
        .byte   $43, $02                               ; $7098: note + duration
        .byte   $40, $02                               ; $709A: note + duration
        .byte   $43, $02                               ; $709C: note + duration
        .byte   $40, $02                               ; $709E: note + duration
        .byte   $41, $02                               ; $70A0: note + duration
        .byte   $43, $02                               ; $70A2: note + duration
        .byte   $41, $02                               ; $70A4: note + duration
        .byte   $3E, $02                               ; $70A6: note + duration
        .byte   $41, $02                               ; $70A8: note + duration
        .byte   $3E, $02                               ; $70AA: note + duration
        .byte   $41, $02                               ; $70AC: note + duration
        .byte   $3E, $02                               ; $70AE: note + duration
        .byte   $40, $02                               ; $70B0: note + duration
        .byte   $41, $02                               ; $70B2: note + duration
        .byte   $96                                    ; $70B4: goto/loop
        .byte   <L_7074, >L_7074    ;   -> $7074
L_70B7:
        .byte   $94                                    ; $70B7: call subroutine
        .byte   <L_7048, >L_7048    ;   -> $7048
L_70BA:
        .byte   $92, $00                              ; $70BA: set param + call
        .byte   <L_7050, >L_7050    ;   -> $7050
        .byte   $92, $02                              ; $70BE: set param + call
        .byte   <L_7050, >L_7050    ;   -> $7050
        .byte   $92, $04                              ; $70C2: set param + call
        .byte   <L_7050, >L_7050    ;   -> $7050
        .byte   $92, $02                              ; $70C6: set param + call
        .byte   <L_7050, >L_7050    ;   -> $7050
        .byte   $96                                    ; $70CA: goto/loop
        .byte   <L_70BA, >L_70BA    ;   -> $70BA
L_70CD:
        .byte   $60, $01                               ; $70CD: end/rest + duration
L_70CF:
        .byte   $86                                    ; $70CF: copy instrument
        .byte   <sfx_instr_6, >sfx_instr_6                      ;   -> sfx_instr_6 ($FA72)
        .byte   $88, $0C                              ; $70D2: set voice $0C
        .byte   $28, $02                               ; $70D4: note + duration
        .byte   $21, $02                               ; $70D6: note + duration
        .byte   $27, $02                               ; $70D8: note + duration
        .byte   $20, $02                               ; $70DA: note + duration
        .byte   $1F, $02                               ; $70DC: note + duration
        .byte   $26, $02                               ; $70DE: note + duration
        .byte   $1E, $02                               ; $70E0: note + duration
        .byte   $1D, $02                               ; $70E2: note + duration
        .byte   $24, $02                               ; $70E4: note + duration
        .byte   $1F, $02                               ; $70E6: note + duration
        .byte   $26, $02                               ; $70E8: note + duration
        .byte   $27, $04                               ; $70EA: note + duration
        .byte   $88, $00                              ; $70EC: set voice $00
        .byte   $86                                    ; $70EE: copy instrument
        .byte   <sfx_instr_0, >sfx_instr_0                      ;   -> sfx_instr_0 ($FAAC)
        .byte   $3A, $03                               ; $70F1: note + duration
        .byte   $3A, $04                               ; $70F3: note + duration
        .byte   $86                                    ; $70F5: copy instrument
        .byte   <sfx_instr_13, >sfx_instr_13                      ;   -> sfx_instr_13 ($FB77)
        .byte   $92, $00                              ; $70F8: set param + call
        .byte   <L_710D, >L_710D    ;   -> $710D
        .byte   $92, $05                              ; $70FC: set param + call
        .byte   <L_710D, >L_710D    ;   -> $710D
        .byte   $92, $00                              ; $7100: set param + call
        .byte   <L_710D, >L_710D    ;   -> $710D
        .byte   $92, $07                              ; $7104: set param + call
        .byte   <L_7129, >L_7129    ;   -> $7129
        .byte   $88, $00                              ; $7108: set voice $00
        .byte   $96                                    ; $710A: goto/loop
        .byte   <L_70CF, >L_70CF    ;   -> $70CF
L_710D:
        .byte   $94                                    ; $710D: call subroutine
        .byte   <L_7145, >L_7145    ;   -> $7145
        .byte   $3F, $01                               ; $7110: note + duration
        .byte   $3E, $01                               ; $7112: note + duration
        .byte   $3D, $01                               ; $7114: note + duration
        .byte   $3C, $01                               ; $7116: note + duration
        .byte   $3E, $01                               ; $7118: note + duration
        .byte   $3D, $01                               ; $711A: note + duration
        .byte   $3C, $01                               ; $711C: note + duration
        .byte   $3B, $01                               ; $711E: note + duration
        .byte   $3D, $01                               ; $7120: note + duration
        .byte   $3C, $01                               ; $7122: note + duration
        .byte   $3B, $01                               ; $7124: note + duration
        .byte   $3A, $01                               ; $7126: note + duration
        .byte   $98                                    ; $7128: return
L_7129:
        .byte   $94                                    ; $7129: call subroutine
        .byte   <L_7145, >L_7145    ;   -> $7145
        .byte   $3C, $01                               ; $712C: note + duration
        .byte   $3B, $01                               ; $712E: note + duration
        .byte   $3A, $01                               ; $7130: note + duration
        .byte   $39, $01                               ; $7132: note + duration
        .byte   $38, $01                               ; $7134: note + duration
        .byte   $37, $01                               ; $7136: note + duration
        .byte   $36, $01                               ; $7138: note + duration
        .byte   $35, $01                               ; $713A: note + duration
        .byte   $34, $01                               ; $713C: note + duration
        .byte   $33, $01                               ; $713E: note + duration
        .byte   $32, $01                               ; $7140: note + duration
        .byte   $31, $01                               ; $7142: note + duration
        .byte   $98                                    ; $7144: return
L_7145:
        .byte   $80, $02                              ; $7145: set param $02
        .byte   $40, $01                               ; $7147: note + duration
        .byte   $3F, $01                               ; $7149: note + duration
        .byte   $3E, $01                               ; $714B: note + duration
        .byte   $3D, $01                               ; $714D: note + duration
        .byte   $3C, $01                               ; $714F: note + duration
        .byte   $3D, $01                               ; $7151: note + duration
        .byte   $3E, $01                               ; $7153: note + duration
        .byte   $3F, $01                               ; $7155: note + duration
        .byte   $82                                    ; $7157: loop decrement
        .byte   $40, $01                               ; $7158: note + duration
        .byte   $3F, $01                               ; $715A: note + duration
        .byte   $3E, $01                               ; $715C: note + duration
        .byte   $3D, $01                               ; $715E: note + duration
        .byte   $98                                    ; $7160: return
L_7161:
        .byte   $94                                    ; $7161: call subroutine
        .byte   <L_7040, >L_7040    ;   -> $7040
        .byte   $21, $06                               ; $7164: note + duration
        .byte   $20, $06                               ; $7166: note + duration
        .byte   $1F, $06                               ; $7168: note + duration
        .byte   $1E, $08                               ; $716A: note + duration
        .byte   $86                                    ; $716C: copy instrument
        .byte   <sfx_instr_0, >sfx_instr_0                      ;   -> sfx_instr_0 ($FAAC)
        .byte   $90                                    ; $716F: filter cutoff $78
        .byte   $43, $03                               ; $7170: note + duration
        .byte   $43, $04                               ; $7172: note + duration
        .byte   $86                                    ; $7174: copy instrument
        .byte   <sfx_instr_9, >sfx_instr_9                      ;   -> sfx_instr_9 ($FAE6)
        .byte   $94                                    ; $7177: call subroutine
        .byte   <L_7196, >L_7196    ;   -> $7196
        .byte   $80, $04                              ; $717A: set param $04
        .byte   $1A, $02                               ; $717C: note + duration
        .byte   $21, $02                               ; $717E: note + duration
        .byte   $1D, $02                               ; $7180: note + duration
        .byte   $21, $02                               ; $7182: note + duration
        .byte   $82                                    ; $7184: loop decrement
        .byte   $94                                    ; $7185: call subroutine
        .byte   <L_7196, >L_7196    ;   -> $7196
        .byte   $80, $04                              ; $7188: set param $04
        .byte   $1C, $02                               ; $718A: note + duration
        .byte   $23, $02                               ; $718C: note + duration
        .byte   $20, $02                               ; $718E: note + duration
        .byte   $23, $02                               ; $7190: note + duration
        .byte   $82                                    ; $7192: loop decrement
        .byte   $96                                    ; $7193: goto/loop
        .byte   <L_7161, >L_7161    ;   -> $7161
L_7196:
        .byte   $80, $04                              ; $7196: set param $04
        .byte   $15, $02                               ; $7198: note + duration
        .byte   $1C, $02                               ; $719A: note + duration
        .byte   $18, $02                               ; $719C: note + duration
        .byte   $1C, $02                               ; $719E: note + duration
        .byte   $82                                    ; $71A0: loop decrement
        .byte   $98                                    ; $71A1: return
L_71A2:
        .byte   $86                                    ; $71A2: copy instrument
        .byte   <sfx_instr_1, >sfx_instr_1                      ;   -> sfx_instr_1 ($FB3D)
L_71A5:
        .byte   $32, $01                               ; $71A5: note + duration
        .byte   $36, $03                               ; $71A7: note + duration
        .byte   $36, $01                               ; $71A9: note + duration
        .byte   $32, $03                               ; $71AB: note + duration
        .byte   $32, $01                               ; $71AD: note + duration
        .byte   $34, $01                               ; $71AF: note + duration
        .byte   $36, $01                               ; $71B1: note + duration
        .byte   $37, $02                               ; $71B3: note + duration
        .byte   $2B, $03                               ; $71B5: note + duration
        .byte   $98                                    ; $71B7: return
L_71B8:
        .byte   $86                                    ; $71B8: copy instrument
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $96                                    ; $71BB: goto/loop
        .byte   <L_71A5, >L_71A5    ;   -> $71A5
L_71BE:
        .byte   $94                                    ; $71BE: call subroutine
        .byte   <L_7040, >L_7040    ;   -> $7040
        .byte   $5F, $01                               ; $71C1: note + duration
        .byte   $1A, $04                               ; $71C3: note + duration
        .byte   $26, $04                               ; $71C5: note + duration
        .byte   $21, $02                               ; $71C7: note + duration
        .byte   $1F, $02                               ; $71C9: note + duration
        .byte   $13, $03                               ; $71CB: note + duration
        .byte   $98                                    ; $71CD: return
L_71CE:
        .byte   $86                                    ; $71CE: copy instrument
        .byte   <sfx_instr_7, >sfx_instr_7                      ;   -> sfx_instr_7 ($FA8F)
        .byte   $37, $04                               ; $71D1: note + duration
        .byte   $86                                    ; $71D3: copy instrument
        .byte   <sfx_instr_12, >sfx_instr_12                      ;   -> sfx_instr_12 ($FB5A)
        .byte   $80, $08                              ; $71D6: set param $08
        .byte   $4F, $04                               ; $71D8: note + duration
        .byte   $4A, $04                               ; $71DA: note + duration
        .byte   $82                                    ; $71DC: loop decrement
        .byte   $4F, $02                               ; $71DD: note + duration
L_71DF:
        .byte   $84                                    ; $71DF: copy 14-byte block
        .byte   <sfx_instr_20, >sfx_instr_20                      ;   -> sfx_instr_20 ($FC48)
        .byte   $1F, $03                               ; $71E2: note + duration
        .byte   $24, $03                               ; $71E4: note + duration
        .byte   $29, $03                               ; $71E6: note + duration
        .byte   $2F, $03                               ; $71E8: note + duration
        .byte   $34, $03                               ; $71EA: note + duration
        .byte   $39, $03                               ; $71EC: note + duration
        .byte   $3E, $03                               ; $71EE: note + duration
        .byte   $43, $03                               ; $71F0: note + duration
        .byte   $48, $03                               ; $71F2: note + duration
        .byte   $4D, $03                               ; $71F4: note + duration
        .byte   $53, $03                               ; $71F6: note + duration
        .byte   $58, $09                               ; $71F8: note + duration
        .byte   $98                                    ; $71FA: return
L_71FB:
        .byte   $86                                    ; $71FB: copy instrument
        .byte   <sfx_instr_7, >sfx_instr_7                      ;   -> sfx_instr_7 ($FA8F)
        .byte   $2D, $04                               ; $71FE: note + duration
        .byte   $86                                    ; $7200: copy instrument
        .byte   <sfx_instr_12, >sfx_instr_12                      ;   -> sfx_instr_12 ($FB5A)
        .byte   $5F, $02                               ; $7203: note + duration
        .byte   $80, $08                              ; $7205: set param $08
        .byte   $48, $04                               ; $7207: note + duration
        .byte   $4D, $04                               ; $7209: note + duration
        .byte   $82                                    ; $720B: loop decrement
        .byte   $5F, $01                               ; $720C: note + duration
        .byte   $88, $02                              ; $720E: set voice $02
        .byte   $96                                    ; $7210: goto/loop
        .byte   <L_71DF, >L_71DF    ;   -> $71DF
L_7213:
        .byte   $90                                    ; $7213: filter cutoff $78
        .byte   $86                                    ; $7214: copy instrument
        .byte   <sfx_instr_7, >sfx_instr_7                      ;   -> sfx_instr_7 ($FA8F)
        .byte   $25, $04                               ; $7217: note + duration
        .byte   $86                                    ; $7219: copy instrument
        .byte   <sfx_instr_12, >sfx_instr_12                      ;   -> sfx_instr_12 ($FB5A)
        .byte   $80, $08                              ; $721C: set param $08
        .byte   $5B, $02                               ; $721E: note + duration
        .byte   $54, $02                               ; $7220: note + duration
        .byte   $56, $02                               ; $7222: note + duration
        .byte   $59, $02                               ; $7224: note + duration
        .byte   $82                                    ; $7226: loop decrement
        .byte   $5B, $02                               ; $7227: note + duration
        .byte   $5F, $02                               ; $7229: note + duration
        .byte   $88, $04                              ; $722B: set voice $04
        .byte   $96                                    ; $722D: goto/loop
        .byte   <L_71DF, >L_71DF    ;   -> $71DF
L_7230:
        .byte   $86                                    ; $7230: copy instrument
        .byte   <sfx_instr_14, >sfx_instr_14                      ;   -> sfx_instr_14 ($FB94)
        .byte   $9A                                    ; $7233: copy 16-byte block
        .byte   <sfx_instr_19, >sfx_instr_19                      ;   -> sfx_instr_19 ($FC38)
        .byte   $8C                                    ; $7236: filter cutoff $F7
        .byte   $8E                                    ; $7237: filter from table
        .byte   $94                                    ; $7238: call subroutine
        .byte   <L_7242, >L_7242    ;   -> $7242
        .byte   $90                                    ; $723B: filter cutoff $78
        .byte   $98                                    ; $723C: return
L_723D:
        .byte   $88, $F4                              ; $723D: set voice $F4
L_723F:
        .byte   $86                                    ; $723F: copy instrument
        .byte   <sfx_instr_15, >sfx_instr_15                      ;   -> sfx_instr_15 ($FBB1)
L_7242:
        .byte   $80, $04                              ; $7242: set param $04
        .byte   $3B, $05                               ; $7244: note + duration
        .byte   $82                                    ; $7246: loop decrement
        .byte   $5F, $01                               ; $7247: note + duration
        .byte   $98                                    ; $7249: return
L_724A:
        .byte   $86                                    ; $724A: copy instrument
        .byte   <sfx_instr_10, >sfx_instr_10                      ;   -> sfx_instr_10 ($FB03)
        .byte   $9A                                    ; $724D: copy 16-byte block
        .byte   <sfx_instr_18, >sfx_instr_18                      ;   -> sfx_instr_18 ($FC28)
        .byte   $8E                                    ; $7250: filter from table
        .byte   $8C                                    ; $7251: filter cutoff $F7
        .byte   $16, $05                               ; $7252: note + duration
        .byte   $5F, $01                               ; $7254: note + duration
        .byte   $16, $01                               ; $7256: note + duration
        .byte   $15, $01                               ; $7258: note + duration
        .byte   $12, $06                               ; $725A: note + duration
        .byte   $13, $02                               ; $725C: note + duration
        .byte   $5F, $05                               ; $725E: note + duration
        .byte   $90                                    ; $7260: filter cutoff $78
        .byte   $98                                    ; $7261: return
L_7262:
        .byte   $86                                    ; $7262: copy instrument
        .byte   <sfx_instr_10, >sfx_instr_10                      ;   -> sfx_instr_10 ($FB03)
        .byte   $96                                    ; $7265: goto/loop
        .byte   <L_726B, >L_726B    ;   -> $726B
L_7268:
        .byte   $86                                    ; $7268: copy instrument
        .byte   <sfx_instr_11, >sfx_instr_11                      ;   -> sfx_instr_11 ($FB20)
L_726B:
        .byte   $16, $05                               ; $726B: note + duration
        .byte   $5F, $01                               ; $726D: note + duration
        .byte   $16, $01                               ; $726F: note + duration
        .byte   $15, $01                               ; $7271: note + duration
        .byte   $12, $06                               ; $7273: note + duration
        .byte   $13, $05                               ; $7275: note + duration
        .byte   $98                                    ; $7277: return
L_7278:
        .byte   $86                                    ; $7278: copy instrument
        .byte   <sfx_instr_12, >sfx_instr_12                      ;   -> sfx_instr_12 ($FB5A)
        .byte   $84                                    ; $727B: copy 14-byte block
        .byte   <sfx_instr_20, >sfx_instr_20                      ;   -> sfx_instr_20 ($FC48)
        .byte   $88, $F4                              ; $727E: set voice $F4
L_7280:
        .byte   $80, $04                              ; $7280: set param $04
        .byte   $44, $04                               ; $7282: note + duration
        .byte   $45, $04                               ; $7284: note + duration
        .byte   $46, $04                               ; $7286: note + duration
        .byte   $47, $04                               ; $7288: note + duration
        .byte   $46, $04                               ; $728A: note + duration
        .byte   $45, $04                               ; $728C: note + duration
        .byte   $82                                    ; $728E: loop decrement
        .byte   $80, $04                              ; $728F: set param $04
        .byte   $42, $04                               ; $7291: note + duration
        .byte   $43, $04                               ; $7293: note + duration
        .byte   $44, $04                               ; $7295: note + duration
        .byte   $45, $04                               ; $7297: note + duration
        .byte   $44, $04                               ; $7299: note + duration
        .byte   $43, $04                               ; $729B: note + duration
        .byte   $82                                    ; $729D: loop decrement
        .byte   $96                                    ; $729E: goto/loop
        .byte   <L_7280, >L_7280    ;   -> $7280
L_72A1:
        .byte   $86                                    ; $72A1: copy instrument
        .byte   <sfx_instr_7, >sfx_instr_7                      ;   -> sfx_instr_7 ($FA8F)
        .byte   $88, $DB                              ; $72A4: set voice $DB
        .byte   $96                                    ; $72A6: goto/loop
        .byte   <L_7280, >L_7280    ;   -> $7280
L_72A9:
        .byte   $86                                    ; $72A9: copy instrument
        .byte   <sfx_instr_10, >sfx_instr_10                      ;   -> sfx_instr_10 ($FB03)
        .byte   $9C                                    ; $72AC: set end markers
        .byte   $9A                                    ; $72AD: copy 16-byte block
        .byte   <sfx_instr_18, >sfx_instr_18                      ;   -> sfx_instr_18 ($FC28)
        .byte   $8E                                    ; $72B0: filter from table
L_72B1:
        .byte   $14, $18                               ; $72B1: note + duration
        .byte   $80, $03                              ; $72B3: set param $03
        .byte   $5F, $18                               ; $72B5: note + duration
        .byte   $82                                    ; $72B7: loop decrement
        .byte   $12, $18                               ; $72B8: note + duration
        .byte   $80, $03                              ; $72BA: set param $03
        .byte   $5F, $18                               ; $72BC: note + duration
        .byte   $82                                    ; $72BE: loop decrement
        .byte   $96                                    ; $72BF: goto/loop
        .byte   <L_72B1, >L_72B1    ;   -> $72B1
L_72C2:
        .byte   $86                                    ; $72C2: copy instrument
        .byte   <sfx_instr_4, >sfx_instr_4                      ;   -> sfx_instr_4 ($FA38)
        .byte   $84                                    ; $72C5: copy 14-byte block
        .byte   <sfx_instr_3, >sfx_instr_3                      ;   -> sfx_instr_3 ($FBEB)
        .byte   $8A, <D_F276                          ; $72C8: set freq ptr -> D_F276
L_72CA:
        .byte   $26, $04                               ; $72CA: note + duration
        .byte   $29, $04                               ; $72CC: note + duration
        .byte   $2D, $04                               ; $72CE: note + duration
        .byte   $2E, $04                               ; $72D0: note + duration
        .byte   $31, $04                               ; $72D2: note + duration
        .byte   $32, $04                               ; $72D4: note + duration
        .byte   $5F, $08                               ; $72D6: note + duration
        .byte   $21, $04                               ; $72D8: note + duration
        .byte   $25, $04                               ; $72DA: note + duration
        .byte   $28, $04                               ; $72DC: note + duration
        .byte   $2B, $04                               ; $72DE: note + duration
        .byte   $2C, $04                               ; $72E0: note + duration
        .byte   $2D, $04                               ; $72E2: note + duration
        .byte   $5F, $08                               ; $72E4: note + duration
        .byte   $96                                    ; $72E6: goto/loop
        .byte   <L_72CA, >L_72CA    ;   -> $72CA
L_72E9:
        .byte   $86                                    ; $72E9: copy instrument
        .byte   <sfx_instr_5, >sfx_instr_5                      ;   -> sfx_instr_5 ($FA55)
L_72EC:
        .byte   $3A, $10                               ; $72EC: note + duration
        .byte   $5F, $10                               ; $72EE: note + duration
        .byte   $39, $10                               ; $72F0: note + duration
        .byte   $5F, $10                               ; $72F2: note + duration
        .byte   $96                                    ; $72F4: goto/loop
        .byte   <L_72EC, >L_72EC    ;   -> $72EC
L_72F7:
        .byte   $86                                    ; $72F7: copy instrument
        .byte   <sfx_instr_10, >sfx_instr_10                      ;   -> sfx_instr_10 ($FB03)
        .byte   $9A                                    ; $72FA: copy 16-byte block
        .byte   <sfx_instr_18, >sfx_instr_18                      ;   -> sfx_instr_18 ($FC28)
        .byte   $8E                                    ; $72FD: filter from table
L_72FE:
        .byte   $16, $20                               ; $72FE: note + duration
        .byte   $15, $20                               ; $7300: note + duration
        .byte   $96                                    ; $7302: goto/loop
        .byte   <L_72FE, >L_72FE    ;   -> $72FE

;===============================================================================
; End of music-sequence.s
;===============================================================================
