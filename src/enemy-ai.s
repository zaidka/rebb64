; ============================================================================
; BUBBLE BOBBLE - ENEMY AI & MOVEMENT ($0CF2-$10D2)
; ============================================================================

; External references
L10D3           := $10D3                ; Baron Von Blubba handler
L7BFE           := $7BFE                ; Platform collision check
L7C26           := $7C26                ; Apply damage/effect
LE9EA           := $E9EA                ; Random number generator

; ============================================================================
; ENEMY_AI_UPDATE ($0CF2) - Main enemy AI loop
; Iterates through all enemies and handles their behavior
; ============================================================================

.segment "CODE"
enemy_ai_update:                                        ; $0CF2
D_0CF2 = enemy_ai_update                                ; Alias for external references
D_CF2 = enemy_ai_update                                 ; Alias (alternate name)
        ldx     #$11                    ; Start with entity 17
L0CF4:                                                  ; $0CF4
        lda     $CA,x                   ; Get entity type
        cmp     #$24                    ; Is it a special type?
        bcs     L0D4E                   ; Yes, handle special
        lda     $A9B2,x                 ; Get AI state
        beq     L0D02                   ; If zero, check for player collision
        jmp     L0F48                   ; Otherwise handle movement

; -----------------------------------------------------------------------------
; Check for player collision ($0D02)
; -----------------------------------------------------------------------------
L0D02:                                                  ; $0D02
        ldy     #$01                    ; Check player 2 first
L0D04:                                                  ; $0D04
        lda     $B2,y                   ; Get player state
        beq     L0D45                   ; Skip if inactive
        cmp     #$0E
        beq     L0D45                   ; Skip if dying
        cmp     #$0F
        beq     L0D45                   ; Skip if dead
        lda     $BA,y                   ; Get player X
        clc
        adc     #$02
        sec
        sbc     $AA0C,x                 ; Subtract enemy X
        bcs     L0D21
        eor     #$FF                    ; Absolute value
        adc     #$01
L0D21:                                                  ; $0D21
        cmp     #$10                    ; Within 16 pixels?
        bcs     L0D45                   ; No, skip
        lda     $C2,y                   ; Get player Y
        sec
        sbc     $AA1E,x                 ; Subtract enemy Y
        bcs     L0D32
        eor     #$FF                    ; Absolute value
        adc     #$01
L0D32:                                                  ; $0D32
        cmp     #$10                    ; Within 16 pixels?
        bcs     L0D45                   ; No, skip
        tya
        sta     $0193,x                 ; Store player index
        lda     $CA,x
        sta     $AA42,x                 ; Store entity type
        lda     #$34                    ; Set captured state
        sta     $CA,x
        bne     L0D4A
L0D45:                                                  ; $0D45
        dey
        bpl     L0D04                   ; Check next player
        bmi     L0D86                   ; No collision, do AI
L0D4A:                                                  ; $0D4A
L_0D4A = L0D4A                                          ; Alias for external references
        dex
        bpl     L0CF4                   ; Next entity
        rts

; -----------------------------------------------------------------------------
; Handle special entity types ($0D4E)
; -----------------------------------------------------------------------------
L0D4E:                                                  ; $0D4E
        cmp     #$34
        bcs     L0D78
        sbc     #$23                    ; Convert to table index
        tay
        lda     $67                     ; Check game state
        bne     L0D4A
        lda     jump_table_lo,y         ; Get jump address low
        sta     L0D66
        lda     jump_table_hi,y         ; Get jump address high
        sta     L0D67
        .byte   $4C                     ; JMP opcode
L0D66:                                                  ; $0D66 - self-modified address
        .byte   $00
L0D67:                                                  ; $0D67
        .byte   $04

; Jump table for entity types $24-$33
; Interleaved low/high bytes: lo0,hi0,lo1,hi1,...
jump_table_lo := *                                      ; $0D68
jump_table_hi := * + 1                                  ; $0D69
        .byte   $B7,$11                 ; $24: $11B7
        .byte   $D6,$10                 ; $25: $10D6
        .byte   $14,$7C                 ; $26: $7C14
        .byte   $74,$12                 ; $27: $1274
        .byte   $B4,$12                 ; $28: $12B4
        .byte   $73,$14                 ; $29: $1473
        .byte   $73,$14                 ; $2A: $1473
        .byte   $F9,$12                 ; $2B: $12F9

L0D78:                                                  ; $0D78
        cmp     #$44                    ; Baron Von Blubba?
        bne     L0D7F
        jmp     L10D3                   ; Handle Baron

