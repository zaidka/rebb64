; ============================================================================
; PLAYER SPRITE UPDATE ROUTINES ($1319 - $1577)
; ============================================================================
; This section handles updating player character sprites on screen, including:
;   - Drawing player sprite animations to screen memory
;   - Handling player-item collision detection  
;   - Managing enemy timers and state transitions
;   - Processing bubble spawn mechanics
;
; The player sprites are composed of multiple character cells that are drawn
; to screen memory each frame to create the animated player characters.
; ============================================================================

; ============================================================================
; UPDATE_PLAYER_SPRITES ($1319)
; ============================================================================
; Main routine to update player character sprites on screen.
; Processes 5 player sprite slots (X = 4 down to 0).
;
; For each sprite slot:
;   - Checks if sprite is active (D_A770,X >= 0)
;   - Decrements animation timer every 4 frames
;   - Copies sprite character data to screen memory
;   - Handles both normal drawing and color RAM drawing
;
; Uses complex pointer arithmetic to calculate screen positions based on:
;   - D_A761,X: Column position
;   - D_A766,X: Row position  
;   - D_A76B,X: Sprite data index
;   - D_ACBD,Y: Character data pointer
; ============================================================================

update_player_sprites:
        ldx     #$04                    ; a2 04    - Process 5 sprites (4 down to 0)
sprite_update_loop:
        ldy     D_A770,x                ; bc 70 a7 - Get sprite active flag
        bmi     next_sprite             ; 30 4e    - Skip if negative (inactive)
        
        ; Decrement animation timer every 4 frames
        lda     D_597F                  ; ad 7f 59 - Get frame counter
        and     #$03                    ; 29 03    - Check low 2 bits
        bne     skip_timer_dec          ; d0 03    - Skip if not multiple of 4
        dec     D_A770,x                ; de 70 a7 - Decrement timer
        
skip_timer_dec:
        lda     D_A76B,x                ; bd 6b a7 - Get sprite data index
        sta     INPPTR                  ; 85 43    - Store in temp
        dec     INPPTR                  ; c6 43    - Decrement (height-1)
        lda     D_ACBD,y                ; b9 bd ac - Get character data
        sta     DATPTR+1                ; 85 42    - Store char data
        
        ; Calculate screen position
        ldy     D_A766,x                ; bc 66 a7 - Get row position
        lda     D_AD1E,y                ; b9 1e ad - Get screen row (low)
        clc                             ; 18
        adc     D_A761,x                ; 7d 61 a7 - Add column offset
        sta     DATLIN+1                ; 85 40    - Store screen address (low)
        lda     D_AD3D,y                ; b9 3d ad - Get screen row (high)
        adc     #$00                    ; 69 00    - Add carry
        sta     DATPTR                  ; 85 41    - Store screen address (high)
        
        ; Draw sprite characters
        ldy     INPPTR                  ; a4 43    - Get height counter
        lda     DATPTR+1                ; a5 42    - Get character data
        beq     use_color_ram           ; f0 0b    - If 0, use color RAM
        cmp     #$40                    ; c9 40    - Check if >= $40
        bcs     check_collision         ; b0 1f    - Yes, check for item collision
        
draw_chars:
        sta     (DATLIN+1),y            ; 91 40    - Write character to screen
        dey                             ; 88       - Next row
        bpl     draw_chars              ; 10 fb    - Loop while Y >= 0
        bmi     next_sprite             ; 30 14    - Done, next sprite

use_color_ram:
        lda     DATLIN+1                ; a5 40    - Get screen address (low)
        sta     DATPTR+1                ; 85 42    - Use as base for color
        lda     DATPTR                  ; a5 41    - Get screen address (high)
        and     #$03                    ; 29 03    - Mask to get page offset
        clc                             ; 18
        adc     #$8b                    ; 69 8b    - Convert to color RAM ($D800)
        sta     INPPTR                  ; 85 43    - Store color RAM high byte
        
copy_color:
        lda     (DATPTR+1),y            ; b1 42    - Read from screen
        sta     (DATLIN+1),y            ; 91 40    - Write to color RAM
        dey                             ; 88       - Next row
        bpl     copy_color              ; 10 f9    - Loop while Y >= 0

next_sprite:
        dex                             ; ca       - Next sprite slot
        bpl     sprite_update_loop      ; 10 aa    - Loop while X >= 0
        rts                             ; 60       - Done

