;===============================================================================
; Bubble Bobble - Entity Movement & Direction Handler
; Address Range: $EC0C-$EDC6 (443 bytes)
;===============================================================================
; This module handles entity movement including platform climbing continuation,
; horizontal movement with wall collision, directional changes, and spawning
; new entities/projectiles.
;
; Key Functions:
; - Platform climbing continuation (from D_EBD9)
; - Horizontal movement with wall detection
; - Entity direction changes based on platform cells
; - Spawn new entities/projectiles when conditions met
;===============================================================================

; Continuation from platform climbing handler (jumped to from D_EBD9 via beq)
; This handles the climbing state counter and Y position updates
; Entry at L_EC0C
    ldy  D_87C8,x               ; Load secondary collision state
    bpl  L_EC17                 ; If positive, use as-is
    lda  #$00                   ; Reset to zero if negative
    sta  D_87C8,x
    tay                         ; Transfer to Y
    
L_EC17:
    cpy  #$10                   ; Check if counter reached 16
    bne  L_EC1E                 ; If not, continue movement
    jmp  D_EC7C                 ; If 16, exit climbing state

; Increment climbing counter and update Y position
L_EC1E:
    inc  D_87C8,x               ; Increment climbing state counter
    lda  D_8840,x               ; Load horizontal velocity
    ora  D_8868,x               ; OR with secondary velocity
    beq  L_EC34                 ; If both zero, use standard table
    
    ; Use alternate movement table (D_ACED) when velocity present
    lda  ZP_C2,x                ; Load Y position
    clc
    ; D_EC2C
    adc  D_ACED,y               ; Add offset from alternate table
    sta  ZP_C2,x                ; Store new Y position
    jmp  D_EC3C                 ; Continue to collision check
    
L_EC34:
    ; Use standard movement table (D_ACDD) when no velocity
    lda  ZP_C2,x                ; Load Y position
    clc
    adc  D_ACDD,y               ; Add offset from standard table
    sta  ZP_C2,x                ; Store new Y position

; Check if entity reached platform level during climb - D_EC3C
    cmp  #$1F                   ; Y position >= $1F (on-screen)?
    bcc  D_EC87                 ; If below, continue to horizontal movement
    sbc  #$15                   ; Subtract base offset
    and  #$07                   ; Check if on 8-pixel boundary
    cmp  INDEX2                 ; Compare with terrain index
    bcs  D_EC87                 ; If >=, continue to horizontal movement
    
    ; Check platform cells above (3 cells at +$51, +$52, +$53)
    ldy  #$51
    lda  (INPFLG),y             ; Check cell +$51
    bmi  D_EC87                 ; If solid, continue horizontal movement
    iny
    lda  (INPFLG),y             ; Check cell +$52
    bmi  D_EC87                 ; If solid, continue horizontal movement
    lda  ZP_23                  ; Check level index
    beq  L_EC5C                 ; If zero, check next row
    iny
    lda  (INPFLG),y             ; Check cell +$53
    bmi  D_EC87                 ; If solid, continue horizontal movement
    
; Check second row of platform cells (at +$79, +$7A, +$7B)
L_EC5C:
    ldy  #$79
    lda  (INPFLG),y             ; Check cell +$79
    bmi  L_EC70                 ; If solid, snap to platform
    iny
    lda  (INPFLG),y             ; Check cell +$7A
    bmi  L_EC70                 ; If solid, snap to platform
    lda  ZP_23                  ; Check level index
    beq  D_EC87                 ; If zero, continue horizontal movement
    iny
    lda  (INPFLG),y             ; Check cell +$7B
    bpl  D_EC87                 ; If not solid, continue horizontal movement
    
; Snap entity Y position to platform boundary
L_EC70:
    lda  ZP_C2,x                ; Load Y position
    sec
    sbc  #$2D                   ; Subtract platform base
    and  #$F8                   ; Round down to 8-pixel boundary
    clc
    adc  #$2D                   ; Add platform base back
    sta  ZP_C2,x                ; Store aligned Y position
    
; Exit climbing state - set flags to exit platform mode - D_EC7C
    lda  #$FF
    sta  D_87A0,x               ; Set primary collision flag
    sta  D_87C8,x               ; Set secondary collision flag
    jmp  L_EB0F                 ; Jump to animation update

; Horizontal movement handler - processes left/right velocity - D_EC87
    lda  D_8840,x               ; Load horizontal velocity
    bpl  L_ECB0                 ; If positive/zero, check right movement
    
    ; Moving left (negative velocity)
    ldy  #$28                   ; Default cell offset
    lda  INDEX2                 ; Check terrain index
    beq  L_EC94                 ; If zero, use default
    ldy  #$50                   ; Alternate cell offset
    
