; ============================================================================
; rebb64 - Sound Engine
; ============================================================================
; Address Range: $F4BC-$F921 (1,126 bytes)
;
; This is the complete SID sound and music system.
; Major routines:
;   - D_F4BD (sound_init): Initialize SID chip and clear sound state
;   - D_F53C (sound_update): Called every frame to update all 3 voices
;   - D_F887: Music/mode initialization (called from credits handler)
; ============================================================================

; First byte at $F4BC - RTS from previous routine
    rts                         ; 60           $f4bc

; ============================================================================
; SOUND_INIT ($F4BD)
; ============================================================================
; Initializes the SID chip and sound variables.
; Clears all SID registers and sets volume to maximum.

; sound_init: (descriptive name from reference)
; D_F4BD: (label defined in bb-master.s)
    ldx  #$16                   ; a2 16        $f4bd  ; 23 SID registers to clear
; sound_init_loop: (descriptive name from reference)
L_F4BF:
    lda  #$08                   ; a9 08        $f4bf  ; Reset value
    sta  SID_V1_FREQ_LO,x       ; 9d 00 d4     $f4c1  ; Clear SID register
    lda  #$00                   ; a9 00        $f4c4
    sta  SID_V1_FREQ_LO,x       ; 9d 00 d4     $f4c6  ; Clear to zero
    dex                         ; ca           $f4c9
    bpl  L_F4BF                 ; 10 f3        $f4ca  ; Loop all registers
    ; Clear music channel state variables
    stx  D_F305                 ; 8e 05 f3     $f4cc  ; Channel 1 state
    stx  D_F306                 ; 8e 06 f3     $f4cf  ; Channel 2 state
    stx  D_F307                 ; 8e 07 f3     $f4d2  ; Channel 3 state
    sta  D_F337                 ; 8d 37 f3     $f4d5  ; Music pointer 1
    sta  D_F35A                 ; 8d 5a f3     $f4d8  ; Music pointer 2
    sta  D_F37D                 ; 8d 7d f3     $f4db  ; Music pointer 3
    sta  D_F391                 ; 8d 91 f3     $f4de  ; Sound effect state
    sta  D_F308                 ; 8d 08 f3     $f4e1  ; Voice 1 active flag
    sta  D_F309                 ; 8d 09 f3     $f4e4  ; Voice 2 active flag
    sta  D_F30A                 ; 8d 0a f3     $f4e7  ; Voice 3 active flag
    stx  STKEY                  ; 86 91        $f4ea  ; Clear keyboard buffer
    ldx  #$1f                   ; a2 1f        $f4ec  ; Volume = 15, filter = low-pass
    stx  SID_VOL                ; 8e 18 d4     $f4ee  ; Set SID volume/filter mode
    rts                         ; 60           $f4f1
D_F4F2:
    stx  $80                    ; 86 80        $f4f2
    ldx  #$0f                   ; a2 0f        $f4f4
L_F4F6:
    lda  D_F30B,x               ; bd 0b f3     $f4f6
    sta  D_F384,x               ; 9d 84 f3     $f4f9
    dex                         ; ca           $f4fc
D_F4FD:
    bpl  L_F4F6                 ; 10 f7        $f4fd
    ldx  D_F392                 ; ae 92 f3     $f4ff
    ldy  D_F393                 ; ac 93 f3     $f502
    stx  D_F394                 ; 8e 94 f3     $f505
    sty  D_F395                 ; 8c 95 f3     $f508
    lda  D_F38C                 ; ad 8c f3     $f50b
    sta  D_F396                 ; 8d 96 f3     $f50e
    lda  D_F38D                 ; ad 8d f3     $f511
    sta  D_F397                 ; 8d 97 f3     $f514
    lda  D_F38E                 ; ad 8e f3     $f517
    sta  D_F398                 ; 8d 98 f3     $f51a
    lda  D_F38F                 ; ad 8f f3     $f51d
    sta  D_F399                 ; 8d 99 f3     $f520
    txa                         ; 8a           $f523
    and  #$07                   ; 29 07        $f524
    sta  SID_FILT_LO            ; 8d 15 d4     $f526 - SID_FILT_LO
    tya                         ; 98           $f529
    stx  BSOUR                  ; 86 a3        $f52a
    lsr                         ; 4a           $f52c
    ror  BSOUR                  ; 66 a3        $f52d
    lsr                         ; 4a           $f52f
    ror  BSOUR                  ; 66 a3        $f530
    lsr                         ; 4a           $f532
    lda  BSOUR                  ; a5 a3        $f533
    ror                         ; 6a           $f535
    sta  SID_FILT_HI            ; 8d 16 d4     $f536 - SID_FILT_HI
    ldx  $80                    ; a6 80        $f539
    rts                         ; 60           $f53b
