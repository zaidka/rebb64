; ============================================================================
; SPECIAL ENEMY HANDLERS ($10D3 - $1318)
; ============================================================================
; This section handles special enemy types and behaviors:
;   - Baron Von Blubba (time-over boss, enemy type $44)
;   - Special items (enemy types $24-$33)
;   - Extended item routines
;
; Called from enemy_ai_update in bb-enemy-ai.s
; ============================================================================

; ============================================================================
; BARON VON BLUBBA HANDLER ($10D3)
; ============================================================================
; Baron Von Blubba is the invincible ghost that appears when time runs out.
; Enemy type $44 triggers this handler.
;
; Movement:
;   - Moves horizontally toward the player who captured it
;   - $0193,X stores which player (0 or 1) captured this enemy
;   - Moves at 8 pixels per frame
;   - After 30 frames ($1E), transforms to type $38
;
; This boss cannot be defeated and will kill players on contact.
; ============================================================================

baron_von_blubba:
        jsr     toggle_enemy_direction  ; 20 2b 11 - Flip direction flag
        lda     D_0193,x                ; bd 93 01 - Which player captured?
        bmi     move_baron_left         ; 30 18    - Negative = move left
        
        ; Move Baron right (toward player)
        lda     D_AA0C,x                ; bd 0c aa - Get X position
        clc                             ; 18
        adc     #$08                    ; 69 08    - Move 8 pixels right
        sta     D_AA0C,x                ; 9d 0c aa
        inc     $dc,x                   ; f6 dc    - Increment move counter
        lda     $dc,x                   ; b5 dc
        cmp     #$1e                    ; c9 1e    - 30 frames elapsed?
        bne     baron_check_collision   ; d0 14    - Not yet

baron_transform:
        lda     #$38                    ; a9 38    - Transform to type $38
        sta     PESSION,x               ; 95 ca
baron_continue:
        jmp     L_0D4A                  ; 4c 4a 0d - Return to AI loop

move_baron_left:
        lda     D_AA0C,x                ; bd 0c aa - Get X position
        sec                             ; 38
        sbc     #$08                    ; e9 08    - Move 8 pixels left
        sta     D_AA0C,x                ; 9d 0c aa
        dec     $dc,x                   ; d6 dc    - Decrement move counter
        beq     baron_transform         ; f0 ec    - If zero, transform

baron_check_collision:
        lda     PESSION,x               ; b5 ca    - Get enemy type
        sta     DATLIN                  ; 85 3f    - Save current type
        stx     OLDTXT+1                ; 86 3e    - Save X register
        jsr     D_105B                  ; 20 5b 10 - Check bubble collision
        lda     PESSION,x               ; b5 ca    - Get enemy type again
        cmp     DATLIN                  ; c5 3f    - Did it change?
        beq     baron_continue          ; f0 e1    - No change, continue
        
        ; Enemy was captured in bubble
        sbc     #$17                    ; e9 17    - Calculate bubble slot
        lsr                             ; 4a       - Divide by 2
        sta     OLDTXT                  ; 85 3d    - Store bubble slot
        lda     D_AA30,x                ; bd 30 aa - Get bubble type
        ldx     OLDTXT                  ; a6 3d    - Get bubble slot
        sta     $b4,x                   ; 95 b4    - Store in bubble array
        jsr     D_1A6F                  ; 20 6f 1a - Award points
        ldx     OLDTXT+1                ; a6 3e    - Restore X
        lda     DATLIN                  ; a5 3f    - Restore enemy type
        sta     PESSION,x               ; 95 ca
        lda     #$02                    ; a9 02    - Set animation state
        sta     $b0                     ; 85 b0
        jmp     L_0D4A                  ; 4c 4a 0d

; ============================================================================
; TOGGLE_ENEMY_DIRECTION ($112B)
; ============================================================================
; Toggles the enemy's direction flag between 0 and 1.
; Used by Baron Von Blubba and other enemies.
;
; Input:  X = enemy slot (0-17)
; Output: D_A9C4,X toggled between 0 and 1
; ============================================================================

toggle_enemy_direction:
        lda     D_A9C4,x                ; bd c4 a9 - Get direction flag
        eor     #$01                    ; 49 01    - Toggle bit 0
        sta     D_A9C4,x                ; 9d c4 a9
        rts                             ; 60

