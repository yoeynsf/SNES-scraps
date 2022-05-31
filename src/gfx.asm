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

spr_nami:
    .byte $00, $00, $00, $00
    .byte $08, $00, $01, $00
    .byte $00, $08, $02, $00
    .byte $08, $08, $03, $00
    .byte $00, $10, $04, $00
    .byte $08, $10, $05, $00
    .byte $00, $18, $06, $00
    .byte $08, $18, $07, $00
    .byte $80