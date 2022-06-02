null:
    .byte $00

.proc clearRAM
  setaxy16  
clear_CGRAM:
    LDA #$08          ; fixed source DMA to PPU, bytes
    STA DMAMODE
    LDA #$22
    STA DMAPPUREG
    LDA #<null
    STA DMAADDR 
    LDA #>null 
    STA DMAADDRHI
    LDA #^null 
    STA DMAADDRBANK 
    LDA #512
    STA DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART

clear_VRAM:
    STZ VMADDL
    STZ VMADDH

    LDA #$09          ; fixed source DMA to PPU, words
    STA DMAMODE
    LDA #$18
    STA DMAPPUREG
    LDA #<null
    STA DMAADDR 
    LDA #>null 
    STA DMAADDRHI
    LDA #^null 
    STA DMAADDRBANK 
    STZ DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART

    clear_WRAM:         ; fixed source DMA to WRAM, bytes
    STZ WMADDL
    STZ WMADDM
    STZ WMADDH


    LDA #$08     
    STA DMAMODE
    LDA #$80
    STA DMAPPUREG
    LDA #<null
    STA DMAADDR 
    LDA #>null 
    STA DMAADDRHI
    LDA #^null 
    STA DMAADDRBANK 
    STZ DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART

    LDA #0 | 1 << 0   ; run again to clear the upper half of the 128K 
    STA COPYSTART

; we clobbered the stack and I don't feel like putting this routine somewhere better
    LDX #LAST_STACK_ADDR  
    TXS
    JML mainprep::clear_done
    
.endproc 

.proc OAM_DMA
    setaxy16
    LDA #$00            
    STA DMAMODE
    LDA #$04
    STA DMAPPUREG
    LDA #<OAM_buf
    STA DMAADDR 
    LDA #>OAM_buf
    STA DMAADDRHI
    LDA #^OAM_buf 
    STA DMAADDRBANK 
    LDA #544            ; 544
    STA DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART
    setaxy8
    RTS 
.endproc 

bgchr_table:
    .word BG0CHR_BASE, BG1CHR_BASE, BG2CHR_BASE

.proc load_BGCHR
    TXA 
    ASL 
    TAX 
    LDA bgchr_table, X 
    STA VMADDL
    INX 
    LDA bgchr_table, X 
    STA VMADDH

    LDA #$01         
    STA DMAMODE
    LDA #$18
    STA DMAPPUREG
    LDA pointer
    STA DMAADDR 
    LDA pointer + 1
    STA DMAADDRHI
    LDA pointer + 2
    STA DMAADDRBANK
    seta16
    LDA #8192 
    STA DMALEN
    setaxy8
    LDA #0 | 1 << 0
    STA COPYSTART
    RTS
.endproc

bgmap_table:
    .word BG0MAP_BASE, BG0MAP2_BASE, BG1MAP_BASE, BG2MAP_BASE

.proc load_BGMAP
    TXA 
    ASL 
    TAX 
    LDA bgmap_table, X 
    STA VMADDL
    INX 
    LDA bgmap_table, X 
    STA VMADDH

    LDA #$01         
    STA DMAMODE
    LDA #$18
    STA DMAPPUREG
    LDA pointer
    STA DMAADDR 
    LDA pointer + 1
    STA DMAADDRHI
    LDA pointer + 2
    STA DMAADDRBANK
    seta16
    LDA #2048 
    STA DMALEN
    setaxy8
    LDA #0 | 1 << 0
    STA COPYSTART
    RTS
.endproc 


.proc sprite_prep
    setaxy16
	LDA OAMposAtFrame
    CLC 
    ADC #32
    CMP #512
    BCC :+
    AND #$FF
:
    STA currentOAMpos
    STA OAMposAtFrame
    setaxy8 
	RTS
.endproc

.proc load_sprites
    seta8
    setxy16
    LDY #0
    LDX currentOAMpos       ;We're about to render a sprite so get the next free one.
:
	LDA (pointer), Y        ; X position
    CMP #$80
    BEQ donesprite
    CLC
    ADC TempX
    STA OAM_buf, X
    INY
    INX
    LDA (pointer), Y        ; Y position
    CLC
    ADC TempY
    STA OAM_buf, X
    INY
    INX
    LDA (pointer), Y        ; tile index
    STA OAM_buf, X
    INY
    INX
    LDA (pointer), Y        ; attribute
    STA OAM_buf, X
    INY
    INX
    CPX #512
    BNE :-
    LDX #0
    JMP :-
    donesprite:
    CPX #512
    BNE :+
    LDX #0
:
    STX currentOAMpos
    setaxy8
	RTS
.endproc

.proc clear_sprites
    setaxy16
    LDX currentOAMpos
    INX
    LDA #$F0
    INC OAMposAtFrame
Clear:
    STA OAM_buf, X
    INX
    INX
    INX
    INX
    CPX #512
    BCC :+
    TXA 
    AND #$0F
    TAX 
    LDA #$F0
:
    CPX OAMposAtFrame
    BNE Clear
    DEC OAMposAtFrame
    setaxy8
    RTS
.endproc

;-------------;
; $00  | $02  |
;-------------;
; $04  | $06  |
;-------------;
; $08  | $0A  |
;-------------;
; $0C  | $0E  |
;-------------;
; $10  | $12  |
;-------------;
; $14  | $16  |
;-------------;
; $18  | $1A  |
;-------------;
; $1C  | $1E  |
;-------------;

spr_table_locations:
    .byte $00, $02, $04, $06, $08, $0A, $0C, $0E
    .byte $10, $12, $14, $16, $18, $1A, $1C, $1E

update_flag_values:
    .word $0001, $0002, $0004, $0008, $0010, $0020, $0040, $0080
    .word $0100, $0200, $0400, $0800, $1000, $2000, $4000, $8000 

.proc load_WRAM_sprite_table    ; target is in X 
    STX temp 
    LDA spr_table_locations, X
    ASL  
    seta16 
    XBA                         ; swap high and low bytes 
    CLC 
    ADC #.loword (sprite_table0_buf)
    STA WMADDL
    LDA #^sprite_table0_buf
    STA WMADDH

    LDA #$00 
    STA DMAMODE
    LDA #$80
    STA DMAPPUREG
    LDA pointer 
    STA DMAADDR 
    LDA pointer + 2 
    STA DMAADDRBANK 
    LDA #1024
    STA DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART

    ASL temp 
    LDX temp 
    LDA update_flag_values, X 
    ORA sprite_table_flags
    STA sprite_table_flags
    setaxy8
    RTS 
.endproc

.proc load_WRAM_CGRAM   ; X = palette # in 32 byte chunks
    seta16
    STX temp 
    TXA
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #.loword (cgram_buf)
    STA WMADDL
    LDA #^cgram_buf
    STA WMADDH

    LDA #$00 
    STA DMAMODE
    LDA #$80
    STA DMAPPUREG
    LDA pointer 
    STA DMAADDR 
    LDA pointer + 2 
    STA DMAADDRBANK 
    LDA #32
    STA DMALEN
    LDA #0 | 1 << 0
    STA COPYSTART

    ASL temp 
    LDX temp 
    LDA update_flag_values, X 
    ORA cgram_update_flags
    STA cgram_update_flags
    setaxy8
    RTS 
.endproc