; ============================================================================
; CHECK_COLLISION ($1372)
; ============================================================================
; Checks if player sprite collides with any active items (bubbles).
; Called when sprite character data is >= $40.
;
; Calculates sprite pixel position:
;   - X position: D_A761,X * 8 + $14
;   - Y position: D_A766,X * 8 + $15
;
; Then checks all 6 bubble slots ($b4-$b9) to see if any are within
; collision distance. If collision detected, awards points and decrements
; the item counter at D_8892,X.
; ============================================================================

check_collision:
        lda     D_A761,x                ; bd 61 a7 - Get column
        asl                             ; 0a       - Multiply by 8
        asl                             ; 0a
        asl                             ; 0a
        adc     #$14                    ; 69 14    - Add offset (20 pixels)
        sta     $44                     ; 85 44    - Store sprite X position
        
        lda     D_A766,x                ; bd 66 a7 - Get row
        asl                             ; 0a       - Multiply by 8
        asl                             ; 0a
        asl                             ; 0a
        adc     #$15                    ; 69 15    - Add offset (21 pixels)
        sta     VARNAM                  ; 85 45    - Store sprite Y position
        
        ldy     D_A76B,x                ; bc 6b a7 - Get sprite data index
        lda     $0200,y                 ; b9 00 02 - Load collision threshold
        sta     OLDTXT                  ; 85 3d    - Store threshold
        stx     OLDTXT+1                ; 86 3e    - Save X register
        
        ; Check all 6 bubble slots
        ldx     #$05                    ; a2 05    - 6 bubbles (5 down to 0)
check_bubble_loop:
        lda     $b4,x                   ; b5 b4    - Get bubble state
        beq     next_bubble             ; f0 1c    - Skip if inactive
        cmp     #$0b                    ; c9 0b    - Check if >= $0B
        bcs     next_bubble             ; b0 18    - Skip if special bubble
        
        ; Check Y distance
        lda     VARNAM                  ; a5 45    - Get sprite Y
        sec                             ; 38
        sbc     $c4,x                   ; f5 c4    - Subtract bubble Y
        cmp     #$10                    ; c9 10    - Within 16 pixels?
        bne     next_bubble             ; d0 0f    - No, skip
        
        ; Check X distance
        lda     $bc,x                   ; b5 bc    - Get bubble X
        sec                             ; 38
        sbc     $44                     ; e5 44    - Subtract sprite X
        cmp     OLDTXT                  ; c5 3d    - Compare to threshold
        bcs     next_bubble             ; b0 06    - Skip if too far
        
        ; Collision detected!
        jsr     D_1A6F                  ; 20 6f 1a - Award points
        dec     D_8892,x                ; de 92 88 - Decrement item counter

next_bubble:
        dex                             ; ca       - Next bubble
        bpl     check_bubble_loop       ; 10 dd    - Loop while X >= 0
        
        ; Resume drawing sprite
        ldy     INPPTR                  ; a4 43    - Restore height counter
        lda     DATPTR+1                ; a5 42    - Restore character data
        ldx     OLDTXT+1                ; a6 3e    - Restore X register
        jmp     draw_chars              ; 4c 53 13 - Continue drawing