; ============================================================================
; SOUND_UPDATE ($F53C)
; ============================================================================
; Called every frame to update music and sound effects.
; Processes all 3 SID voices for music playback.
; sound_update: (descriptive name from reference)
; D_F53C: (label defined in bb-master.s)
    ldx  #$02                   ; a2 02        $f53c  ; Process 3 voices (2,1,0)
    lda  #$00                   ; a9 00        $f53e
    sta  SYESSION               ; 85 a4        $f540  ; Clear active voice count
; sound_voice_loop: (descriptive name from reference)
L_F542:
    lda  D_F308,x               ; bd 08 f3     $f542  ; Check if voice X is active
    beq  L_F54C                 ; f0 05        $f545  ; Skip if not playing
    inc  SYESSION               ; e6 a4        $f547  ; Count active voices
    jsr  D_F55B                 ; 20 5b f5     $f549  ; Update sound effect for voice X
L_F54C:
    ldy  D_7430,x               ; bc 30 74     $f54c  ; Get music channel offset
    lda  D_F337,y               ; b9 37 f3     $f54f  ; Check music data pointer
    beq  L_F557                 ; f0 03        $f552  ; Skip if no music
    jsr  D_F6A5                 ; 20 a5 f6     $f554  ; Update music for channel
L_F557:
    dex                         ; ca           $f557  ; Next voice
    bpl  L_F542                 ; 10 e8        $f558  ; Loop all 3 voices
L_F55A:
    rts                         ; 60           $f55a
D_F55B:
    dec  $a0,x                  ; d6 a0        $f55b
    bne  L_F55A                 ; d0 fb        $f55d
    lda  $8a,x                  ; b5 8a        $f55f
    sta  $85                    ; 85 85        $f561
    lda  $8d,x                  ; b5 8d        $f563
    sta  $86                    ; 85 86        $f565
    jmp  D_F56F                 ; 4c 6f f5     $f567
D_F56A:
    lda  #$01                   ; a9 01        $f56a
D_F56C:
    jsr  music_add_offset       ; 20 20 74     $f56c
D_F56F:
    ldy  #$00                   ; a0 00        $f56f
    lda  ($85),y                ; b1 85        $f571
    bpl  L_F581                 ; 10 0c        $f573
    iny                         ; c8           $f575
    eor  #$c0                   ; 49 c0        $f576
    sta  D_F57C                 ; 8d 7c f5     $f578
    jmp  (D_F256)               ; 6c 56 f2     $f57b
L_F57E:
    jmp  D_F63B                 ; 4c 3b f6     $f57e
L_F581:
    sta  STATUS                 ; 85 90        $f581
    cmp  #$5f                   ; c9 5f        $f583
    bcs  L_F57E                 ; b0 f7        $f585
    adc  $87,x                  ; 75 87        $f587
    sta  $78                    ; 85 78        $f589
    lda  D_F305,x               ; bd 05 f3     $f58b
    beq  L_F57E                 ; f0 ee        $f58e
    lda  #$08                   ; a9 08        $f590
    sta  $7c                    ; 85 7c        $f592
    ldy  D_7436,x               ; bc 36 74     $f594
    sta  SID_V1_CTRL,y          ; 99 04 d4     $f597 - SID_V1_CTRL
    cpx  STKEY                  ; e4 91        $f59a
    bne  L_F5A1                 ; d0 03        $f59c
    jsr  D_F4F2                 ; 20 f2 f4     $f59e
