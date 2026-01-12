; ============================================================================
; BUBBLE PHYSICS AND SPRITE POSITIONING ($1578 - $1843)
; ============================================================================
; This section handles:
;   - Bubble animation and movement
;   - Bubble firing mechanics
;   - VIC-II sprite register updates
;   - Player/entity sprite positioning
; ============================================================================

; ============================================================================
; UPDATE_BUBBLES ($1578)
; ============================================================================
; Updates bubble animations and movement for both players.
; Handles bubble firing animation frames and screen updates.
;
; Zero-page usage:
;   $5D/$5E - Bubble animation timer (P1/P2)
;   $52/$53 - Bubble state flags (P1/P2)
;   $4E/$4F - Bubble screen position low (P1/P2)
;   $50/$51 - Bubble screen position high (P1/P2)
; ============================================================================

update_bubbles:
        ldx     #$01                    ; a2 01    - Process both players (1,0)
        
bubble_player_loop:
        lda     $5d,x                   ; b5 5d    - Get bubble animation timer
        bpl     bubble_animation_done   ; 10 48    - Skip if timer not expired
        
        ; Reset animation timer and toggle bubble state
        lda     #$0b                    ; a9 0b    - Reset animation timer to 11
        sta     $5d,x                   ; 95 5d
        lda     $52,x                   ; b5 52    - Get bubble state flag
        cmp     #$ff                    ; c9 ff    - Is it $FF (inactive)?
        beq     bubble_animation_done   ; f0 3e    - Yes, skip
        
        ; Toggle bubble state flag (bit 7)
        eor     #$80                    ; 49 80    - Toggle high bit
        sta     $52,x                   ; 95 52
        bpl     bubble_animation_done   ; 10 38    - Skip if now positive
        
        ; Bubble is firing - set to inactive
        lda     #$ff                    ; a9 ff
        sta     $52,x                   ; 95 52
        
        ; Clear bubble display areas on screen
        lda     $4e,x                   ; b5 4e    - Get bubble screen low
        sta     DATLIN+1                ; 85 40
        sta     DATPTR+1                ; 85 42
        sta     $44                     ; 85 44
        lda     $50,x                   ; b5 50    - Get bubble screen high
        ora     #$54                    ; 09 54    - Set to screen memory page
        sta     DATPTR                  ; 85 41
        eor     #$04                    ; 49 04    - Flip between screens
        sta     VARNAM                  ; 85 45
        adc     #$3b                    ; 69 3b    - Add color RAM offset
        sta     INPPTR                  ; 85 43
        
        ; Clear 3 rows of bubble display (8 bytes each)
        ldy     #$00                    ; a0 00
clear_bubble_row1:
        lda     (DATPTR+1),y            ; b1 42    - Read from screen
        sta     (DATLIN+1),y            ; 91 40    - Write to clear area 1
        sta     ($44),y                 ; 91 44    - Write to clear area 2
        iny                             ; c8
        lda     (DATPTR+1),y            ; b1 42
        sta     (DATLIN+1),y            ; 91 40
        sta     ($44),y                 ; 91 44
        
        ldy     #$28                    ; a0 28    - Next row (+40 bytes)
        lda     (DATPTR+1),y            ; b1 42
        sta     (DATLIN+1),y            ; 91 40
        sta     ($44),y                 ; 91 44
        iny                             ; c8
        lda     (DATPTR+1),y            ; b1 42
        sta     (DATLIN+1),y            ; 91 40
        sta     ($44),y                 ; 91 44
        
