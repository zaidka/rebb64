;===============================================================================
; Bubble Bobble - Entity AI & Attack Logic
; Address Range: $EDC7-$EFBB (501 bytes)
;===============================================================================
; This module handles entity artificial intelligence including attack decisions,
; Y-axis movement (jumping/gravity), and player tracking logic.
;
; Key Functions:
; - Attack decision logic (when entities shoot projectiles at player)
; - Entity position update routine (D_EDCD)
; - Animation toggle (simple frame flip)
; - Player Y-position comparison for AI behavior
; - Horizontal movement with platform collision
; - Vertical movement (jumping/falling with screen wrapping)
;===============================================================================

; L_EDC7: Continuation from projectile spawn - jumped here when spawn aborted
L_EDC7:
    ldy  $02                    ; Restore Y register
    lda  #$FF                   ; Set value to $FF
    bmi  L_EDC3                 ; Always taken - jump back to projectile setup

; D_EDCD: Update entity position - main entity update routine
; Called from multiple places to update entity state
; X register holds entity index
D_EDCD:
    lda  D_8818,x               ; Load animation frame data
    bpl  L_EE49                 ; If positive, skip attack logic
    
    ; Check attack timer
    lda  D_8890,x               ; Load attack cooldown timer
    beq  L_EDDC                 ; If zero, check if can attack
    dec  D_8890,x               ; Decrement cooldown
    bne  L_EE49                 ; If not zero yet, skip attack logic
    
; Check if entity can attack player
L_EDDC:
    lda  D_87A0,x               ; Load collision state
    bpl  L_EE49                 ; If positive, can't attack
    lda  D_87F0,x               ; Load vertical collision flags
    bpl  L_EE49                 ; If positive, can't attack
    
    ; Use RNG to add randomness to attack (25% chance)
    jsr  D_E9EA                 ; Get random number
    and  #$03                   ; Keep only bits 0-1 (0-3 range)
    bne  L_EE49                 ; If not zero (75% chance), skip attack
    
    ; Compare entity X position with player X position
    ldy  OPPTR                  ; $4B - Player index pointer
    lda  FA,x                   ; Load entity X position
    sbc  a:FA,y                 ; Subtract player X position (carry already clear from AND)
    bcs  L_EE07                 ; If entity >= player, check right side
    
    ; Entity is to the left of player
    lda  D_8520,x               ; Load animation frame
    cmp  D_8750,x               ; Compare with frame limit
    bcs  L_EE49                 ; If frame >= limit, facing wrong way
    
    ; Check if entity at right edge
    lda  FA,x                   ; Load X position
    cmp  #$F4                   ; At right edge?
    bcs  L_EE49                 ; If yes, can't attack
    sec                         ; Set carry for next check
    bcs  L_EE15                 ; Always taken - check Y position
    
; Entity is to the right of player
L_EE07:
    lda  D_8520,x               ; Load animation frame
    cmp  D_8750,x               ; Compare with frame limit
    bcc  L_EE49                 ; If frame < limit, facing wrong way
    
    ; Check if entity at left edge
    lda  FA,x                   ; Load X position
    cmp  #$34                   ; At left boundary?
    bcc  L_EE49                 ; If yes, can't attack
    
; Check Y position - entity must be at or above player
L_EE15:
    lda  ZP_C2,x                ; Load entity Y position
    sbc  a:ZP_C2,y              ; Subtract player Y position
    bcc  L_EE49                 ; If entity below player, can't attack
    beq  L_EE25                 ; If equal Y, skip RNG check
    
    ; Add more randomness if Y positions differ (3.125% chance)
    jsr  D_E9EA                 ; Get random number
    and  #$1F                   ; Keep bits 0-4 (0-31 range)
    bne  L_EE49                 ; If not zero, skip attack
    
; Find free projectile slot
L_EE25:
    ldy  #$0F                   ; Start at slot 15 (check slots 15-0)
    
