;===============================================================================
; Bubble Bobble - Entity Bubble Physics & Climbing Handler
; Address Range: $E9FD-$EC0B (527 bytes)
;===============================================================================
; This module handles bubble physics for trapped enemies, player climbing
; mechanics, and Y-position updates with platform collision detection.
;
; Key Functions:
; - Entity bubble movement (floating upward with wrapping)
; - Platform collision detection when climbing/descending
; - Directional velocity management
; - Animation frame updates based on movement
; - Self-modifying code for jump targets at $EB94, $EBB5/$EBB6
;===============================================================================

; Entry point at $E9FD - Main bubble entity handler
; X register holds entity index
    jsr  D_EDCD                 ; Update entity position
    lda  D_8818,x               ; Load animation frame data
    bmi  L_EA08                 ; If negative, process bubble physics
    jmp  D_ED3B                 ; Otherwise, handle normal entity

; Bubble physics handler
L_EA08:
    jsr  D_EE62                 ; Jump state handler
    lda  D_85E8,x               ; Load entity state flags
    sta  $02                    ; Store in temp (bit flags for behavior)
    lda  D_87F0,x               ; Load vertical collision flags
    bmi  L_EA18                 ; If negative, check climbing state
    jmp  D_EB3F                 ; Handle bubble ascent

; Check if entity is on platform
L_EA18:
    lda  D_87A0,x               ; Load platform collision state
    bmi  L_EA20                 ; If negative, check bubble trapped state
    jmp  D_EBD9                 ; Handle platform physics

; Check if entity is bubble-trapped
L_EA20:
    lda  D_8700,x               ; Load movement state
    beq  L_EA6B                 ; If zero, skip collision checks
    
    ; Calculate adjacent cell pointer (subtract $A0 from current cell)
    lda  INPFLG                 ; $11 - Cell pointer low
    sec
    sbc  #$A0                   ; Subtract one row (40 cols * 4 bytes)
    sta  $04                    ; Store in temp pointer
    lda  $12                    ; Cell pointer high
    sbc  #$00
    sta  $05                    ; Complete temp pointer
    
    ; Check 5 platform cells for open space (detect if trapped by platforms)
    ; This checks: cell+$02, +$2A, +$52, +$7A, +$A2 (vertical column)
    ldy  #$02                   ; Check cell offset +$02
    lda  ($04),y
    bmi  L_EA3E                 ; If solid, continue checking
    ldy  #$2A                   ; Check cell offset +$2A
    lda  ($04),y
    bmi  L_EA62                 ; If solid, set "trapped" flag
    
L_EA3E:
    ldy  #$2A                   ; Check cell offset +$2A
    lda  ($04),y
    bmi  L_EA4A                 ; If solid, continue checking
    ldy  #$52                   ; Check cell offset +$52
    lda  ($04),y
    bmi  L_EA62                 ; If solid, set "trapped" flag
    
L_EA4A:
    ldy  #$52                   ; Check cell offset +$52
    lda  ($04),y
    bmi  L_EA56                 ; If solid, continue checking
    ldy  #$7A                   ; Check cell offset +$7A
    lda  ($04),y
    bmi  L_EA62                 ; If solid, set "trapped" flag
    
L_EA56:
    ldy  #$7A                   ; Check cell offset +$7A
    lda  ($04),y
    bmi  L_EA6B                 ; If solid, skip flag setting
    ldy  #$A2                   ; Check cell offset +$A2
    lda  ($04),y
    bpl  L_EA6B                 ; If not solid, skip flag setting
    
L_EA62:
    ; Entity is trapped between platforms
    lda  $02                    ; Load state flags
    ora  #$04                   ; Set "trapped" bit
    sta  D_85E8,x               ; Store back to entity state
    sta  $02                    ; Update temp copy

; Check if entity can climb platform
L_EA6B:
    lda  ZP_C2,x                ; Load Y position
    cmp  #$1F                   ; Below screen top?
    bcc  L_EA8C                 ; Yes, skip climb check
    
    lda  INDEX2                 ; $24 - Terrain index
    beq  L_EA78                 ; If zero, check platform above
    jmp  D_EAFA                 ; Otherwise, handle standard movement

; Check platform cells above entity (3 cells at +$51, +$52, +$53)
L_EA78:
    ldy  #$51                   ; Cell offset +$51
    lda  (INPFLG),y             ; Check cell
    bmi  L_EA92                 ; If solid, can't climb
    iny                         ; Next cell (+$52)
    lda  (INPFLG),y
    bmi  L_EA92                 ; If solid, can't climb
    lda  $23                    ; Level/world index
    beq  L_EA8C                 ; If zero, allow climb
    iny                         ; Next cell (+$53)
    lda  (INPFLG),y
    bmi  L_EA92                 ; If solid, can't climb
    
L_EA8C:
    ; Entity can climb - advance vertical state
    inc  D_87F0,x               ; Increment vertical collision state
    jmp  D_EB3F                 ; Handle bubble ascent

