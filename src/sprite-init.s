;===============================================================================
; bb-sprite-init.s - Sprite Display Initialization Routines
;===============================================================================
; Address range: $3E77-$3FAF (313 bytes)
;
; This module contains multiple sprite initialization routines that set up
; sprite display parameters by writing to self-modifying code locations at
; $E849-$E861. These routines configure sprite pointers and control bytes
; for the VIC-II sprite multiplexer.
;
; All routines write to the same target addresses but with different values:
;   $E849-$E84A: Sprite routine 1 pointer/instruction
;   $E84C-$E84D: Sprite data pointer 1 (low/high)
;   $E853-$E854: Sprite routine 2 pointer/instruction
;   $E856-$E857: Sprite data pointer 2 (low/high)
;   $E85D-$E85E: Sprite routine 3 pointer/instruction
;   $E860-$E861: Sprite data pointer 3 (low/high)
;===============================================================================

;-------------------------------------------------------------------------------
; Data Fragment ($3E77-$3E78)
;-------------------------------------------------------------------------------
        .byte   $86,$3F                             ; $3E77 - STX DATLIN (fragment)

;-------------------------------------------------------------------------------
; Sprite Init Routine 1 ($3E79-$3E93)
;-------------------------------------------------------------------------------
; Sets up sprite display with specific pointer values
; Entry point from external code

routine_3E79:
        ldx     #$99                                ; $3E79 - X register preset
        lda     #$20                                ; $3E7B - Sprite pointer 1 low
        sta     D_E84C                              ; $3E7D
        lda     #$30                                ; $3E80 - Sprite pointer 2 low
        sta     D_E856                              ; $3E82
        stx     D_E84D                              ; $3E85 - Set pointer 1 high
        stx     D_E857                              ; $3E88 - Set pointer 2 high
        lda     #$C0                                ; $3E8B - Sprite routine 1 value
        sta     D_E849                              ; $3E8D
        lda     #$D0                                ; $3E90 - Sprite routine 2 value
        bne     L_3EAF_common_end                   ; $3E92 - Always branches

;-------------------------------------------------------------------------------
; Sprite Init Routine 2 ($3E94-$3EAE) - D_3E94
;-------------------------------------------------------------------------------
; Main sprite initialization routine called from bb-bubble-handler.s
; Sets up sprite display for entity processing

D_3E94:
        stx     DATLIN                              ; $3E94 - Save entity index
        lda     #$C0                                ; $3E96 - Sprite pointer 1 low
        sta     D_E84C                              ; $3E98
        lda     #$D0                                ; $3E9B - Sprite pointer 2 low
        sta     D_E856                              ; $3E9D
        ldx     #$92                                ; $3EA0 - Sprite page high value
        stx     D_E84D                              ; $3EA2 - Set pointer 1 high
        stx     D_E857                              ; $3EA5 - Set pointer 2 high
        lda     #$E0                                ; $3EA8 - Sprite routine 1 value
        sta     D_E849                              ; $3EAA
        lda     #$F0                                ; $3EAD - Sprite routine 2 value

;-------------------------------------------------------------------------------
; Common Ending for Init Routines ($3EAF-$3ED3)
;-------------------------------------------------------------------------------
L_3EAF_common_end:
        sta     D_E853                              ; $3EAF - Set sprite routine 2
        lda     #$00                                ; $3EB2 - Clear flag
        sta     OLDTXT                              ; $3EB4

;-------------------------------------------------------------------------------
; D_3EB6 - Sprite Control Setup (shared by multiple routines)
;-------------------------------------------------------------------------------
D_3EB6:
        stx     D_E84A                              ; $3EB6 - Set sprite instruction 1
        stx     D_E854                              ; $3EB9 - Set sprite instruction 2
        lda     #$20                                ; $3EBC - Sprite pointer 3 low
        sta     D_E860                              ; $3EBE
        lda     #$80                                ; $3EC1 - Sprite pointer 3 high
        sta     D_E861                              ; $3EC3
        lda     #$60                                ; $3EC6 - RTS opcode
        sta     D_E85D                              ; $3EC8 - Set sprite routine 3
        lda     #$82                                ; $3ECB - STX instruction opcode
        sta     D_E85E                              ; $3ECD - Modify sprite code
        clc                                         ; $3ED0 - Clear carry
        jmp     D_E7CF                              ; $3ED1 - Jump to sprite display

