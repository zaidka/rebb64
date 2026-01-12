; ============================================================================
; rebb64 - Game Loop and Level Management
; ============================================================================
; This file contains the game start sequence, level initialization, and
; the main game loop that runs every frame during gameplay.
;
; ADDRESS RANGE: $08E4 - $0AAA
;
; KEY ROUTINES:
;   D_08E4 - Game start sequence (new game initialization)
;   D_090E - Level start setup
;   D_09A5 - Level initialization/transition
;   L_0A07 - Main game loop (heart of the game, runs every frame)
;   D_0AAB - Player-enemy collision detection
; ============================================================================

.setcpu "6502"

; ============================================================================
; GAME START SEQUENCE ($08E4)
; ============================================================================
; Called when starting a new game. Sets up initial state for both players.
; ============================================================================
D_08E4:
        jsr     D_0885                          ; $08E4 - Initialize game state
        ldy     #$04                            ; $08E7
        jsr     $05ad                           ; $08E9
        ldx     #$41                            ; $08EC
        ldy     #$ac                            ; $08EE
        jsr     $e42a                           ; $08F0 - Load data
        lda     #$74                            ; $08F3
        sta     $ba                             ; $08F5 - FA (Player 1 X)
        lda     #$e4                            ; $08F7
        sta     $bb                             ; $08F9 - FNADR (Player 2 X)
        lda     #$83                            ; $08FB
        sta     $c2                             ; $08FD - Player 1 Y
        sta     $c3                             ; $08FF - TAPE1 (Player 2 Y)
        lda     $b3                             ; $0901 - ESSION+1 (Player 2 state)
        pha                                     ; $0903 - Save for later
        inc     $b3                             ; $0904 - Increment player 2 state
        jsr     $e4da                           ; $0906
D_0909:
        jsr     $e494                           ; $0909 - Wait one frame

; ============================================================================
; LEVEL START SETUP ($090E)
; ============================================================================
; Initializes all game state variables at the start of each level
; ============================================================================
D_090E:
        ldx     #$01                            ; $090C
        stx     $20                             ; $090E - Set game mode flag
        stx     $f073                           ; $0910
        lda     #$ff                            ; $0913
        sta     $d015                           ; $0915 - VIC_SPR_ENA (enable all sprites)
        jsr     $7bc8                           ; $0918
        jsr     $e374                           ; $091B - Screen setup
        
        ; Clear various game state variables
        ldx     #$00                            ; $091E
        stx     $54                             ; $0920
        stx     $55                             ; $0922
        stx     $0409                           ; $0924
        stx     $040a                           ; $0927
        stx     $59bf                           ; $092A
        stx     $8728                           ; $092D
        stx     $8729                           ; $0930
        lda     #$12                            ; $0933
        sta     $5b3f                           ; $0935
        jsr     $7f53                           ; $0938 - Player death handler (player 0)
        inx                                     ; $093B
        jsr     $7f53                           ; $093C - Player death handler (player 1)
        jsr     $e9ea                           ; $093F - Random number
        and     #$1e                            ; $0942
        adc     #$0a                            ; $0944
        sta     $58                             ; $0946
        
        ; Set player starting positions
        lda     #$84                            ; $0948
        sta     $ba                             ; $094A - FA (Player 1 X)
        lda     #$94                            ; $094C
        sta     $bb                             ; $094E - FNADR (Player 2 X)
        lda     #$b5                            ; $0950
        sta     $c2                             ; $0952 - Player 1 Y
        sta     $c3                             ; $0954 - TAPE1 (Player 2 Y)
        
        ; Set starting lives (3)
        ldx     #$03                            ; $0956
        stx     $045a                           ; $0958
        stx     $045b                           ; $095B
        stx     $59ff                           ; $095E
        
        ; Initialize counters
        ldx     #$07                            ; $0961
        stx     $ab                             ; $0963 - RIDBE
        lda     #$00                            ; $0965
        ldx     #$05                            ; $0967