; ============================================================================
; SPECIAL ITEM HANDLER ($1134)
; ============================================================================
; Handles special items (enemy types $24-$33) that fall from popped bubbles.
; These items include:
;   - Fruits (watermelon, apple, etc.) for points
;   - Power-ups (shoes for speed, etc.)
;   - Special bonuses
;
; This routine checks if items are within the visible play area and
; collects them when a player touches them.
; ============================================================================

special_item_handler:
        lda     ZP_BE                   ; a5 be    - Get game state
        cmp     #$09                    ; c9 09    - Is it state 9?
        beq     skip_item_check_far     ; f0 55    - Yes, skip (to $118F)
        
        ldx     #$11                    ; a2 11    - Check all 18 slots
check_item_loop:
        lda     PESSION,x               ; b5 ca    - Get enemy type
        cmp     #$26                    ; c9 26    - Is it type $26 (item)?
        bne     next_item               ; d0 36    - No, check next
        
        ; Calculate item screen position
        lda     $dc,x                   ; b5 dc    - Get item column
        asl                             ; 0a       - Multiply by 8
        asl                             ; 0a
        asl                             ; 0a
        adc     #$14                    ; 69 14    - Add offset (20 pixels)
        sta     DATLIN+1                ; 85 40    - Store X screen pos
        
        lda     $ee,x                   ; b5 ee    - Get item row
        asl                             ; 0a       - Multiply by 8
        asl                             ; 0a
        asl                             ; 0a
        adc     #$15                    ; 69 15    - Add offset (21 pixels)
        sec                             ; 38
        sbc     ZP_BD                   ; e5 bd    - Subtract viewport Y
        bcs     check_y_top             ; b0 04    - No underflow
        cmp     #$f8                    ; c9 f8    - Check if near top
        bcs     check_x_pos             ; b0 04    - Within range
check_y_top:
        cmp     #$38                    ; c9 38    - Check if below 56 pixels
        bcs     next_item               ; b0 19    - Too far down
        
check_x_pos:
        lda     DATLIN+1                ; a5 40    - Get X screen pos
        sec                             ; 38
        sbc     ZP_BC                   ; e5 bc    - Subtract viewport X
        bcs     check_x_left            ; b0 04    - No underflow
        cmp     #$f8                    ; c9 f8    - Check if near left
        bcs     collect_item            ; b0 04    - Within range
check_x_left:
        cmp     #$40                    ; c9 40    - Check if beyond 64 pixels
        bcs     next_item               ; b0 0a    - Too far right
        
collect_item:
        lda     #$3a                    ; a9 3a    - Set to collected type
        sta     PESSION,x               ; 95 ca
        sta     D_AA42,x                ; 9d 42 aa - Save original type
        dec     D_5BBF                  ; ce bf 5b - Decrement item counter

next_item:
        dex                             ; ca       - Next enemy slot
        bpl     check_item_loop         ; 10 c1    - Continue if >= 0
        
        ; Check if all items collected
        lda     D_5BBF                  ; ad bf 5b - Get item counter
        bpl     skip_item_check         ; 10 0e    - Still items left
        
        ; All items collected - trigger special event
        lda     ZP_BE                   ; a5 be    - Get current game state
        sta     D_119F                  ; 8d 9f 11 - Save it
        lda     #$09                    ; a9 09    - Set state to 9
        sta     ZP_BE                   ; 85 be
        lda     #$82                    ; a9 82    - Reset counter to 130
        sta     D_5BBF                  ; 8d bf 5b
skip_item_check:
        rts                             ; 60       - Return ($118E)

; ============================================================================
; REMAINING SPECIAL ENEMY CODE ($118F - $1318)
; ============================================================================
; This section contains additional special item handlers and extended
; enemy behavior routines. Keeping as .byte for now due to complexity.
; ============================================================================

