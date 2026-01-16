; ============================================================================
; rebb64 - Game Variables ($0400-$045B)
; ============================================================================
;
; This file contains the initial game variable data and lives counters.
; Score storage, lives, and game state data.
;
; ============================================================================

.segment "CODE"

; ============================================================================
; [DATA] GAME VARIABLES ($0400-$045B)
; ============================================================================
; Score storage, lives, game state. Keep as bytes.

game_variables:
        .byte   $00,$00,$00,$00,$00,$00,$00,$20  ; $0400 - Score area  
        .byte   $00,$00,$00,$13,$79,$E7,$79,$E7  ; $0408
        .byte   $79,$E7,$79,$E7,$79,$E7,$79,$E7  ; $0410
        .byte   $79,$E7,$79,$E7,$79,$E7,$79,$E7  ; $0418
        .byte   $79,$E7,$D4,$7B,$B2,$3C,$B2,$3C  ; $0420
        .byte   $B2,$3C,$B2,$3C,$B2,$3C,$B2,$3C  ; $0428
        .byte   $58,$E7,$94,$3E,$FD,$3E,$52,$E7  ; $0430
        .byte   $D4,$3E,$67,$E7,$67,$E7,$77,$3E  ; $0438
        .byte   $2D,$3D,$DB,$7B,$A9,$3D,$77,$3D  ; $0440
        .byte   $D3,$3C,$DB,$3C,$DF,$3C,$68,$E9  ; $0448
        .byte   $FD,$3E,$28,$3F,$68,$E9,$68,$E9  ; $0450
        .byte   $88,$3F                          ; $0458 (2 bytes, rest is lives)

; Lives counter - EASILY MODDABLE!
D_045A:
lives_p1:   .byte   $00                          ; $045A - Player 1 lives
lives_p2:   .byte   $00                          ; $045B - Player 2 lives
