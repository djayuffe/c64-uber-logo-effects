; =============================================================================
; C64 UBER LOGO EFFECTS v1.0.0
; A self-contained ACME demo: full bitmap logo, tunnel, and wire cube.
;
; Build:
;   acme --strict-segments -f cbm -o build/c64_uber_logo_effects.prg c64_uber_logo_effects.asm
; Run:
;   x64sc build/c64_uber_logo_effects.prg
; =============================================================================

!cpu 6502

* = $0801
!byte $0d,$08,$0a,$00,$9e,$20,$31,$36,$33,$38,$34,$00,$00,$00 ; 10 SYS 16384

* = $4000

BORDER=$d020
BGCOL=$d021
CTRL1=$d011
CTRL2=$d016
MEMPTR=$d018
RASTER=$d012
CIA2PRA=$dd00
CPU_PORT=$01
SCREEN=$0400
COLOR=$d800
BITMAP=$2000
CHARSET=$3000

SRC_LO=$fb
SRC_HI=$fc
DST_LO=$fd
DST_HI=$fe
CNT_LO=$02
CNT_HI=$03
FRAME=$04
TMP0=$05
TMP1=$06
TUNROW=$07
TUNCOL=$08
CUBECOUNT=$09
CUBEPTRLO=$0a
CUBEPTRHI=$0b
COLPTRLO=$0c
COLPTRHI=$0d

Start:
        sei
        lda #$35
        sta CPU_PORT
        lda #$7f
        sta $dc0d
        sta $dd0d
        lda $dc0d
        lda $dd0d
        lda #$00
        sta $d01a
        jsr VicBank0
        lda #$00
        sta BORDER
        sta BGCOL
        sta FRAME

MainLoop:
        jsr ShowFullLogo
        ldx #$96
        jsr LogoPulseWait
        jsr FlashOut

        jsr InitCharsetEffect
        ldx #$f0
        jsr TunnelEffect
        jsr FlashOut

        jsr InitCharsetEffect
        ldx #$f0
        jsr CubeEffect
        jsr FlashOut

        jmp MainLoop

VicBank0:
        lda CIA2PRA
        and #%11111100
        ora #%00000011
        sta CIA2PRA
        rts

ModeMCBitmap:
        jsr VicBank0
        lda #%00111011
        sta CTRL1
        lda #%00011000
        sta CTRL2
        lda #$18
        sta MEMPTR
        lda #$00
        sta BGCOL
        rts

ModeText:
        jsr VicBank0
        lda #%00011011
        sta CTRL1
        lda #%00001000
        sta CTRL2
        lda #$1c
        sta MEMPTR
        lda #$00
        sta BGCOL
        rts

DisplayOff:
        lda #$0b
        sta CTRL1
        lda #$08
        sta CTRL2
        rts

!zone WaitFrame
WaitFrame:
        lda #$ff
.w1:
        cmp RASTER
        bne .w1
.w2:
        cmp RASTER
        beq .w2
        rts

!zone CopyCount
CopyCount:
.loop:
        lda CNT_LO
        ora CNT_HI
        beq .done
        ldy #$00
        lda (SRC_LO),y
        sta (DST_LO),y
        inc SRC_LO
        bne .srcok
        inc SRC_HI
.srcok:
        inc DST_LO
        bne .dstok
        inc DST_HI
.dstok:
        lda CNT_LO
        bne .declo
        dec CNT_HI
.declo:
        dec CNT_LO
        jmp .loop
.done:
        rts

!zone ClearScreenColor
ClearScreenColor:
        lda #$20
        ldx #$00
.loop:
        sta SCREEN+$000,x
        sta SCREEN+$100,x
        sta SCREEN+$200,x
        sta SCREEN+$300,x
        lda #$00
        sta COLOR+$000,x
        sta COLOR+$100,x
        sta COLOR+$200,x
        sta COLOR+$300,x
        lda #$20
        inx
        bne .loop
        rts

!zone ClearBitmap
ClearBitmap:
        lda #$00
        ldx #$00
.loop:
        sta BITMAP+$000,x
        sta BITMAP+$100,x
        sta BITMAP+$200,x
        sta BITMAP+$300,x
        sta BITMAP+$400,x
        sta BITMAP+$500,x
        sta BITMAP+$600,x
        sta BITMAP+$700,x
        sta BITMAP+$800,x
        sta BITMAP+$900,x
        sta BITMAP+$a00,x
        sta BITMAP+$b00,x
        sta BITMAP+$c00,x
        sta BITMAP+$d00,x
        sta BITMAP+$e00,x
        sta BITMAP+$f00,x
        sta BITMAP+$1000,x
        sta BITMAP+$1100,x
        sta BITMAP+$1200,x
        sta BITMAP+$1300,x
        sta BITMAP+$1400,x
        sta BITMAP+$1500,x
        sta BITMAP+$1600,x
        sta BITMAP+$1700,x
        sta BITMAP+$1800,x
        sta BITMAP+$1900,x
        sta BITMAP+$1a00,x
        sta BITMAP+$1b00,x
        sta BITMAP+$1c00,x
        sta BITMAP+$1d00,x
        sta BITMAP+$1e00,x
        sta BITMAP+$1f00,x
        inx
        bne .loop
        rts

ShowFullLogo:
        jsr DisplayOff
        jsr ClearBitmap
        jsr ClearScreenColor

        lda #<uber_mc_full_320x200_bitmap
        sta SRC_LO
        lda #>uber_mc_full_320x200_bitmap
        sta SRC_HI
        lda #<BITMAP
        sta DST_LO
        lda #>BITMAP
        sta DST_HI
        lda #<$1f40
        sta CNT_LO
        lda #>$1f40
        sta CNT_HI
        jsr CopyCount

        lda #<uber_mc_full_320x200_screen
        sta SRC_LO
        lda #>uber_mc_full_320x200_screen
        sta SRC_HI
        lda #<SCREEN
        sta DST_LO
        lda #>SCREEN
        sta DST_HI
        lda #<$03e8
        sta CNT_LO
        lda #>$03e8
        sta CNT_HI
        jsr CopyCount

        lda #<uber_mc_full_320x200_color
        sta SRC_LO
        lda #>uber_mc_full_320x200_color
        sta SRC_HI
        lda #<COLOR
        sta DST_LO
        lda #>COLOR
        sta DST_HI
        lda #<$03e8
        sta CNT_LO
        lda #>$03e8
        sta CNT_HI
        jsr CopyCount

        jsr ModeMCBitmap
        rts

!zone LogoPulseWait
LogoPulseWait:
.loop:
        jsr WaitFrame
        inc FRAME
        lda FRAME
        and #$0f
        tay
        lda ColorRamp,y
        sta BORDER
        dex
        bne .loop
        rts

!zone FlashOut
FlashOut:
        ldx #$10
.loop:
        txa
        and #$0f
        sta BORDER
        sta BGCOL
        jsr WaitFrame
        dex
        bne .loop
        lda #$00
        sta BORDER
        sta BGCOL
        rts

