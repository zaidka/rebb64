; ============================================================================
; level-data-part2.s - Level data part 2 with disassembled routines
; ============================================================================
;
; This file replaces the binary level-data-part2.bin file.
; It contains a mix of sprite data (as .byte directives) and disassembled
; code for the routines that were previously embedded in the binary.
;
; Memory range: $7440-$7FFF (3008 bytes)
;
; Key routines converted to assembly:
; - L_7AC0: Sprite data transform helper
; - D_7AE3: Level 99 (Super Drunk) special handler  
; - D_7B53: Credits display routine
; - D_7BA6: Clear entity state
; - D_7BB3: Bank RAM under I/O
; - D_7BC3/D_7BC6/D_7BC8: Wait for frames
; - D_7BD4: Clear player enemy state
; - D_7BDB: Set player enemy state
; - D_7BE8: Game over sequence
; - D_7BFE: Get terrain type
; - D_7C14: Toggle entity flag
; - D_7C21: Add score
; - D_7C37: Special level handler
; - D_7C3C: Timer decrement
; - D_7E80: Check pause (SPACE key)
; - D_7EB3: Read keyboard
; - D_7EC1: Check quit (RUN/STOP)
; - D_7F53: Player death handler
; - D_7F85/D_7F88: Level skip handlers
;
; ============================================================================

.setcpu "6502"

; ============================================================================
; LOCAL SYMBOL ALIASES
; ============================================================================
; Map shorter names to the symbols defined in master.s for readability
; Only define symbols that DON'T already exist in master.s

ZP_37       = MEMSIZ                ; Pause flag ($37)
ZP_3C       = OLDLIN1               ; Temp storage - current player index ($3C)
ZP_40       = DATLIN1               ; Temp storage ($40)
ZP_41       = DATPTR                ; Temp storage ($41)

; Symbols needed but not defined elsewhere
D_1288      = $1288                 ; Score handler routine
D_587F      = $587F                 ; Target level storage
D_A739      = $A739                 ; Y position offset table
D_A73D      = $A73D                 ; Game over Y position
D_A745      = $A745                 ; Game over Y position +1
D_A76F      = $A76F                 ; Entity state array
D_A77C      = $A77C                 ; Entity attribute table +1
D_A783      = $A783                 ; Entity attribute table +8

.segment "LEVELS2"

; ============================================================================
; SPRITE DATA: Player in bubble sprites ($7440-$7ABF)
; ============================================================================
; This section contains sprite graphics for players captured in bubbles
; and related animation frames. Kept as binary data.