L0D7F:                                                  ; $0D7F
        cmp     #$4C
L0D81:                                                  ; $0D81
        bne     L0D4A
        jmp     L0EC5

; -----------------------------------------------------------------------------
; Enemy AI behavior ($0D86)
; Called when no player collision detected
; -----------------------------------------------------------------------------
L0D86:                                                  ; $0D86
        jsr     LE9EA                   ; Get random number
        cmp     #$EA
        bcs     L0E00                   ; High value, use position-based AI
        ldy     #$11
        stx     $3C                     ; Save current entity index
L0D91:                                                  ; $0D91
        cpy     $3C
        beq     L0DFD                   ; Skip self
        lda     $A9B2,y
        bne     L0DFD                   ; Skip if entity has AI state
        lda     $CA,y
        cmp     #$24
        bcs     L0DFD                   ; Skip special types
        lda     $AA0C,x                 ; Get X position
        sec
        sbc     $AA0C,y
        bcs     L0DAE
        eor     #$FF
        adc     #$01
L0DAE:                                                  ; $0DAE
        cmp     #$10                    ; Within 16 pixels?
        bcs     L0DFD
        lda     $AA1E,x                 ; Get Y position
        sec
        sbc     $AA1E,y
        bcs     L0DBF
        eor     #$FF
        adc     #$01
L0DBF:                                                  ; $0DBF
        cmp     #$10
        bcs     L0DFD
        jsr     LE9EA                   ; Random direction
        cmp     #$1E
        bcs     L0DE4
        lda     $EE,x                   ; Get row position
        cmp     #$04
        bcs     L0DD4
        lda     #$02                    ; Move down
        bne     L0E23
L0DD4:                                                  ; $0DD4
        cmp     #$1C
        bcc     L0DDC
        lda     #$00                    ; Move up
        beq     L0E23
L0DDC:                                                  ; $0DDC
        jsr     LE9EA
        and     #$02
        jmp     L0E23

L0DE4:                                                  ; $0DE4
        lda     $DC,x                   ; Get column position
        cmp     #$02
        bcs     L0DEE
        lda     #$01                    ; Move right
        bne     L0E23
L0DEE:                                                  ; $0DEE
        cmp     #$1C
        bcc     L0DF6
        lda     #$03                    ; Move left
        bne     L0E23
L0DF6:                                                  ; $0DF6
        jsr     LE9EA
        ora     #$01
        bne     L0E23
L0DFD:                                                  ; $0DFD
        dey
        bpl     L0D91

; -----------------------------------------------------------------------------
; Position-based AI ($0E00)
; Use level layout to determine movement
; -----------------------------------------------------------------------------
L0E00:                                                  ; $0E00
        ldy     $EE,x
        cpy     #$04
        bcs     L0E08
        ldy     #$04
L0E08:                                                  ; $0E08
        cpy     #$1D
        bcc     L0E0E
        ldy     #$1C
L0E0E:                                                  ; $0E0E
        lda     $AD1E,y
        clc
        adc     $DC,x
        sta     $40
        lda     $AD3D,y
        and     #$03
        adc     #$85
        sta     $41
        ldy     #$29
        lda     ($40),y                 ; Read level data

; -----------------------------------------------------------------------------
; Apply movement direction ($0E23)
; A = direction (0=up, 1=right, 2=down, 3=left)
; -----------------------------------------------------------------------------
L0E23:                                                  ; $0E23
        and     #$03
        bne     L0E52
        ; Direction 0: Move up
        dec     $A9D6,x
        dec     $A9D6,x
        dec     $AA1E,x
        dec     $AA1E,x
        lda     $A9D6,x
        and     #$07
        sta     $A9D6,x
        bne     L0E4F
        dec     $EE,x
        bpl     L0E4F
        lda     #$1A
        sta     $EE,x
        lda     $CA,x
        cmp     #$18
        bcs     L0E4F
        lda     #$38
        sta     $CA,x
L0E4F:                                                  ; $0E4F
        jmp     L0D4A

L0E52:                                                  ; $0E52
        cmp     #$01
        bne     L0E71
        ; Direction 1: Move right
        lda     $AA0C,x
        adc     #$01
        sta     $AA0C,x
        inc     $A9C4,x
        lda     $A9C4,x
        cmp     #$04
        bne     L0EC2
        lda     #$00
        sta     $A9C4,x
        inc     $DC,x
        bne     L0EC2

