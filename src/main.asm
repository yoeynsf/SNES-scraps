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

    LDPT chr_3
    LDX #3
    JSR load_WRAM_sprite_table

    LDPT pal_0
    LDX #8
    JSR load_WRAM_CGRAM

    LDPT pal_1
    LDX #9
    JSR load_WRAM_CGRAM

    LDPT pal_2
    LDX #10
    JSR load_WRAM_CGRAM

    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_8_16
    STA OBSEL 

:                       ; spin until vblank is over because the transfers
    BIT HVBJOY 
    BMI :-
    
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

 

    JSR clear_sprites

    LDA framecounter
WaitVBlank:
    CMP framecounter
    BEQ WaitVBlank    ; This exists so our loop runs only once per frame.
    JMP main
.endproc