sprite_data_7440:
        .byte   $00,$00,$00,$00,$00,$0F,$00,$00,$F0,$00,$03,$00,$00,$0C,$F0,$00
        .byte   $33,$C0,$00,$CF,$00,$00,$CC,$00,$03,$3C,$00,$03,$30,$00,$0C,$00
        .byte   $00,$0C,$C0,$00,$0C,$C0,$00,$33,$C0,$00,$33,$00,$02,$33,$00,$0A
        .byte   $30,$00,$2A,$C0,$00,$2B,$C0,$00,$2F,$C0,$00,$EC,$C0,$00,$EC,$35
        .byte   $00,$00,$00,$F0,$00,$00,$0F,$00,$00,$00,$C0,$00,$00,$30,$00,$00
        .byte   $0C,$00,$00,$03,$00,$00,$03,$00,$00,$00,$C0,$00,$00,$C0,$00,$00
        .byte   $30,$00,$00,$30,$00,$00,$30,$C0,$00,$0C,$A0,$00,$0C,$A8,$00,$0C
        .byte   $AA,$00,$0C,$BA,$00,$03,$BE,$00,$03,$8E,$C0,$03,$8E,$C0,$03,$35
        .byte   $C0,$00,$AF,$C0,$01,$2A,$C0,$05,$40,$C0,$01,$6B,$30,$00,$AF,$30
        .byte   $00,$97,$30,$00,$55,$30,$00,$00,$0C,$00,$00,$0C,$00,$00,$0C,$00
        .byte   $00,$03,$00,$00,$03,$00,$00,$00,$C0,$00,$00,$C0,$00,$00,$30,$00
        .byte   $00,$0C,$00,$00,$03,$00,$00,$00,$F0,$00,$00,$0F,$00,$00,$00,$35
        .byte   $BE,$80,$03,$AA,$10,$03,$00,$54,$03,$FA,$50,$03,$FE,$80,$0C,$FE
        .byte   $80,$0C,$F5,$00,$CC,$95,$40,$CC,$00,$03,$30,$00,$03,$30,$00,$00
        .byte   $30,$00,$0C,$C0,$00,$30,$C0,$00,$33,$00,$00,$C3,$00,$00,$0C,$00
        .byte   $00,$30,$00,$00,$C0,$00,$0F,$00,$00,$F0,$00,$00,$00,$00,$00,$35
        .byte   $00,$00,$0F,$00,$00,$F0,$00,$03,$00,$00,$0C,$30,$00,$30,$C0,$00
        .byte   $33,$C0,$00,$CF,$00,$00,$CC,$00,$03,$3C,$00,$03,$30,$00,$03,$30
        .byte   $00,$0C,$00,$00,$0C,$30,$00,$0C,$F0,$00,$0C,$C0,$02,$0C,$C0,$0A
        .byte   $30,$00,$2A,$30,$00,$2B,$30,$00,$2C,$30,$00,$EC,$30,$00,$EF,$35
        .byte   $F0,$00,$00,$0F,$00,$00,$00,$C0,$00,$00,$30,$00,$00,$0C,$00,$00
        .byte   $0C,$00,$00,$03,$00,$00,$03,$00,$00,$00,$C0,$00,$00,$C0,$00,$00
        .byte   $C0,$00,$00,$30,$00,$00,$30,$C0,$00,$30,$A0,$00,$30,$A8,$00,$30
        .byte   $AA,$00,$0C,$BA,$00,$0C,$8E,$00,$0C,$8E,$C0,$0C,$BE,$C0,$0C,$35
        .byte   $30,$00,$AF,$30,$00,$2A,$30,$00,$40,$30,$01,$6B,$30,$05,$AF,$0C
        .byte   $00,$AF,$0C,$00,$17,$0C,$00,$55,$0C,$00,$00,$0C,$00,$00,$03,$00
        .byte   $00,$03,$00,$00,$03,$00,$00,$00,$C0,$00,$00,$C0,$00,$00,$30,$00
        .byte   $00,$30,$00,$00,$0C,$00,$00,$03,$00,$00,$00,$F0,$00,$00,$0F,$03
        .byte   $BE,$80,$0C,$AA,$00,$0C,$00,$40,$0C,$FA,$50,$0C,$FE,$94,$0C,$F5
        .byte   $80,$30,$D5,$40,$30,$80,$03,$30,$00,$03,$30,$00,$03,$30,$00,$00
        .byte   $C0,$00,$0C,$C0,$00,$0C,$C0,$00,$33,$00,$00,$33,$00,$00,$CC,$00
        .byte   $00,$0C,$00,$00,$30,$00,$00,$C0,$00,$0F,$00,$00,$F0,$00,$00,$03
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$0A,$00
        .byte   $00,$2A,$00,$00,$2A,$00,$00,$A0,$00,$00,$0A,$00,$02,$AA,$00,$2A
        .byte   $AA,$00,$AA,$AA,$00,$AA,$80,$02,$A8,$3C,$02,$A0,$FF,$02,$A3,$FF
        .byte   $0A,$8F,$F0,$0A,$8F,$C0,$0A,$3F,$CC,$0A,$3F,$3C,$0A,$3F,$30,$EA
        .byte   $00,$00,$00,$2A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$AA,$AA,$AA,$00,$2A,$AA,$AA,$82,$AA,$AA,$A8,$2A,$AA,$AA
        .byte   $8A,$AA,$AA,$A2,$00,$0A,$A2,$0F,$C2,$A8,$3F,$F0,$A8,$FF,$FC,$2A
        .byte   $C3,$FC,$2A,$00,$FF,$2A,$0C,$FF,$0A,$3C,$3F,$0A,$30,$3F,$CA,$55
        .byte   $00,$00,$00,$80,$00,$00,$A8,$00,$00,$AA,$00,$00,$AA,$80,$00,$AA
        .byte   $A0,$00,$AA,$A8,$00,$AA,$A8,$00,$AA,$AA,$28,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$2A,$AA,$AA
        .byte   $2A,$AA,$A8,$2A,$AA,$A8,$2A,$AA,$A8,$8A,$AA,$A0,$8A,$AA,$A0,$20
        .byte   $0A,$3C,$F0,$0A,$3C,$C0,$0A,$3C,$C0,$0A,$3C,$C0,$0A,$3C,$00,$0A
        .byte   $3C,$00,$0A,$3C,$00,$02,$3C,$0C,$02,$B0,$3C,$00,$8F,$30,$00,$3F
        .byte   $C0,$01,$5F,$C0,$05,$5F,$C0,$05,$5F,$F0,$15,$7F,$FF,$15,$7F,$FF
        .byte   $35,$FF,$FF,$FF,$FF,$FF,$FF,$FC,$FF,$FF,$F0,$3F,$FF,$F0,$3F,$55
        .byte   $F0,$3F,$CA,$C0,$3F,$CA,$C0,$3F,$CA,$C0,$3F,$CA,$00,$3F,$CA,$00
        .byte   $3F,$CA,$00,$3F,$CA,$00,$3F,$0A,$00,$FC,$FE,$00,$03,$57,$3F,$FD
        .byte   $55,$3F,$F5,$55,$3F,$F5,$55,$FF,$F5,$55,$FF,$F5,$55,$FF,$F5,$54
        .byte   $FF,$FD,$51,$FF,$FF,$C5,$FF,$00,$15,$FC,$55,$55,$F1,$55,$55,$03
        .byte   $8A,$AA,$80,$8A,$AA,$80,$8A,$AA,$00,$8A,$AA,$00,$8A,$A8,$00,$8A
        .byte   $A0,$00,$8A,$80,$00,$2A,$80,$05,$2A,$00,$55,$2A,$01,$55,$EA,$15
        .byte   $54,$EA,$95,$50,$EA,$95,$40,$EA,$A5,$00,$EA,$A4,$00,$AA,$A8,$00
        .byte   $2A,$A8,$00,$4A,$A8,$00,$4A,$AA,$00,$4A,$AA,$00,$4A,$AA,$00,$00
        .byte   $FF,$F0,$3F,$3F,$FC,$FF,$3F,$FF,$FF,$0F,$FF,$FF,$0F,$FF,$FF,$03
        .byte   $FF,$FF,$00,$5F,$FF,$01,$56,$AA,$05,$D5,$AA,$07,$D5,$6A,$17,$55
        .byte   $5A,$1F,$55,$5A,$1D,$55,$56,$15,$55,$55,$15,$55,$55,$05,$55,$55
        .byte   $05,$55,$55,$01,$55,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03
        .byte   $C5,$55,$55,$C5,$55,$54,$C5,$55,$52,$C5,$40,$0A,$C5,$40,$0A,$C5
        .byte   $55,$52,$C5,$55,$52,$85,$55,$52,$A1,$55,$4A,$A8,$55,$2A,$AA,$00
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$6A,$AA,$AA
        .byte   $5A,$AA,$AA,$5A,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $2A,$AA,$80,$AA,$AA,$88,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$AA,$AA,$A8,$AA,$AA,$A8,$AA,$AA,$90,$AA,$AA,$50,$AA,$A9
        .byte   $50,$AA,$95,$50,$AA,$55,$50,$A9,$55,$50,$A9,$55,$40,$A5,$55,$40
        .byte   $95,$55,$00,$55,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$A0
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$0F,$00,$00,$30,$00,$00,$C0,$00
        .byte   $03,$00,$00,$0C,$00,$00,$30,$00,$00,$30,$00,$00,$C0,$02,$00,$C0
        .byte   $0A,$03,$00,$00,$03,$00,$2A,$03,$00,$AA,$0C,$02,$AA,$0C,$0A,$80
        .byte   $0C,$0A,$0F,$0C,$28,$3F,$30,$28,$FC,$30,$28,$F0,$30,$A3,$F3,$EA
        .byte   $03,$FF,$C0,$FC,$00,$3F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$0A,$AA,$A0,$2A,$AA,$A8,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$00,$02,$AA,$AA,$A8,$AA,$AA,$AA,$2A,$AA,$AA,$8A,$00,$0A,$8A
        .byte   $CF,$C2,$A2,$3F,$F2,$A2,$03,$F0,$A2,$00,$F0,$A8,$0C,$FC,$A8,$55
        .byte   $00,$00,$00,$00,$00,$00,$F0,$00,$00,$0C,$00,$00,$03,$00,$00,$00
        .byte   $C0,$00,$00,$30,$00,$00,$0C,$00,$00,$0C,$00,$00,$03,$00,$80,$03
        .byte   $00,$A0,$00,$C0,$A8,$A0,$C0,$AA,$A8,$C0,$AA,$A8,$30,$AA,$A8,$30
        .byte   $AA,$A8,$30,$AA,$A8,$30,$AA,$A8,$0C,$AA,$A0,$0C,$AA,$A0,$0C,$20
        .byte   $30,$A3,$CF,$30,$A3,$CC,$30,$A3,$CC,$C0,$A3,$CC,$C0,$A3,$C0,$C0
        .byte   $A3,$C3,$C0,$23,$0F,$C0,$20,$0C,$C0,$05,$C0,$C0,$15,$C0,$C0,$15
        .byte   $C0,$C0,$57,$F0,$C0,$57,$FF,$C3,$DF,$FF,$C3,$FF,$FF,$C3,$FF,$FF
        .byte   $C3,$FF,$03,$C3,$FC,$00,$30,$FC,$FC,$30,$FF,$FF,$30,$3F,$FF,$55
        .byte   $3C,$FC,$28,$30,$FC,$28,$30,$FC,$28,$30,$FC,$28,$00,$FC,$28,$00
        .byte   $FC,$28,$00,$F0,$A8,$03,$CF,$E8,$00,$35,$7A,$3F,$D5,$5E,$3F,$D5
        .byte   $5E,$FF,$D5,$5C,$FF,$D5,$51,$FF,$D5,$45,$FF,$F5,$15,$FF,$FC,$55
        .byte   $FF,$01,$55,$FC,$55,$54,$F1,$55,$52,$F1,$55,$4A,$F1,$55,$2A,$03
        .byte   $AA,$A0,$0C,$AA,$80,$0C,$AA,$80,$0C,$AA,$00,$03,$AA,$00,$03,$A8
        .byte   $01,$43,$A8,$15,$43,$A8,$55,$43,$AA,$55,$03,$AA,$54,$03,$AA,$50
        .byte   $03,$AA,$80,$03,$2A,$80,$03,$2A,$A0,$03,$4A,$A2,$03,$4A,$AA,$83
        .byte   $2A,$AA,$83,$AA,$AA,$83,$AA,$AA,$8C,$AA,$AA,$0C,$AA,$AA,$0C,$00
        .byte   $30,$05,$FF,$30,$15,$6A,$30,$1D,$5A,$0C,$7D,$56,$0C,$75,$56,$0C
        .byte   $55,$55,$0C,$55,$55,$03,$15,$55,$03,$15,$55,$03,$05,$55,$00,$C0
        .byte   $00,$00,$C0,$00,$00,$30,$00,$00,$30,$00,$00,$0C,$00,$00,$03,$00
        .byte   $00,$00,$C0,$00,$00,$3C,$00,$00,$03,$00,$00,$00,$00,$00,$00,$03
        .byte   $F1,$40,$2A,$A1,$40,$2A,$A1,$55,$4A,$A1,$55,$4A,$A1,$55,$4A,$A8
        .byte   $55,$2A,$6A,$00,$AA,$5A,$AA,$AA,$56,$AA,$A9,$56,$AA,$A5,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$C0,$00,$03,$3C,$00,$3C,$03,$FF,$C0,$00
        .byte   $AA,$A8,$0C,$AA,$A5,$0C,$AA,$95,$0C,$A9,$55,$30,$A5,$54,$30,$95
        .byte   $54,$30,$95,$50,$30,$55,$50,$C0,$55,$40,$C0,$54,$00,$C0,$00,$03
        .byte   $00,$00,$03,$00,$00,$0C,$00,$00,$0C,$00,$00,$30,$00,$00,$C0,$00
        .byte   $03,$00,$00,$3C,$00,$00,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$A0

; ============================================================================
; SPRITE TRANSFORM HELPER ($7AC0)
; ============================================================================
; Transforms a byte value for sprite rendering on level 99
; Called by the level 99 handler to process sprite data
;
; Input: A = byte to transform, Y = source offset
; Output: A = transformed byte, ZP_40 updated
; Modifies: A, ZP_40

L_7AC0:
        tay                         ; a8
        and     #$C0                ; 29 c0
        asl                         ; 0a
        rol                         ; 2a
        rol                         ; 2a
        sta     ZP_40               ; 85 40
        tya                         ; 98
        and     #$30                ; 29 30
        lsr                         ; 4a
        lsr                         ; 4a
        ora     ZP_40               ; 05 40
        sta     ZP_40               ; 85 40
        tya                         ; 98
        and     #$0C                ; 29 0c
        asl                         ; 0a
        asl                         ; 0a
        ora     ZP_40               ; 05 40
        sta     ZP_40               ; 85 40
        tya                         ; 98
        and     #$03                ; 29 03
        lsr                         ; 4a
        ror                         ; 6a
        ror                         ; 6a
        ora     ZP_40               ; 05 40
        rts                         ; 60

; ============================================================================
; LEVEL 99 SPECIAL HANDLER ($7AE3)
; ============================================================================
; Called when player reaches level 99 (Super Drunk / final boss level)
; Sets up special screen rendering for the boss battle by copying and
; transforming sprite data to screen memory
;
; Input: None
; Output: Screen memory updated for boss display
; Modifies: A, X, Y, ZP_02-05, ZP_3C, DATPTR

level_99_handler:
D_7AE3:
        lda     #$08                ; a9 08 - 9 iterations (0-8)
        sta     ZP_3C               ; 85 3c
@loop_outer:
        ldx     ZP_3C               ; a6 3c
        lda     tbl_7B2F,x          ; bd 2f 7b - Load source pointer low
        sta     ZP_02               ; 85 02
        lda     tbl_7B38,x          ; bd 38 7b - Load source pointer high
        sta     ZP_03               ; 85 03
        lda     tbl_7B41,x          ; bd 41 7b - Load dest pointer low
        sta     ZP_04               ; 85 04
        lda     tbl_7B4A,x          ; bd 4a 7b - Load dest pointer high
        sta     ZP_05               ; 85 05
        ldy     #$3E                ; a0 3e - 62 bytes per block
        ldx     #$15                ; a2 15 - 21 iterations inner loop
@loop_inner:
        sty     DATPTR              ; 84 41
        lda     (ZP_02),y           ; b1 02 - Get source byte
        jsr     L_7AC0              ; 20 c0 7a - Transform it
        dec     DATPTR              ; c6 41
        ldy     DATPTR              ; a4 41
        dey                         ; 88
        sta     (ZP_04),y           ; 91 04 - Store transformed byte
        iny                         ; c8
        lda     (ZP_02),y           ; b1 02
        jsr     L_7AC0              ; 20 c0 7a
        ldy     DATPTR              ; a4 41
        sta     (ZP_04),y           ; 91 04
        dey                         ; 88
        lda     (ZP_02),y           ; b1 02
        jsr     L_7AC0              ; 20 c0 7a
        ldy     DATPTR              ; a4 41
        iny                         ; c8
        sta     (ZP_04),y           ; 91 04
        dey                         ; 88
        dey                         ; 88
        dey                         ; 88
        dex                         ; ca
        bne     @loop_inner         ; d0 d7
        dec     ZP_3C               ; c6 3c
        bpl     @loop_outer         ; 10 b9
        rts                         ; 60

; --- Data tables for level 99 handler ---
; Source pointers (low bytes) - point into sprite data at $76xx-$78xx
tbl_7B2F:
        .byte   $40,$80,$C0,$00,$40,$80,$C0,$00,$40
; Source pointers (high bytes)
tbl_7B38:
        .byte   $76,$76,$76,$77,$77,$77,$77,$78,$78
; Dest pointers (low bytes) - point into screen buffer at $7Cxx-$7Exx
tbl_7B41:
        .byte   $C0,$80,$40,$80,$40,$00,$40,$00,$C0
; Dest pointers (high bytes)
tbl_7B4A:
        .byte   $7C,$7C,$7C,$7D,$7D,$7D,$7E,$7E,$7D

; ============================================================================
; CREDITS DISPLAY ROUTINE ($7B53)
; ============================================================================
; Shows credits display after game over, handles continue prompt
;
; Input: None
; Output: Credits screen displayed
; Modifies: A, X, Y, ZP_40, ZP_41, RIDBS

credits_display:
D_7B53:
        ldx     #$93                ; a2 93
        ldy     #$AB                ; a0 ab
        jsr     D_E42A              ; 20 2a e4 - Display routine
        jsr     D_E3A7              ; 20 a7 e3 - Update sprites
        ldx     #$00                ; a2 00
        lda     D_045A              ; ad 5a 04 - Player 1 lives
        pha                         ; 48
        bpl     @p1_alive           ; 10 03
        stx     D_045A              ; 8e 5a 04 - Clear if negative
@p1_alive:
        lda     lives_p2            ; ad 5b 04 - Player 2 lives
        pha                         ; 48
        bpl     @p2_alive           ; 10 03
        stx     lives_p2            ; 8e 5b 04 - Clear if negative
@p2_alive:
        jsr     D_046C              ; 20 6c 04 - Check player state
        ldx     #$01                ; a2 01
@restore_loop:
        pla                         ; 68
        sta     D_045A,x            ; 9d 5a 04 - Restore lives
        bpl     @skip_gameover      ; 10 03
        jsr     game_over_sequence  ; 20 e8 7b - Show game over
@skip_gameover:
        dex                         ; ca
        bpl     @restore_loop       ; 10 f4
        ldx     RIDBE               ; a6 ab
        inx                         ; e8
        bpl     @credit_ok          ; 10 02
        ldx     #$00                ; a2 00
@credit_ok:
        txa                         ; 8a
        ora     #$20                ; 09 20
        sta     credits_count       ; 8d a4 7b
        ldx     #$96                ; a2 96
        ldy     #$7B                ; a0 7b
        jmp     D_E42A              ; 4c 2a e4

; --- Credits text data ---
credits_text:
        .byte   $1F,$21,$17,$03     ; Position: column $21, row $17, length 3
        .byte   $43,$52,$45,$44,$49,$54,$53  ; "CREDITS"
        .byte   $1F,$24,$18         ; Position: column $24, row $18
credits_count:
        .byte   $00                 ; Credit count (modified at runtime)
        .byte   $10                 ; Terminator ($10 = end of text marker)

; ============================================================================
; CLEAR ENTITY STATE ($7BA6)
; ============================================================================
; Clears entity state array, initializes for new level
;
; Input: None
; Output: X=0, OPMASK=0
; Modifies: A, X

clear_entity_state:
D_7BA6:
        ldx     #$05                ; a2 05
        lda     #$FF                ; a9 ff
@loop:
        sta     D_A76F,x            ; 9d 6f a7
        dex                         ; ca
        bne     @loop               ; d0 fa
        stx     OPMASK              ; 86 4d
        rts                         ; 60

; ============================================================================
; BANK RAM UNDER I/O ($7BB3)
; ============================================================================
; Saves registers and banks in RAM at $D000-$DFFF
; Called at start of IRQ handlers to access game data under I/O
;
; Input: A, X, Y (to be saved)
; Output: RAM banked in at $D000-$DFFF
; Modifies: ZP_15-17, ZP_2E, R6510

bank_ram_under_io:
D_7BB3:
        sta     ZP_15               ; 85 15 - Save A
        stx     ZP_16               ; 86 16 - Save X
        sty     ZP_17               ; 84 17 - Save Y
        cld                         ; d8    - Clear decimal mode
        lda     R6510               ; a5 01 - Get CPU port
        sta     ZP_2E               ; 85 2e - Save it
        lda     #$35                ; a9 35 - RAM under I/O, BASIC off
        sta     R6510               ; 85 01
        rts                         ; 60

; ============================================================================
; WAIT FOR FRAME SYNC ($7BC3)
; ============================================================================
; Waits for a specified number of frames
;
; Entry points:
;   D_7BC3 - Wait 5 frames
;   D_7BC6 - Wait 10 frames
;   D_7BC8 - Wait N frames (counter in A)
;
; Input: A = frame count (or use specific entry point)
; Output: None
; Modifies: A

wait_5_frames:
D_7BC3:
        lda     #$05                ; a9 05
        .byte   $2C                 ; BIT abs - skip next 2 bytes
wait_10_frames:
D_7BC6:
        lda     #$0A                ; a9 0a
wait_frames:
D_7BC8:
        sta     D_0100              ; 8d 00 01 - Store counter on stack page
@loop:
        jsr     D_E494              ; 20 94 e4 - Wait one frame
        dec     D_0100              ; ce 00 01
        bne     @loop               ; d0 f8
        rts                         ; 60

; ============================================================================
; PLAYER ENEMY STATE HANDLERS ($7BD4, $7BDB)
; ============================================================================

; Clear enemy state for a player entity
; Input: X = player index
; Output: Jump to enemy update routine
clear_player_enemy_state:
D_7BD4:
        lda     #$00                ; a9 00
        sta     PESSION,x           ; 95 ca
        jmp     D_E779              ; 4c 79 e7

; Set enemy state to $FF for player
; Input: X = player index
; Output: Jump to entity update
set_player_enemy_state:
D_7BDB:
        lda     #$FF                ; a9 ff
        sta     PESSION,x           ; 95 ca
        lda     #$00                ; a9 00
        sta     ZP_DC,x             ; 95 dc
        sta     ZP_EE,x             ; 95 ee
        jmp     D_E968              ; 4c 68 e9

; ============================================================================
; GAME OVER SEQUENCE ($7BE8)
; ============================================================================
; Called when a player loses all lives
; Updates display and handles game over state
;
; Input: X = player index
; Output: None
; Modifies: A, Y, ZP_40

game_over_sequence:
D_7BE8:
        stx     ZP_40               ; 86 40 - Save player index
        ldy     D_A739,x            ; bc 39 a7 - Get Y position offset
        sty     D_A73D              ; 8c 3d a7
        iny                         ; c8
        sty     D_A745              ; 8c 45 a7
        ldx     #$3B                ; a2 3b
        ldy     #$A7                ; a0 a7
        jsr     D_E42A              ; 20 2a e4 - Display "GAME OVER"
        ldx     ZP_40               ; a6 40
        rts                         ; 60

; ============================================================================
; GET TERRAIN TYPE ($7BFE)
; ============================================================================
; Gets terrain type for entity position
;
; Input: X = entity index
; Output: A = direction, Y = lookup index, ZP_40/41 = screen address
; Modifies: A, Y, ZP_40, ZP_41

get_terrain_type:
D_7BFE:
        lda     ZP_EE,x             ; b5 ee - Get entity row
        asl                         ; 0a   - *2 for table lookup
        tay                         ; a8
        lda     D_AC01,y            ; b9 01 ac - Screen address low
        adc     ZP_DC,x             ; 75 dc - Add column offset
        sta     ZP_40               ; 85 40
        lda     D_AC02,y            ; b9 02 ac - Screen address high
        adc     #$85                ; 69 85 - Add page offset
        sta     ZP_41               ; 85 41
        lda     D_A9D6,x            ; bd d6 a9 - Get direction
        rts                         ; 60