L0E71:                                                  ; $0E71
        cmp     #$02
        bne     L0EAD
        ; Direction 2: Move down
        inc     $A9D6,x
        inc     $A9D6,x
        inc     $AA1E,x
        inc     $AA1E,x
        lda     $A9D6,x
        cmp     #$08
        bne     L0E90
        lda     #$00
        sta     $A9D6,x
        jmp     L0D4A

L0E90:                                                  ; $0E90
        cmp     #$02
        bne     L0EC2
        inc     $EE,x
        lda     $EE,x
        cmp     #$1D
        bne     L0EC2
        lda     #$00
        sta     $EE,x
        lda     $CA,x
        cmp     #$18
        bcs     L0E4F
        lda     #$38
        sta     $CA,x
        jmp     L0D4A

L0EAD:                                                  ; $0EAD
        ; Direction 3: Move left
        lda     $AA0C,x
        sec
        sbc     #$02
        sta     $AA0C,x
        dec     $A9C4,x
        bpl     L0EC2
        lda     #$03
        sta     $A9C4,x
        dec     $DC,x
L0EC2:                                                  ; $0EC2
        jmp     L0D4A

; -----------------------------------------------------------------------------
; Special enemy behavior ($0EC5)
; Handles type $4C enemies
; -----------------------------------------------------------------------------
L0EC5:                                                  ; $0EC5
        lda     #$00
        ldy     $A9D6,x
        bne     L0EFA
        lda     $EE,x
        asl     a
        tay
        lda     $AC01,y
        adc     $DC,x
        sta     $40
        lda     $AC02,y
        adc     #$85
        sta     $41
        ldy     #$78
        lda     ($40),y
        bmi     L0EFD
        iny
        lda     ($40),y
        bmi     L0EFD
        inc     $EE,x
        lda     #$04
        ldy     $EE,x
        cpy     #$1D
        bne     L0EFA
L0EF3:                                                  ; $0EF3
        lda     #$38
        sta     $CA,x
        jmp     L0D4A

L0EFA:                                                  ; $0EFA
        sta     $A9D6,x
L0EFD:                                                  ; $0EFD
        lda     $DC,x
        asl     a
        asl     a
        asl     a
        adc     #$14
        sta     $40
        lda     $EE,x
        asl     a
        asl     a
        asl     a
        adc     #$15
        sta     $41
        ldy     #$01
L0F11:                                                  ; $0F11
        lda     $B2,y
        beq     L0F42
        lda     $BA,y
        sec
        sbc     $40
        bcs     L0F22
        eor     #$FF
        adc     #$01
L0F22:                                                  ; $0F22
        cmp     #$10
        bcs     L0F42
        lda     $C2,y
        sec
        sbc     $41
        bcs     L0F32
        eor     #$FF
        adc     #$01
L0F32:                                                  ; $0F32
        cmp     #$10
        bcs     L0F42
        lda     $AB51,y
        tay
        lda     #$70
        jsr     L7C26                   ; Apply effect
        jmp     L0EF3

L0F42:                                                  ; $0F42
        dey
        bpl     L0F11
        jmp     L0D4A

; -----------------------------------------------------------------------------
; Enemy movement handler ($0F48)
; Called when enemy has AI state set
; -----------------------------------------------------------------------------
L0F48:                                                  ; $0F48
        jsr     L0F61
        lda     $CA,x
        cmp     #$0C
        bcs     L0F5E
        lda     $AA42,x
        bpl     L0F5E
        lda     $A9B2,x
        beq     L0F5E
        jsr     L0F61
L0F5E:                                                  ; $0F5E
        jmp     L0D4A

L0F61:                                                  ; $0F61
        dec     $A9B2,x
        and     #$7F
        tay
        lda     $AA30,x
        bpl     L0F73
        tya
        lsr     a
        tay
        bne     L0F73
        ldy     #$01
L0F73:                                                  ; $0F73
D_0F73 = L0F73                                          ; Alias for external references
        jmp     L0F91

; Unreachable code / alternate entry point
        lda     $A9FA,x
        cmp     #$0A
        bcs     L0F91
        inc     $A9FA,x
        lda     $ACB6,y
        sta     $CA,x
        cmp     #$04
        bne     L0F8D
        lda     #$0A
        sta     $CA,x
L0F8D:                                                  ; $0F8D
        lda     #$0A
        bne     L0F98
L0F91:                                                  ; $0F91
        lda     $ACB6,y
        sta     $CA,x
        lda     #$04
