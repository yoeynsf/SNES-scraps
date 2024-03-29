.proc spc_boot
    seta8
    setxy16
:                   ; wait for SPC to boot
    LDA APU0    
    CMP #$AA
    BNE :-
:
    LDA APU1
    CMP #$BB
    BNE :-

    LDA #$FF        ; write a nonzero to initiate transfer
    STA APU1          
    
    STZ APU2        ; set transfer address to $0300
    LDA #$03
    STA APU3

    LDA #$CC        ; IPL bootrom expects $CC
    STA APU0
:                   ; wait for SPC to mimic it
    CMP APU0 
    BNE :-

; We are ready to transfer the driver

    LDX #0
    STZ SPC_transfer_counter
transfer_driver:
    LDA f:spc_driver, X
    STA APU1

    LDA SPC_transfer_counter
    STA APU0        

:
    CMP APU0
    BNE :-
    INA 
    STA SPC_transfer_counter
    INX 
    CPX #DRIVER_SIZE
    BNE transfer_driver

; transfer is finished, execute program
 
    LDA #$03    ; write entry point address
    STZ APU2
    STA APU3

    LDA SPC_transfer_counter    ; completed
    INA
    INA 
    STA APU0

    setxy8
    RTS 
.endproc 