L_EE27:
    lda  a:BLNON,y              ; Check projectile slot
    bmi  L_EE31                 ; If negative (free), use this slot
    dey                         ; Try previous slot
    bpl  L_EE27                 ; Loop if more slots to check
    bmi  L_EE49                 ; No free slots, exit
    
; Create attack projectile
L_EE31:
    lda  #$42                   ; Projectile type $42
    sta  a:BLNON,y              ; Store in projectile slot
    tya                         ; Transfer slot index to A
    sta  D_87A0,x               ; Store in entity collision state
    lda  #$07                   ; Attack animation frame count
    sta  D_8818,x               ; Store in animation data
    lda  #$96                   ; Cooldown timer (150 frames)
    sta  D_8890,x               ; Store in attack timer
    lda  #$09                   ; Projectile state value
    sta  D_A9FC,y               ; Store in projectile state array
    
; L_EE49: Exit point for attack logic
L_EE49:
    rts

; D_EE4A: State handler - simple animation toggle
; Flips animation frame between 0 and 1 every 2 calls
D_EE4A:
    inc  D_8610,x               ; Increment animation counter
    lda  D_8610,x               ; Load counter
    cmp  #$02                   ; Reached 2?
    bcc  L_EE61                 ; If not, return
    
    ; Reset counter and toggle frame
    lda  #$00
    sta  D_8610,x               ; Reset counter to 0
    lda  D_8520,x               ; Load current frame
    eor  #$01                   ; Toggle bit 0 (0<->1)
    sta  D_8520,x               ; Store new frame
    
L_EE61:
    rts

; D_EE62: Jump handler - player Y-position comparison for AI
; Compares player Y with entity Y and sets entity state flags
D_EE62:
    ldy  OPPTR                  ; $4B - Player index pointer
    lda  a:ZP_C2,y              ; Load player Y position
    cmp  ZP_C2,x                ; Compare with entity Y
    beq  L_EE7E                 ; If equal, set state 1
    bcc  L_EE91                 ; If player below entity, set state 2
    
    ; Player above entity - clear state flags
    lda  #$00
    sta  D_86D8,x               ; Clear collision data
    sta  D_8700,x               ; Clear movement state
    lda  D_85E8,x               ; Load entity state flags
    and  #$0B                   ; Keep only bits 0, 1, 3 (clear bits 2, 4-7)
    sta  D_85E8,x               ; Store updated flags
    rts
    
; Player at same Y as entity
L_EE7E:
    lda  #$FF                   ; Set flag to $FF
    sta  D_86D8,x               ; Set collision data
    lda  #$00
    sta  D_8700,x               ; Clear movement state
    lda  D_85E8,x               ; Load entity state flags
    and  #$0B                   ; Keep only bits 0, 1, 3
    sta  D_85E8,x               ; Store updated flags
    
L_EE90:
    rts

; Player below entity - manage directional flags
L_EE91:
    dec  D_8660,x               ; Decrement direction timer
    bne  L_EE90                 ; If not zero, return
    
    ; Timer expired - toggle direction
    ldy  D_86B0,x               ; Load current direction index
    lda  #$FF
    sta  D_86D8,y               ; Set collision flag for current direction
    
    ; XOR with $28 to toggle between two direction states
    tya                         ; Transfer direction to A
    eor  #$28                   ; Toggle direction (0<->$28)
    tay                         ; Store back in Y
    
    lda  #$00
    sta  D_86D8,y               ; Clear collision flag for new direction
    
    ; Store new direction and reset timer
    tya
    sta  D_86B0,x               ; Store new direction index
    lda  D_8688,x               ; Load direction change interval
    sta  D_8660,x               ; Reset direction timer
    rts

; Unused entry point - sets $04 to $02 then continues
    lda  #$02                   ; Set value to 2
    
; Entity movement handler - D_EEB4
; Processes horizontal movement based on state flags
    sta  $04                    ; Store movement value in temp
    lda  D_85E8,x               ; Load entity state flags
    sta  $02                    ; Store in temp
    and  #$04                   ; Check bit 2 (trapped flag)
    beq  L_EEC5                 ; If clear, use normal movement
    
    ; Trapped between platforms - use inverted movement
    jsr  D_EF4C                 ; Handle inverted vertical movement
    jmp  D_EEC8                 ; Continue to position update
    