L_F5A1:
    ldy  $78                    ; a4 78        $f5a1
    lda  FREQ_TABLE_HI,y        ; b9 18 f4     $f5a3 - Frequency high byte
    sta  CHRGOT                 ; 85 79        $f5a6
    pha                         ; 48           $f5a8
    lda  FREQ_TABLE_LO,y        ; b9 b9 f3     $f5a9 - Frequency low byte
    sta  $78                    ; 85 78        $f5ac
    ldy  D_7430,x               ; bc 30 74     $f5ae
    sta  D_F333,y               ; 99 33 f3     $f5b1
    pla                         ; 68           $f5b4
    sta  D_F334,y               ; 99 34 f3     $f5b5
    ldy  D_742D,x               ; bc 2d 74     $f5b8
    lda  D_F2C4,y               ; b9 c4 f2     $f5bb
    sta  TXTPTR                 ; 85 7a        $f5be
    lda  D_F2C5,y               ; b9 c5 f2     $f5c0
    sta  $7b                    ; 85 7b        $f5c3
    lda  D_F2C7,y               ; b9 c7 f2     $f5c5
    sta  $7d                    ; 85 7d        $f5c8
    lda  D_F2C8,y               ; b9 c8 f2     $f5ca
    sta  $7e                    ; 85 7e        $f5cd
    lda  D_F2C6,y               ; b9 c6 f2     $f5cf
    ldy  D_7430,x               ; bc 30 74     $f5d2
    sta  D_F335,y               ; 99 35 f3     $f5d5
    and  #$f7                   ; 29 f7        $f5d8
    pha                         ; 48           $f5da
    stx  $7f                    ; 86 7f        $f5db
    ldy  D_7437,x               ; bc 37 74     $f5dd
    dey                         ; 88           $f5e0
    ldx  #$06                   ; a2 06        $f5e1
L_F5E3:
    lda  $78,x                  ; b5 78        $f5e3
    sta  SID_V1_FREQ_LO,y       ; 99 00 d4     $f5e5 - SID_V1_FREQ_LO
    dey                         ; 88           $f5e8
    dex                         ; ca           $f5e9
    bpl  L_F5E3                 ; 10 f7        $f5ea
    iny                         ; c8           $f5ec
    pla                         ; 68           $f5ed
    sta  SID_V1_CTRL,y          ; 99 04 d4     $f5ee - SID_V1_CTRL
    ldx  $7f                    ; a6 7f        $f5f1
    ldy  D_7430,x               ; bc 30 74     $f5f3
    jsr  D_F68D                 ; 20 8d f6     $f5f6
    lda  D_7357,x               ; bd 57 73     $f5f9
    sta  D_F608                 ; 8d 08 f6     $f5fc
    lda  D_735A,x               ; bd 5a 73     $f5ff
    sta  D_F60B                 ; 8d 0b f6     $f602
    ldy  #$17                   ; a0 17        $f605
L_F607:
    lda  D_F2AE,y               ; b9 ae f2     $f607
    sta  D_F31B,y               ; 99 1b f3     $f60a
    dey                         ; 88           $f60d
    bpl  L_F607                 ; 10 f7        $f60e
    ldy  D_7430,x               ; bc 30 74     $f610
    lda  D_F328,y               ; b9 28 f3     $f613
    and  #$08                   ; 29 08        $f616
    beq  L_F624                 ; f0 0a        $f618
    lda  STATUS                 ; a5 90        $f61a
    clc                         ; 18           $f61c
    adc  $87,x                  ; 75 87        $f61d
    sta  D_F325,y               ; 99 25 f3     $f61f
    bne  L_F627                 ; d0 03        $f622
L_F624:
    jsr  D_F659                 ; 20 59 f6     $f624
L_F627:
    ldy  D_742D,x               ; bc 2d 74     $f627
    lda  D_F2C9,y               ; b9 c9 f2     $f62a
    pha                         ; 48           $f62d
    lda  D_F2CA,y               ; b9 ca f2     $f62e
    ldy  D_7430,x               ; bc 30 74     $f631
    sta  D_F337,y               ; 99 37 f3     $f634
    pla                         ; 68           $f637
    sta  D_F336,y               ; 99 36 f3     $f638
