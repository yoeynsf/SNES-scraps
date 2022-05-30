JOY_SIGNATURE   = 4 << 0
KEY_R           = 1 << 4
KEY_L           = 1 << 5
KEY_X           = 1 << 6
KEY_A           = 1 << 7
KEY_RIGHT       = 1 << 8
KEY_LEFT        = 1 << 9
KEY_DOWN        = 1 << 10
KEY_UP          = 1 << 11
KEY_START       = 1 << 12
KEY_SELECT      = 1 << 13
KEY_Y           = 1 << 14
KEY_B           = 1 << 15

SPRITECHR_BASE  = $0000

SPR_CHR_SLOT0       = $00
SPR_CHR_SLOT1       = $02
SPR_CHR_SLOT3       = $04
SPR_CHR_SLOT4       = $06
SPR_CHR_SLOT5       = $08
SPR_CHR_SLOT6       = $0A
SPR_CHR_SLOT7       = $0C
SPR_CHR_SLOT8       = $0E
SPR_CHR_SLOT9       = $10
SPR_CHR_SLOT10      = $12
SPR_CHR_SLOT11      = $14
SPR_CHR_SLOT12      = $16
SPR_CHR_SLOT13      = $18
SPR_CHR_SLOT14      = $1A
SPR_CHR_SLOT15      = $1C
SPR_CHR_SLOT16      = $1E

.macro LDPT addr
    LDA #<addr
    STA pointer 
    LDA #>addr
    STA pointer + 1
    LDA #^addr
    STA pointer + 2
.endmacro