L_EC94:
    lda  ZP_23                  ; Check level index
    bne  L_ECA9                 ; If non-zero, move left unconditionally
    
    ; Check if wall to the left
    lda  (INPFLG),y             ; Check left cell
    bpl  L_ECA9                 ; If not solid, move left
    iny                         ; Check adjacent cell
    lda  (INPFLG),y
    bmi  L_ECA9                 ; If solid, reverse direction
    
    ; Hit wall - reverse horizontal velocity
    lda  #$01
    sta  D_8840,x               ; Change to positive (move right)
    jmp  L_EB0F                 ; Update animation
    
L_ECA9:
    ; Move left 2 pixels
    dec  FA,x                   ; Decrement X position
    dec  FA,x                   ; Decrement X position again
    jmp  L_EB0F                 ; Update animation

; Check right movement (positive velocity in D_8868,x)
L_ECB0:
    lda  D_8868,x               ; Load secondary velocity
    bpl  L_ECDC                 ; If positive/zero, done with movement
    
    ; Moving right (negative secondary velocity indicates rightward)
    lda  FA,x                   ; Load X position
    cmp  #$F4                   ; At right edge?
    beq  L_ECD0                 ; If yes, reverse direction
    
    ldy  #$2B                   ; Default cell offset
    lda  INDEX2                 ; Check terrain index
    beq  L_ECC3                 ; If zero, use default
    ldy  #$53                   ; Alternate cell offset
    
L_ECC3:
    lda  ZP_23                  ; Check level index
    bne  L_ECD8                 ; If non-zero, move right unconditionally
    
    ; Check if wall to the right
    lda  (INPFLG),y             ; Check right cell
    bpl  L_ECD8                 ; If not solid, move right
    dey                         ; Check adjacent cell
    lda  (INPFLG),y
    bmi  L_ECD8                 ; If solid, reverse direction
    
L_ECD0:
    ; Hit wall or edge - reverse secondary velocity
    lda  #$01
    sta  D_8868,x               ; Change to positive
    jmp  L_EB0F                 ; Update animation
    
L_ECD8:
    ; Move right 2 pixels
    inc  FA,x                   ; Increment X position
    inc  FA,x                   ; Increment X position again
    
L_ECDC:
    jmp  L_EB0F                 ; Update animation

; Movement handler for state bit flag 0 (called from D_EAFA) - D_ECDF
; Handles directional decision based on player/target position
    lda  ZP_25                  ; Load player Y / level index
    cmp  D_8750,x               ; Compare with target direction
    bcs  L_ECED                 ; If >=, skip direction change
    
    ; Change entity direction (incomplete instruction - self-modifying code)
    lda  D_8750,x               ; Load target direction
    .byte $9D                   ; STA absolute,X opcode (next 2 bytes are address)
    ; Note: This appears to be incomplete/corrupted code
    ; Falls through to JSR which may be the actual continuation
    jsr  D_6085                 ; Call direction handler

; Check platform cell and potentially reverse entity direction
L_ECED:
    ldy  #$28                   ; Default cell offset
    lda  INDEX2                 ; Check terrain index
    beq  L_ECF5                 ; If zero, use default
    ldy  #$50                   ; Alternate cell offset
    
L_ECF5:
    lda  #$FE                   ; Direction value (-2 for leftward)
    
; Common direction change routine (used by multiple entry points)
L_ECF7:
    sta  $04                    ; Store direction in temp
    lda  ZP_23                  ; Check level index
    bne  L_ED0A                 ; If non-zero, change direction
    
    ; Check if platform allows direction change
    lda  (INPFLG),y             ; Check cell
    bpl  L_ED0A                 ; If not solid, change direction
    
    ; Platform is solid - toggle entity state bits 0 and 1
    lda  D_85E8,x               ; Load entity state flags
    eor  #$03                   ; XOR bits 0 and 1
    sta  D_85E8,x               ; Store updated flags
    rts
    
L_ED0A:
    ; Apply direction change to X position
    lda  FA,x                   ; Load X position
    clc
    adc  $04                    ; Add direction offset
    sta  FA,x                   ; Store new X position
    rts

; Handle right direction input (entry point for external calls) - D_ED12
    ldy  #$28                   ; Cell offset
    lda  #$FC                   ; Direction value (-4 for rightward)
    bmi  L_ECF7                 ; Always taken - jump to common handler

; Handle left direction input (entry point for external calls) - D_ED18
    ldy  #$2B                   ; Cell offset
    lda  #$04                   ; Direction value (+4 for leftward)
    bpl  L_ECF7                 ; Always taken - jump to common handler

; Movement handler for state bit flag 1 (called from D_EAFA) - D_ED1E
; Controls animation frame based on position comparison
    lda  ZP_25                  ; Load player Y / level index
    cmp  D_8750,x               ; Compare with target
    bcc  L_ED2B                 ; If less, change frame
    
    ; Reset animation frame to zero
    lda  #$00
    sta  D_8520,x               ; Clear animation frame
    rts
    
