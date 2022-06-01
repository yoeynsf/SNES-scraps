.proc mainprep
    setaxy8

    JML clearRAM
clear_done:
    setaxy8

    JSR spc_boot

    LDPT chr_0
    LDX #0
    JSR load_WRAM_sprite_table

    LDPT chr_1
    LDX #1
    JSR load_WRAM_sprite_table

    LDPT chr_2
    LDX #2
    JSR load_WRAM_sprite_table

    LDPT pal_0
    LDX #8
    JSR load_WRAM_CGRAM

    LDPT bgchr_0
    LDX #0 
    JSR load_BGCHR

    LDPT bgmap_0
    LDX #0 
    JSR load_BGMAP

    LDPT bgpal_0
    LDX #0
    JSR load_WRAM_CGRAM

    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_16_32
    STA OBSEL 

:                       ; spin until vblank is over because the transfers
    BIT HVBJOY 
    BMI :-
    
    LDA #1
    STA BGMODE

    LDA #((BG0MAP_BASE >> 10) << 2) | 1
    STA BG1SC
    LDA #(BG1MAP_BASE >> 10) << 2
    STA BG2SC
    LDA #(BG2MAP_BASE >> 10) << 2
    STA BG3SC

    LDA #(BG1CHR_BASE >> 8 | BG0CHR_BASE >> 12)
    STA BG12NBA
    LDA #(BG2CHR_BASE >> 12)
    STA BG34NBA

    LDA #%00010111
    STA TM
    LDA #$0F
    STA PPUBRIGHT     ; $2100, turn the screen ON
    LDA #%10000000
    STA PPUNMI        ; $4200, enable NMI at VBlank
    JMP main 
.endproc     

.proc main
    setaxy8
    LDA #$00
    TAX 
    TAY 
    JSR sprite_prep

    LDPT spr_owen
    LDA #32
    STA TempX
    LDA #96
    STA TempY
    JSR load_sprites
 

    JSR clear_sprites

    LDA framecounter
WaitVBlank:
    CMP framecounter
    BEQ WaitVBlank    ; This exists so our loop runs only once per frame.
    JMP main
.endproc


