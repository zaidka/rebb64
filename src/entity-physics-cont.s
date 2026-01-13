; ==============================================================================
; Bubble Bobble - Entity Physics Continuation & Title Screen Init
; ==============================================================================
; Address range: $EFBC-$F0ED (306 bytes)
;
; This module contains:
; - L_EFBC: Entity platform collision check (Y offset $51)
; - D_EFC0: Entity movement handler with state-based logic
; - D_F005: Title screen initialization routine
;
; Entity state flags (D_85E8,x):
;   Bit 0: Direction (0=right, 1=left)
;   Bit 2: Trapped between platforms
;   Bit 4+: Various movement states
;
; Movement handlers called:
;   D_EF4C: Trapped movement handler
;   D_EFA0: Normal vertical movement
;   D_EEEB: Left movement handler
;   L_EF2A: Right movement handler
; ==============================================================================

; L_EFBC - Platform collision check with Y offset $51
; Jumps to L_EF7D (earlier routine) for actual collision detection
    ldy  #$51                   ; Cell offset for platform check
    bne  L_EF7D                 ; Always branch to collision handler

; D_EFC0 - Main entity movement and animation update
; Called from entity update loop to handle physics and animation
D_EFC0:
    lda  #$01                   ; Set operation flag
    sta  $04                    ; Store in zero page
    lda  D_85E8,x               ; Load entity state flags
    sta  $02                    ; Save for later use
    and  #$04                   ; Check bit 2 (trapped flag)
    beq  L_EFD3                 ; If not trapped, use normal movement
    
    ; Trapped between platforms - use special handler
    jsr  D_EF4C                 ; Handle trapped movement
    jmp  D_EFD6                 ; Continue to horizontal movement

L_EFD3:
    ; Normal vertical movement
    jsr  D_EFA0                 ; Handle normal vertical movement

D_EFD6:
    ; Update entity position after vertical movement
    jsr  D_E9B8                 ; Update entity screen position
    
    ; Handle horizontal movement based on direction flag
    ldy  #$60                   ; Cell offset for horizontal check
    lda  $02                    ; Retrieve state flags
    and  #$01                   ; Check bit 0 (direction flag)
    beq  L_EFE7                 ; If 0 (right), move right
    
    ; Move left
    jsr  D_EEEB                 ; Left movement handler
    jmp  D_EFEA                 ; Continue to animation

L_EFE7:
    ; Move right
    jsr  L_EF2A                 ; Right movement handler

    ; D_EFEA - Update animation frame counter
    inc  D_8610,x               ; Increment animation counter
    lda  D_8610,x               ; Load counter
    cmp  #$02                   ; Check if 2 frames elapsed
    bcc  L_F004                 ; If less, skip frame update
    
    ; Reset counter and advance animation frame
    lda  #$00                   ; Reset counter
    sta  D_8610,x               ; Store counter
    inc  D_8520,x               ; Increment animation frame
    lda  D_8520,x               ; Load frame
    and  #$03                   ; Mask to 4 frames (0-3)
    sta  D_8520,x               ; Store masked frame

L_F004:
    rts                         ; Return


; ==============================================================================
; D_F005 - Title Screen Initialization
; ==============================================================================
; This routine sets up the title screen display:
; - Initializes sprites for title logo
; - Sets up VIC registers for display
; - Copies game state data
; - Displays credits text
; - Waits for player input (fire button)
; ==============================================================================

    ; D_F005 - Title Screen Initialization
    jsr  D_A5A0                 ; Initialize title screen graphics
    
    ; Set up text display pointers
    ldx  #$EE                   ; Text pointer low byte
    ldy  #$F0                   ; Text pointer high byte
    jsr  D_E42A                 ; Display text routine
    
    ; Initialize three sprites for title logo
    ldx  #$05                   ; Sprite 0 setup
    ldy  #$08
    jsr  D_A625                 ; Configure sprite
    
    ldx  #$03                   ; Sprite 1 setup
    ldy  #$0B
    jsr  D_A625                 ; Configure sprite
    
    ldx  #$01                   ; Sprite 2 setup
    ldy  #$0E
    jsr  D_A625                 ; Configure sprite
    
    ; Configure sprite positions and colors
    ldx  #$01                   ; Start with sprite 1
    ldy  #$02                   ; Y register for VIC offset