; Entity colliding with platform above
L_EA92:
    lda  D_86D8,x               ; Load collision data
    ora  D_8700,x               ; OR with movement state
    beq  D_EAFA                 ; If both zero, use standard movement
    
    lda  ENESSION,x             ; Load entity state ($B2,x)
    cmp  #$03                   ; State 3?
    beq  D_EAFA                 ; Yes, use standard movement
    
    ; Check if entity should move down vs up
    lda  $25                    ; Player Y position / level index
    cmp  D_8750,x               ; Compare to target direction
    bcs  L_EABE                 ; If >=, move down
    
    ; Move up - check cell at +$53
    ldy  #$53                   ; Cell offset
    lda  $23                    ; Level/world index
    cmp  #$06                   ; World 6?
    bne  D_EAFA                 ; No, use standard movement
    
    ; Calculate pointer offset +$08
    lda  INPFLG                 ; $11
    adc  #$08                   ; Add 8
    sta  $04
    lda  $12
    adc  #$00
    sta  $05
    jmp  D_EAD1                 ; Check platform cell

; Move down path
L_EABE:
    ldy  #$50                   ; Cell offset +$50
    lda  $23                    ; Level/world index
    bne  D_EAFA                 ; If not zero, use standard movement
    
    ; Calculate pointer offset -$09
    lda  INPFLG                 ; $11
    sec
    sbc  #$09                   ; Subtract 9
    sta  $04
    lda  $12
    sbc  #$00
    sta  $05

; Check if platform cell allows passage
D_EAD1:
    lda  (INPFLG),y             ; Check current cell
    bmi  D_EAFA                 ; If solid, use standard movement
    ldy  #$50                   ; Check offset cell
    lda  ($04),y
    bpl  D_EAFA                 ; If not solid, use standard movement
    
    ; Set directional velocity
    lda  #$00
    sta  D_8840,x               ; Clear horizontal velocity
    sta  D_8868,x               ; Clear secondary velocity
    
    lda  $25                    ; Player Y / level index
    cmp  D_8750,x               ; Compare to target
    bcc  L_EAEF                 ; If less, move left
    
    dec  D_8840,x               ; Move right (set to $FF)
    bne  L_EAF2                 ; Always taken
    
L_EAEF:
    dec  D_8868,x               ; Move left (set to $FF)
    
L_EAF2:
    lda  #$0F                   ; Platform climb state
    sta  D_87A0,x               ; Set collision state
    jmp  D_EBD9                 ; Handle platform physics

; Standard movement handler - processes state bit flags
D_EAFA:
    lsr  $02                    ; Shift state flags right
    bcc  L_EB01                 ; If bit 0 clear, skip
    jsr  D_ECDF                 ; Handle movement bit 0
    
L_EB01:
    lsr  $02                    ; Shift state flags right
    bcc  L_EB08                 ; If bit 1 clear, skip
    jsr  D_ED1E                 ; Handle movement bit 1
    
L_EB08:
    lsr  $02                    ; Shift state flags right
    bcc  L_EB0F                 ; If bit 2 clear, skip
    jmp  D_EBC4                 ; Handle movement bit 2 (reset velocities)

; Animation frame update at $EB0F
L_EB0F:
    inc  D_8610,x               ; Increment animation counter
    lda  D_8610,x
    cmp  #$02                   ; Every 2 frames?
    bcc  L_EB33                 ; No, return
    
    ; Reset counter and update animation frame
    lda  #$00
    sta  D_8610,x               ; Reset counter
    inc  D_8520,x               ; Increment animation frame
    lda  D_8520,x
    and  D_8778,x               ; Mask with animation limit
    bne  L_EB33                 ; If not zero, return
    
    ; Wrap animation frame
    lda  D_8520,x
    sec
    sbc  D_8750,x               ; Subtract frame count
    sta  D_8520,x               ; Store wrapped frame
    
L_EB33:
    rts

; Self-modifying code setup routines
; These modify jump targets at runtime

; Setup for downward movement (called from elsewhere) - D_EB34
    lda  #$2C                   ; Opcode for BIT absolute
    sta  D_EB94                 ; Modify instruction at $EB94
    lda  #$4A                   ; Low byte of target
    ldy  #$EE                   ; High byte of target
    bne  L_EB48                 ; Always taken

; Setup for bubble ascent - D_EB3F
    lda  #$4C                   ; Opcode for JMP absolute
    sta  D_EB94                 ; Modify instruction at $EB94
    
    ; D_EB44
    lda  #$0F                   ; Low byte of target
    ldy  #$EB                   ; High byte of target

; Store modified jump target address
L_EB48:
    sta  D_EBB5                 ; Store low byte at $EBB5
    sty  D_EBB6                 ; Store high byte at $EBB6
    
    ; Update Y position (bubble rises)
    lda  ZP_C2,x                ; Load Y position
    clc
    adc  #$02                   ; Move up 2 pixels
    sta  ZP_C2,x                ; Store new position
    cmp  #$F5                   ; Reached top wrap point?
    bne  L_EB5F
    
    ; Wrap to bottom of screen
    lda  #$15                   ; Bottom Y position
    sta  ZP_C2,x
    bne  L_EBB4                 ; Jump to exit (always taken)

