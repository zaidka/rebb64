;===============================================================================
; bb-screen-scroll.s - Level intro screen scrolling animation
;===============================================================================
; Address range: $3AB8-$3C00
;
; Creates a smooth vertical scrolling "curtain rise" effect when entering a
; new level. Uses self-modifying code and double buffering for smooth animation.
;===============================================================================

;-------------------------------------------------------------------------------
; Screen scroll/animation routine - vertical scrolling effect for level intro
;-------------------------------------------------------------------------------
; Address: $3AB8-$3C00
; Creates a smooth vertical scrolling animation when entering a new level.
; Uses self-modifying code and double buffering for the effect.
;-------------------------------------------------------------------------------
        jsr     $E494               ; Wait for frame sync
        
        ; Setup self-modifying code addresses (store screen page)
        lda     $30                 ; ARYTAB+1 (screen page)
        sta     $3BF1               ; Modify code at $3BF1
        sta     $3BFA               ; Modify code at $3BFA
        sta     $3AF0               ; Modify code at $3AF0 (self-mod target)
        
        ; Calculate alternate screen addresses
        eor     #$04                ; Toggle screen page
        clc
        adc     #$03
        sta     $41                 ; DATPTR - pointer high byte
        lda     $2F                 ; ARYTAB (screen page low)
        adc     #$01
        sta     $24                 ; INDEX2
        eor     #$08
        sta     $19                 ; TEMPST
        
        ; Initialize screen pointers
        lda     #$CC
        sta     $40                 ; DATLIN+1 (screen pointer high)
        sta     $3E                 ; OLDTXT+1
        lda     #$B8
        sta     $18                 ; Screen output pointer low
        sta     $23                 ; Second screen pointer
        lda     #$DB
        sta     $3F                 ; DATLIN (screen pointer low)
        
        ; Copy initial data block
        jsr     $16E4               ; Setup call
        inx

@copy_init_data:
        lda     $3CB2,x             ; Source data
        sta     $1200,x             ; Copy to destination
        inx
        bne     @copy_init_data     ; Loop until X wraps to 0
        
        ; Setup scroll parameters
        lda     #$19                ; 25 rows to scroll
        sta     $42                 ; DATPTR+1 (row counter)
        ldy     #$30                ; Column offset
        ldx     #$08                ; 9 bytes per row

@save_row_data:
        lda     ($40),y             ; Read from screen buffer 1
        sta     $3CC4,x             ; Save to temp buffer 1
        lda     ($3E),y             ; Read from screen buffer 2
        sta     $3CCD,x             ; Save to temp buffer 2
        dey
        dex
        bpl     @save_row_data      ; Loop at $3B08
        
        ; Main scroll loop - process each row (D_3B0A in reference)
@scroll_loop_init:
        ldx     #$00
        stx     $3D                 ; OLDTXT (row index)
        stx     $3C                 ; OLDLIN+1

@process_row:
        ldy     $3D                 ; Get row index
        lda     ($3E),y             ; Read color data
        sta     $3CBB,y             ; Store color
        lda     ($40),y             ; Read screen data
        sta     $3CB2,y             ; Store screen char
        tay                         ; Use as index
        
        ; Get character definition pointer
        lda     $0200,y             ; Character pointer low
        sta     $44
        lda     $0300,y             ; Character pointer high
        ora     $2F                 ; ARYTAB
        eor     #$08
        sta     $45                 ; VARNAM
        
        ; Process 8 bytes of character data
        ldy     #$00

@process_char_byte:
        lda     ($44),y             ; Get character byte
        ora     $ADB1,x             ; OR with mask table
        sta     $3CD6,x             ; Store to output buffer 1
        and     $ADF9,x             ; AND with second mask
        ora     $ADB1,x             ; OR with mask again
        sta     $3D1E,x             ; Store to output buffer 2
        inx
        iny
        cpy     #$08                ; 8 bytes per character
        bne     @process_char_byte
        
        inc     $3D                 ; Next row
        cpx     #$48                ; 72 bytes total (9 chars * 8)
        bne     @process_row
        
        ; Frame sync and fill bottom row
        jsr     $E494               ; Wait for frame
        ldy     #$08
        clc