D_F63B:
    ldy  #$01                   ; a0 01        $f63b
    lda  ($85),y                ; b1 85        $f63d
    ldy  STATUS                 ; a4 90        $f63f
    cpy  #$60                   ; c0 60        $f641
    beq  L_F649                 ; f0 04        $f643
    tay                         ; a8           $f645
    lda  D_F399,y               ; b9 99 f3     $f646
L_F649:
    sta  $a0,x                  ; 95 a0        $f649
    lda  #$02                   ; a9 02        $f64b
    jsr  music_add_offset       ; 20 20 74     $f64d
    lda  $85                    ; a5 85        $f650
    sta  $8a,x                  ; 95 8a        $f652
    lda  $86                    ; a5 86        $f654
    sta  $8d,x                  ; 95 8d        $f656
    rts                         ; 60           $f658
D_F659:
    lda  D_F333,y               ; b9 33 f3     $f659
    sta  DFLTN,x                ; 95 98        $f65c
    sta  TXTPTR                 ; 85 7a        $f65e
    lda  D_F334,y               ; b9 34 f3     $f660
    sta  TESSION,x              ; 95 9b        $f663
    sta  $7b                    ; 85 7b        $f665
D_F667:
    lda  D_F326,y               ; b9 26 f3     $f667
    sta  D_F33B,y               ; 99 3b f3     $f66a
    lda  D_F325,y               ; b9 25 f3     $f66d
    sta  D_F33A,y               ; 99 3a f3     $f670
    lda  D_F324,y               ; b9 24 f3     $f673
    sta  D_F339,y               ; 99 39 f3     $f676
    lda  D_F323,y               ; b9 23 f3     $f679
    sta  D_F338,y               ; 99 38 f3     $f67c
    rts                         ; 60           $f67f
D_F680:
    ldy  D_7430,x               ; bc 30 74     $f680
    lda  D_F331,y               ; b9 31 f3     $f683
    sta  TXTPTR                 ; 85 7a        $f686
    lda  D_F332,y               ; b9 32 f3     $f688
    sta  $7b                    ; 85 7b        $f68b
D_F68D:
    ldy  D_7430,x               ; bc 30 74     $f68d
    lda  TXTPTR                 ; a5 7a        $f690
    sta  SVXT,x                 ; 95 92        $f692
    lda  $7b                    ; a5 7b        $f694
    sta  BESSION,x              ; 95 95        $f696
    lda  D_F329,y               ; b9 29 f3     $f698
    sta  D_F33C,y               ; 99 3c f3     $f69b
    lda  D_F32A,y               ; b9 2a f3     $f69e
    sta  D_F33D,y               ; 99 3d f3     $f6a1
    rts                         ; 60           $f6a4
D_F6A5:
    lda  D_F335,y               ; b9 35 f3     $f6a5
    and  #$08                   ; 29 08        $f6a8
    beq  L_F6C2                 ; f0 16        $f6aa
    lda  $a0,x                  ; b5 a0        $f6ac
    cmp  D_F336,y               ; d9 36 f3     $f6ae
    bcs  L_F70C                 ; b0 59        $f6b1
    lda  #$00                   ; a9 00        $f6b3
    sta  D_F336,y               ; 99 36 f3     $f6b5
    lda  D_F335,y               ; b9 35 f3     $f6b8
    and  #$f6                   ; 29 f6        $f6bb
    sta  D_F335,y               ; 99 35 f3     $f6bd
    bne  L_F703                 ; d0 41        $f6c0
L_F6C2:
    lda  D_F336,y               ; b9 36 f3     $f6c2
    bne  L_F6EF                 ; d0 28        $f6c5
    lda  D_F337,y               ; b9 37 f3     $f6c7
    clc                         ; 18           $f6ca
    adc  #$01                   ; 69 01        $f6cb
    beq  L_F70C                 ; f0 3d        $f6cd
    sbc  #$01                   ; e9 01        $f6cf
    sta  D_F337,y               ; 99 37 f3     $f6d1
    bne  L_F70C                 ; d0 36        $f6d4
    stx  $7f                    ; 86 7f        $f6d6
    ldy  D_7437,x               ; bc 37 74     $f6d8
    dey                         ; 88           $f6db
    ldx  #$06                   ; a2 06        $f6dc