L_0969:
        sta     $0400,x                         ; $0969 - Clear score area
        dex                                     ; $096C
        bpl     L_0969                          ; $096D
        sta     $ac                             ; $096F - RIDBS
        sta     $ad                             ; $0971 - RODBS
        lda     #$01                            ; $0973
        sta     $ae                             ; $0975 - RODBE
        lda     #$04                            ; $0977
        sta     $af                             ; $0979 - IRQTMP
        
        ; Handle 2-player mode
        ldy     #$03                            ; $097B
        pla                                     ; $097D - Restore player 2 state
        bne     L_098A                          ; $097E - Skip if 2-player
        ldy     #$01                            ; $0980 - 1-player mode
        inc     $ab                             ; $0982 - RIDBE
        sta     $b3                             ; $0984 - ESSION+1
        sta     $bb                             ; $0986 - FNADR
        sta     $c3                             ; $0988 - TAPE1
L_098A:
        sty     $5b7f                           ; $098A
        
        ; Self-modifying code setup
        lda     #$60                            ; $098D - RTS opcode
        sta     $23de                           ; $098F
        lda     #$4c                            ; $0992 - JMP opcode
        sta     $0f73                           ; $0994
        sta     $049d                           ; $0997
        lda     #$ed                            ; $099A
        sta     $0a39                           ; $099C - Modify instruction at D_0A39
        lda     #$0b                            ; $099F
        sta     $0a3a                           ; $09A1 - Modify instruction at D_0A3A
        sec                                     ; $09A4

; ============================================================================
; LEVEL INITIALIZATION ($09A5)
; ============================================================================
; Prepares the level for play. Can be called with carry set (new level)
; or carry clear (continue from death).
; ============================================================================
D_09A5:
        bcc     L_09D3                          ; $09A5 - Branch based on carry
        lda     #$00                            ; $09A7
        sta     $d015                           ; $09A9 - VIC_SPR_ENA (disable sprites)
        jsr     $e740                           ; $09AC
        jsr     $e000                           ; $09AF
        jsr     $37c9                           ; $09B2
        jsr     $e4c5                           ; $09B5
        lda     #$0d                            ; $09B8
        jsr     $e740                           ; $09BA
        jsr     $7b53                           ; $09BD
D_09C0:
        lda     #$09                            ; $09C0
        sta     $d800                           ; $09C2 - Color RAM
        sta     $d801                           ; $09C5 - Color RAM
        jsr     $e4da                           ; $09C8
        lda     #$ff                            ; $09CB
        sta     $d015                           ; $09CD - VIC_SPR_ENA (enable sprites)
        jmp     D_09DC                          ; $09D0

L_09D3:
        jsr     $e000                           ; $09D3
        jsr     $37c9                           ; $09D6
        jsr     $e4c5                           ; $09D9

; ============================================================================
; FINAL LEVEL SETUP ($09DC)
; ============================================================================
; Final setup before entering main game loop
; ============================================================================
D_09DC:
        jsr     $e3a7                           ; $09DC - Update sprite animations
        jsr     $e189                           ; $09DF
        jsr     $392a                           ; $09E2
        jsr     $05c5                           ; $09E5
        jsr     $e554                           ; $09E8
        jsr     $e658                           ; $09EB
        jsr     $e6cd                           ; $09EE
        jsr     $2b31                           ; $09F1
        jsr     $e49b                           ; $09F4
        jsr     $17be                           ; $09F7
        jsr     $3c01                           ; $09FA
        lda     #$32                            ; $09FD - 50 frames = 1 second timer
        sta     $2b                             ; $09FF - TXTTAB (frame sub-counter)
        lda     #$00                            ; $0A01
        sta     $08                             ; $0A03 - ENDCHR (reset frame counter)
        dec     $37                             ; $0A05 - MEMSIZ (unpause)

; ============================================================================
; MAIN GAME LOOP ($0A07)
; ============================================================================
; This is the heart of the game - called every frame during gameplay.
; Processes all game logic: input, physics, enemies, collisions, etc.
;
; TIMING: The game runs at 25fps using a double-frame wait system.
; The loop executes once every 2 VIC frames (50Hz / 2 = 25Hz).
; ============================================================================
main_game_loop:
L_0A07:
        jsr     $1844                           ; $0A07 - Update player input/movement