;-------------------------------------------------------------------------------
; Data Fragment ($3ED4)
;-------------------------------------------------------------------------------
        .byte   $86                                 ; $3ED4 - Fragment (STX)

;-------------------------------------------------------------------------------
; Sprite Init Routine 3 ($3ED5-$3EFC) - D_3ED5
;-------------------------------------------------------------------------------
; Initialize sprite display from table data
; Uses Y register as index into sprite data tables

D_3ED5:
        .byte   $3F                                 ; $3ED5 - RLA illegal opcode (data?)
        .byte   $BC,$C4                             ; $3ED6 - Data bytes (LDY addr,X?)
        lda     #$A2                                ; $3ED8 - Preset X register value
        tya                                         ; $3EDA - Transfer index
        lda     D_AB5B,y                            ; $3EDB - Load sprite low from table
        bne     L_3EE1_has_value                    ; $3EDE - Branch if non-zero
        inx                                         ; $3EE0 - Increment if zero

L_3EE1_has_value:
        sta     D_E84C                              ; $3EE1 - Set sprite pointer 1 low
        clc                                         ; $3EE4
        adc     #$10                                ; $3EE5 - Add offset for pointer 2
        sta     D_E856                              ; $3EE7
        stx     D_E84D                              ; $3EEA - Set pointer 1 high
        stx     D_E857                              ; $3EED - Set pointer 2 high
        ldx     #$99                                ; $3EF0 - New X value
        lda     D_AB5F,y                            ; $3EF2 - Load sprite routine value
        sta     D_E849                              ; $3EF5 - Set sprite routine 1
        clc                                         ; $3EF8
        adc     #$10                                ; $3EF9 - Add offset
        bne     L_3EAF_common_end                   ; $3EFB - Always branches to common end

;-------------------------------------------------------------------------------
; Sprite Init Routine 4 ($3EFD-$3F81)
;-------------------------------------------------------------------------------
; Complex sprite setup with graphics compositing
; Uses entity data to configure sprites and performs 8-byte block copying

routine_3EFD:
        stx     DATLIN                              ; $3EFD - Save entity index
        ldy     D_A9C4,x                            ; $3EFF - Get entity sub-position
        ldx     #$99                                ; $3F02 - Preset X
        lda     D_A826,y                            ; $3F04 - Load sprite data from table
        cmp     #$E0                                ; $3F07 - Check if >= $E0
        beq     L_3F0C_skip_inc                     ; $3F09 - Skip increment if equal
        inx                                         ; $3F0B - Increment X

L_3F0C_skip_inc:
        sta     D_E84C                              ; $3F0C - Set sprite pointer 1 low

D_3F0F:
        clc                                         ; $3F0F
        adc     #$10                                ; $3F10 - Add offset for pointer 2
        sta     D_E856                              ; $3F12
        stx     D_E84D                              ; $3F15 - Set pointer 1 high
        stx     D_E857                              ; $3F18 - Set pointer 2 high
        ldx     #$9A                                ; $3F1B - Different X value
        lda     D_A82A,y                            ; $3F1D - Load sprite routine value
        sta     D_E849                              ; $3F20
        clc                                         ; $3F23
        adc     #$10                                ; $3F24 - Add offset
        bne     L_3EAF_common_end                   ; $3F26 - Branch to common end

        ; Alternate exit path
        txa                                         ; $3F28 - Check X
        beq     L_3F2E_do_copy                      ; $3F29 - Branch if zero
        jmp     D_E97A                              ; $3F2B - Otherwise jump to handler

;-------------------------------------------------------------------------------
; Graphics Block Copy Loop ($3F2E-$3F81)
;-------------------------------------------------------------------------------
; Copies 8-byte blocks from source to destination using indirect addressing
; Processes 10 blocks (X counts down from 9 to 0)

L_3F2E_do_copy:
        lda     #$20                                ; $3F2E - Initialize source pointer low
        sta     OLDTXT                              ; $3F30 - Store at $3D
        lda     #$70                                ; $3F32 - Initialize mask pointer low
        sta     $44                                 ; $3F34
        lda     #$A2                                ; $3F36 - Initialize pointers high
        sta     OLDTXT+1                            ; $3F38 - Store at $3E
        sta     VARNAM                              ; $3F3A - Store at $45
        
        ldx     #$09                                ; $3F3C - Loop counter (10 blocks)