bubble_animation_done:
        dex                             ; ca       - Next player
        bpl     bubble_player_loop      ; 10 b1    - Loop for both players
        
        ; Rest of bubble/timer system is complex, keeping as .byte
        .byte   $A5,$67,$F0,$14,$C6,$67,$D0,$A6                 ; $15C9
        .byte   $A5,$1C,$49,$07,$85,$1C,$A5,$1E                 ; $15D1
        .byte   $49,$07,$85,$1E,$A9,$32,$85,$2B                 ; $15D9
        .byte   $A5,$2A,$F0,$03,$4C,$94,$16,$E6                 ; $15E1
        .byte   $37,$A5,$2D,$D0,$0A,$20,$B8,$3A                 ; $15E9
        .byte   $E6,$2D,$A9,$0A,$4C,$8F,$16,$10                 ; $15F1
        .byte   $27,$A2,$01,$B5,$B2,$F0,$19,$C9                 ; $15F9
        .byte   $01,$F0,$15,$CD,$7F,$5A,$D0,$15                 ; $1601
        .byte   $A9,$01,$95,$B2,$BD,$13,$A8,$9D                 ; $1609
        .byte   $28,$87,$BD,$70,$85,$9D,$48,$85                 ; $1611
        .byte   $CA,$10,$E0,$E6,$21,$C6,$37,$60                 ; $1619
        .byte   $A0,$43,$20,$AD,$05,$20,$E8,$1A                 ; $1621
        .byte   $A2,$FF,$86,$58,$E8,$8E,$FF,$58                 ; $1629
        .byte   $E8,$A9,$00,$9D,$D6,$A9,$9D,$C4                 ; $1631
        .byte   $A9,$9D,$30,$AA,$9D,$42,$AA,$20                 ; $1639
        .byte   $EA,$E9,$29,$01,$A8,$B9,$77,$A7                 ; $1641
        .byte   $95,$DC,$95,$02,$20,$EA,$E9,$29                 ; $1649
        .byte   $01,$A8,$B9,$79,$A7,$95,$EE,$95                 ; $1651
        .byte   $04,$B5,$B2,$F0,$04,$A9,$3A,$95                 ; $1659
        .byte   $CA,$CA,$10,$CD,$20,$02,$1B,$A2                 ; $1661
        .byte   $01,$B5,$B2,$F0,$0E,$B5,$02,$95                 ; $1669
        .byte   $DC,$B5,$04,$95,$EE,$8A,$0A,$69                 ; $1671
        .byte   $2E,$95,$CA,$CA,$10,$EB,$86,$2B                 ; $1679
        .byte   $E8,$86,$2D,$A5,$A4,$D0,$FC,$A0                 ; $1681
        .byte   $27,$20,$AD,$05,$A5,$2C,$85,$2A                 ; $1689
        .byte   $C6,$37,$60                                     ; $1691

D_1694:
        ; Baron hurry-up sequence handling
        .byte   $AD,$B1,$A9,$D0,$41,$A2,$08                     ; $1694
        .byte   $BD,$9C,$8C,$9D,$9C,$51                         ; $169B
        .byte   $9D,$9C,$55,$BD,$EC,$8C,$9D,$EC                 ; $16A1
        .byte   $51,$9D,$EC,$55,$A9,$0D,$9D,$9C                 ; $16A9
        .byte   $D9,$9D,$EC,$D9,$CA,$10,$E3,$CE                 ; $16B1
        .byte   $B1,$A9,$A5,$10,$C9,$63,$D0,$19                 ; $16B9
        .byte   $A9,$74,$85,$BC,$A9,$65,$85,$BD                 ; $16C1
        .byte   $A0,$06,$84,$BF,$88,$84,$C0,$A2                 ; $16C9
        .byte   $00,$86,$BE,$CA,$8E,$FF,$5A,$86                 ; $16D1
        .byte   $2B,$A5,$2D,$10,$19,$A6,$4A,$E0                 ; $16D9
        .byte   $01,$D0,$12,$A2,$05,$B5,$B4,$F0                 ; $16E1
        .byte   $09,$C9,$0B,$B0,$05,$A9,$FF,$9D                 ; $16E9
        .byte   $2A,$87,$CA,$10,$F0,$60,$A6,$4A                 ; $16F1
        .byte   $D0,$E5,$8E,$FF,$58,$CA,$A5,$53                 ; $16F9
        .byte   $10,$04,$86,$53,$30,$02,$86,$5E                 ; $1701
        .byte   $A5,$58,$10,$08,$20,$EA,$E9,$29                 ; $1709
        .byte   $03,$4C,$19,$17,$A5,$2A,$69,$08                 ; $1711
        .byte   $85,$58,$A2,$11,$B5,$CA,$30,$2C                 ; $1719
        .byte   $C9,$46,$F0,$28,$C9,$44,$F0,$24                 ; $1721
        .byte   $C9,$4A,$F0,$20,$9D,$42,$AA,$A8                 ; $1729
        .byte   $A9,$3A,$C0,$04,$F0,$08,$C0,$38                 ; $1731
        .byte   $90,$10,$C0,$42,$B0,$0C,$A4,$68                 ; $1739
        .byte   $F0,$08,$B9,$E4,$A8,$9D,$E8,$A9                 ; $1741
        .byte   $A9,$4C,$95,$CA,$CA,$10,$CD,$A5                 ; $1749
        .byte   $69,$F0,$0B,$20,$2E,$1E,$A9,$15                 ; $1751
        .byte   $85,$B4,$85,$C6,$85,$C7,$A9,$32                 ; $1759
        .byte   $85,$2B,$A9,$FF,$85,$2D,$A9,$09                 ; $1761
        .byte   $85,$2A,$A5,$68,$F0,$03,$4C,$17                 ; $1769
        .byte   $35,$60,$1F,$0C,$05,$07,$43,$4F                 ; $1771
        .byte   $4E,$47,$52,$41,$54,$55,$4C,$41                 ; $1779
        .byte   $54,$49,$4F,$4E,$53,$1F,$04,$08                 ; $1781
        .byte   $05,$59,$4F,$55,$40,$48,$41,$56                 ; $1789
        .byte   $45,$40,$43,$4F,$4D,$50,$4C,$45                 ; $1791
        .byte   $54,$45,$44,$40,$42,$55,$42,$42                 ; $1799
        .byte   $4C,$45,$40,$42,$4F,$42,$42,$4C                 ; $17A1
        .byte   $45,$1F,$0C,$0B,$01,$5C,$40,$57                 ; $17A9
        .byte   $48,$41,$54,$40,$48,$45,$52,$4F                 ; $17B1
        .byte   $45,$53,$40,$5C,$10,$A2,$05,$B5                 ; $17B9
        .byte   $C4,$9D,$92,$88,$A9,$15,$95,$C4                 ; $17C1
        .byte   $A9,$00,$9D,$C2,$85,$CA,$10,$EF                 ; $17C9
        .byte   $A9,$16,$85,$11,$20,$94,$E4,$20                 ; $17D1
        .byte   $94,$E4,$20,$05,$18,$A2,$07,$B5                 ; $17D9
        .byte   $B2,$F0,$17,$86,$12,$20,$87,$1E                 ; $17E1
        .byte   $A6,$12,$B5,$C2,$DD,$90,$88,$F0                 ; $17E9
        .byte   $06,$F6,$C2,$F6,$C2,$D0,$03,$DE                 ; $17F1
        .byte   $C0,$85,$CA,$E0,$01,$D0,$E0,$C6                 ; $17F9
        .byte   $11,$D0,$D1,$60                                 ; $1801