skip_item_check_far:
        .byte   $CE,$BF,$5B,$D0,$0F,$A9,$28,$8D                 ; $118F
        .byte   $BF,$5B,$A9,$FF,$8D,$2A,$87,$A9                 ; $1197
        .byte   $00,$85,$BE,$60,$AD,$BF,$5B,$C9                 ; $119F
        .byte   $11,$B0,$E4,$29,$01,$D0,$E0,$AD                 ; $11A7
        .byte   $15,$D0,$49,$FC,$8D,$15,$D0,$60                 ; $11AF
        .byte   $BD,$D6,$A9,$49,$04,$9D,$D6,$A9                 ; $11B7
        .byte   $F0,$11,$F6,$EE,$B5,$EE,$C9,$1D                 ; $11BF
        .byte   $90,$06,$D6,$EE,$A9,$38,$95,$CA                 ; $11C7
        .byte   $4C,$4A,$0D,$20,$FE,$7B,$A0,$00                 ; $11CF
        .byte   $B1,$40,$30,$F4,$A0,$28,$B1,$40                 ; $11D7
        .byte   $10,$EE,$A9,$38,$95,$CA,$A0,$04                 ; $11DF
        .byte   $B9,$70,$A7,$30,$06,$88,$10,$F8                 ; $11E7
        .byte   $4C,$4A,$0D,$8C,$5C,$12,$B5,$DC                 ; $11EF
        .byte   $85,$42,$A9,$00,$85,$43,$20,$EA                 ; $11F7
        .byte   $E9,$29,$0F,$85,$3C,$20,$EA,$E9                 ; $11FF
        .byte   $29,$0F,$85,$3D,$18,$75,$DC,$C9                 ; $1207
        .byte   $1E,$90,$04,$A9,$FF,$85,$3D,$A9                 ; $120F
        .byte   $FF,$C6,$40,$C5,$40,$D0,$02,$C6                 ; $1217
        .byte   $41,$A0,$00,$E6,$43,$B1,$40,$30                 ; $121F
        .byte   $0C,$A0,$28,$B1,$40,$10,$06,$C6                 ; $1227
        .byte   $42,$C6,$3C,$10,$E2,$A5,$3D,$30                 ; $122F
        .byte   $23,$A5,$43,$18,$65,$40,$85,$40                 ; $1237
        .byte   $90,$02,$E6,$41,$E6,$40,$D0,$02                 ; $123F
        .byte   $E6,$41,$A0,$01,$B1,$40,$30,$0C                 ; $1247
        .byte   $A0,$29,$B1,$40,$10,$06,$E6,$43                 ; $124F
        .byte   $C6,$3D,$10,$E8,$A0,$00,$A5,$42                 ; $1257
        .byte   $99,$61,$A7,$B5,$EE,$99,$66,$A7                 ; $125F
        .byte   $A5,$43,$99,$6B,$A7,$A9,$06,$99                 ; $1267
        .byte   $70,$A7,$4C,$4A,$0D,$20,$2B,$11                 ; $126F
        .byte   $BC,$93,$01,$10,$06,$C9,$01,$D0                 ; $1277
        .byte   $F1,$F0,$04,$C9,$00,$D0,$EB,$A9                 ; $127F
        .byte   $3A,$8D,$AC,$12,$20,$FE,$7B,$BC                 ; $1287
        .byte   $93,$01,$10,$0A,$A0,$4F,$B1,$40                 ; $128F
        .byte   $30,$12,$D6,$DC,$10,$08,$A0,$52                 ; $1297
        .byte   $B1,$40,$30,$08,$F6,$DC,$20,$2B                 ; $129F
        .byte   $15,$4C,$4A,$0D,$A9,$3A,$95,$CA                 ; $12A7
        .byte   $9D,$42,$AA,$D0,$F4,$A9,$60,$8D                 ; $12AF
        .byte   $A8,$12,$20,$86,$12,$A9,$4C,$8D                 ; $12B7
        .byte   $A8,$12,$FE,$C4,$A9,$BD,$C4,$A9                 ; $12BF
        .byte   $29,$03,$9D,$C4,$A9,$B5,$CA,$C9                 ; $12C7
        .byte   $3A,$D0,$0C,$A9,$2C,$95,$CA,$BD                 ; $12CF
        .byte   $93,$01,$49,$80,$9D,$93,$01,$B5                 ; $12D7
        .byte   $DC,$DD,$0C,$AA,$D0,$11,$BC,$1E                 ; $12DF
        .byte   $AA,$A9,$64,$99,$90,$88,$A9,$FF                 ; $12E7
        .byte   $99,$18,$88,$A9,$38,$95,$CA,$4C                 ; $12EF
        .byte   $4A,$0D,$F6,$EE,$20,$2B,$15,$90                 ; $12F7
        .byte   $04,$A9,$3A,$D0,$08,$B5,$EE,$C9                 ; $12FF
        .byte   $1D,$D0,$EC,$A9,$38,$95,$CA,$BC                 ; $1307
        .byte   $0C,$AA,$A9,$FF,$99,$18,$88,$4C                 ; $130F
        .byte   $4A,$0D                                         ; $1317
