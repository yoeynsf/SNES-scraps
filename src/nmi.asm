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

    ;JSR HDMA_prep

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
    LDA #3          ; 011 == Write 4 bytes, B0->$21XX, B1->$21XX B2->$21XX+1 B3->$21XX+1
    STA DMAMODE
    LDA CGADDR
    STA DMAPPUREG
    LDA #<hdma_table
    STA DMAADDR
    LDA #>hdma_table
    STA DMAADDRHI
    LDA #^hdma_table
    STA DMAADDRBANK


    LDA #$43          ; indrect, Write 4 bytes -- B0->$21XX, B1->$21XX B2->$21XX+1 B3->$21XX+1
    STA DMAMODE | 1 << 4
    LDA CGADDR
    STA DMAPPUREG | 1 << 4
    LDA #<indirect_hdma_table
    STA DMAADDR | 1 << 4
    LDA #>indirect_hdma_table
    STA DMAADDRHI | 1 << 4
    LDA #^indirect_hdma_table
    STA DMAADDRBANK | 1 << 4

    LDA #^hdma_ram
    STA HDMAINDBANK | 1 << 4

    LDA #3
    STA HDMASTART 

    LDA #$FF
    STA hdma_ram + 2
    LDA #$7F
    STA hdma_ram + 3
        
    LDA #%00000000
    STA hdma_ram + 6
    LDA #%01000011
    STA hdma_ram + 7
    RTS 
.endproc

hdma_table:
    .byte $10
    .byte $00, $00, $FF, $7F
    .byte $04
    .byte $00, $00, $1F, $00
    .byte $04
    .byte $00, $00, $28, $04
    .byte $04
    .byte $00, $00, $40, $48
    .byte $04
    .byte $00, $00, $80, $7C
    .byte $04
    .byte $00, $00, $1F, $00
    .byte $04
    .byte $00, $00, $28, $04
    .byte $04
    .byte $00, $00, $40, $48
    .byte $04
    .byte $00, $00, $80, $7C
    .byte $04
    .byte $00, $00, $FF, $7F
end:
    .byte $00

indirect_hdma_table:
    .byte $4F
    .byte <hdma_ram, >hdma_ram 
    .byte $10
    .byte <hdma_color, >hdma_color
    .byte $10
    .byte <hdma_ram, >hdma_ram 
end2:
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

; welcome to baltimore