L_3F3E_block_loop:
        ldy     D_A82E,x                            ; $3F3E - Get offset from table
        lda     (DATLIN+1),y                        ; $3F41 - Load value via indirect
        tay                                         ; $3F43 - Use as index
        lda     D_0200,y                            ; $3F44 - Load from page 2
        sta     DATPTR+1                            ; $3F47 - Store pointer low ($42)
        lda     D_0300,y                            ; $3F49 - Load from page 3 (IERROR)
        ora     ARYTAB                              ; $3F4C - OR with $2F
        sta     INPPTR                              ; $3F4E - Store pointer high ($43)
        
        ldy     #$07                                ; $3F50 - Copy 8 bytes

L_3F52_byte_loop:
        lda     (DATPTR+1),y                        ; $3F52 - Load source byte ($42),Y
        and     ($44),y                             ; $3F54 - AND with mask ($44),Y
        ora     (OLDTXT),y                          ; $3F56 - OR with destination ($3D),Y
        sta     (MEMSIZ+1),y                        ; $3F58 - Store result ($38),Y
        dey                                         ; $3F5A
        bpl     L_3F52_byte_loop                    ; $3F5B - Loop for all 8 bytes
        
        ; Update pointers for next block (add 8 to each)
        lda     $44                                 ; $3F5D - Mask pointer low
        clc                                         ; $3F5F
        adc     #$08                                ; $3F60
        sta     $44                                 ; $3F62
        
        lda     OLDTXT                              ; $3F64 - Source pointer low
        adc     #$08                                ; $3F66
        sta     OLDTXT                              ; $3F68
        
        lda     MEMSIZ+1                            ; $3F6A - Dest pointer low
        adc     #$08                                ; $3F6C
        sta     MEMSIZ+1                            ; $3F6E
        bcc     L_3F74_no_carry                     ; $3F70 - Skip if no carry
        inc     CURLIN                              ; $3F72 - Increment dest high byte

L_3F74_no_carry:
        lda     OLDLIN+1                            ; $3F74 - Get counter value
        inc     OLDLIN+1                            ; $3F76 - Increment for next iteration
        ldy     D_A82E,x                            ; $3F78 - Get offset again
        sta     (DATLIN+1),y                        ; $3F7B - Store counter back
        dex                                         ; $3F7D - Decrement block counter
        bpl     L_3F3E_block_loop                   ; $3F7E - Loop for all 10 blocks
        
        inx                                         ; $3F80 - X = 0
        jmp     D_E97A                              ; $3F81 - Jump to handler

;-------------------------------------------------------------------------------
; Data Tables ($3F84-$3F8B)
;-------------------------------------------------------------------------------
D_3F84:
        .byte   $09,$13                             ; $3F84 - Data values
        .byte   $42,$46,$86,$3F,$BD,$D6             ; $3F86 - Data fragment (D_3F86 defined in bb-master.s)

;-------------------------------------------------------------------------------
; Sprite Init Routine 5 ($3F8C-$3FAC)
;-------------------------------------------------------------------------------
; Another sprite initialization variant
; Entry from external code

routine_3F8C:
        lda     #$85                                ; $3F8C
        and     D_30A9,x                            ; $3F8E - (likely invalid address)
        sta     D_E84C                              ; $3F91 - Set sprite pointer 1
        lda     #$40                                ; $3F94
        sta     D_E856                              ; $3F96 - Set sprite pointer 2
        ldx     #$42                                ; $3F99 - Sprite page value
        stx     D_E84D                              ; $3F9B - Set pointer 1 high
        stx     D_E857                              ; $3F9E - Set pointer 2 high
        ldx     #$40                                ; $3FA1 - Different page value
        lda     #$A8                                ; $3FA3 - Sprite routine 1
        sta     D_E849                              ; $3FA5
        lda     #$B8                                ; $3FA8 - Sprite routine 2
        sta     D_E853                              ; $3FAA

;-------------------------------------------------------------------------------
; D_3FAD - Jump to Shared Setup
;-------------------------------------------------------------------------------
D_3FAD:
        jmp     D_3EB6                              ; $3FAD - Jump to shared sprite setup

;===============================================================================
; End of bb-sprite-init.s
;===============================================================================
