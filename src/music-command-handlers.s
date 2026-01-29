; ============================================================================
; rebb64 - Music Command Handlers
; ============================================================================
; Address Range: $7305-$7429 (293 bytes of code)
; Data Tables: $742A-$743F (various lookup tables)
;
; This file contains the music command dispatch handlers that were previously
; embedded in level-data.bin. These routines process music commands and
; control the SID sound chip.
;
; The "music_track_pointers" table in music-tables.s points to these handlers.
; When the sound engine encounters special music commands, it uses
; jmp (D_F256) to dispatch to the appropriate handler routine.
;
; Entry points (called via music_track_pointers):
;   $7305: Handler 0  - Set music parameter and update
;   $7317: Handler 1  - Decrement and loop control
;   $7333: Handler 2  - Load timing value (0D)
;   $7336: Handler 3  - Load timing value (1C) and copy data
;   $735D: Handler 4  - Set voice parameter
;   $7366: Handler 5  - Set frequency pointers
;   $7378: Handler 6  - Set filter cutoff (F7)
;   $737C: Handler 7  - Set filter cutoff (from table)
;   $7388: Handler 8  - Set filter cutoff (78) with mode 3
;   $738E: Handler 9  - Multi-step voice parameter update
;   $7396: Handler 10 - Complex pointer and data update
;   $73B7: Handler 11 - Update pointers and continue
;   $73BD: Handler 12 - Loop counter check and control
;   $73DD: Handler 13 - Copy 16-byte block to sound registers
;   $73F5: Handler 14 - Set sound effect end markers
;
; Helper routines:
;   $7405 (music_save_pointer): Save music data pointer
;   $7414 (music_load_pointer): Load pointer from music data
;   $7420 (music_add_offset): Add offset to music pointer
;
; Called from:
;   sound-engine.s at $F57B: jmp (D_F256)
; ============================================================================

; ============================================================================
; Handler 0 ($7305) - Set music parameter and update
; ============================================================================
; Loads a byte from music data and stores it in the F292 table
.segment "MUSICHANDLERS"

music_handler_00:
        lda     ($85),y                 ; b1 85        $7305
        ldy     $82,x                   ; b4 82        $7307
        sta     D_F292,y                ; 99 92 f2     $7309
        lda     #$02                    ; a9 02        $730c
        jsr     music_add_offset        ; 20 20 74     $730e
        jsr     music_save_pointer      ; 20 05 74     $7311
        jmp     D_F56F                  ; 4c 6f f5     $7314

; ============================================================================
; Handler 1 ($7317) - Decrement and loop control
; ============================================================================
; Decrements a counter and handles looping logic
music_handler_01:
        dec     $82,x                   ; d6 82        $7317
        ldy     $82,x                   ; b4 82        $7319
        lda     D_F292,y                ; b9 92 f2     $731b
        sec                             ; 38           $731e
        sbc     #$01                    ; e9 01        $731f
        sta     D_F292,y                ; 99 92 f2     $7321
        beq     @continue               ; f0 08        $7324
        jsr     music_restore_pointer   ; 20 d0 73     $7326
        inc     $82,x                   ; f6 82        $7329
        lda     #$00                    ; a9 00        $732b
        .byte   $2C                     ; BIT trick    $732d
@continue:
        lda     #$01                    ; a9 01        $732e
        jmp     D_F56C                  ; 4c 6c f5     $7330

; ============================================================================
; Handler 2 ($7333) - Load timing value (0D)
; ============================================================================
music_handler_02:
        lda     #$0D                    ; a9 0d        $7333
        .byte   $2C                     ; BIT trick    $7335

; ============================================================================
; Handler 3 ($7336) - Load timing value (1C) and copy data
; ============================================================================
; Loads a pointer from music data, then copies data from that location
; to the sound effect table at $F2AE
music_handler_03:
        lda     #$1C                    ; a9 1c        $7336
        pha                             ; 48           $7338
        lda     ($85),y                 ; b1 85        $7339
        sta     $78                     ; 85 78        $733b
        iny                             ; c8           $733d
        lda     ($85),y                 ; b1 85        $733e
        sta     $79                     ; 85 79        $7340
        lda     D_7357,x                ; bd 57 73     $7342
        sta     @copy_target+1          ; 8d 4d 73     $7345
        pla                             ; 68           $7348
        tay                             ; a8           $7349
@copy_loop:
        lda     ($78),y                 ; b1 78        $734a
@copy_target:
        sta     D_F2AE,y                ; 99 ae f2     $734c (self-modified high byte)
        dey                             ; 88           $734f
        bpl     @copy_loop              ; 10 f8        $7350
        lda     #$03                    ; a9 03        $7352
        jmp     D_F56C                  ; 4c 6c f5     $7354