main_loop_entry:
D_0A0A:
        jsr     $7e80                           ; $0A0A - Check for SPACE (pause)
        jsr     $7ec1                           ; $0A0D - Check for RUN/STOP (quit)
        jsr     $f1ac                           ; $0A10 - Update sound/music
        jsr     $1578                           ; $0A13 - Update bubbles physics
        jsr     $e3a7                           ; $0A16 - Update sprite animations
        jsr     $1319                           ; $0A19 - Update player sprites
        jsr     $045c                           ; $0A1C - Check player state/join game
        
        ; Frame sync setup: Self-modifying code for double-buffer wait
        ; Stores current frame and next frame values for 2-frame wait (25fps)
        ldx     $08                             ; $0A1F - ENDCHR (frame counter)
        stx     D_0A5D                          ; $0A21 - Modify CMP operand below
        inx                                     ; $0A24 - Frame + 1
        stx     D_0A61                          ; $0A25 - Modify second CMP operand
        
        ; Decrement invincibility timers
        lda     $a824                           ; $0A28 - Player 1 invincibility
        beq     L_0A30                          ; $0A2B
        dec     $a824                           ; $0A2D
L_0A30:
        lda     $a825                           ; $0A30 - Player 2 invincibility
        beq     L_0A38                          ; $0A33
        dec     $a825                           ; $0A35
L_0A38:
        jsr     $0bed                           ; $0A38 - Spawn enemies
        lda     $58ff                           ; $0A3B - Boss active flag
        beq     L_0A48                          ; $0A3E
        lda     $593f                           ; $0A40 - Boss state
D_0A43:
        bne     L_0A48                          ; $0A43
        jsr     $1ab6                           ; $0A45 - Update boss
L_0A48:
        jsr     $e90e                           ; $0A48 - Update screen/graphics
        jsr     $0aab                           ; $0A4B - Check player-enemy collisions
        jsr     $0cf2                           ; $0A4E - Update enemy AI
        jsr     $13be                           ; $0A51 - Process bubble captures
        jsr     $2cb7                           ; $0A54 - Update collectibles
        jsr     $32c1                           ; $0A57 - Check for EXTEND bonus (D_32C1)
        
        ; Frame skip: Wait for 2 frames (25fps double-buffer sync)
wait_frame:
L_0A5A:
        lda     $08                             ; $0A5A - ENDCHR
        cmp     #$00                            ; $0A5C - Self-modified value
D_0A5D = * - 1                                  ; Label for self-modifying code
        beq     L_0A5A                          ; $0A5E - Wait until frame changes
D_0A60:
        cmp     #$01                            ; $0A60 - Self-modified value
D_0A61 = * - 1                                  ; Label for self-modifying code
        beq     L_0A5A                          ; $0A62 - Wait another frame
        
        ; Check if game should continue
        lda     $b2                             ; $0A64 - ENESSION (Player 1 state)
        ora     $b3                             ; $0A66 - ESSION+1 (Player 2 state)
        beq     L_0A99                          ; $0A68 - Both dead = GAME OVER
        lda     $21                             ; $0A6A - Level complete flag
        beq     L_0A07                          ; $0A6C - Not complete, loop back
        
        ; Level complete sequence
        lda     #$00                            ; $0A6E
        sta     $37                             ; $0A70 - MEMSIZ
        sta     $5aff                           ; $0A72
        jsr     $e494                           ; $0A75 - Wait one frame
        jsr     $2e79                           ; $0A78
        inc     $10                             ; $0A7B - SUBFLG (increment level)
        lda     $10                             ; $0A7D - SUBFLG
        ldx     #$01                            ; $0A7F
L_0A81:
        ldy     $b2,x                           ; $0A81 - Check player state
        beq     L_0A88                          ; $0A83
        sta     $0409,x                         ; $0A85 - Store level for player
L_0A88:
        dex                                     ; $0A88
        bpl     L_0A81                          ; $0A89
        cmp     #$64                            ; $0A8B - Check if level 100 (ending)
        beq     L_0AA8                          ; $0A8D
        jsr     $e4da                           ; $0A8F
        lda     $21                             ; $0A92 - Level complete flag
        cmp     #$7f                            ; $0A94
        jmp     D_09A5                          ; $0A96 - Start next level
        
L_0A99:
        ; Game over sequence
        inc     $37                             ; $0A99 - MEMSIZ
        jsr     $e3a7                           ; $0A9B
        ldy     #$20                            ; $0A9E
D_0AA0:
        jsr     $05ad                           ; $0AA0
        lda     #$96                            ; $0AA3
        jmp     $7bc8                           ; $0AA5

L_0AA8:
        ; Ending sequence (level 100 complete)
        jmp     $a5b7                           ; $0AA8