L_F6DE:
    sta  SID_V1_FREQ_LO,y       ; 99 00 d4     $f6de - SID_V1_FREQ_LO
    dey                         ; 88           $f6e1
    dex                         ; ca           $f6e2
    bpl  L_F6DE                 ; 10 f9        $f6e3
    ldx  $7f                    ; a6 7f        $f6e5
    cpx  STKEY                  ; e4 91        $f6e7
    bne  L_F6EE                 ; d0 03        $f6e9
    sta  D_F391                 ; 8d 91 f3     $f6eb
L_F6EE:
    rts                         ; 60           $f6ee
L_F6EF:
    lda  D_F336,y               ; b9 36 f3     $f6ef
    clc                         ; 18           $f6f2
    adc  #$01                   ; 69 01        $f6f3
    beq  L_F70C                 ; f0 15        $f6f5
    sbc  #$01                   ; e9 01        $f6f7
    sta  D_F336,y               ; 99 36 f3     $f6f9
    bne  L_F70C                 ; d0 0e        $f6fc
    lda  D_F335,y               ; b9 35 f3     $f6fe
    and  #$f6                   ; 29 f6        $f701
L_F703:
    ldy  D_7436,x               ; bc 36 74     $f703
    sta  SID_V1_CTRL,y          ; 99 04 d4     $f706 - SID_V1_CTRL
    ldy  D_7430,x               ; bc 30 74     $f709
L_F70C:
    lda  D_F32C,y               ; b9 2c f3     $f70c
    beq  L_F78A                 ; f0 79        $f70f
    lda  D_F32B,y               ; b9 2b f3     $f711
    beq  L_F71F                 ; f0 09        $f714
    sec                         ; 38           $f716
    sbc  #$01                   ; e9 01        $f717
    sta  D_F32B,y               ; 99 2b f3     $f719
    jmp  L_F78A                 ; 4c 8a f7     $f71c
L_F71F:
    lda  SVXT,x                 ; b5 92        $f71f
    sta  TXTPTR                 ; 85 7a        $f721
    lda  BESSION,x              ; b5 95        $f723
    sta  $7b                    ; 85 7b        $f725
    lda  D_F33C,y               ; b9 3c f3     $f727
    beq  L_F744                 ; f0 18        $f72a
    sec                         ; 38           $f72c
    sbc  #$01                   ; e9 01        $f72d
    sta  D_F33C,y               ; 99 3c f3     $f72f
    lda  TXTPTR                 ; a5 7a        $f732
    clc                         ; 18           $f734
    adc  D_F32D,y               ; 79 2d f3     $f735
    sta  TXTPTR                 ; 85 7a        $f738
    lda  $7b                    ; a5 7b        $f73a
    adc  D_F32E,y               ; 79 2e f3     $f73c
    sta  $7b                    ; 85 7b        $f73f
    jmp  D_F776                 ; 4c 76 f7     $f741
L_F744:
    lda  D_F33D,y               ; b9 3d f3     $f744
    beq  L_F761                 ; f0 18        $f747
    sec                         ; 38           $f749
    sbc  #$01                   ; e9 01        $f74a
    sta  D_F33D,y               ; 99 3d f3     $f74c
    lda  TXTPTR                 ; a5 7a        $f74f
    clc                         ; 18           $f751
    adc  D_F32F,y               ; 79 2f f3     $f752
    sta  TXTPTR                 ; 85 7a        $f755
    lda  $7b                    ; a5 7b        $f757
    adc  D_F330,y               ; 79 30 f3     $f759
    sta  $7b                    ; 85 7b        $f75c
    jmp  D_F776                 ; 4c 76 f7     $f75e
L_F761:
    lda  D_F32C,y               ; b9 2c f3     $f761
    and  #$81                   ; 29 81        $f764
    beq  D_F776                 ; f0 0e        $f766
    bpl  L_F770                 ; 10 06        $f768
    jsr  D_F680                 ; 20 80 f6     $f76a
    jmp  L_F71F                 ; 4c 1f f7     $f76d