InitCharsetEffect:
        jsr DisplayOff
        jsr ModeText
        jsr ClearScreenColor
        jsr BuildEffectCharset
        rts

!zone BuildEffectCharset
BuildEffectCharset:
        lda #$00
        ldx #$00
.clear:
        sta CHARSET+$0100,x
        sta CHARSET+$0200,x
        inx
        bne .clear

        lda #%00011000
        sta CHARSET+$2e*8+3
        sta CHARSET+$2e*8+4

        lda #%00011000
        sta CHARSET+$2b*8+0
        sta CHARSET+$2b*8+1
        sta CHARSET+$2b*8+2
        sta CHARSET+$2b*8+5
        sta CHARSET+$2b*8+6
        sta CHARSET+$2b*8+7
        lda #%11111111
        sta CHARSET+$2b*8+3
        sta CHARSET+$2b*8+4

        lda #%10000001
        sta CHARSET+$58*8+0
        sta CHARSET+$58*8+7
        lda #%01000010
        sta CHARSET+$58*8+1
        sta CHARSET+$58*8+6
        lda #%00100100
        sta CHARSET+$58*8+2
        sta CHARSET+$58*8+5
        lda #%00011000
        sta CHARSET+$58*8+3
        sta CHARSET+$58*8+4

        lda #%11111111
        sta CHARSET+$23*8+0
        sta CHARSET+$23*8+7
        lda #%10011001
        sta CHARSET+$23*8+1
        sta CHARSET+$23*8+2
        sta CHARSET+$23*8+3
        sta CHARSET+$23*8+4
        sta CHARSET+$23*8+5
        sta CHARSET+$23*8+6

        lda #$ff
        ldx #$00
.block:
        sta CHARSET+$40*8,x
        inx
        cpx #$08
        bne .block

        lda #%11111111
        sta CHARSET+$57*8+0
        sta CHARSET+$57*8+7
        lda #%00011000
        sta CHARSET+$57*8+1
        sta CHARSET+$57*8+2
        sta CHARSET+$57*8+3
        sta CHARSET+$57*8+4
        sta CHARSET+$57*8+5
        sta CHARSET+$57*8+6
        rts

!zone TunnelEffect
TunnelEffect:
.frame:
        txa
        pha
        jsr RenderTunnelFrame
        jsr WaitFrame
        inc FRAME
        pla
        tax
        dex
        bne .frame
        rts

RenderTunnelFrame:
        lda #$00
        sta TUNROW
.row:
        ldx TUNROW
        lda ScreenRowLo,x
        sta DST_LO
        lda ScreenRowHi,x
        sta DST_HI
        lda ColorRowLo,x
        sta COLPTRLO
        lda ColorRowHi,x
        sta COLPTRHI
        lda #$00
        sta TUNCOL
.col:
        lda TUNCOL
        sec
        sbc #20
        bcs .xp
        eor #$ff
        clc
        adc #1
.xp:
        sta TMP0
        lda TUNROW
        sec
        sbc #12
        bcs .yp
        eor #$ff
        clc
        adc #1
.yp:
        clc
        adc TMP0
        clc
        adc FRAME
        lsr
        lsr
        and #$07
        tax
        lda DepthChars,x
        ldy TUNCOL
        sta (DST_LO),y
        lda DepthColors,x
        sta (COLPTRLO),y
        inc TUNCOL
        lda TUNCOL
        cmp #40
        bne .col
        inc TUNROW
        lda TUNROW
        cmp #25
        bne .row
        rts

!zone CubeEffect
CubeEffect:
.frame:
        txa
        pha
        jsr ClearScreenColor
        jsr RenderCubeFrame
        jsr WaitFrame
        inc FRAME
        pla
        tax
        dex
        bne .frame
        rts

!zone RenderCubeFrame
RenderCubeFrame:
        lda FRAME
        and #$1f
        tax
        lda CubeFrameCount,x
        sta CUBECOUNT
        lda CubeFrameLo,x
        sta CUBEPTRLO
        lda CubeFrameHi,x
        sta CUBEPTRHI
        ldy #$00
.loop:
        lda CUBECOUNT
        beq .done
        lda (CUBEPTRLO),y
        sta TMP0
        iny
        lda (CUBEPTRLO),y
        sta TMP1
        iny

        sty TUNCOL          ; preserve cube frame-data index while using Y=0 for stores

        clc
        lda #<SCREEN
        adc TMP0
        sta DST_LO
        lda #>SCREEN
        adc TMP1
        sta DST_HI
        lda #$57
        ldy #$00
        sta (DST_LO),y

        clc
        lda #<COLOR
        adc TMP0
        sta DST_LO
        lda #>COLOR
        adc TMP1
        sta DST_HI
        lda FRAME
        and #$0f
        tax
        lda ColorRamp,x
        ldy #$00
        sta (DST_LO),y

        ldy TUNCOL          ; restore cube frame-data index for next offset word
        dec CUBECOUNT
        jmp .loop
.done:
        rts

; -----------------------------------------------------------------------------
; Tables
; -----------------------------------------------------------------------------
ScreenRowLo:
!byte <(SCREEN+0),<(SCREEN+40),<(SCREEN+80),<(SCREEN+120),<(SCREEN+160),<(SCREEN+200),<(SCREEN+240),<(SCREEN+280),<(SCREEN+320),<(SCREEN+360),<(SCREEN+400),<(SCREEN+440),<(SCREEN+480),<(SCREEN+520),<(SCREEN+560),<(SCREEN+600),<(SCREEN+640),<(SCREEN+680),<(SCREEN+720),<(SCREEN+760),<(SCREEN+800),<(SCREEN+840),<(SCREEN+880),<(SCREEN+920),<(SCREEN+960)
ScreenRowHi:
!byte >(SCREEN+0),>(SCREEN+40),>(SCREEN+80),>(SCREEN+120),>(SCREEN+160),>(SCREEN+200),>(SCREEN+240),>(SCREEN+280),>(SCREEN+320),>(SCREEN+360),>(SCREEN+400),>(SCREEN+440),>(SCREEN+480),>(SCREEN+520),>(SCREEN+560),>(SCREEN+600),>(SCREEN+640),>(SCREEN+680),>(SCREEN+720),>(SCREEN+760),>(SCREEN+800),>(SCREEN+840),>(SCREEN+880),>(SCREEN+920),>(SCREEN+960)
ColorRowLo:
!byte <(COLOR+0),<(COLOR+40),<(COLOR+80),<(COLOR+120),<(COLOR+160),<(COLOR+200),<(COLOR+240),<(COLOR+280),<(COLOR+320),<(COLOR+360),<(COLOR+400),<(COLOR+440),<(COLOR+480),<(COLOR+520),<(COLOR+560),<(COLOR+600),<(COLOR+640),<(COLOR+680),<(COLOR+720),<(COLOR+760),<(COLOR+800),<(COLOR+840),<(COLOR+880),<(COLOR+920),<(COLOR+960)
ColorRowHi:
!byte >(COLOR+0),>(COLOR+40),>(COLOR+80),>(COLOR+120),>(COLOR+160),>(COLOR+200),>(COLOR+240),>(COLOR+280),>(COLOR+320),>(COLOR+360),>(COLOR+400),>(COLOR+440),>(COLOR+480),>(COLOR+520),>(COLOR+560),>(COLOR+600),>(COLOR+640),>(COLOR+680),>(COLOR+720),>(COLOR+760),>(COLOR+800),>(COLOR+840),>(COLOR+880),>(COLOR+920),>(COLOR+960)