; ============================================================================
; Data/Code overlap ($7357-$735C) - 6 bytes
; ============================================================================
; These tables hold LOW BYTES of voice parameter block addresses, used by
; self-modifying code in sound-engine.s to patch lda/sta absolute,y operands.
; D_7357: source block low bytes (voice 0 in MUSICTABLES, voices 1-2 in CODE_F2C4)
; D_735A: destination block low bytes (all in CODE_F2C4)
D_7357:
        .byte   <D_F2AE, <voice1_src_block, <voice2_src_block
D_735A:
        .byte   <D_F31B, <voice1_dst_block, <voice2_dst_block

; ============================================================================
; Handler 4 ($735D) - Set voice parameter
; ============================================================================
music_handler_04:
        lda     ($85),y                 ; b1 85        $735d
        sta     $87,x                   ; 95 87        $735f
        lda     #$02                    ; a9 02        $7361
        jmp     D_F56C                  ; 4c 6c f5     $7363

; ============================================================================
; Handler 5 ($7366) - Set frequency pointers
; ============================================================================
; Sets up pointers for frequency control
music_handler_05:
        lda     ($85),y                 ; b1 85        $7366
        ldy     D_742D,x                ; bc 2d 74     $7368
        sta     D_F2B6,y                ; 99 b6 f2     $736b
        lda     #>D_F276                ; a9 f2        $736e (high byte of MUSICTABLES timing data)
        sta     D_F2B7,y                ; 99 b7 f2     $7370
        lda     #$02                    ; a9 02        $7373
        jmp     D_F56C                  ; 4c 6c f5     $7375

; ============================================================================
; Handler 6 ($7378) - Set filter cutoff (F7)
; ============================================================================
music_handler_06:
        ldy     #$F7                    ; a0 f7        $7378
        bne     filter_set_sid          ; d0 06        $737a

; ============================================================================
; Handler 7 ($737C) - Set filter cutoff (from table)
; ============================================================================
music_handler_07:
        ldy     D_742A,x                ; bc 2a 74     $737c
        txa                             ; 8a           $737f
filter_store_accumulator:
        sta     $91                     ; 85 91        $7380
filter_set_sid:
        sty     $D417                   ; 8c 17 d4     $7382 - SID Filter Cutoff Hi
        jmp     D_F56A                  ; 4c 6a f5     $7385

; ============================================================================
; Handler 8 ($7388) - Set filter cutoff (78) with mode 3
; ============================================================================
music_handler_08:
        ldy     #$78                    ; a0 78        $7388
        lda     #$03                    ; a9 03        $738a
        bne     filter_store_accumulator ; d0 f2       $738c

; ============================================================================
; Handler 9 ($738E) - Multi-step voice parameter update
; ============================================================================
music_handler_09:
        lda     ($85),y                 ; b1 85        $738e
        sta     $87,x                   ; 95 87        $7390
        iny                             ; c8           $7392
        lda     #$04                    ; a9 04        $7393
        .byte   $2C                     ; BIT trick    $7395

; ============================================================================
; Handler 10 ($7396) - Complex pointer and data update
; ============================================================================
music_handler_10:
        lda     #$03                    ; a9 03        $7396
        sty     @restore_y+1            ; 8c b0 73     $7398
        tay                             ; a8           $739b
        lda     $85                     ; a5 85        $739c
        pha                             ; 48           $739e
        lda     $86                     ; a5 86        $739f
        pha                             ; 48           $73a1
        tya                             ; 98           $73a2
        jsr     music_add_offset        ; 20 20 74     $73a3
        jsr     music_save_pointer      ; 20 05 74     $73a6
        pla                             ; 68           $73a9
        sta     $86                     ; 85 86        $73aa
        pla                             ; 68           $73ac
        sta     $85                     ; 85 85        $73ad
@restore_y:
        ldy     #$01                    ; a0 01        $73af (self-modified)
        jsr     music_load_pointer      ; 20 14 74     $73b1
        jmp     D_F56F                  ; 4c 6f f5     $73b4

; ============================================================================
; Handler 11 ($73B7) - Update pointers and continue
; ============================================================================
music_handler_11:
        jsr     music_load_pointer      ; 20 14 74     $73b7
        jmp     D_F56F                  ; 4c 6f f5     $73ba

; ============================================================================
; Handler 12 ($73BD) - Loop counter check and control
; ============================================================================
music_handler_12:
        lda     $82,x                   ; b5 82        $73bd
        cmp     D_7433,x                ; dd 33 74     $73bf
        bne     @not_done               ; d0 04        $73c2
        dec     D_F308,x                ; de 08 f3     $73c4
        rts                             ; 60           $73c7