L_F770:
    jsr  D_F68D                 ; 20 8d f6     $f770
    jmp  L_F71F                 ; 4c 1f f7     $f773
D_F776:
    ldy  D_7436,x               ; bc 36 74     $f776
    lda  TXTPTR                 ; a5 7a        $f779
    sta  SID_V1_PW_LO,y         ; 99 02 d4     $f77b - SID_V1_PW_LO
    sta  SVXT,x                 ; 95 92        $f77e
    lda  $7b                    ; a5 7b        $f780
    sta  SID_V1_PW_HI,y         ; 99 03 d4     $f782 - SID_V1_PW_HI
    sta  BESSION,x              ; 95 95        $f785
    ldy  D_7430,x               ; bc 30 74     $f787
L_F78A:
    lda  D_F328,y               ; b9 28 f3     $f78a
    beq  L_F7FA                 ; f0 6b        $f78d
    and  #$08                   ; 29 08        $f78f
    beq  L_F7E0                 ; f0 4d        $f791
    cpx  #$02                   ; e0 02        $f793
    beq  L_F7E0                 ; f0 49        $f795
    lda  D_F31F,y               ; b9 1f f3     $f797
    sec                         ; 38           $f79a
    sbc  #$01                   ; e9 01        $f79b
    sta  D_F31F,y               ; 99 1f f3     $f79d
    bne  L_F7FA                 ; d0 58        $f7a0
    lda  D_F321,y               ; b9 21 f3     $f7a2
    sta  D_F31F,y               ; 99 1f f3     $f7a5
    lda  D_F323,y               ; b9 23 f3     $f7a8
    sta  $80                    ; 85 80        $f7ab
    lda  D_F324,y               ; b9 24 f3     $f7ad
    sta  $81                    ; 85 81        $f7b0
    lda  D_F325,y               ; b9 25 f3     $f7b2
    pha                         ; 48           $f7b5
    lda  D_F327,y               ; b9 27 f3     $f7b6
    bpl  L_F7BE                 ; 10 03        $f7b9
    lda  D_F326,y               ; b9 26 f3     $f7bb
L_F7BE:
    tay                         ; a8           $f7be
    pla                         ; 68           $f7bf
    clc                         ; 18           $f7c0
    adc  ($80),y                ; 71 80        $f7c1
    pha                         ; 48           $f7c3
    dey                         ; 88           $f7c4
    tya                         ; 98           $f7c5
    ldy  D_7430,x               ; bc 30 74     $f7c6
    sta  D_F327,y               ; 99 27 f3     $f7c9
    pla                         ; 68           $f7cc
    tay                         ; a8           $f7cd
    lda  FREQ_TABLE_HI,y        ; b9 18 f4     $f7ce - Frequency high byte
    pha                         ; 48           $f7d1
    lda  FREQ_TABLE_LO,y        ; b9 b9 f3     $f7d2 - Frequency low byte
    ldy  D_7436,x               ; bc 36 74     $f7d5
    sta  SID_V1_FREQ_LO,y       ; 99 00 d4     $f7d8 - SID_V1_FREQ_LO
    pla                         ; 68           $f7db
    sta  SID_V1_FREQ_HI,y       ; 99 01 d4     $f7dc - SID_V1_FREQ_HI
    rts                         ; 60           $f7df
L_F7E0:
    lda  DFLTN,x                ; b5 98        $f7e0
    sta  TXTPTR                 ; 85 7a        $f7e2
    lda  TESSION,x              ; b5 9b        $f7e4
    sta  $7b                    ; 85 7b        $f7e6
    lda  D_F327,y               ; b9 27 f3     $f7e8
    beq  L_F7FB                 ; f0 0e        $f7eb
    sec                         ; 38           $f7ed
    sbc  #$01                   ; e9 01        $f7ee
    sta  D_F327,y               ; 99 27 f3     $f7f0
    lda  D_F328,y               ; b9 28 f3     $f7f3
    and  #$02                   ; 29 02        $f7f6
    bne  L_F851                 ; d0 57        $f7f8
L_F7FA:
    rts                         ; 60           $f7fa
