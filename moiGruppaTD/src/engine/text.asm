INCLUDE "game.inc"
SECTION "Engine: text", ROM0
;; DE=cadena ASCII (mayusculas, cifras, espacios), HL=destino en RAM.
;; Texto terminado en 0. Destruye A,DE,HL; conserva BC.
text_draw::
    ld a, [de]
    inc de
    and a
    ret z
    cp " "
    jr z, .space
    cp "A"
    jr nc, .letter
    sub "0"
    add TILE_FONT
    jr .write
.letter
    sub "A"
    add TILE_FONT + 10
    jr .write
.space
    xor a
.write
    ld [hl+], a
    jr text_draw
;; A=0..99, HL=destino RAM. Dos digitos. Destruye A,B.
text_number::
    cp 100
    jr c, .valid
    ld a, 99
.valid
    ld b, 0
.tens
    cp 10
    jr c, .write
    sub 10
    inc b
    jr .tens
.write
    add TILE_FONT
    push af
    ld a, b
    add TILE_FONT
    ld [hl+], a
    pop af
    ld [hl+], a
    ret