; ============================================================================
; TOGGLE ENTITY FLAG ($7C14)
; ============================================================================
; Toggles bit 0 of entity flag, then jumps to score routine
;
; Input: X = entity index
; Output: A = $38
; Modifies: A, D_A9C4,x

toggle_entity_flag:
D_7C14:
        lda     D_A9C4,x            ; bd c4 a9
        eor     #$01                ; 49 01
        sta     D_A9C4,x            ; 9d c4 a9
        lda     #$38                ; a9 38
        jmp     D_1288              ; 4c 88 12

; ============================================================================
; ADD SCORE ($7C21)
; ============================================================================
; Adds score value to player's score using BCD arithmetic
;
; Input: X = player index
; Output: Score updated
; Modifies: A, Y

add_score:
D_7C21:
        ldy     D_AB51,x            ; bc 51 ab - Get player score offset
add_score_value:
D_7C24:
        lda     #$01                ; a9 01
        sed                         ; f8    - Set decimal mode
@add_loop:
        clc                         ; 18
        adc     D_0400,y            ; 79 00 04 - Add to score
        sta     D_0400,y            ; 99 00 04
        bcc     @done               ; 90 05 - No carry, done
        lda     #$01                ; a9 01
        dey                         ; 88
        bpl     @add_loop           ; 10 f2 - Continue adding carry
@done:
        cld                         ; d8    - Clear decimal mode
        rts                         ; 60

; ============================================================================
; SPECIAL LEVEL HANDLER ($7C37)
; ============================================================================
special_level_handler:
D_7C37:
        lda     #$45                ; a9 45
        jmp     D_7FB2              ; 4c b2 7f

; ============================================================================
; TIMER DECREMENT ($7C3C)
; ============================================================================
timer_decrement:
D_7C3C:
        dec     D_37C7,x            ; de c7 37 - X should be 0
        rts                         ; 60

; ============================================================================
; SPRITE DATA: Game over graphics ($7C40-$7E7F)
; ============================================================================
; This section contains sprite graphics for game over display and
; other UI elements. Kept as binary data.

sprite_data_7C40:
        .byte   $00,$00,$00,$00,$00,$02,$00,$00,$2A,$00,$00,$AA,$00,$02,$AA,$00
        .byte   $0A,$AA,$00,$2A,$AA,$00,$2A,$AA,$28,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$A8
        .byte   $2A,$AA,$A8,$2A,$AA,$A8,$2A,$AA,$A8,$0A,$AA,$A2,$0A,$AA,$A2,$00
        .byte   $00,$00,$00,$AA,$AA,$A8,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$A8,$00,$AA,$82,$AA,$A8,$2A,$AA,$A2,$AA
        .byte   $AA,$8A,$AA,$AA,$8A,$A0,$00,$2A,$83,$F0,$2A,$0F,$FC,$A8,$3F,$FF
        .byte   $A8,$3F,$C3,$A8,$FF,$00,$A0,$FF,$30,$A0,$FC,$3C,$A3,$FC,$0C,$7D
        .byte   $00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$A0,$00,$00,$A8
        .byte   $00,$00,$A8,$00,$00,$0A,$00,$00,$A0,$00,$00,$AA,$80,$00,$AA,$A8
        .byte   $00,$AA,$AA,$00,$02,$AA,$00,$3C,$2A,$80,$FF,$0A,$80,$FF,$CA,$80
        .byte   $0F,$F2,$A0,$03,$F2,$A0,$33,$FC,$A0,$3C,$FC,$A0,$0C,$FC,$A0,$FF
        .byte   $02,$AA,$A2,$02,$AA,$A2,$00,$AA,$A2,$00,$AA,$A2,$00,$2A,$A2,$00
        .byte   $0A,$A2,$00,$02,$A2,$50,$02,$A8,$55,$00,$A8,$55,$40,$A8,$15,$54
        .byte   $AB,$05,$56,$AB,$01,$56,$AB,$00,$5A,$AB,$00,$1A,$AB,$00,$2A,$AA
        .byte   $00,$2A,$A8,$00,$2A,$A1,$00,$AA,$A1,$00,$AA,$A1,$00,$AA,$A1,$00
        .byte   $A3,$FC,$0F,$A3,$FC,$03,$A3,$FC,$03,$A3,$FC,$03,$A3,$FC,$00,$A3
        .byte   $FC,$00,$A3,$FC,$00,$A0,$FC,$00,$BF,$3F,$00,$D5,$C0,$00,$55,$7F
        .byte   $FC,$55,$5F,$FC,$55,$5F,$FC,$55,$5F,$FF,$55,$5F,$FF,$15,$5F,$FF
        .byte   $45,$7F,$FF,$53,$FF,$FF,$54,$00,$FF,$55,$55,$3F,$55,$55,$4F,$00
        .byte   $0F,$3C,$A0,$03,$3C,$A0,$03,$3C,$A0,$03,$3C,$A0,$00,$3C,$A0,$00
        .byte   $3C,$A0,$00,$3C,$A0,$30,$3C,$80,$3C,$0E,$80,$0C,$F2,$00,$03,$FC
        .byte   $00,$03,$F5,$40,$03,$F5,$50,$0F,$F5,$50,$FF,$FD,$54,$FF,$FD,$54
        .byte   $FF,$FF,$5C,$FF,$FF,$FF,$FF,$3F,$FF,$FC,$0F,$FF,$FC,$0F,$FF,$00
        .byte   $02,$AA,$A8,$22,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
        .byte   $AA,$AA,$2A,$AA,$AA,$2A,$AA,$AA,$06,$AA,$AA,$05,$AA,$AA,$05,$6A
        .byte   $AA,$05,$56,$AA,$05,$55,$AA,$05,$55,$6A,$01,$55,$6A,$01,$55,$5A
        .byte   $00,$55,$56,$00,$05,$55,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $55,$55,$53,$15,$55,$53,$85,$55,$53,$A0,$01,$53,$A0,$01,$53,$85
        .byte   $55,$53,$85,$55,$53,$85,$55,$52,$A1,$55,$4A,$A8,$55,$2A,$AA,$00
        .byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$A9
        .byte   $AA,$AA,$A5,$AA,$AA,$A5,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        .byte   $FC,$0F,$FF,$FF,$3F,$FC,$FF,$FF,$FC,$FF,$FF,$F0,$FF,$FF,$F0,$FF
        .byte   $FF,$C0,$FF,$F5,$00,$AA,$95,$40,$AA,$57,$50,$A9,$57,$D0,$A5,$55
        .byte   $D4,$A5,$55,$F4,$95,$55,$74,$55,$55,$54,$55,$55,$54,$55,$55,$50
        .byte   $55,$55,$50,$55,$55,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; ============================================================================