L_F7FB:
    lda  D_F338,y               ; b9 38 f3     $f7fb
    beq  L_F814                 ; f0 14        $f7fe
    sec                         ; 38           $f800
    sbc  #$01                   ; e9 01        $f801
    sta  D_F338,y               ; 99 38 f3     $f803
    lda  TXTPTR                 ; a5 7a        $f806
    clc                         ; 18           $f808
    adc  D_F31B,y               ; 79 1b f3     $f809
    sta  TXTPTR                 ; 85 7a        $f80c
    lda  D_F31C,y               ; b9 1c f3     $f80e
    jmp  D_F85C                 ; 4c 5c f8     $f811
L_F814:
    lda  D_F339,y               ; b9 39 f3     $f814
    beq  L_F82D                 ; f0 14        $f817
    sec                         ; 38           $f819
    sbc  #$01                   ; e9 01        $f81a
    sta  D_F339,y               ; 99 39 f3     $f81c
D_F81F:
    lda  $7a                    ; a5 7a        $f81f
    clc                         ; 18           $f821
    adc  D_F31D,y               ; 79 1d f3     $f822
    sta  TXTPTR                 ; 85 7a        $f825
    lda  D_F31E,y               ; b9 1e f3     $f827
    jmp  D_F85C                 ; 4c 5c f8     $f82a
L_F82D:
    lda  D_F33A,y               ; b9 3a f3     $f82d
    beq  L_F846                 ; f0 14        $f830
    sec                         ; 38           $f832
    sbc  #$01                   ; e9 01        $f833
    sta  D_F33A,y               ; 99 3a f3     $f835
    lda  TXTPTR                 ; a5 7a        $f838
    clc                         ; 18           $f83a
    adc  D_F31F,y               ; 79 1f f3     $f83b
    sta  TXTPTR                 ; 85 7a        $f83e
    lda  D_F320,y               ; b9 20 f3     $f840
    jmp  D_F85C                 ; 4c 5c f8     $f843
L_F846:
    lda  D_F33B,y               ; b9 3b f3     $f846
    beq  L_F872                 ; f0 27        $f849
    sec                         ; 38           $f84b
    sbc  #$01                   ; e9 01        $f84c
    sta  D_F33B,y               ; 99 3b f3     $f84e
L_F851:
    lda  TXTPTR                 ; a5 7a        $f851
    clc                         ; 18           $f853
    adc  D_F321,y               ; 79 21 f3     $f854
    sta  TXTPTR                 ; 85 7a        $f857
    lda  D_F322,y               ; b9 22 f3     $f859
D_F85C:
    adc  $7b                    ; 65 7b        $f85c
    sta  $7b                    ; 85 7b        $f85e
L_F860:
    ldy  D_7436,x               ; bc 36 74     $f860
    lda  TXTPTR                 ; a5 7a        $f863
    sta  DFLTN,x                ; 95 98        $f865
    sta  SID_V1_FREQ_LO,y       ; 99 00 d4     $f867 - SID_V1_FREQ_LO
    lda  $7b                    ; a5 7b        $f86a
    sta  TESSION,x              ; 95 9b        $f86c
    sta  SID_V1_FREQ_HI,y       ; 99 01 d4     $f86e - SID_V1_FREQ_HI
L_F871:
    rts                         ; 60           $f871
L_F872:
    lda  D_F328,y               ; b9 28 f3     $f872
    and  #$81                   ; 29 81        $f875
    beq  L_F860                 ; f0 e7        $f877
    bpl  L_F881                 ; 10 06        $f879
    jsr  D_F659                 ; 20 59 f6     $f87b
    jmp  L_F7FB                 ; 4c fb f7     $f87e
L_F881:
    jsr  D_F667                 ; 20 67 f6     $f881
    jmp  L_F7FB                 ; 4c fb f7     $f884

; D_F887: Music/mode initialization routine
D_F887:
    sta  TIME                   ; 85 9e        $f887
    sty  $9f                    ; 84 9f        $f889
    lda  #$00                   ; a9 00        $f88b
    sta  D_F305                 ; 8d 05 f3     $f88d
    ldx  #$06                   ; a2 06        $f890