L_F028:
    lda  D_8570,x               ; Load sprite color
    sta  VIC_SPR0_COL,x         ; Set sprite color register
    lda  #$68                   ; X position = 104
    sta  VIC_SPR0_X,y           ; Set sprite X coordinate
    lda  D_A632,x               ; Load sprite Y position
    sta  VIC_SPR0_Y,y           ; Set sprite Y coordinate
    lda  #$60                   ; Sprite data pointer
    sta  D_53F8,x               ; Set screen pointer for sprite
    dey                         ; Previous VIC register
    dey                         ; (X/Y regs are 2 bytes apart)
    dex                         ; Previous sprite
    bpl  L_F028                 ; Loop for all sprites
    
    ; Enable sprites and set initial state
    stx  SUBFLG                 ; Store X (now $FF) in flag
    lda  #$03                   ; Enable sprites 0, 1
    sta  VIC_SPR_ENA            ; Write to sprite enable register
    
    ; Set up display pointers for text rendering
    lda  #$4F                   ; Text row pointer
    sta  DATLIN+1               ; Store in zero page
    lda  #$51                   ; Text column pointer
    sta  DATPTR                 ; Store in zero page
    sta  ROESSION               ; Also store in $BD
    
    inx                         ; X = 0 (was $FF)
    jsr  D_E3D9                 ; Display text line
    
    ; Display second line of text
    lda  #$C7                   ; New row pointer
    sta  DATLIN+1               ; Update row
    jsr  D_E3D9                 ; Display text line
    
    ; Display third line of text
    lda  #$3F                   ; New row pointer
    sta  DATLIN+1               ; Update row
    inc  DATPTR                 ; Increment column pointer
    jsr  D_E3D9                 ; Display text line
    
    ; Update display and prepare game state
    jsr  D_E393                 ; Update screen display
    
    ; Copy game state data (10 bytes)
    ldx  #$09                   ; Counter for 10 bytes
L_F06D:
    lda  $6B,x                  ; Load from source
    sta  D_57D4,x               ; Store to destination
    lda  #$00                   ; Clear value
    sta  D_D8AF,x               ; Clear destination array
    dex                         ; Decrement counter
    bpl  L_F06D                 ; Loop until done
    
    ; Initialize game variables
    stx  D_5AFF                 ; Store $FF in flag
    inx                         ; X = 0
    stx  VARNAM                 ; Clear variable
    inx                         ; X = 1
    stx  D_8572                 ; Set game state flag
    inx                         ; X = 2

; Display player scores/stats loop
L_F085:
    lda  D_A637,x               ; Load pointer low byte
    sta  DATPTR                 ; Store in zero page
    ldy  D_A634,x               ; Load pointer high byte
    sty  DATLIN+1               ; Store in zero page
    
    lda  D_0409,x               ; Load score/stat value
    cmp  #$63                   ; Compare to 99
    bcc  L_F0AE                 ; If less, handle as number
    beq  L_F0A4                 ; If equal to 99, special case
    
    ; Value > 99: Copy 3-byte value
    ldy  #$02                   ; Copy 3 bytes
L_F09A:
    lda  a:ZP_75,y              ; Load from source
    sta  (DATLIN+1),y           ; Store via pointer
    dey                         ; Next byte
    bpl  L_F09A                 ; Loop for all 3 bytes
    bmi  L_F0BE                 ; Always branch to continue

L_F0A4:
    ; Value = 99: Display single "1"
    lda  #$01                   ; Value to display
    ldy  #$00                   ; Offset 0
    sta  (DATLIN+1),y           ; Store via pointer
    tya                         ; A = 0
    ldy  DATLIN+1               ; Load pointer high byte
    .byte $2C                   ; BIT absolute - skips next 2 bytes

L_F0AE:
    ; Value < 99: Convert and display number
    adc  #$01                   ; Add 1 to value
    iny                         ; Increment Y
    pha                         ; Save A
    stx  MEMSIZ+1               ; Save X register
    lda  D_8570,x               ; Load color value
    tax                         ; Move to X
    pla                         ; Restore A
    jsr  D_3266                 ; Display number routine
    ldx  MEMSIZ+1               ; Restore X register

L_F0BE:
    dex                         ; Next player/stat
    bpl  L_F085                 ; Loop for all players
    
    ; Initialize player state variables
    inx                         ; X = 0
    stx  ESSION+1               ; Clear player 1 state
    inx                         ; X = 1
    stx  ENESSION               ; Set player 2 state
    lda  #$0A                   ; Delay counter
    sta  D_8572                 ; Store counter

; Wait for input loop
L_F0CC:
    jsr  D_7EB3                 ; Read joystick/keyboard
    cmp  #$FE                   ; Check for fire button
    beq  L_F0E3                 ; Fire pressed - start game
    cmp  #$F7                   ; Check for special key
    beq  L_F0E1                 ; Special key - toggle mode
    
    jsr  D_E9EA                 ; Get random number (keep PRNG active)
    lda  #$FF                   ; Reset value
    sta  CIA1_PRB               ; Write to CIA port
    bne  L_F0CC                 ; Always branch - continue waiting

L_F0E1:
    ; Toggle number of players
    inc  ESSION+1               ; Increment player count

L_F0E3:
    ; Start game
    inc  SUBFLG                 ; Set game start flag
    inc  D_5AFF                 ; Set active flag
    jsr  D_08E4                 ; Initialize game
    jmp  D_F005                 ; Return to title (or continue)