; ============================================================================
; ENEMY_TIMER_HANDLER ($13BE - $1577)
; ============================================================================
; Handles enemy timers, state transitions, and special behaviors.
; This is a complex section with many subsystems. Keeping as .byte for now.
; ============================================================================

        .byte   $A2,$11,$DE,$FA,$A9,$D0,$4E,$B5                 ; $13BE
        .byte   $CA,$C9,$04,$D0,$07,$9D,$42,$AA                 ; $13C6
        .byte   $A9,$3A,$D0,$34,$C9,$24,$B0,$35                 ; $13CE
        .byte   $C9,$18,$90,$69,$E9,$18,$4A,$A8                 ; $13D6
        .byte   $AD,$BF,$5A,$99,$B4,$00,$B9,$C4                 ; $13DE
        .byte   $00,$09,$01,$99,$C4,$00,$B9,$BC                 ; $13E6
        .byte   $00,$29,$FE,$99,$BC,$00,$A9,$FF                 ; $13EE
        .byte   $99,$2A,$87,$BD,$30,$AA,$99,$A2                 ; $13F6
        .byte   $87,$A9,$00,$99,$22,$85,$A9,$38                 ; $13FE
        .byte   $95,$CA,$4C,$43,$14,$C9,$42,$D0                 ; $1406
        .byte   $34,$A9,$FF,$30,$F3,$BD,$FA,$A9                 ; $140E
        .byte   $C9,$11,$B0,$29,$29,$01,$D0,$25                 ; $1416
        .byte   $B5,$CA,$C9,$04,$F0,$04,$C9,$48                 ; $141E
        .byte   $D0,$06,$49,$4C,$95,$CA,$D0,$15                 ; $1426
        .byte   $C9,$24,$B0,$11,$C9,$18,$90,$0D                 ; $142E
        .byte   $E9,$18,$4A,$A8,$B9,$55,$AB,$4D                 ; $1436
        .byte   $15,$D0,$8D,$15,$D0,$CA,$30,$03                 ; $143E
        .byte   $4C,$C0,$13,$A2,$11,$A0,$00,$B5                 ; $1446
        .byte   $CA,$C9,$34,$90,$01,$C8,$CA,$10                 ; $144E
        .byte   $F6,$98,$C0,$02,$B0,$12,$20,$5F                 ; $1456
        .byte   $14,$A2,$11,$B5,$CA,$C9,$04,$D0                 ; $145E
        .byte   $08,$9D,$42,$AA,$A9,$3A,$95,$CA                 ; $1466
        .byte   $60,$CA,$10,$EF,$60,$B5,$B2,$C9                 ; $146E
        .byte   $0E,$D0,$1D,$A9,$3A,$95,$CA,$9D                 ; $1476
        .byte   $42,$AA,$8A,$49,$01,$A8,$B9,$CA                 ; $147E
        .byte   $00,$C9,$2E,$F0,$08,$C9,$30,$F0                 ; $1486
        .byte   $04,$A9,$32,$85,$2B,$4C,$4A,$0D                 ; $148E
        .byte   $CE,$45,$15,$EE,$49,$15,$20,$2B                 ; $1496
        .byte   $15,$EE,$45,$15,$CE,$49,$15,$B0                 ; $149E
        .byte   $D2,$BD,$42,$AA,$29,$7F,$D0,$1D                 ; $14A6
        .byte   $FE,$30,$AA,$BD,$30,$AA,$29,$0F                 ; $14AE
        .byte   $D0,$03,$DE,$30,$AA,$BD,$30,$AA                 ; $14B6
        .byte   $49,$80,$9D,$30,$AA,$9D,$42,$AA                 ; $14BE
        .byte   $A9,$1E,$9D,$75,$A7,$BD,$75,$A7                 ; $14C6
        .byte   $F0,$06,$DE,$75,$A7,$4C,$4A,$0D                 ; $14CE
        .byte   $B5,$BA,$38,$E9,$14,$4A,$4A,$4A                 ; $14D6
        .byte   $85,$40,$A0,$00,$D5,$DC,$B0,$02                 ; $14DE
        .byte   $A0,$02,$98,$9D,$65,$E7,$B5,$C2                 ; $14E6
        .byte   $38,$E9,$15,$4A,$4A,$4A,$85,$41                 ; $14EE
        .byte   $DE,$42,$AA,$10,$14,$A9,$01,$B4                 ; $14F6
        .byte   $DC,$C4,$40,$90,$05,$F0,$1E,$A9                 ; $14FE
        .byte   $FF,$18,$75,$DC,$95,$DC,$4C,$4A                 ; $1506
        .byte   $0D,$A9,$01,$B4,$EE,$C4,$41,$90                 ; $150E
        .byte   $05,$F0,$0A,$A9,$FF,$18,$75,$EE                 ; $1516
        .byte   $95,$EE,$4C,$4A,$0D,$A9,$00,$9D                 ; $151E
        .byte   $42,$AA,$4C,$4A,$0D,$B5,$DC,$0A                 ; $1526
        .byte   $0A,$0A,$69,$18,$85,$40,$B5,$EE                 ; $152E
        .byte   $0A,$0A,$0A,$69,$15,$85,$41,$A0                 ; $1536
        .byte   $01,$B9,$B2,$00,$F0,$2F,$C9,$19                 ; $153E
        .byte   $F0,$04,$C9,$0D,$B0,$27,$B9,$BA                 ; $1546
        .byte   $00,$38,$E5,$40,$B0,$04,$49,$FF                 ; $154E
        .byte   $69,$01,$C9,$10,$B0,$17,$B9,$C2                 ; $1556
        .byte   $00,$38,$E5,$41,$B0,$04,$49,$FF                 ; $155E
        .byte   $69,$01,$C9,$10,$B0,$07,$A9,$0E                 ; $1566
        .byte   $99,$B2,$00,$38,$60,$88,$10,$C9                 ; $156E
        .byte   $18,$60                                         ; $1576