L_F892:
    lda  #$08                   ; a9 08        $f892
    sta  SID_V1_FREQ_LO,x       ; 9d 00 d4     $f894 - SID_V1_FREQ_LO
    lda  #$00                   ; a9 00        $f897
    sta  SID_V1_FREQ_LO,x       ; 9d 00 d4     $f899 - SID_V1_FREQ_LO
    dex                         ; ca           $f89c
    bpl  L_F892                 ; 10 f3        $f89d
    ldy  #$1a                   ; a0 1a        $f89f
    ldx  #$04                   ; a2 04        $f8a1
L_F8A3:
    lda  (TIME),y               ; b1 9e        $f8a3
    sta  SID_V1_PW_LO,x         ; 9d 02 d4     $f8a5 - SID_V1_PW_LO
    dey                         ; 88           $f8a8
    dex                         ; ca           $f8a9
    bpl  L_F8A3                 ; 10 f7        $f8aa
    ldy  #$1d                   ; a0 1d        $f8ac
    lda  (TIME),y               ; b1 9e        $f8ae
    tax                         ; aa           $f8b0
    lda  FREQ_TABLE_LO,x        ; bd b9 f3     $f8b1 - Frequency low byte
    sta  SID_V1_FREQ_LO         ; 8d 00 d4     $f8b4 - SID_V1_FREQ_LO
    sta  D_F333                 ; 8d 33 f3     $f8b7
    lda  FREQ_TABLE_HI,x        ; bd 18 f4     $f8ba - Frequency high byte
    sta  SID_V1_FREQ_HI         ; 8d 01 d4     $f8bd - SID_V1_FREQ_HI
    sta  D_F334                 ; 8d 34 f3     $f8c0
    dey                         ; 88           $f8c3
    lda  (TIME),y               ; b1 9e        $f8c4
    sta  D_F337                 ; 8d 37 f3     $f8c6
    dey                         ; 88           $f8c9
    lda  (TIME),y               ; b1 9e        $f8ca
    sta  D_F336                 ; 8d 36 f3     $f8cc
    ldy  #$18                   ; a0 18        $f8cf
    lda  (TIME),y               ; b1 9e        $f8d1
    sta  D_F335                 ; 8d 35 f3     $f8d3
    dey                         ; 88           $f8d6
L_F8D7:
    lda  (TIME),y               ; b1 9e        $f8d7
    sta  D_F31B,y               ; 99 1b f3     $f8d9
    dey                         ; 88           $f8dc
    bpl  L_F8D7                 ; 10 f8        $f8dd
    lda  D_F32C                 ; ad 2c f3     $f8df
    beq  L_F8FA                 ; f0 16        $f8e2
    lda  D_F331                 ; ad 31 f3     $f8e4
    sta  SVXT                   ; 85 92        $f8e7
    lda  D_F332,y               ; b9 32 f3     $f8e9
    sta  BESSION                ; 85 95        $f8ec
    lda  D_F329                 ; ad 29 f3     $f8ee
    sta  D_F33C                 ; 8d 3c f3     $f8f1
    lda  D_F32A                 ; ad 2a f3     $f8f4
    sta  D_F33D                 ; 8d 3d f3     $f8f7
L_F8FA:
    lda  D_F328                 ; ad 28 f3     $f8fa
    beq  L_F921                 ; f0 22        $f8fd
    lda  D_F333                 ; ad 33 f3     $f8ff
    sta  DFLTN                  ; 85 98        $f902
    lda  D_F334                 ; ad 34 f3     $f904
    sta  TESSION                ; 85 9b        $f907
    lda  D_F326                 ; ad 26 f3     $f909
    sta  D_F33B                 ; 8d 3b f3     $f90c
    lda  D_F325                 ; ad 25 f3     $f90f
    sta  D_F33A                 ; 8d 3a f3     $f912
    lda  D_F324                 ; ad 24 f3     $f915
    sta  D_F339                 ; 8d 39 f3     $f918
    lda  D_F323                 ; ad 23 f3     $f91b
    sta  D_F338                 ; 8d 38 f3     $f91e
L_F921:
    rts                         ; 60           $f921