L_ED2B:
    ; Check cell and set frame to 2
    ldy  #$2B                   ; Cell offset
    lda  INDEX2                 ; Check terrain index
    beq  L_ED33                 ; If zero, use default
    ldy  #$53                   ; Alternate cell offset
    
L_ED33:
    lda  #$02                   ; Animation frame 2
    bne  L_ECF7                 ; Always taken - use common direction handler

; Increment entity animation frame
L_ED37:
    inc  D_8818,x               ; Increment animation frame data
    rts

; Decrement entity animation frame (alternate entry point) - D_ED3B
    dec  D_8818,x               ; Decrement animation frame data
    beq  L_ED41                 ; If zero, spawn projectile
    rts                         ; Otherwise return
    
; Spawn projectile/entity when animation frame reaches zero
L_ED41:
    .byte $BC                   ; LDY absolute,X opcode
    ldy  #$87                   ; Operand high byte (loads from $87A0,x)
    bmi  L_ED37                 ; If negative, just increment and return
    
    ; Setup to spawn projectile
    lda  #$FF
    sta  D_87A0,x               ; Set collision state
    
    ; Calculate spawn X position (entity X - $14) / 8
    lda  FA,x                   ; Load entity X position
    sec
    sbc  #$14                   ; Subtract left border offset
    lsr                         ; Divide by 8 (shift right 3 times)
    lsr
    lsr
    sta  ADRAY1                 ; Store grid X position in $03
    
    sty  $02                    ; Store Y register in temp
    
    ; Check entity animation frame vs target to determine projectile direction
    lda  D_8520,x               ; Load animation frame
    cmp  D_8750,x               ; Compare with target frame
    bcs  L_ED68                 ; If >=, projectile goes right
    
    ; Projectile goes left
    lda  #$02                   ; Direction code for left
    sta  $0195,y                ; Store in projectile direction array
    ldy  #$2B                   ; Cell offset for left
    bne  L_ED71                 ; Skip right setup
    
L_ED68:
    ; Projectile goes right
    lda  #$80                   ; Direction code for right
    sta  $0195,y                ; Store in projectile direction array
    ldy  #$27                   ; Cell offset for right
    lda  #$FE                   ; Direction offset
    
; Store direction and check if spawn position is valid
L_ED71:
    sta  $04                    ; Store direction offset
    lda  (INPFLG),y             ; Check spawn cell
    bmi  L_EDC7                 ; If solid, abort spawn
    iny                         ; Check adjacent cell
    lda  (INPFLG),y
    bmi  L_EDC7                 ; If solid, abort spawn
    
    ; Valid spawn position - create projectile entity
    ldy  $02                    ; Restore Y (entity slot)
    lda  ADRAY1                 ; Load grid X position
    clc
    adc  $04                    ; Add direction offset
    sta  $00DE,y                ; Store in entity array +$DE
    sta  D_AA0E,y               ; Store in data table
    
    ; Calculate spawn Y position (entity Y - $15) / 8
    lda  ZP_C2,x                ; Load entity Y position
    sec
    sbc  #$15                   ; Subtract top border offset
    lsr                         ; Divide by 8
    lsr
    lsr
    sta  $00F0,y                ; Store grid Y position in array +$F0
    
    ; Store source entity index
    txa                         ; Transfer entity index to A
    sta  D_AA20,y               ; Store in projectile source table
    
    ; Initialize projectile state
    lda  #$00
    sta  D_A9C6,y               ; Clear projectile state 1
    sta  D_A9D8,y               ; Clear projectile state 2
    
    ; Check entity type to determine projectile type
    lda  ENESSION,x             ; Load entity type/state
    cmp  #$08                   ; Entity type 8?
    bne  L_EDAA                 ; If not, check type 7
    
    ; Entity type 8 - spawn projectile type $2A
    lda  #$2A
    bne  L_EDC3                 ; Store and complete spawn
    
L_EDAA:
    cmp  #$07                   ; Entity type 7?
    bne  L_EDB9                 ; If not, use default projectile
    
    ; Entity type 7 - special handling
    tya                         ; Transfer slot to A
    sta  D_8890,x               ; Store in entity data array
    lda  #$2C                   ; Animation frame $2C
    sta  D_8818,x               ; Store in animation data
    bne  L_EDC3                 ; Complete spawn
    
L_EDB9:
    ; Default projectile type - based on direction
    lda  $0195,y                ; Load projectile direction
    and  #$7F                   ; Clear high bit
    sta  D_A9C6,y               ; Store as projectile state
    lda  #$28                   ; Default projectile type
    
L_EDC3:
    sta  $00CC,y                ; Store projectile type in array +$CC
    
    ; L_EDC7
    rts

; End of entity movement handler section