; ============================================================================
; UPDATE_SPRITE_POSITIONS ($1805)
; ============================================================================
; Updates VIC-II sprite registers with current player/entity positions.
; Processes sprites 0-7, setting X, Y positions and colors.
;
; For each sprite (X = 7 down to 0):
;   - Reads position from $BA+X (X coord), $C2+X (Y coord)
;   - Writes to VIC-II sprite position registers ($D000+)
;   - Sets sprite color from D_8548,X
;   - Handles invincibility flash (alternates colors from D_8570,X)
;   - Sets sprite pointer from D_8520,X (animation frame)
; ============================================================================

update_sprite_positions:
        ldx     #$07                    ; a2 07    - 8 sprites (7 down to 0)
        ldy     #$0e                    ; a0 0e    - VIC offset (sprite 7 Y = $D00E)
        
sprite_pos_loop:
        lda     FA,x                    ; b5 ba    - Get entity X position ($BA+X)
        sta     VIC_SPR0_X,y            ; 99 00 d0 - Store to VIC sprite X
        lda     ZP_C2,x                 ; b5 c2    - Get entity Y position ($C2+X)
        sta     VIC_SPR0_Y,y            ; 99 01 d0 - Store to VIC sprite Y
        lda     D_8548,x                ; bd 48 85 - Get sprite color
        sta     VIC_SPR0_COL,x          ; 9d 27 d0 - Set sprite color register
        
        ; Check if entity is active and should flash
        lda     ENESSION,x              ; b5 b2    - Get entity state ($B2+X)
        beq     set_sprite_pointer      ; f0 0f    - Skip if inactive
        cmp     #$11                    ; c9 11    - State >= $11?
        bcs     set_sprite_pointer      ; b0 0b    - Skip special states
        lda     D_8728,x                ; bd 28 87 - Get invincibility flash timer
        beq     set_sprite_pointer      ; f0 06    - Skip if not flashing
        lda     D_8570,x                ; bd 70 85 - Get alternate color (flash)
        sta     VIC_SPR0_COL,x          ; 9d 27 d0 - Override color for flash effect
        
set_sprite_pointer:
        ; Set sprite pointer (which sprite image to display)
        lda     D_8520,x                ; bd 20 85 - Get animation frame
        and     #$1f                    ; 29 1f    - Mask to 32 frames
        sta     D_8520,x                ; 9d 20 85 - Store back
        clc                             ; 18
        adc     D_8598,x                ; 7d 98 85 - Add sprite base pointer
        sta     D_53F8,x                ; 9d f8 53 - Store to screen 1 sprite pointers
        sta     D_57F8,x                ; 9d f8 57 - Store to screen 2 sprite pointers
        
        dey                             ; 88       - Next VIC Y register
        dey                             ; 88       - (Y decrements by 2 per sprite)
        dex                             ; ca       - Next sprite
        bpl     sprite_pos_loop         ; 10 c6    - Loop all 8 sprites
        rts                             ; 60
