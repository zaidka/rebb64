;===============================================================================
; bb-graphics-copy.s - Graphics and sprite data copying
;===============================================================================
; Address range: $3C01-$3CB1
;
; This module handles copying and compositing sprite/graphics data, likely for
; animating sprites or creating composite graphics from multiple sources.
;===============================================================================

;-------------------------------------------------------------------------------
; Graphics initialization and setup routine
;-------------------------------------------------------------------------------
; Address: $3C01-$3CB1
; Initializes graphics state and composites sprite data
;-------------------------------------------------------------------------------
D_3C01:
        lda     #$13                ; Graphics mode
        sta     $A9B0
        ldx     $A9AE               ; Check init flag
        bne     @skip_init
        sta     $A9AE               ; Set init flag

@skip_init:
        lda     $10                 ; Level number
        cmp     #$63                ; Level 99?
        bne     @setup_ptrs
        
        ; Level 99 special case
        lda     #$01
        sta     $A9AE
        lda     #$00
        sta     $A9AF
        sta     $A9B0

@setup_ptrs:
        lda     #$46                ; Setup graphics pointers
        sta     $0A
        sta     $0C
        ldx     #$00
        stx     $09
        lda     #$48
        sta     $0B

@comp_loop:
        lda     $519C,x             ; Get sprite index 1
        tay
        lda     $0200,y             ; Sprite pointer low
        sta     $02
        lda     $0300,y             ; Sprite pointer high
        ora     #$40
        sta     $03
        lda     $51EC,x             ; Get sprite index 2
        tay
        lda     $0200,y
        sta     $04
        lda     $0300,y
        ora     #$40
        sta     $05
        lda     $A9A8,x             ; Calculate dest address 1
        asl
        asl
        asl
        adc     #$90
        sta     $11
        lda     #$00
        adc     #$FE
        sta     $12
        lda     $AD15,x             ; Calculate dest address 2
        asl
        asl
        asl
        adc     #$90
        sta     $13
        lda     #$00
        adc     #$FE
        sta     $14
        ldy     #$07                ; Composite 8 bytes

@copy_byte:
        lda     ($02),y             ; OR sprite data together
        ora     ($11),y
        sta     ($09),y
        lda     ($04),y
        ora     ($13),y
        sta     ($0B),y
        dey
        bpl     @copy_byte
        
        lda     $09                 ; Advance pointers
        clc
        adc     #$08
        sta     $09
        lda     $0B
        adc     #$08
        sta     $0B
        inx
        cpx     #$09                ; 9 sprites
        bne     @comp_loop
        
        ldx     #$47                ; Copy buffers

@buf_loop:
        lda     $4600,x
        sta     $4E00,x
        lda     $4648,x
        sta     $4E48,x
        dex
        bpl     @buf_loop
        
        jsr     $E494               ; Wait/sync
        lda     #$02
        sta     $A9B1               ; Set complete flag
        ldx     #$FD
        ldy     #$AC
        jmp     $E42A               ; Continue