; Check if on platform boundary
L_EB5F:
    cmp  #$1F                   ; Below screen top?
    bcc  L_EBB4                 ; Yes, exit
    sbc  #$2D                   ; Subtract platform base
    and  #$07                   ; Check if on 8-pixel boundary
    bne  L_EBB4                 ; Not on boundary, exit
    
    ; Check platform cells (3 cells at +$51, +$52, +$53)
    ldy  #$51
    lda  (INPFLG),y
    bmi  L_EBB4                 ; Solid platform, exit
    iny
    lda  (INPFLG),y
    bmi  L_EBB4                 ; Solid platform, exit
    lda  $23                    ; Level index
    beq  L_EB7D                 ; If zero, check next set
    iny
    lda  (INPFLG),y
    bmi  L_EBB4                 ; Solid platform, exit

; Check second platform row (cells at +$79, +$7A, +$7B)
L_EB7D:
    ldy  #$79
    lda  (INPFLG),y
    bmi  L_EB91                 ; Solid platform, decrease state
    iny
    lda  (INPFLG),y
    bmi  L_EB91                 ; Solid platform, decrease state
    lda  $23                    ; Level index
    beq  L_EBB4                 ; If zero, exit
    iny
    lda  (INPFLG),y
    bpl  L_EBB4                 ; Not solid, exit

; Decrease vertical collision state (descending)
L_EB91:
    dec  D_87F0,x               ; Decrement vertical collision state
    
; Self-modified instruction at D_EB94 - either JMP or BIT depending on setup
    jmp  L_EB0F                 ; Modified at runtime (may become BIT)

; Horizontal position check for player interaction
    lda  D_85E8,x               ; Load entity state
    and  #$04                   ; Check "trapped" bit
    sta  $04                    ; Store in temp
    lda  FA,x                   ; Load entity X position
    ldy  OPPTR                  ; $4B - Player index pointer
    cmp  FA,y                   ; Compare with player X
    bcs  L_EBAA                 ; If entity >= player, go right
    
    lda  #$02                   ; Direction = left
    .byte $2C                   ; BIT absolute - skip next 2-byte instruction
    
L_EBAA:
    lda  #$01                   ; Direction = right
    ora  $04                    ; Combine with state flags
    sta  D_85E8,x               ; Store updated state
    jmp  D_EE4A                 ; Continue with state handler

; Self-modified jump target (3-byte instruction modified at runtime)
L_EBB4:
    .byte $4C                   ; JMP opcode - D_EBB5 points here (= * - 1)
    .byte $0F                   ; Target address low (modified) - D_EBB5
    .byte $EB                   ; Target address high (modified) - D_EBB6
    rts

; Alternative bubble physics setup - D_EBB8
    lda  #$4C                   ; JMP opcode
    sta  D_EB94                 ; Modify instruction
    lda  #$B7                   ; Target low
    ldy  #$EB                   ; Target high
    jmp  L_EB48                 ; Store target address

; Reset horizontal velocities - D_EBC4
    lda  #$00
    sta  D_8840,x               ; Clear horizontal velocity
    sta  D_8868,x               ; Clear secondary velocity
    lda  D_85E8,x               ; Load entity state
    and  #$FB                   ; Clear bit 2 (trapped flag)
    sta  D_85E8,x               ; Store back
    lda  #$1F                   ; Platform state value
    sta  D_87A0,x               ; Set collision state

; Platform climbing physics handler - D_EBD9
    beq  L_EC0C                 ; If zero, exit
    cmp  #$10                   ; State >= $10?
    bcs  L_EBFB                 ; Yes, handle fast descent
    
    ; Slow descent (state 0-15)
    dec  D_87A0,x               ; Decrement platform state
    tay                         ; Transfer to Y
    lda  D_8840,x               ; Check horizontal velocity
    ora  D_8868,x               ; OR with secondary velocity
    beq  L_EBF0                 ; If both zero, use table
    
    ; Manual descent with velocity
    dec  ZP_C2,x                ; Move down 1 pixel
    jmp  D_EC87                 ; Continue processing
    
L_EBF0:
    ; Table-driven descent
    lda  ZP_C2,x                ; Load Y position
    sec
    sbc  D_ACDD,y               ; Subtract offset from table
    sta  ZP_C2,x                ; Store new position
    jmp  L_EB0F                 ; Update animation

; Fast descent (state >= $10)
L_EBFB:
    dec  D_87A0,x               ; Decrement platform state
    and  #$03                   ; Check if multiple of 4
    bne  L_EC0B                 ; Not multiple, exit
    
    ; Toggle animation frame every 4th frame
    lda  D_8520,x               ; Load animation frame
    eor  D_8750,x               ; XOR with frame limit
    sta  D_8520,x               ; Store toggled frame
    
L_EC0B:
    rts

; $EC0C marks the end of this routine section