; CHECK PAUSE ($7E80)
; ============================================================================
; Check for SPACE key (pause game)
; When pressed, pauses game until SPACE is pressed again
;
; Input: None
; Output: Returns normally, or stays in pause loop
; Modifies: A, ZP_37, ZP_2A, ZP_5D, ZP_5E, D_A9B1

check_pause:
D_7E80:
        jsr     D_7EB6              ; 20 b6 7e - Read keyboard
        bne     check_pause_return  ; d0 2d - Key not pressed, return
        inc     ZP_37               ; e6 37 - Increment pause state
        lda     ZP_2A               ; a5 2a
        pha                         ; 48
        lda     D_A9B1              ; ad b1 a9
        pha                         ; 48
        lda     ZP_5D               ; a5 5d
        pha                         ; 48
        lda     ZP_5E               ; a5 5e
        pha                         ; 48
@wait_release1:
        jsr     read_keyboard_wait  ; 20 b3 7e - Wait for key release
        beq     @wait_release1      ; f0 fb
@wait_press:
        jsr     read_keyboard_wait  ; 20 b3 7e - Wait for key press
        bne     @wait_press         ; d0 fb
@wait_release2:
        jsr     read_keyboard_wait  ; 20 b3 7e - Wait for key release
        beq     @wait_release2      ; f0 fb
        pla                         ; 68
        sta     ZP_5E               ; 85 5e
        pla                         ; 68
        sta     ZP_5D               ; 85 5d
        pla                         ; 68
        sta     D_A9B1              ; 8d b1 a9
        pla                         ; 68
        sta     ZP_2A               ; 85 2a
        dec     ZP_37               ; c6 37
check_pause_return:                 ; Shared by check_quit
        rts                         ; 60

; ============================================================================
; READ KEYBOARD ($7EB3, $7EB6, $7EB8)
; ============================================================================
; Read keyboard for SPACE key
;
; Entry points:
;   D_7EB3 - Wait one frame then read
;   D_7EB6 - Read immediately  
;   D_7EB8 - Set row and read
;
; Output: Z flag set if SPACE pressed, A = keyboard value

read_keyboard_frame:
read_keyboard_wait:
D_7EB3:
        jsr     D_E494              ; 20 94 e4 - Wait one frame
D_7EB6:
        lda     #$7F                ; a9 7f - Select keyboard row
read_keyboard:
D_7EB8:
        sta     CIA1_PRA            ; 8d 00 dc
        lda     CIA1_PRB            ; ad 01 dc - Read keyboard column
        cmp     #$DF                ; c9 df - Check for SPACE ($DF when pressed)
        rts                         ; 60

; ============================================================================
; CHECK QUIT ($7EC1)
; ============================================================================
; Check for RUN/STOP key to quit game
;
; Input: None
; Output: If quit, jumps to title screen
; Modifies: A, X, ZP_37, D_5AFF

check_quit:
D_7EC1:
        jsr     D_7EB6              ; 20 b6 7e - Read keyboard
        cmp     #$BF                ; c9 bf - Check for RUN/STOP
        bne     check_pause_return  ; d0 ea - Not pressed, return (shares RTS with check_pause)
        ; RUN/STOP pressed - quit to title
        lda     #$00                ; a9 00
        sta     ZP_37               ; 85 37
        sta     D_5AFF              ; 8d ff 5a
        ldx     #$07                ; a2 07
        jsr     D_1E30              ; 20 30 1e
        jsr     D_1805              ; 20 05 18
        jsr     D_F4BD              ; 20 bd f4 - Init sound
        pla                         ; 68    - Clean up stack
        pla                         ; 68
        lda     #$19                ; a9 19
        jmp     D_7BC8              ; 4c c8 7b