@fill_bottom:
        tya
        adc     #$37                ; Character code (space)
        sta     ($40),y             ; Write to screen
        lda     #$0F                ; White color
        sta     ($3E),y             ; Write color
        dey
        bpl     @fill_bottom
        
        ; Restore saved row data
        ldx     #$08
        ldy     #$30

@restore_row:
        lda     $3CC4,x             ; Get saved screen data
        sta     ($40),y             ; Write to screen
        lda     $3CCD,x             ; Get saved color
        sta     ($3E),y             ; Write color
        lda     $3CBB,x             ; Rotate buffers
        sta     $3CCD,x
        lda     $3CB2,x
        sta     $3CC4,x
        dey
        dex
        bpl     @restore_row
        
        ; Copy processed data to screen
        ldy     #$47                ; 72 bytes

@copy_to_screen:
        lda     $3CD6,y             ; Get processed character data
        sta     ($18),y             ; Write to screen
        dey
        bpl     @copy_to_screen
        
        ; Check if scroll complete
        lda     $42                 ; DATPTR+1 (row counter)
        cmp     #$0C                ; 12 rows remaining?
        bne     @advance_scroll
        
        ; Final rows - copy second buffer
        ldy     #$47

@copy_final:
        lda     $3D1E,y             ; Get second buffer data
        sta     ($18),y             ; Write to screen
        dey
        bpl     @copy_final
        
        ; Delay loop for final animation
        ldy     #$3C
        jsr     $05AD               ; Delay routine
        ldx     #$06

@delay_loop:
        lda     #$08
        jsr     $7BC8               ; More delay
        lda     #$0C
        eor     #$03                ; Calculate value
        sta     $3BA1               ; Self-modify instruction (!)
        ldy     #$08

@inner_delay:
        sta     ($3E),y             ; Write to screen
        dey
        bpl     @inner_delay
        dex
        bne     @delay_loop

@wait_sync:
        lda     $A4                 ; SYESSION
        bne     @wait_sync          ; Wait for completion
        
        ldy     #$27
        jsr     $05AD               ; Final delay

@advance_scroll:
        ; Advance screen pointers up one row (40 bytes)
        lda     $40                 ; DATLIN+1
        sec
        sbc     #$28                ; Move up 40 bytes
        sta     $40                 ; DATLIN+1
        sta     $3E                 ; OLDTXT+1
        bcs     @no_page_wrap
        dec     $41                 ; DATPTR (handle page crossing)
        dec     $3F                 ; DATLIN

@no_page_wrap:
        dec     $42                 ; DATPTR+1 (decrement row counter)
        beq     @scroll_done        ; If zero, scroll complete
        jmp     @scroll_loop_init   ; Continue scrolling (JMP $3B0A)

@scroll_done:
        ; Cleanup after scroll complete
        jsr     $E494               ; Wait for frame
        ldx     #$08
        ldy     #$30

@final_restore:
        lda     $3CC4,x             ; Restore final row
        sta     ($40),y
        lda     $3CCD,x
        sta     ($3E),y
        dey
        dex
        bpl     @final_restore
        
        ; Copy screen data
        ldy     #$47
        inx                         ; X = 1

@final_copy:
        lda     ($23),y             ; Read from source
        sta     ($18),y             ; Write to destination
        dey
        bpl     @final_copy
        
        ; Restore saved data
@restore_saved:
        lda     $0100,x             ; Stack page data
        sta     $3CB2,x             ; Restore to buffer
        lda     $8B00,x             ; High memory data
        sta     $E200,x             ; Restore to high memory
        dex
        bne     @restore_saved
        
        jmp     $7B53               ; Jump to next routine
