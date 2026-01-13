; -----------------------------------------------------------------------------
; bb-spawn-handlers.s
; Enemy spawn handling, player collision with spawned items, score processing
; Address range: $284D - $29BA (366 bytes)
; -----------------------------------------------------------------------------

.segment "CODE"

; External references
L1E6C           := $1E6C
L2162           := $2162
L220C           := $220C
L2301           := $2301
L2C9F           := $2C9F

; -----------------------------------------------------------------------------
; SPAWN_POSITION_INIT ($284D)
; Initialize spawn position from level data
; Calculates X,Y position from $A754/$A75F tables
; -----------------------------------------------------------------------------
spawn_position_init:                                    ; $284D
        lda     $A754
        asl     a
        asl     a
        asl     a
        adc     #$14
        sta     $BA,x                   ; Set X position
        lda     $A75F
        asl     a
        asl     a
        asl     a
        adc     #$05
        sta     $C2,x                   ; Set Y position
        cmp     #$ED
        bne     @L2877
        cpx     #$02
        bcc     @L287C
        lda     #$07
        sta     $8890,x
        dec     $B2,x
        dec     $4A
        lda     #$0E
        sta     $8548,x
@L2877:                                                 ; $2877
        cpx     #$02
        bcc     @L288D
        rts

@L287C:                                                 ; $287C
        lda     #$64
        ldy     $BA,x
        cpy     #$94
        bcc     @L2886
        lda     #$B4
@L2886:                                                 ; $2886
        sta     $BA,x
@L2888:                                                 ; $2888
        lda     #$01
        sta     $B2,x
        rts

; -----------------------------------------------------------------------------
; SPAWN_UPDATE ($288D)
; Update spawn state based on animation timer
; -----------------------------------------------------------------------------
@L288D:                                                 ; $288D
        ldy     $8818,x
        bmi     @L2895
        jsr     L2301
@L2895:                                                 ; $2895
        lda     $85E8,x
        sta     $02
        jsr     L220C
        ldx     $22
        lda     $87A0,x
        bpl     @L2888
        rts

; -----------------------------------------------------------------------------
; SPAWN_ANIMATION ($28A5)
; Handle spawn animation state
; -----------------------------------------------------------------------------
spawn_animation:                                        ; $28A5
        lda     #$00
        sta     $8728,x
        lda     $86D8,x
        cmp     #$12
        beq     @L28BB
        lda     #$12
        sta     $86D8,x
        lda     #$20
        sta     $8610,x
@L28BB:                                                 ; $28BB
        dec     $8610,x
        lda     $8610,x
        bmi     @L28E9
        lsr     a
        and     #$03
        beq     @L28CE
        ldy     $8840,x
        clc
        adc     #$0B
@L28CE:                                                 ; $28CE
        sta     $8520,x
        lda     $87A0,x
        bpl     @L28DB
        lda     $87F0,x
        bmi     @L28E8
@L28DB:                                                 ; $28DB
        lda     $C2,x
        clc
        adc     #$03
        cmp     #$F5
        bcc     @L28E6
        lda     #$15
@L28E6:                                                 ; $28E6
        sta     $C2,x
@L28E8:                                                 ; $28E8
        rts

@L28E9:                                                 ; $28E9
        tay
        lsr     a
        and     #$03
        clc
        adc     #$0F
        sta     $8520,x
        cpy     #$C8
        bne     @L28E8
        inc     $B2,x
        rts

; -----------------------------------------------------------------------------
; SPAWN_STATE_CHANGE ($28FB)
; Handle spawn state transitions
; -----------------------------------------------------------------------------
spawn_state_change:                                     ; $28FB
        jsr     L2916
        ldx     $22
        lda     #$01
        sta     $B2,x
        jsr     L1E6C
        ldx     $22
        lda     #$18
        sta     $B2,x
        rts

; -----------------------------------------------------------------------------
; SPAWN_TIMER ($290D)
; Decrement spawn timer and toggle state
; -----------------------------------------------------------------------------
spawn_timer:                                            ; $290D
        dec     $8688,x
        bne     L2916
        lda     #$01
        sta     $B2,x
L2916:                                                  ; $2916
        lda     $8548,x
        eor     #$05
        sta     $8548,x
        jmp     L2162

; -----------------------------------------------------------------------------
; SCORE_DISPLAY ($2921)
; Display score from spawn pickup
; Self-modifying code: modifies addresses at $2970/$2971 and $298D/$298E
; -----------------------------------------------------------------------------
; Self-modifying operand address
smc_score_operand := score_display + 1                  ; $2922

score_display:                                          ; $2921
        .byte   $A9                     ; LDA immediate opcode
        .byte   $00                     ; $2922 - self-modified operand
        bne     @L2995
        inc     smc_score_operand       ; Self-modify: inc $2922
        ldy     $8890,x
        lda     $A790,y
        tay
        inc     $B2,x
        lda     #$C8
        sta     $87A0,x
        txa
        sta     $8520,x
        lda     #$F2
        sta     $8598,x
        lda     $A8E4,y
        and     #$07
        sta     $8548,x
        lda     #$00
        sta     $8728,x
        sta     $05
        lda     $A892,y
        jsr     L2C9F
        lda     $A783,x
        sta     @L2970+1                ; Self-modify store address low
        sta     @L298D                  ; Store low byte to $298D
        lda     $A789,x
        sta     @L2970+2                ; Self-modify store address high
        sta     @L298E                  ; Store high byte to $298E
        ldy     #$0F
        ldx     #$3D
@L296A:                                                 ; $296A
        lda     ($04),y
        jsr     @L2996
@L2970:                                                 ; $2970 - self-modified STA abs,x
        sta     $0400,x                 ; Address modified at runtime
        dex
        dex
        dex
        dey
        bpl     @L296A
        lda     $04
        clc
        adc     #$10
        sta     $04
        bcc     @L2983
        inc     $05
@L2983:                                                 ; $2983
        ldy     #$0F
        ldx     #$3E
@L2987:                                                 ; $2987
        lda     ($04),y
        jsr     @L2996
        .byte   $9D                     ; $298C - STA abs,x opcode
@L298D:                                                 ; $298D - low byte of address (self-modified)
        .byte   $00
@L298E:                                                 ; $298E - high byte of address (self-modified)
        .byte   $04
        dex
        dex
        dex
        dey
        bpl     @L2987
@L2995:                                                 ; $2995
        rts

; -----------------------------------------------------------------------------
; BIT_MIRROR ($2996)
; Mirror bits in accumulator for display purposes
; Input: A = byte to mirror
; Output: A = mirrored byte
; -----------------------------------------------------------------------------
@L2996:                                                 ; $2996
        sta     $02
        and     #$80
        beq     @L299D
        lsr     a
@L299D:                                                 ; $299D
        eor     $02
        sta     $02
        and     #$20
        beq     @L29A6
        lsr     a
@L29A6:                                                 ; $29A6
        eor     $02
        sta     $02
        and     #$08
        beq     @L29AF
        lsr     a
@L29AF:                                                 ; $29AF
        eor     $02
        sta     $02
        and     #$02
        beq     @L29B8
        lsr     a
@L29B8:                                                 ; $29B8
        eor     $02
        rts

