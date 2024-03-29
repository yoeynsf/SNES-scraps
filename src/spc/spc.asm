.setcpu "none"
.include "spc-65c02.inc"
.include "spc_defines.inc" 

.segment "SPCZEROPAGE"    
temp:               .res 1
SPC_control_buf:    .res 1

.segment "SPCBSS"


;--------------------------------------

.segment "SPCDRIVER"
spc_entrypoint:
    
    jsr driver_init
wait_tick:
    jmp wait_tick 

;--------------------------------------

.proc driver_init    

    ldy #0      ; zero out DSP regs
:
    stx DSPADDR  
    sty DSPDATA 
    inx 
    bpl :-

    lda SPC_control_buf
    eor #$80
    sta CONTROL

    rts 
.endproc