L_EEC5:
    jsr  D_EFA0                 ; Handle normal vertical movement
    
; D_EEC8: Position update after movement
D_EEC8:
    jsr  D_E9B8                 ; Convert entity position to screen coordinates
    
    ldy  #$BD                   ; Default value
    lda  $02                    ; Load state flags
    and  #$01                   ; Check bit 0 (direction flag)
    beq  L_EED9                 ; If clear, move right
    
    ; Move left
    jsr  D_EEDF                 ; Handle leftward movement
    jmp  L_EB0F                 ; Update animation
    
L_EED9:
    jsr  D_EF1E                 ; Handle rightward movement
    jmp  L_EB0F                 ; Update animation

; D_EEDF: Leftward movement handler
D_EEDF:
    lda  ZP_25                  ; Load player Y / level index
    cmp  #$04                   ; Compare with threshold
    bcs  D_EEEB                 ; If >= 4, check platforms
    
    ; Below threshold - force frame 4
    lda  #$04
    sta  D_8520,x               ; Set animation frame to 4
    rts
    
; Check platform cells for leftward movement - D_EEEB
    sty  D_EF15                 ; Store Y (self-modifying: changes RTS below to different opcode)
    lda  ZP_23                  ; Load level index
    bne  L_EF08                 ; If non-zero, move without checks
    
    ; Check cells to the left
    ldy  #$00                   ; Cell offset 0
    lda  (INPFLG),y             ; Check cell
    bmi  L_EF0D                 ; If solid, reverse direction
    
    ldy  #$28                   ; Cell offset $28
    lda  (INPFLG),y             ; Check cell
    bmi  L_EF0D                 ; If solid, reverse direction
    
    ldy  INDEX2                 ; Check terrain index
    beq  L_EF08                 ; If zero, move left
    
    ldy  #$50                   ; Cell offset $50
    lda  (INPFLG),y             ; Check cell
    bmi  L_EF0D                 ; If solid, reverse direction
    
; Move left 2 pixels
L_EF08:
    dec  FA,x                   ; Decrement X position
    dec  FA,x                   ; Decrement X position again
    rts
    
; Hit wall - reverse horizontal direction
L_EF0D:
    lda  D_85E8,x               ; Load entity state flags
    eor  #$03                   ; Toggle bits 0 and 1
    sta  D_85E8,x               ; Store updated flags
    
    ; D_EF15 - Self-modified by STY above
    rts

    ; Unused/corrupted code (3 bytes) - appears to be dead code
    ; Note: D_4985 is defined in bb-loader.s, this JSR is likely unreachable
    jsr  D_4985                 ; May be data or dead code
    .byte $04, $9D              ; Illegal NOP instruction
    jsr  D_6085                 ; Continues but likely dead code

; D_EF1E: Rightward movement handler
D_EF1E:
    lda  ZP_25                  ; Load player Y / level index
    cmp  #$04                   ; Compare with threshold
    bcc  L_EF2A                 ; If < 4, check platforms
    
    ; At or above threshold - force frame 0
    lda  #$00
    sta  D_8520,x               ; Set animation frame to 0
    rts
    
; Check platform cells for rightward movement
L_EF2A:
    sty  D_EF15                 ; Store Y (self-modifying: changes RTS)
    lda  ZP_23                  ; Load level index
    bne  L_EF47                 ; If non-zero, move without checks
    
    ; Check cells to the right
    ldy  #$03                   ; Cell offset 3
    lda  (INPFLG),y             ; Check cell
    bmi  L_EF0D                 ; If solid, reverse direction (reuse code)
    
    ldy  #$2B                   ; Cell offset $2B
    lda  (INPFLG),y             ; Check cell
    ; D_EF3B
    bmi  L_EF0D                 ; If solid, reverse direction
    
    ldy  INDEX2                 ; Check terrain index
    beq  L_EF47                 ; If zero, move right
    
    ldy  #$53                   ; Cell offset $53
    lda  (INPFLG),y             ; Check cell
    bmi  L_EF0D                 ; If solid, reverse direction
    