@not_done:
        dec     $82,x                   ; d6 82        $73c8
        jsr     music_restore_pointer   ; 20 d0 73     $73ca
        jmp     D_F56F                  ; 4c 6f f5     $73cd

; ============================================================================
; Helper: music_restore_pointer ($73D0)
; ============================================================================
; Restores music data pointer from saved state tables
music_restore_pointer:
        ldy     $82,x                   ; b4 82        $73d0
        lda     D_F28A,y                ; b9 8a f2     $73d2
        sta     $85                     ; 85 85        $73d5
        lda     D_F28E,y                ; b9 8e f2     $73d7
        sta     $86                     ; 85 86        $73da
        rts                             ; 60           $73dc

; ============================================================================
; Handler 13 ($73DD) - Copy 16-byte block to sound registers
; ============================================================================
music_handler_13:
        lda     ($85),y                 ; b1 85        $73dd
        sta     $78                     ; 85 78        $73df
        iny                             ; c8           $73e1
        lda     ($85),y                 ; b1 85        $73e2
        sta     $79                     ; 85 79        $73e4
        ldy     #$0F                    ; a0 0f        $73e6
@copy_loop:
        lda     ($78),y                 ; b1 78        $73e8
        sta     D_F30B,y                ; 99 0b f3     $73ea
        dey                             ; 88           $73ed
        bpl     @copy_loop              ; 10 f8        $73ee
        lda     #$03                    ; a9 03        $73f0
        jmp     D_F56C                  ; 4c 6c f5     $73f2

; ============================================================================
; Handler 14 ($73F5) - Set sound effect end markers
; ============================================================================
music_handler_14:
        ldy     D_742D,x                ; bc 2d 74     $73f5
        lda     #$FF                    ; a9 ff        $73f8
        sta     D_F2C8,y                ; 99 c8 f2     $73fa
        lda     #$FE                    ; a9 fe        $73fd
        sta     D_F2CA,y                ; 99 ca f2     $73ff
        jmp     D_F56A                  ; 4c 6a f5     $7402

; ============================================================================
; Helper: music_save_pointer ($7405)
; ============================================================================
; Saves current music data pointer to state tables
music_save_pointer:
        ldy     $82,x                   ; b4 82        $7405
        lda     $85                     ; a5 85        $7407
        sta     D_F28A,y                ; 99 8a f2     $7409
        lda     $86                     ; a5 86        $740c
        sta     D_F28E,y                ; 99 8e f2     $740e
        inc     $82,x                   ; f6 82        $7411
        rts                             ; 60           $7413

; ============================================================================
; Helper: music_load_pointer ($7414)
; ============================================================================
; Loads a 16-bit pointer from music data into $85/$86
music_load_pointer:
        lda     ($85),y                 ; b1 85        $7414
        pha                             ; 48           $7416
        iny                             ; c8           $7417
        lda     ($85),y                 ; b1 85        $7418
        sta     $86                     ; 85 86        $741a
        pla                             ; 68           $741c
        sta     $85                     ; 85 85        $741d
        rts                             ; 60           $741f

; ============================================================================
; Helper: music_add_offset ($7420)
; ============================================================================
; Adds accumulator value to music data pointer ($85/$86)
music_add_offset:
        clc                             ; 18           $7420
        adc     $85                     ; 65 85        $7421
        sta     $85                     ; 85 85        $7423
        bcc     @done                   ; 90 02        $7425
        inc     $86                     ; e6 86        $7427
@done:
        rts                             ; 60           $7429

; ============================================================================
; DATA TABLES ($742A-$743F)
; ============================================================================
; These tables are referenced by the handlers above and by sound-engine.s

; D_742A - Filter cutoff table (3 bytes)
D_742A:
        .byte   $F1, $F2, $F4           ; f1 f2 f4     $742a

; D_742D - Sound channel offset table (accessed at $7368, $73F5, and sound-engine.s)
D_742D:
        .byte   $00, $1D, $3A           ; 00 1d 3a     $742d

; D_7430 - Voice frequency offset table (accessed throughout sound-engine.s)
D_7430:
        .byte   $00, $23, $46           ; 00 23 46     $7430
D_7433:                                 ; Voice frequency offset table +3
        .byte   $00, $0C, $18           ; 00 0c 18     $7433

; D_7436 - SID voice control offset table
D_7436:
        .byte   $00                     ; 00           $7436

; D_7437 - Additional SID offset table
D_7437:
        .byte   $07, $0E, $15           ; 07 0e 15     $7437
        .byte   $00, $00, $00           ; 00 00 00     $743a
        .byte   $00, $00, $08           ; 00 00 08     $743d