L0F98:                                                  ; $0F98
        sta     $38
        lda     $DC,x
        sta     $39
        lda     $AA0C,x
        sta     $3A
        lda     $0193,x
        bpl     L0FD1
        ; Negative player index - move left
        dec     $DC,x
        lda     $AA0C,x
        sec
        sbc     #$08
        sta     $AA0C,x
        jsr     L105B                   ; Check bubble collision
        lda     $CA,x
        cmp     #$06
        bcs     L100A
        jsr     L7BFE                   ; Check platform
        beq     L0FC7
        ldy     #$00
        lda     ($40),y
        bmi     L100B
L0FC7:                                                  ; $0FC7
        ldy     #$29
        lda     ($40),y
        bmi     L100B
        ldy     #$50
        bne     L0FFE

L0FD1:                                                  ; $0FD1
        ; Positive player index - move right
        lda     $DC,x
        cmp     #$1C
        beq     L100B
        inc     $DC,x
        lda     $AA0C,x
        clc
        adc     #$08
        sta     $AA0C,x
        jsr     L105B                   ; Check bubble collision
        lda     $CA,x
        cmp     #$06
        bcs     L100A
        jsr     L7BFE                   ; Check platform
        beq     L0FF6
        ldy     #$01
        lda     ($40),y
        bmi     L100B
L0FF6:                                                  ; $0FF6
        ldy     #$28
        lda     ($40),y
        bmi     L100B
        ldy     #$51
L0FFE:                                                  ; $0FFE
        lda     ($40),y
        bmi     L100B
        lda     $A9B2,x
        and     #$7F
        sta     $A9B2,x
L100A:                                                  ; $100A
        rts

L100B:                                                  ; $100B
        ; Collision detected - reset position
        lda     $3A
        sec
        sbc     #$14
        and     #$F8
        adc     #$13
        sta     $AA0C,x
        lda     $39
        sta     $DC,x
        lda     $38
        ldy     $A9B2,x
        bpl     L1050
        ldy     #$00
        lda     $BB
        sec
        sbc     $AA0C,x
        bcs     L1030
        eor     #$FF
        adc     #$01
L1030:                                                  ; $1030
        cmp     #$10
        bcs     L1045
        lda     $C3
        sec
        sbc     $AA1E,x
        bcs     L1040
        eor     #$FF
        adc     #$01
L1040:                                                  ; $1040
        cmp     #$10
        bcs     L1045
        iny
L1045:                                                  ; $1045
        tya
        sta     $0193,x
        lda     $38
        sta     $AA42,x
        lda     #$34
L1050:                                                  ; $1050
        sta     $CA,x
        lda     #$00
        sta     $A9C4,x
        sta     $A9B2,x
        rts

; -----------------------------------------------------------------------------
; Check bubble collision ($105B)
; Checks if enemy collides with any bubbles
; -----------------------------------------------------------------------------
L105B:                                                  ; $105B
D_105B = L105B                                          ; Alias for external references
        ldy     #$05
L105D:                                                  ; $105D
        lda     $B4,y                   ; Get bubble state
        beq     L108C                   ; Skip if empty
        cmp     #$16
        bcs     L106A
        cmp     #$0B
        bcs     L108C
L106A:                                                  ; $106A
        lda     $BC,y                   ; Bubble X
        sec
        sbc     $AA0C,x                 ; Enemy X
        bcs     L1077
        eor     #$FF
        adc     #$01
L1077:                                                  ; $1077
        cmp     #$10
        bcs     L108C
        lda     $C4,y                   ; Bubble Y
        sec
        sbc     $AA1E,x                 ; Enemy Y
        bcs     L1088
        eor     #$FF
        adc     #$01
L1088:                                                  ; $1088
        cmp     #$10
        bcc     L1090                   ; Collision!
L108C:                                                  ; $108C
        dey
        bpl     L105D
        rts

; -----------------------------------------------------------------------------
; Handle bubble capture ($1090)
; Enemy captured by bubble
; -----------------------------------------------------------------------------
L1090:                                                  ; $1090
        tya
        asl     a
        adc     #$18
        sta     $CA,x                   ; Set captured state
        lda     $B4,y
        cmp     #$0A
        beq     L10A1
        cmp     #$16
        bcc     L10B1
L10A1:                                                  ; $10A1
        lda     $87A2,y
        pha
        lda     #$FF
        sta     $87A2,y
        sta     $87CA,y
        sta     $87F2,y
        pla
L10B1:                                                  ; $10B1
        sta     $AA30,x
        pha
        lda     #$00
        sta     $B4,y                   ; Clear bubble
        sta     $863A,y
        sta     $A9B2,x
        lda     #$FF
        sta     $85C2,y
        lda     #$A0
        sta     $A9FA,x
        pla
        tay
        lda     $AB81,y
        sta     $AA42,x
        rts