; Move right 2 pixels
L_EF47:
    inc  FA,x                   ; Increment X position
    inc  FA,x                   ; Increment X position again
    rts

; D_EF4C: Inverted vertical movement
; Used when entity trapped between platforms (bit 2 of state set)
D_EF4C:
    lda  $04                    ; Load movement value
    eor  #$FF                   ; Invert all bits
    sta  $04                    ; Store inverted value
    inc  $04                    ; Add 1 (two's complement negation)
    
    lda  INDEX2                 ; Check terrain index
    bne  L_EF98                 ; If non-zero, skip special checks
    
    ; Check for screen wrap at top
    lda  ZP_C2,x                ; Load Y position
    cmp  #$15                   ; At top boundary?
    bne  L_EF70                 ; If not, check platforms above
    
    ; At top - check if can wrap to bottom
    lda  FA,x                   ; Load X position
    sbc  #$13                   ; Subtract offset (carry clear from CMP)
    lsr                         ; Divide by 8
    lsr
    lsr
    tay                         ; Use as index
    lda  D_88C1,y               ; Check wrap permission table
    bmi  L_EF8F                 ; If negative, can't wrap - reverse
    
    ; Wrap to bottom
    lda  #$F5                   ; Bottom Y position
    sta  ZP_C2,x                ; Store new Y
    rts
    
; Check platforms above current position
L_EF70:
    lda  INPFLG                 ; Load cell pointer low
    sec
    sbc  #$28                   ; Subtract one row (40 bytes)
    sta  INPFLG                 ; Store back
    bcs  L_EF7B                 ; If no borrow, continue
    dec  TANSGN                 ; Decrement high byte
    
L_EF7B:
    ldy  #$01                   ; Cell offset 1
    
L_EF7D:
    lda  (INPFLG),y             ; Check cell above
    bmi  L_EF8F                 ; If solid, reverse direction
    iny                         ; Next cell
    lda  (INPFLG),y             ; Check next cell
    bmi  L_EF8F                 ; If solid, reverse direction
    lda  ZP_23                  ; Check level index
    beq  L_EF98                 ; If zero, continue movement
    iny                         ; Third cell
    lda  (INPFLG),y             ; Check third cell
    bpl  L_EF98                 ; If not solid, continue movement
    
; Hit ceiling or can't wrap - reverse vertical direction
L_EF8F:
    lda  D_85E8,x               ; Load entity state flags
    eor  #$0C                   ; Toggle bits 2 and 3
    sta  D_85E8,x               ; Store updated flags
    rts
    
; Apply vertical movement
L_EF98:
    lda  ZP_C2,x                ; Load Y position
    clc
    adc  $04                    ; Add movement offset
    sta  ZP_C2,x                ; Store new Y position
    rts

; Normal vertical movement handler - D_EFA0
; Used when entity not trapped
    lda  INDEX2                 ; Check terrain index
    bne  L_EF98                 ; If non-zero, apply movement directly
    
    ; Check for screen wrap at bottom
    lda  ZP_C2,x                ; Load Y position
    cmp  #$F5                   ; At bottom boundary?
    bcc  L_EFBC                 ; If not, check platforms below
    
    ; At bottom - check if can wrap to top
    lda  FA,x                   ; Load X position
    sbc  #$14                   ; Subtract offset (carry clear from CMP)
    lsr                         ; Divide by 8
    lsr
    lsr
    tay                         ; Use as index
    lda  D_8501,y               ; Check wrap permission table
    bmi  L_EF8F                 ; If negative, can't wrap - reverse
    
    ; Wrap to top
    lda  #$15                   ; Top Y position
    sta  ZP_C2,x                ; Store new Y
    rts

; End of entity AI section ($EFBC starts next section)
