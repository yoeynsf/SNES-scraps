chr_table_lo:
    .byte <chr_0, <chr_1, <chr_2, <chr_3
chr_table_mid:
    .byte >chr_0, >chr_1, >chr_2, >chr_3
chr_table_hi:
    .byte ^chr_0, ^chr_1, ^chr_2, ^chr_3

pal_table_lo:
    .byte <pal_0, <pal_1, <pal_2, <pal_3
pal_table_mid:
    .byte >pal_0, >pal_1, >pal_2, >pal_3
pal_table_hi:
    .byte ^pal_0, ^pal_1, ^pal_2, ^pal_3

; sprite CHRs (1K) - palettes
chr_0:
  .incbin "output/chr/chr0.chr"
chr_1:
  .incbin "output/chr/chr1.chr"
chr_2:
  .incbin "output/chr/chr2.chr"
chr_3:
  .incbin "output/chr/chr3.chr"

pal_0:
  .incbin "output/pal/chr0.pal"
pal_1:
  .incbin "output/pal/chr1.pal"
pal_2:
  .incbin "output/pal/chr2.pal"
pal_3:
  .incbin "output/pal/chr3.pal"

; BG CHRs (8K) - palettes - maps (2K)
bgchr_0:
    .incbin "output/chr/bgchr0.chr"
bgpal_0:
    .incbin "output/pal/bgchr0.pal"
bgmap_0:
    .incbin "output/map/bg0.map"



spr_owen:
    .byte 0, 0, $00, $00
    .byte 4, 10, $02, $00
    .byte 20, 4, $04, $00
    .byte 36, 4, $06, $00
    .byte 52, 4, $08, $00
    .byte 20, 20, $0A, $00
    .byte 36, 20, $0C, $00
    .byte 52, 20, $0E, $00
    .byte 15, 36, $20, $00
    .byte 31, 36, $22, $00
    .byte 47, 36, $24, $00
    .byte 15, 52, $26, $00
    .byte 31, 52, $28, $00
    .byte 47, 52, $2A, $00
    .byte 15, 68, $2C, $00
    .byte 31, 68, $2E, $00
    .byte 47, 68, $40, $00
    .byte 15, 84, $42, $00
    .byte 31, 84, $44, $00
    .byte 47, 84, $46, $00
    .byte 15, 100, $48, $00
    .byte 31, 100, $4A, $00
    .byte 47, 100, $4C, $00
    .byte $80