; --- Text data for continue/game over messages ($7EA1-$7F52) ---
gameover_text_data:
        .byte   $00
        .byte   $1F,$0B,$08         ; Position code
        .byte   $8A,$8B,$97,$97,$97,$97,$97,$97,$40,$96
        .byte   $00
        .byte   $1F,$0B,$0C
        .byte   $8A,$8B,$97,$97,$97,$97,$97,$97,$40,$96
        .byte   $00
        .byte   $1F,$0B,$0D
        .byte   $8A,$8B,$97,$97,$97,$97,$97,$97,$40,$96
        .byte   $1F,$0D,$09
        .byte   $85,$86,$87,$87,$88,$89
        .byte   $1F,$0C,$0A
        .byte   $8A,$8B,$97,$97,$97,$97,$40,$96
        .byte   $1F,$0C,$0B
        .byte   $85,$86,$87,$87,$87,$87,$88,$89
        .byte   $1F,$0B,$0E
        .byte   $8A,$8B,$97,$97,$8C,$8E,$97,$97,$40,$96
        .byte   $1F,$0B,$0F
        .byte   $85,$86,$87,$87,$8D,$8F,$87,$87,$88,$89
        .byte   $1F,$0E,$16
        .byte   $90,$92,$94,$90
        .byte   $1F,$0E,$17
        .byte   $91,$93,$95,$91
        .byte   $10                 ; Terminator

; ============================================================================
; PLAYER DEATH RESPAWN HANDLER ($7F53)
; ============================================================================
; Called when a player dies to set up respawn state
; Handles level 99 special case with unique setup
;
; Input: X = player index
; Output: Player state updated for respawn
; Modifies: A, multiple ZP and memory locations

player_death_respawn:
D_7F53:
        lda     #$88                ; a9 88
        sta     D_A77D,x            ; 9d 7d a7
        and     #$08                ; 29 08
        sta     D_A77B,x            ; 9d 7b a7
        lsr                         ; 4a
        sta     D_A77F,x            ; 9d 7f a7
        sta     D_A781,x            ; 9d 81 a7
        lda     #$FF                ; a9 ff
        sta     D_A783,x            ; 9d 83 a7
        lda     #$00                ; a9 00
        sta     FAC,x               ; 95 61
        sta     FAC+2,x             ; 95 63
        sta     FAC+4,x             ; 95 65
        sta     D_37C7,x            ; 9d c7 37
        sta     D_8728,x            ; 9d 28 87
        sta     D_A813,x            ; 9d 13 a8
        sta     D_86D8,x            ; 9d d8 86
        lda     SUBFLG              ; a5 10 - Current level
        cmp     #$63                ; c9 63 - Level 99?
        bne     @done               ; d0 20 - No, skip special setup
        ; Level 99 special death handling
        lda     #$22                ; a9 22
        sta     FOUR6               ; 85 53
        sta     ZP_5E               ; 85 5e
        lda     #$51                ; a9 51
        sta     ZP_52               ; 85 52
        sta     ZP_5D               ; 85 5d
        lda     #$08                ; a9 08
        sta     D_A77B              ; 8d 7b a7
        sta     D_A77C              ; 8d 7c a7
        sta     ZP_4A               ; 85 4a
        lda     #$BD                ; a9 bd
        sta     D_23DE              ; 8d de 23
        lda     #$3C                ; a9 3c
        sta     D_0F73              ; 8d 73 0f
@done:
        rts                         ; 60

; ============================================================================
; LEVEL SKIP HANDLERS ($7FA4, $7FA7)
; ============================================================================
; Handles level skip cheat/powerup
;
; Entry points:
;   D_7FA4 - Skip 3 levels
;   D_7FA7 - Skip 7 levels
;   D_7FB2 - Entry with A already set (used by D_7C37)
;
; Input: None (or A = skip amount for D_7FB2)
; Output: Level advanced, screen updated
; Modifies: A, X, ZP_37, VIC registers

level_skip_3:
D_7FA4:
        lda     #$03                ; a9 03
        .byte   $2C                 ; BIT abs - skip next 2 bytes
level_skip_7:
D_7FA7:
        lda     #$07                ; a9 07
        clc                         ; 18
        adc     SUBFLG              ; 65 10 - Add to current level
        cmp     #$63                ; c9 63 - Cap at level 99
        bcc     @level_ok           ; 90 02
        lda     #$63                ; a9 63
@level_ok:
D_7FB2:                             ; Entry point from D_7C37
        sta     D_587F              ; 8d 7f 58
        pla                         ; 68    - Remove return addresses
        pla                         ; 68
        pla                         ; 68
        pla                         ; 68
        inc     ZP_37               ; e6 37
        ldx     #$06                ; a2 06
@flash_loop:
        lda     VIC_BORDER          ; ad 20 d0
        eor     #$02                ; 49 02 - Flash border
        sta     VIC_BORDER          ; 8d 20 d0
        sta     VIC_BG0             ; 8d 21 d0
        jsr     wait_10_frames      ; 20 c6 7b
        dex                         ; ca
        bne     @flash_loop         ; d0 ef
        jsr     D_2E79              ; 20 79 2e
        jsr     D_E4DA              ; 20 da e4
D_7FD4:                             ; Loop target for level advancement
        inc     SUBFLG              ; e6 10
        lda     SUBFLG              ; a5 10
        cmp     D_587F              ; cd 7f 58
        bne     @next_level         ; d0 04
        clc                         ; 18
        jmp     D_09A5              ; 4c a5 09
@next_level:
        jsr     D_E000              ; 20 00 e0 - Level renderer
        jsr     D_37C9              ; 20 c9 37
        jsr     D_392A              ; 20 2a 39
        lda     #$00                ; a9 00
        sta     ZP_20               ; 85 20
        jmp     D_7FD4              ; 4c d4 7f - Loop back to check next level

; ============================================================================
; FINAL ROUTINE ($7FF1) - Not D_7FD4!
; ============================================================================
; This small routine is called from somewhere else
final_routine:
        lda     #$FE                ; a9 fe
        sta     D_8728,x            ; 9d 28 87
        rts                         ; 60

; --- Trailing data bytes ($7FF7-$7FFF) ---
trailing_data:
        .byte   $FF,$29,$FF,$FF,$00,$EF,$FF,$7D,$FF