DepthChars:
!byte $20,$2e,$2b,$58,$23,$57,$40,$57
DepthColors:
!byte $00,$06,$0e,$03,$0d,$01,$07,$0f
ColorRamp:
!byte $00,$06,$0e,$03,$0d,$01,$05,$0c,$0f,$07,$0a,$08,$02,$04,$09,$0b

!if * > $7000 {
    !error "Code or tables overlap the full-logo source at $7000"
}

* = $9800
CubeFrameCount:
!byte 116,102,105,104,104,105,112,112,100,103,97,105,99,106,105,98,108,100,112,107,103,97,97,110,114,110,97,97,104,107,112,100
CubeFrameLo:
!byte <CubeFrame_00,<CubeFrame_01,<CubeFrame_02,<CubeFrame_03,<CubeFrame_04,<CubeFrame_05,<CubeFrame_06,<CubeFrame_07,<CubeFrame_08,<CubeFrame_09,<CubeFrame_10,<CubeFrame_11,<CubeFrame_12,<CubeFrame_13,<CubeFrame_14,<CubeFrame_15,<CubeFrame_16,<CubeFrame_17,<CubeFrame_18,<CubeFrame_19,<CubeFrame_20,<CubeFrame_21,<CubeFrame_22,<CubeFrame_23,<CubeFrame_24,<CubeFrame_25,<CubeFrame_26,<CubeFrame_27,<CubeFrame_28,<CubeFrame_29,<CubeFrame_30,<CubeFrame_31
CubeFrameHi:
!byte >CubeFrame_00,>CubeFrame_01,>CubeFrame_02,>CubeFrame_03,>CubeFrame_04,>CubeFrame_05,>CubeFrame_06,>CubeFrame_07,>CubeFrame_08,>CubeFrame_09,>CubeFrame_10,>CubeFrame_11,>CubeFrame_12,>CubeFrame_13,>CubeFrame_14,>CubeFrame_15,>CubeFrame_16,>CubeFrame_17,>CubeFrame_18,>CubeFrame_19,>CubeFrame_20,>CubeFrame_21,>CubeFrame_22,>CubeFrame_23,>CubeFrame_24,>CubeFrame_25,>CubeFrame_26,>CubeFrame_27,>CubeFrame_28,>CubeFrame_29,>CubeFrame_30,>CubeFrame_31
CubeFrame_00:
!word $00fa,$00fb,$00fc,$00fd,$00fe,$00ff,$0100,$0101,$0102,$0103,$0104,$0105
!word $0106,$0107,$0108,$0109,$010a,$010b,$010c,$010d,$010e,$0136,$015e,$0186
!word $01ae,$01d6,$01fe,$0226,$024e,$0276,$029e,$02c6,$02ee,$02ed,$02ec,$02eb
!word $02ea,$02e9,$02e8,$02e7,$02e6,$02e5,$02e4,$02e3,$02e2,$02e1,$02e0,$02df
!word $02de,$02dd,$02dc,$02db,$02da,$02b2,$028a,$0262,$023a,$0212,$01ea,$01c2
!word $019a,$0172,$014a,$0122,$014e,$014f,$0150,$0151,$0152,$0153,$0154,$0155
!word $0156,$0157,$0158,$0159,$015a,$0182,$01aa,$01d2,$01fa,$0222,$024a,$0272
!word $029a,$0299,$0298,$0297,$0296,$0295,$0294,$0293,$0292,$0291,$0290,$028f
!word $028e,$0266,$023e,$0216,$01ee,$01c6,$019e,$0176,$0123,$0124,$014d,$0135
!word $0134,$015b,$02c5,$02c4,$029b,$02b3,$02b4,$028d
CubeFrame_01:
!word $0120,$0121,$0122,$0123,$0124,$0125,$0126,$0127,$0128,$0129,$012a,$012b
!word $012c,$012d,$012e,$012f,$0130,$0131,$0132,$0133,$0134,$015c,$0184,$01ac
!word $01d4,$01fc,$0223,$024b,$0273,$029b,$02c3,$02eb,$0313,$0312,$0311,$0310
!word $030f,$030e,$030d,$030c,$030b,$02e2,$02e1,$02e0,$02df,$02de,$02dd,$02dc
!word $02db,$02da,$02b2,$028a,$0261,$0239,$0211,$01e9,$01c1,$0199,$0170,$0148
!word $0150,$0151,$0152,$0153,$0154,$0155,$0156,$0157,$0158,$0159,$015a,$015b
!word $0224,$024c,$0274,$0272,$0271,$0270,$026f,$0246,$0245,$0244,$0243,$0242
!word $0241,$0240,$0218,$01f0,$01c8,$01a0,$0178,$014c,$014d,$014e,$014f,$02c4
!word $029c,$02b3,$02b4,$028d,$0266,$0267
CubeFrame_02:
!word $0148,$0149,$014a,$014b,$014c,$014d,$014e,$014f,$0150,$0179,$017a,$017b
!word $017c,$017d,$017e,$017f,$0180,$0181,$01a9,$01d1,$01f9,$0221,$0249,$0270
!word $0298,$02c0,$02e8,$0310,$0338,$0337,$0336,$030d,$030c,$030b,$030a,$02e1
!word $02e0,$02df,$02de,$02dd,$02b4,$02b3,$02b2,$028a,$0262,$0239,$0211,$01e9
!word $01c1,$0198,$0170,$012a,$012b,$012c,$012d,$012e,$012f,$0130,$0131,$0132
!word $0133,$0134,$0135,$0136,$015e,$0186,$01ae,$01d5,$01fd,$0225,$024d,$0275
!word $0274,$0273,$024a,$0248,$0247,$0246,$0245,$021c,$021b,$021a,$01f2,$01ca
!word $01a2,$0152,$0125,$0126,$0127,$0128,$0129,$0182,$015b,$015c,$0311,$02ea
!word $02c3,$029c,$028b,$028c,$0265,$0266,$023f,$0240,$0219
CubeFrame_03:
!word $0148,$0149,$0172,$0173,$0174,$019d,$019e,$019f,$01c8,$01c9,$01ca,$01f3
!word $01f4,$021c,$0244,$026c,$0294,$02bc,$02e4,$030c,$0334,$035c,$0333,$0332
!word $0309,$02e0,$02df,$02b6,$028d,$028c,$0263,$023b,$0212,$01ea,$01c1,$0199
!word $0170,$0104,$0105,$0106,$012f,$0130,$0131,$0132,$0133,$0134,$015d,$015e
!word $015f,$0160,$0188,$01af,$01d7,$01fe,$0226,$024d,$0275,$0274,$024b,$024a
!word $0249,$0220,$021f,$021e,$01f5,$01cc,$01a4,$017c,$0154,$012c,$014a,$0123
!word $0124,$0125,$0126,$0127,$0128,$0101,$0102,$0103,$01ce,$01cf,$01d0,$01a9
!word $01aa,$01ab,$0184,$0185,$0186,$0335,$0336,$030f,$02e8,$02e9,$02c2,$029b
!word $029c,$0264,$023d,$023e,$023f,$0218,$0219,$021a
CubeFrame_04:
!word $0120,$0149,$0172,$019b,$01c4,$01ed,$0216,$023f,$0267,$0290,$02b8,$02e0
!word $0309,$0331,$0308,$02df,$02b6,$028e,$0265,$023c,$0213,$01eb,$01c2,$019a
!word $0171,$00df,$00e0,$0109,$010a,$010b,$0134,$0135,$015e,$015f,$0160,$0189
!word $018a,$01b1,$01d9,$0200,$0227,$024e,$0276,$029d,$0274,$0273,$024a,$0221
!word $01f8,$01f7,$01ce,$01a6,$017e,$0157,$012f,$0107,$0121,$0122,$0123,$00fc
!word $00fd,$00fe,$00ff,$0100,$0101,$0102,$0103,$00dc,$00dd,$00de,$0240,$0219
!word $021a,$021b,$021c,$01f5,$01f6,$01d1,$01d2,$01d3,$01d4,$01ad,$01ae,$01af
!word $01b0,$0332,$030b,$030c,$030d,$02e6,$02e7,$02e8,$02c1,$02c2,$02c3,$029c
!word $023d,$0217,$0218,$01f1,$01f2,$01f3,$01f4,$01cd
CubeFrame_05:
!word $00fa,$0122,$014a,$0172,$019a,$01c3,$01eb,$0213,$023b,$0263,$028c,$02b5
!word $02de,$0307,$02df,$02b6,$028e,$0266,$023e,$0215,$01ed,$01c4,$019c,$0173
!word $014b,$00e2,$010b,$0134,$015d,$0186,$01af,$01d8,$0201,$0228,$024f,$0276
!word $029d,$02c4,$029b,$0273,$024a,$0222,$01f9,$01d1,$01a8,$0180,$0159,$0131
!word $010a,$00fb,$00fc,$00fd,$00fe,$00ff,$0100,$0101,$00da,$00db,$00dc,$00dd
!word $00de,$00df,$00e0,$00e1,$0264,$0265,$023f,$0240,$0241,$0242,$0243,$0244
!word $0245,$021e,$021f,$0220,$0221,$0223,$0224,$0225,$01fe,$01ff,$0200,$0308
!word $0309,$030a,$02e3,$02e4,$02e5,$02e6,$02e7,$02e8,$02c1,$02c2,$02c3,$01ee
!word $01ef,$01c8,$01c9,$01ca,$01cb,$01cc,$01cd,$01a6,$01a7
CubeFrame_06:
!word $00d3,$00fb,$0123,$014a,$0172,$019a,$01c2,$01ea,$0212,$0239,$0261,$0289
!word $028a,$02b3,$02b4,$02b5,$028d,$0265,$023d,$0216,$01ee,$01c6,$019e,$0175
!word $014d,$0124,$00fc,$00e5,$010d,$0135,$015e,$0186,$01ae,$01d6,$01fe,$0226
!word $024f,$0277,$029f,$029e,$02c5,$02c4,$02c3,$029b,$0273,$024b,$0222,$01fa
!word $01d2,$01aa,$0183,$015b,$0134,$010c,$00d4,$00d5,$00d6,$00d7,$00d8,$00d9
!word $00da,$00db,$00dc,$00dd,$00de,$00df,$00e0,$00e1,$00e2,$00e3,$00e4,$028b
!word $028c,$028e,$028f,$0290,$0291,$0292,$0293,$0294,$0295,$0296,$0297,$0298
!word $0299,$029a,$029c,$029d,$02b6,$02b7,$02b8,$02b9,$02ba,$02bb,$02bc,$02bd
!word $02be,$02bf,$02c0,$02c1,$02c2,$019f,$01a0,$01a1,$01a2,$01a3,$01a4,$01a5
!word $01a6,$01a7,$01a8,$01a9
CubeFrame_07:
!word $00ad,$00d4,$00fc,$0123,$014b,$0172,$019a,$01c1,$01e9,$0210,$0238,$025f
!word $0260,$0261,$0262,$0263,$0264,$023d,$0215,$01ee,$01c7,$019f,$0178,$014f
!word $0127,$00fe,$00d6,$0138,$0160,$0187,$01af,$01d7,$01fe,$0226,$024e,$0275
!word $029d,$02c5,$02ec,$0314,$02eb,$02ea,$02c1,$02c0,$0298,$0271,$0249,$0222
!word $01fa,$01d3,$01ab,$0184,$0185,$015e,$015f,$00ae,$00af,$00b0,$00d9,$00da
!word $00db,$00dc,$00dd,$00de,$0107,$0108,$0109,$010a,$010b,$010c,$0135,$0136
!word $0137,$028a,$028b,$028c,$028d,$028e,$02b7,$02b8,$02b9,$02ba,$02bb,$02bc
!word $02e5,$02e6,$02e7,$02e8,$02e9,$0312,$0313,$0265,$0266,$028f,$0290,$0291
!word $0292,$0293,$0294,$02bd,$02be,$02bf,$0179,$017a,$017b,$017c,$017d,$01a6
!word $01a7,$01a8,$01a9,$01aa
CubeFrame_08:
!word $00b0,$00d7,$00fe,$0125,$014c,$0173,$019a,$01c1,$01e8,$020f,$0236,$0237
!word $0238,$0211,$0212,$0213,$0214,$01ed,$01c6,$019f,$0178,$0151,$012a,$0101
!word $00d9,$01b2,$01d9,$0200,$0227,$024e,$0275,$029c,$02c3,$02ea,$0311,$0338
!word $030f,$02e7,$02be,$0297,$0270,$0249,$0222,$01fb,$01d4,$01d5,$01d6,$01af
!word $01b0,$01b1,$00b1,$00da,$00db,$00dc,$0105,$0106,$0107,$0130,$0131,$0132
!word $015b,$015c,$015d,$0186,$0187,$0188,$0260,$0261,$0262,$028b,$028c,$028d
!word $02b6,$02b7,$02b8,$02e1,$02e2,$02e3,$030c,$030d,$030e,$0337,$0215,$023e
!word $023f,$0268,$0269,$026a,$0293,$0294,$02bd,$012b,$0154,$0155,$017e,$017f
!word $0180,$01a9,$01aa,$01d3
CubeFrame_09:
!word $00b4,$00db,$00da,$0101,$0128,$0127,$014e,$0175,$0174,$019b,$019a,$01c1
!word $01e8,$01e7,$020e,$020f,$01e9,$01c2,$01c3,$019c,$019d,$0176,$0177,$0150
!word $0151,$012a,$012b,$0104,$00dc,$022a,$0251,$0250,$0277,$0276,$029d,$029c
!word $02c3,$02ea,$02e9,$0310,$030f,$0336,$0335,$035c,$0334,$030c,$02e4,$02bc
!word $0294,$026d,$026e,$0247,$0248,$0221,$0222,$01fb,$01fc,$01d5,$01d6,$01ff
!word $0200,$0229,$00dd,$00de,$0107,$0130,$0131,$015a,$0183,$0184,$01ad,$01ae
!word $01d7,$0201,$0237,$0238,$0261,$0262,$028b,$028c,$02b5,$02de,$02df,$0308
!word $0309,$0332,$0333,$01ec,$01ed,$0216,$0217,$0240,$0241,$026a,$026b,$012d
!word $012e,$0157,$0158,$0181,$0182,$01ab,$01ac
CubeFrame_10:
!word $0108,$0107,$012e,$012d,$012c,$0153,$0152,$0151,$0178,$0177,$0176,$019d
!word $019c,$019b,$01c2,$01c1,$01c0,$01e7,$01e6,$01bf,$0199,$019a,$0173,$0174
!word $014d,$014e,$014f,$0128,$0129,$0102,$0103,$0104,$00dd,$00de,$02a1,$02a0
!word $02c7,$02c6,$02c5,$02c4,$02eb,$02ea,$02e9,$02e8,$030f,$030e,$030d,$030c
!word $0333,$0332,$0331,$0309,$02e1,$02ba,$0292,$026a,$026b,$0244,$0245,$0246
!word $021f,$0220,$0221,$0222,$01fb,$01fc,$0225,$024e,$024f,$0278,$0131,$015a
!word $0183,$01ac,$01d5,$01fd,$0226,$020f,$0210,$0239,$0262,$028b,$028c,$02b5
!word $02de,$0307,$0308,$01c5,$01ee,$01ef,$0218,$0241,$0130,$0159,$0181,$01aa
!word $01d3
CubeFrame_11:
!word $0185,$0184,$0183,$0182,$01a9,$01a8,$01a7,$01a6,$01a5,$01a4,$01a3,$01ca
!word $01c9,$01c8,$01c7,$01c6,$01c5,$01c4,$01c3,$01ea,$01e9,$01e8,$01e7,$01c0
!word $0199,$0172,$014b,$0124,$0125,$0126,$0127,$0100,$0101,$0102,$0103,$0104
!word $0105,$00de,$00df,$00e0,$00e1,$010a,$0133,$015c,$02ee,$02ed,$02ec,$02eb
!word $02ea,$02e9,$02e8,$02e7,$030e,$030d,$030c,$030b,$030a,$0309,$0308,$0307
!word $0306,$02de,$02b7,$028f,$0268,$0240,$0241,$0242,$021b,$021c,$021d,$021e
!word $021f,$0220,$01f9,$01fa,$01fb,$0224,$024c,$0275,$029d,$02c6,$01ad,$01d5
!word $01fd,$0225,$024e,$0276,$029e,$0210,$0239,$0262,$028b,$02b4,$02dd,$014d
!word $0175,$019e,$01ef,$0217,$0109,$0132,$015a,$01aa,$01d3
CubeFrame_12:
!word $0200,$01ff,$01fe,$01fd,$01fc,$01fb,$01fa,$01f9,$01f8,$01f7,$01f6,$01f5
!word $01f4,$01f3,$01f2,$01f1,$01f0,$01ef,$01ee,$01ed,$01ec,$01eb,$01ea,$01e9
!word $01e8,$01c1,$0199,$0172,$014b,$0123,$00fc,$00fd,$00fe,$00ff,$0100,$0101
!word $0102,$0103,$0104,$0105,$0106,$0107,$0108,$0109,$010a,$010b,$010c,$0135
!word $015d,$0186,$01af,$01d7,$02ec,$02eb,$02ea,$02e9,$02e8,$02e7,$02e6,$02e5
!word $02e4,$02e3,$02e2,$02e1,$02e0,$02df,$02de,$02dd,$02dc,$02b4,$028d,$0265
!word $023d,$0216,$0222,$024b,$0273,$029b,$02c4,$0227,$024f,$0276,$029d,$02c5
!word $0211,$0239,$0262,$028b,$02b3,$0124,$014d,$0175,$019d,$01c6,$0134,$015b
!word $0183,$01ab,$01d2
CubeFrame_13:
!word $0279,$0278,$0277,$0276,$0275,$0274,$024b,$024a,$0249,$0248,$0247,$0246
!word $0245,$0244,$0243,$0242,$0241,$0218,$0217,$0216,$0215,$0214,$0213,$01eb
!word $01c4,$019c,$0174,$014d,$0125,$00fd,$00d6,$00ae,$00af,$00b0,$00b1,$00da
!word $00db,$00dc,$00dd,$00de,$00df,$00e0,$00e1,$010a,$010b,$010c,$010d,$0135
!word $015e,$0186,$01af,$01d7,$0200,$0228,$0251,$02e9,$02e8,$02e7,$02e6,$02e5
!word $02e4,$02e3,$02ba,$02b9,$02b8,$02b7,$02b6,$02b5,$02b4,$02b3,$028b,$0264
!word $023c,$01ec,$01c5,$019d,$019e,$019f,$01c8,$01c9,$01ca,$01cb,$01cc,$01cd
!word $01f6,$01f7,$01f8,$0220,$0271,$0299,$02c1,$029f,$029e,$02c5,$02c4,$02c3
!word $02ea,$023b,$0263,$00fe,$0175,$0134,$015b,$0182,$01aa,$01d1
CubeFrame_14:
!word $02a0,$029f,$029e,$029d,$029c,$029b,$029a,$0299,$0298,$026f,$026e,$026d
!word $026c,$026b,$026a,$0269,$0268,$0267,$023f,$0217,$01ef,$01c7,$019f,$0178
!word $0150,$0128,$0100,$00d8,$00b0,$00b1,$00b2,$00db,$00dc,$00dd,$00de,$0107
!word $0108,$0109,$010a,$010b,$0134,$0135,$0136,$015e,$0186,$01af,$01d7,$01ff
!word $0227,$0250,$0278,$02be,$02bd,$02bc,$02bb,$02ba,$02b9,$02b8,$02b7,$02b6
!word $02b5,$02b4,$02b3,$02b2,$028a,$0262,$023a,$0213,$01eb,$01c3,$019b,$0173
!word $0174,$0175,$019e,$01a0,$01a1,$01a2,$01a3,$01cc,$01cd,$01ce,$01f6,$021e
!word $0246,$0296,$02c3,$02c2,$02c1,$02c0,$02bf,$0266,$028d,$028c,$00d7,$00fe
!word $0125,$014c,$015d,$015c,$0183,$0182,$01a9,$01a8,$01cf
CubeFrame_15:
!word $02c7,$02c6,$02c5,$02c4,$02c3,$02c2,$02c1,$02c0,$02bf,$02be,$02bd,$02bc
!word $0294,$026c,$0244,$021c,$01f4,$01cc,$01a4,$017c,$0154,$012c,$0104,$00dc
!word $00b4,$00b5,$00de,$00df,$0108,$0109,$010a,$0133,$0134,$015d,$015e,$0186
!word $01ae,$01d6,$01fe,$0227,$024f,$0277,$029f,$0293,$0292,$0291,$0290,$028f
!word $02b6,$02b5,$02b4,$02b3,$02b2,$02b1,$0289,$0261,$0239,$0211,$01ea,$01c2
!word $019a,$0172,$014a,$014b,$014c,$0175,$0176,$0177,$0178,$0179,$01a2,$01a3
!word $0299,$0298,$0297,$0296,$0295,$02bb,$02ba,$02b9,$02b8,$02b7,$00b3,$00da
!word $00d9,$0100,$00ff,$00fe,$0125,$0124,$015c,$0183,$0182,$0181,$0180,$017f
!word $01a6,$01a5
CubeFrame_16:
!word $029d,$02c4,$02c3,$02ea,$02e9,$0310,$02e8,$02c0,$0298,$0270,$0248,$0220
!word $01f8,$01d0,$01a8,$0180,$0158,$0130,$0108,$00e0,$0109,$010a,$0133,$0134
!word $015d,$0185,$01ad,$01d5,$01fd,$0225,$024d,$0275,$026a,$0269,$0268,$028f
!word $028e,$028d,$028c,$02b3,$02b2,$02b1,$0289,$0261,$0239,$0211,$01e9,$01c1
!word $0199,$0171,$0149,$0121,$0122,$0123,$014c,$014d,$014e,$014f,$0178,$0179
!word $017a,$01a2,$01ca,$01f2,$021a,$0242,$029c,$029b,$029a,$0299,$026f,$026e
!word $026d,$026c,$026b,$030f,$030e,$030d,$02e4,$02e3,$02e2,$02e1,$02e0,$02df
!word $02de,$02dd,$02b4,$00df,$00de,$00dd,$0104,$0103,$0102,$0101,$0100,$00ff
!word $00fe,$00fd,$0124,$015c,$015b,$015a,$0159,$017f,$017e,$017d,$017c,$017b
CubeFrame_17:
!word $0274,$029c,$02c3,$02eb,$0313,$029b,$0273,$024b,$0224,$01fc,$01d4,$01ac
!word $0184,$015c,$0134,$024c,$0240,$0267,$0266,$028d,$02b4,$02b3,$02da,$02b2
!word $028a,$0261,$0239,$0211,$01e9,$01c1,$0199,$0170,$0148,$0120,$0121,$0122
!word $0123,$014c,$014d,$014e,$014f,$0150,$0178,$01a0,$01c8,$01f0,$0218,$0272
!word $0271,$0270,$026f,$0246,$0245,$0244,$0243,$0242,$0241,$0312,$0311,$0310
!word $030f,$030e,$030d,$030c,$030b,$02e2,$02e1,$02e0,$02df,$02de,$02dd,$02dc
!word $02db,$0133,$0132,$0131,$0130,$012f,$012e,$012d,$012c,$012b,$012a,$0129
!word $0128,$0127,$0126,$0125,$0124,$015b,$015a,$0159,$0158,$0157,$0156,$0155
!word $0154,$0153,$0152,$0151
CubeFrame_18:
!word $024a,$0273,$029b,$02c4,$02ec,$0315,$02ed,$02c5,$029e,$0276,$024e,$0226
!word $01fe,$01d6,$01af,$0187,$015f,$015e,$0135,$0134,$0133,$015b,$0183,$01ab
!word $01d2,$01fa,$0222,$023e,$0265,$028d,$02b4,$02dc,$0303,$02db,$02b3,$028a
!word $0262,$023a,$0212,$01ea,$01c2,$0199,$0171,$0149,$014a,$0123,$0124,$0125
!word $014d,$0175,$019d,$01c6,$01ee,$0216,$0249,$0248,$0247,$0246,$0245,$0244
!word $0243,$0242,$0241,$0240,$023f,$0314,$0313,$0312,$0311,$0310,$030f,$030e
!word $030d,$030c,$030b,$030a,$0309,$0308,$0307,$0306,$0305,$0304,$015d,$015c
!word $015a,$0159,$0158,$0157,$0156,$0155,$0154,$0153,$0152,$0151,$0150,$014f
!word $014e,$014c,$014b,$0132,$0131,$0130,$012f,$012e,$012d,$012c,$012b,$012a
!word $0129,$0128,$0127,$0126
CubeFrame_19:
!word $01f8,$0221,$024a,$0273,$029b,$02c4,$02ed,$02c5,$029e,$0276,$024f,$0227
!word $0200,$01d8,$01b1,$0189,$0188,$015f,$015e,$0135,$0134,$0133,$010a,$0109
!word $0131,$0159,$0180,$01a8,$01d0,$023d,$0265,$028d,$02b6,$02de,$0306,$032e
!word $02dd,$02b5,$0264,$023c,$0214,$01eb,$01c3,$019b,$0173,$014b,$0123,$0174
!word $019c,$01c4,$01ec,$0215,$01f7,$01f6,$021d,$021c,$021b,$021a,$0219,$0218
!word $023f,$023e,$02ec,$02eb,$02ea,$0311,$0310,$030f,$030e,$030d,$030c,$030b
!word $030a,$0331,$0330,$032f,$0187,$0186,$0185,$0184,$01ab,$01aa,$01a9,$01a7
!word $01a6,$01a5,$01a4,$01a3,$01a2,$01a1,$01c8,$01c7,$01c6,$01c5,$0108,$0107
!word $0106,$0105,$0104,$0103,$012a,$0129,$0128,$0127,$0126,$0125,$0124
CubeFrame_20:
!word $01ce,$01f7,$01f8,$0221,$024a,$0273,$0274,$029d,$0276,$024e,$0227,$0200
!word $01d9,$01b1,$018a,$0189,$0160,$015f,$015e,$0135,$0134,$010b,$010a,$0109
!word $00e0,$00df,$0107,$012f,$0156,$017e,$01a6,$023c,$0265,$028e,$02b7,$02df
!word $0308,$0331,$0309,$02e0,$02b8,$0290,$0267,$023f,$0216,$01ed,$01c4,$019b
!word $0172,$0149,$0120,$0171,$019a,$01c2,$01eb,$0213,$01cd,$01f4,$01f3,$01f2
!word $0219,$0218,$0217,$023d,$029c,$02c3,$02c2,$02c1,$02e8,$02e7,$02e6,$030d
!word $030c,$030b,$0332,$01b0,$01af,$01ae,$01ad,$01d4,$01d3,$01d2,$01d1,$01f6
!word $01f5,$021c,$021b,$021a,$0240,$00de,$00dd,$00dc,$0103,$0102,$0101,$0100
!word $00ff,$00fe,$00fd,$00fc,$0123,$0122,$0121
CubeFrame_21:
!word $01a4,$01a5,$01ce,$01cf,$01f8,$01f9,$0222,$0223,$024c,$024d,$0226,$01ff
!word $01d7,$01b0,$0189,$0188,$015f,$015e,$0135,$0134,$0133,$010a,$0109,$0108
!word $00df,$00de,$00b5,$00b4,$00dc,$0104,$012c,$0154,$017c,$023b,$0264,$0265
!word $028e,$02b7,$02b8,$02e1,$030a,$030b,$0334,$030c,$02e4,$02bc,$0293,$0292
!word $0269,$0268,$023f,$0216,$0215,$01ec,$01c3,$01c2,$0199,$0198,$016f,$01c1
!word $01e9,$0212,$01a3,$01ca,$01c9,$01f0,$01ef,$023c,$0274,$0273,$029a,$02c1
!word $02c0,$02e7,$030e,$030d,$01af,$01d6,$01d5,$01fc,$0249,$0270,$026f,$0296
!word $0295,$00b3,$00da,$00d9,$0100,$00ff,$00fe,$0125,$0124,$0123,$014a,$0149
!word $0170
CubeFrame_22:
!word $017a,$017b,$01a4,$01a5,$01a6,$01cf,$01d0,$01d1,$01d2,$01fb,$01fc,$01d5
!word $01ae,$01af,$0188,$0161,$0160,$0137,$0136,$0135,$0134,$010b,$010a,$0109
!word $0108,$00df,$00de,$00dd,$00dc,$00b3,$00b2,$00b1,$00d9,$0101,$012a,$0152
!word $0263,$0264,$028d,$028e,$028f,$02b8,$02b9,$02e2,$02e3,$02e4,$030d,$030e
!word $02e7,$02e8,$02be,$02bd,$02bc,$0293,$0292,$0291,$0268,$0267,$0266,$023d
!word $023c,$023b,$0212,$0211,$0210,$01e7,$01e6,$020f,$0239,$023a,$01a1,$01c8
!word $01ef,$01ee,$0215,$0223,$024a,$0271,$0299,$02c0,$01d6,$01fd,$0224,$024c
!word $0273,$029a,$02c1,$00d8,$00d7,$00fe,$0125,$014c,$014b,$0172,$0199,$01c0
!word $01bf
CubeFrame_23:
!word $0178,$0179,$017a,$017b,$017c,$017d,$01a6,$01a7,$01a8,$01a9,$01aa,$01ab
!word $0184,$0185,$015e,$015f,$0138,$0137,$0136,$0135,$010c,$010b,$010a,$0109
!word $0108,$0107,$00de,$00dd,$00dc,$00db,$00da,$00d9,$00b0,$00af,$00ae,$00ad
!word $00d6,$00fe,$0127,$014f,$0264,$0265,$0266,$028f,$0290,$0291,$0292,$0293
!word $0294,$02bd,$02be,$02bf,$02c0,$02e9,$02ea,$0313,$0314,$0312,$02e8,$02e7
!word $02e6,$02e5,$02bc,$02bb,$02ba,$02b9,$02b8,$02b7,$028e,$028d,$028c,$028b
!word $028a,$0261,$0260,$025f,$0262,$0263,$019f,$01c7,$01ee,$0215,$023d,$01d3
!word $01fa,$0222,$0249,$0271,$0298,$0160,$0187,$01af,$01d7,$01fe,$0226,$024e
!word $0275,$029d,$02c5,$02ec,$00d4,$00fc,$0123,$014b,$0172,$019a,$01c1,$01e9
!word $0210,$0238
CubeFrame_24:
!word $014e,$014f,$0150,$0151,$0152,$0153,$0154,$0155,$0156,$0157,$0158,$0159
!word $015a,$0133,$0134,$010d,$010e,$010c,$010b,$010a,$0109,$0108,$0107,$0106
!word $0105,$0104,$0103,$0102,$0101,$0100,$00ff,$00fe,$00fd,$00fc,$00fb,$00fa
!word $0123,$0124,$014d,$028e,$028f,$0290,$0291,$0292,$0293,$0294,$0295,$0296
!word $0297,$0298,$0299,$029a,$02c3,$02c4,$02ed,$02ee,$02ec,$02eb,$02ea,$02e9
!word $02e8,$02e7,$02e6,$02e5,$02e4,$02e3,$02e2,$02e1,$02e0,$02df,$02de,$02dd
!word $02dc,$02db,$02da,$02b3,$02b4,$028d,$0176,$019e,$01c6,$01ee,$0216,$023e
!word $0266,$0182,$01aa,$01d2,$01fa,$0222,$024a,$0272,$0136,$015e,$0186,$01ae
!word $01d6,$01fe,$0226,$024e,$0276,$029e,$02c6,$0122,$014a,$0172,$019a,$01c2
!word $01ea,$0212,$023a,$0262,$028a,$02b2
CubeFrame_25:
!word $0174,$0175,$0176,$014f,$0150,$0151,$0152,$0153,$0154,$012d,$012e,$012f
!word $0130,$0109,$010a,$00e3,$00e4,$00e2,$0108,$0107,$0106,$0105,$012c,$012b
!word $012a,$0129,$0128,$0127,$014e,$014d,$014c,$014b,$014a,$0171,$0170,$016f
!word $0172,$0173,$0268,$0269,$026a,$026b,$026c,$026d,$0246,$0247,$0248,$0249
!word $024a,$024b,$0274,$0275,$029e,$029f,$02c8,$02c7,$02c6,$02c5,$02ec,$02eb
!word $02ea,$02e9,$02e8,$02e7,$030e,$030d,$030c,$030b,$030a,$0309,$0330,$032f
!word $032e,$032d,$0306,$02de,$02b7,$028f,$019d,$01c5,$01ee,$0217,$023f,$0158
!word $0181,$01a9,$01d2,$01fa,$0223,$010c,$0135,$015d,$0185,$01ae,$01d6,$01fe
!word $0227,$024f,$0277,$02a0,$0198,$01c0,$01e9,$0211,$023a,$0262,$028b,$02b3
!word $02dc,$0304
CubeFrame_26:
!word $0173,$0174,$014d,$014e,$014f,$0128,$0129,$0102,$0103,$0104,$00dd,$00de
!word $0107,$0108,$012e,$012d,$012c,$0153,$0152,$0151,$0178,$0177,$0176,$019d
!word $019c,$019b,$01c2,$01c1,$01c0,$01e7,$01e6,$01bf,$0199,$019a,$026a,$026b
!word $0244,$0245,$0246,$021f,$0220,$0221,$0222,$01fb,$01fc,$0225,$024e,$024f
!word $0278,$02a1,$02a0,$02c7,$02c6,$02c5,$02c4,$02eb,$02ea,$02e9,$02e8,$030f
!word $030e,$030d,$030c,$0333,$0332,$0331,$0309,$02e1,$02ba,$0292,$01c5,$01ee
!word $01ef,$0218,$0241,$0130,$0159,$0181,$01aa,$01d3,$0131,$015a,$0183,$01ac
!word $01d5,$01fd,$0226,$020f,$0210,$0239,$0262,$028b,$028c,$02b5,$02de,$0307
!word $0308
CubeFrame_27:
!word $019b,$0174,$0175,$014e,$0127,$0128,$0101,$00da,$00db,$00b4,$00dc,$0104
!word $012c,$0153,$0152,$0179,$0178,$019f,$01c6,$01c5,$01ec,$0213,$0212,$0239
!word $0238,$025f,$0211,$01e9,$01c2,$0244,$0245,$021e,$021f,$01f8,$01f9,$01d2
!word $01d3,$01ac,$01ad,$01d6,$01ff,$0227,$0250,$0279,$0278,$029f,$029e,$02c5
!word $02c4,$02c3,$02ea,$02e9,$02e8,$030f,$030e,$0335,$0334,$030c,$02e4,$02bc
!word $0294,$026c,$019c,$01ef,$01f0,$0219,$021a,$0243,$00dd,$00de,$0107,$0130
!word $0131,$015a,$0183,$0184,$0155,$0156,$017f,$0180,$01a9,$01fc,$0225,$0226
!word $024f,$0260,$0289,$028a,$02b3,$02b4,$02b5,$02de,$02df,$02e0,$0309,$030a
!word $0333
CubeFrame_28:
!word $019c,$0175,$014e,$0127,$00ff,$00d8,$00b1,$00d9,$0100,$0128,$0150,$0177
!word $019f,$01c6,$01ed,$0214,$023b,$0262,$0289,$02b0,$0261,$023a,$0212,$01eb
!word $01c3,$021e,$01f7,$01f8,$01d1,$01aa,$0183,$0184,$015d,$0186,$01ae,$01d7
!word $0200,$0229,$0251,$027a,$0279,$02a0,$029f,$029e,$02c5,$02c4,$02eb,$02ea
!word $02e9,$0310,$030f,$02e7,$02bf,$0296,$026e,$0246,$019d,$01c7,$01c8,$01f1
!word $01f2,$01f3,$01f4,$021d,$00b2,$00db,$00dc,$00dd,$0106,$0107,$0108,$0131
!word $0132,$0133,$015c,$01a0,$01c9,$01ca,$01cb,$01cc,$01f5,$01f6,$0221,$0222
!word $0223,$0224,$024d,$024e,$024f,$0250,$02b1,$02b2,$02b3,$02dc,$02dd,$02de
!word $02df,$02e0,$02e1,$02e2,$02e3,$030c,$030d,$030e
CubeFrame_29:
!word $019d,$0175,$014d,$0126,$00fe,$00d6,$00ae,$00fd,$0125,$0174,$019c,$01c4
!word $01eb,$0213,$023b,$0263,$028b,$02b3,$0264,$023c,$0214,$01ec,$01c5,$01f8
!word $01d1,$01aa,$0183,$015b,$0134,$010d,$0135,$015e,$0186,$01af,$01d7,$0200
!word $0228,$0251,$0279,$0278,$029f,$029e,$02c5,$02c4,$02c3,$02ea,$02e9,$02c1
!word $0299,$0270,$0248,$0220,$019e,$019f,$01c8,$01c9,$01ca,$01cb,$01cc,$01cd
!word $01f6,$01f7,$00af,$00b0,$00b1,$00da,$00db,$00dc,$00dd,$00de,$00df,$00e0
!word $00e1,$010a,$010b,$010c,$0215,$0216,$0217,$0218,$0241,$0242,$0243,$0244
!word $0245,$0246,$0247,$0249,$024a,$024b,$0274,$0275,$0276,$0277,$02b4,$02b5
!word $02b6,$02b7,$02b8,$02b9,$02e2,$02e3,$02e4,$02e5,$02e6,$02e7,$02e8
CubeFrame_30:
!word $019e,$0175,$014d,$0124,$00fc,$00d3,$00fb,$0123,$014a,$0172,$019a,$01c2
!word $01ea,$0212,$0239,$0261,$0289,$028a,$02b3,$02b4,$02b5,$028d,$0265,$023d
!word $0216,$01ee,$01c6,$01aa,$0183,$015b,$0134,$010c,$00e5,$010d,$0135,$015e
!word $0186,$01ae,$01d6,$01fe,$0226,$024f,$0277,$029f,$029e,$02c5,$02c4,$02c3
!word $029b,$0273,$024b,$0222,$01fa,$01d2,$019f,$01a0,$01a1,$01a2,$01a3,$01a4
!word $01a5,$01a6,$01a7,$01a8,$01a9,$00d4,$00d5,$00d6,$00d7,$00d8,$00d9,$00da
!word $00db,$00dc,$00dd,$00de,$00df,$00e0,$00e1,$00e2,$00e3,$00e4,$028b,$028c
!word $028e,$028f,$0290,$0291,$0292,$0293,$0294,$0295,$0296,$0297,$0298,$0299
!word $029a,$029c,$029d,$02b6,$02b7,$02b8,$02b9,$02ba,$02bb,$02bc,$02bd,$02be
!word $02bf,$02c0,$02c1,$02c2
CubeFrame_31:
!word $01a0,$0177,$0176,$014d,$0124,$0123,$00fa,$0122,$014a,$0171,$0199,$01c1
!word $01e9,$0211,$0239,$0260,$0288,$02b0,$02b1,$02b2,$02b3,$028c,$028d,$028e
!word $028f,$0290,$0268,$0240,$0218,$01f0,$01c8,$0184,$015c,$0133,$010b,$00e3
!word $015b,$0183,$01ab,$01d4,$01fc,$0224,$024c,$0274,$029c,$02c4,$01ac,$01a1
!word $01a2,$01a3,$01a4,$01a5,$017e,$017f,$0180,$0181,$0182,$00fb,$00fc,$00fd
!word $00fe,$00ff,$0100,$0101,$0102,$00db,$00dc,$00dd,$00de,$00df,$00e0,$00e1
!word $00e2,$02b4,$02b5,$02b6,$02b7,$02b8,$02b9,$02ba,$02bb,$02bc,$02bd,$02be
!word $02bf,$02c0,$02c1,$02c2,$02c3,$0291,$0292,$0293,$0294,$0295,$0296,$0297
!word $0298,$0299,$029a,$029b

!if * > $d000 {
    !error "Cube effect data crosses the $D000 I/O area"
}

* = $7000
LogoAssetDataBegin:
!source "assets/logo-pack/uber_mc_full_320x200.asm"
LogoAssetDataEnd:

!if LogoAssetDataEnd > $9800 {
    !error "Full-logo source overlaps cube effect data at $9800"
}
