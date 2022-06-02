.proc NMI 
    PHA         
    PHX         
    PHY         
    setaxy8  
    bit a:NMISTATUS

    JSR read_controllers
    JSR OAM_DMA

    seta16
    LDA sprite_table_flags
    BEQ :+
    JSR DMA_sprite_graphics
:
    LDA cgram_update_flags
    BEQ :+
    JSR DMA_palettes
:
    setaxy8

    JSR HDMA_prep

    INC framecounter
	PLY       
    PLX
    PLA         
    RTI
.endproc

.proc read_controllers
    setaxy16

    LDY joy0_status     ; save previous frame's inputs
	LDA #$0001  			  ; poll the controller
	STA JOY0
	STZ JOY0 		        ; finish poll 
	LDX #$0010
:	
	LDA JOY0
    LSR
    ROL joy0_status
    DEX
    BNE :-
    
    TYA 
    AND joy0_status       
    STA joy0_held        ; determine held buttons
    setaxy8
    RTS 
.endproc


.proc HDMA_prep
    LDA #2         
    STA DMAMODE
    LDA #<BGSCROLLX
    STA DMAPPUREG
    LDA #<hdma_table
    STA DMAADDR
    LDA #>hdma_table
    STA DMAADDRHI
    LDA #^hdma_table
    STA DMAADDRBANK
    LDA #1
    STA HDMASTART
    RTS 
.endproc

hdma_table:
    .byte 75
    .byte BGOFFSET, $00
    .byte 36
    .byte BGOFFSET - 40, $00
    .byte 15
    .byte BGOFFSET - 24, $00
    .byte 2
    .byte BGOFFSET - 23, $00
    .byte 2
    .byte BGOFFSET - 22, $00
    .byte 2
    .byte BGOFFSET - 21, $00
    .byte 20
    .byte BGOFFSET - 20, $00
    .byte 2
    .byte BGOFFSET + 1, $00
    .byte 2
    .byte BGOFFSET + 2, $00
    .byte 2
    .byte BGOFFSET + 3, $00
    .byte 2
    .byte BGOFFSET + 4, $00
    .byte 2
    .byte BGOFFSET + 5, $00
    .byte 2
    .byte BGOFFSET + 6, $00
    .byte 2
    .byte BGOFFSET + 7, $00
    .byte 2
    .byte BGOFFSET + 8, $00
    .byte 2
    .byte BGOFFSET + 9, $00
    .byte 2
    .byte BGOFFSET + 10, $00
    .byte 2
    .byte BGOFFSET + 11, $00
    .byte 2
    .byte BGOFFSET + 12, $00
    .byte 2
    .byte BGOFFSET + 13, $00
    .byte 2
    .byte BGOFFSET + 14, $00
    .byte 2
    .byte BGOFFSET + 15, $00
    .byte 2
    .byte BGOFFSET + 16, $00
    .byte 2
    .byte BGOFFSET + 17, $00
    .byte 2
    .byte BGOFFSET + 18, $00
    .byte 2
    .byte BGOFFSET + 19, $00
    .byte 2
    .byte BGOFFSET + 20, $00
    .byte 2
    .byte BGOFFSET + 21, $00
    .byte 2
    .byte BGOFFSET + 22, $00
    .byte 2
    .byte BGOFFSET + 23, $00
    .byte 2
    .byte BGOFFSET + 24, $00
    .byte 2
    .byte BGOFFSET + 25, $00
    .byte 2
    .byte BGOFFSET + 26, $00
    .byte 2
    .byte BGOFFSET + 27, $00
    .byte 2
    .byte BGOFFSET + 28, $00
    .byte 2
    .byte BGOFFSET + 29, $00
    .byte 2
    .byte BGOFFSET + 30, $00
    .byte 2
    .byte BGOFFSET + 31, $00
    .byte 2
    .byte BGOFFSET + 32, $00
    .byte 2
    .byte BGOFFSET + 33, $00
    .byte 2
    .byte BGOFFSET + 34, $00
    .byte 2
    .byte BGOFFSET + 35, $00
    .byte 2
    .byte BGOFFSET, $00
end:
    .byte $00


.proc DMA_sprite_graphics  
var_index       =   temp 
var_counter     =   temp + 1

    setaxy8
    LDA #$FF               
    STA var_index
    LDA #16
    STA var_counter 

    CLC
check_bit:
    seta8
    DEC var_counter         ; see if we've checked all the bits  
    BMI done

    INC var_index           ; move the index
    seta16
    LSR sprite_table_flags
    seta8
    BCC check_bit           ; if no bit, retry 

do_dma:
    seta16
    LDY var_index
    LDX spr_table_locations, Y
    TXA 
    XBA 
    CLC 
    ADC #SPRITECHR_BASE
    STA VMADDL

    LDA #$01            
    STA DMAMODE
    LDA #$18
    STA DMAPPUREG

    LDY var_index
    LDX spr_table_locations, Y
    TXA 
    ASL                             ; shift because WRAM is not word addressed like VRAM
    XBA 
    CLC 
    ADC #.loword (sprite_table0_buf)
    STA DMAADDR 
    
    LDA #^sprite_table0_buf
    STA DMAADDRBANK 

    LDA #1024
    STA DMALEN

    LDA #0 | 1 << 0
    STA COPYSTART
    LDA sprite_table_flags
    BNE check_bit
done:
    RTS 
.endproc

.proc DMA_palettes
var_index       =   temp 
var_counter     =   temp + 1

    setaxy8
    LDA #$FF               
    STA var_index
    LDA #16
    STA var_counter 

    CLC
check_bit:
    seta8
    DEC var_counter         ; see if we've checked all the bits  
    BMI done

    INC var_index           ; move the index
    seta16
    LSR cgram_update_flags
    seta8
    BCC check_bit           ; if no bit, retry 

do_dma:
    LDA var_index
    ASL 
    ASL 
    ASL 
    ASL 
    STA CGADDR
       
    STZ DMAMODE
    LDA #$22
    STA DMAPPUREG

    LDY var_index
    seta16
    TYA 
    ASL 
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC #.loword (cgram_buf)
    STA DMAADDR
    LDA #^cgram_buf
    STA DMAADDRBANK

    LDA #32
    STA DMALEN

    LDA #0 | 1 << 0
    STA COPYSTART
    LDA cgram_update_flags
    BNE check_bit
done:
    RTS 
.endproc