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
        .byte   $00,$00,$00,$00,$00,$00,$00,$20                         ; $0400 - Score area
        .byte   $00,$00,$00,$13                                         ; $0408 - Game state data
        .byte   <D_E779,>D_E779, <D_E779,>D_E779                       ; $040C - Entity render vectors
        .byte   <D_E779,>D_E779, <D_E779,>D_E779                       ; $0410
        .byte   <D_E779,>D_E779, <D_E779,>D_E779                       ; $0414
        .byte   <D_E779,>D_E779, <D_E779,>D_E779                       ; $0418
        .byte   <D_E779,>D_E779, <D_E779,>D_E779                       ; $041C
        .byte   <D_E779,>D_E779, <D_7BD4,>D_7BD4                       ; $0420
        .byte   $B2,$3C,$B2,$3C,$B2,$3C,$B2,$3C                        ; $0424
        .byte   $B2,$3C,$B2,$3C                                         ; $042C
        .byte   <D_E758,>D_E758, $94,$3E, $FD,$3E, <D_E752,>D_E752     ; $0430
        .byte   $D4,$3E, <D_E767,>D_E767, <D_E767,>D_E767, $77,$3E     ; $0438
        .byte   $2D,$3D,<D_7BDB,>D_7BDB,$A9,$3D,$77,$3D               ; $0440
        .byte   $D3,$3C,$DB,$3C,$DF,$3C, <D_E968,>D_E968               ; $0448
        .byte   $FD,$3E,$28,$3F, <D_E968,>D_E968, <D_E968,>D_E968     ; $0450
        .byte   $88,$3F                                                 ; $0458

; Lives counter - EASILY MODDABLE!
D_045A:
lives_p1:   .byte   $00                          ; $045A - Player 1 lives
lives_p2:   .byte   $00                          ; $045B - Player 2 lives
