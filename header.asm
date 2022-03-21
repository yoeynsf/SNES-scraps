; Definition of the internal header and vectors at $00FFC0-$00FFFF
.include "src/snes.inc"
.include "src/defines.inc"
.smart
.p816


.segment "HEADER"
romname:
    ; The ROM name must be no longer than 21 characters.
    .byte "HDMA_Test            "
map_mode:
    .byte $30                                       ; LoROM, FastROM (120ns)
    .byte $00                                       ; 00: no extra RAM; 02: RAM with battery
    .byte MEMSIZE_256KB                             ; ROM size
    .byte MEMSIZE_NONE                              ; backup RAM size 
    .byte REGION_AMERICA
    .byte $33                                       ; publisher id, or $33 for see 16 bytes before header
    .byte $00                                       ; ROM revision number
    .word $0000                                     ; sum of all bytes will be poked here after linking
    .word $0000                                     ; $FFFF minus above sum will also be poked here
    .res 4                                          ; unused vectors
    .addr cop_handler, brk_handler, abort_handler   ; clcxce mode vectors
    .addr NMI_stub, $FFFF, IRQ_stub                 ; reset unused because reset switches to 6502 mode
    .res 4                                          ; more unused vectors
    ; 6502 mode vectors
    ; brk unused because 6502 mode uses irq handler and pushes the
    ; X flag clear for /IRQ or set for BRK
    .addr ecop_handler, $FFFF, eabort_handler
    .addr enmi_handler, RESET, eirq_handler

  .segment "ZEROPAGE"
framecounter:           .res 1
joy0_status:            .res 2
joy0_held:              .res 2
hdma_ram:               .res 4
hdma_color:             .res 4
currentOAMpos:          .res 2
OAMposAtFrame:          .res 2
temp:                   .res 4
TempX:                  .res 1
TempY:                  .res 1
pointer:                .res 3
SPC_transfer_pointer:   .res 3
SPC_transfer_counter:   .res 1
SPC_transfer_size:      .res 2
sprite_table_flags:     .res 2  ; each bit denotes if a 1K chunk needs to be updated in vblank
cgram_update_flags:     .res 2  ; same as above but for 32 byte CGRAM palettes

.segment "LORAM"
OAM_buf:                .res 512
OAMhi_buf:              .res 32

.segment "HIRAM"
sprite_table0_buf:      .res 8192
sprite_table1_buf:      .res 8192
cgram_buf:              .res 512
  
.segment "BANK0"
    .include "src/vectorstub.asm"
    .include "src/init.asm"
    .include "src/main.asm"
    .include "src/sub.asm"
    .include "src/nmi.asm"
    .include "src/irq.asm"
    .include "src/gfx.asm"
    .include "src/spc_comm.asm"

.segment "BANK1"
DRIVER_SIZE =   (spc_driver_end - spc_driver)

spc_driver:
    .incbin "src/spc/driver.bin"
spc_driver_end:
