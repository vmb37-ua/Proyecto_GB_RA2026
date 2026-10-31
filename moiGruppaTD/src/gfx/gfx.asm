;;==============================================================
;; Graficos: tiles del juego y paleta
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"

SECTION "Graphics data", ROM0

;; Casilla 2x2. Se copia a VRAM a partir del tile TILE_CASILLA
Casilla_placeholder:
    db $FF, $FF, $E0, $E0, $C0, $C0, $C0, $C0, $80, $80, $80, $80, $80, $80, $80, $80 ; tile 1 (sup-izq)
    db $FF, $FF, $07, $07, $03, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01 ; tile 2 (sup-der)
    db $80, $80, $80, $80, $80, $80, $80, $80, $C0, $C0, $C0, $C0, $E0, $E0, $FF, $FF ; tile 3 (inf-izq)
    db $01, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03, $03, $07, $07, $FF, $FF ; tile 4 (inf-der)
.fin:

Tile_camino:
    db $55, $FF, $99, $F7, $55, $AA, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $66, $00 ; tile 5
.fin:

Tile_camino_inv:
    db $66, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $55, $AA, $99, $F7, $55, $FF ; tile 6
.fin:

Tiles_pollo:
    db $57, $FF, $9F, $F8, $50, $BF, $F0, $10, $E2, $22, $F0, $40, $8C, $F4, $7C, $78 ; tile 7 (sup-izq)
    db $D5, $FF, $59, $F7, $D5, $EA, $FF, $86, $F9, $69, $31, $51, $21, $41, $8D, $11 ; tile 8 (sup-der)
    db $67, $3C, $FA, $26, $FC, $44, $D4, $6C, $E6, $3C, $5F, $B8, $99, $FF, $57, $FF ; tile 9 (inf-izq)
    db $03, $2D, $13, $02, $6B, $02, $97, $02, $6F, $04, $ED, $1A, $C9, $FF, $75, $FF ; tile 10 (inf-der)
.fin:

Tiles_strong:
    db $07, $07, $08, $0F, $08, $0A, $08, $0E, $3C, $33, $43, $40, $94, $80, $A0, $90 ; tile 11 (sup-izq)
    db $8C, $8C, $52, $DE, $53, $5F, $6F, $6D, $7D, $99, $95, $15, $33, $01, $1A, $06 ; tile 12 (sup-der)
    db $92, $B1, $FD, $92, $4B, $7C, $78, $7F, $09, $0E, $09, $08, $0F, $08, $0F, $0F ; tile 13 (inf-izq)
    db $56, $8E, $A8, $58, $D8, $38, $30, $F0, $A6, $66, $29, $AF, $69, $AF, $E6, $E6 ; tile 14 (inf-der)
.fin:

Tile_cursor:
    db $F0, $F0, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00 ; tile 15 (esquina sup-izq)
.fin:

Tiles_numeros:
    db $3C, $3C, $42, $42, $46, $46, $4A, $4A, $52, $52, $62, $62, $42, $42, $3C, $3C ; tile 16 (0)
    db $08, $08, $18, $18, $28, $28, $48, $48, $08, $08, $08, $08, $08, $08, $7E, $7E ; tile 17 (1)
    db $3C, $3C, $42, $42, $02, $02, $02, $02, $0C, $0C, $10, $10, $20, $20, $7E, $7E ; tile 18 (2)
    db $3C, $3C, $42, $42, $02, $02, $1C, $1C, $02, $02, $02, $02, $42, $42, $3C, $3C ; tile 19 (3)
    db $0E, $0E, $14, $14, $24, $24, $44, $44, $7E, $7E, $04, $04, $04, $04, $0E, $0E ; tile 20 (4)
    db $7E, $7E, $40, $40, $40, $40, $3C, $3C, $02, $02, $02, $02, $42, $42, $3C, $3C ; tile 21 (5)
    db $3C, $3C, $42, $42, $40, $40, $7C, $7C, $42, $42, $42, $42, $42, $42, $3C, $3C ; tile 22 (6)
    db $7E, $7E, $02, $02, $02, $02, $04, $04, $08, $08, $10, $10, $10, $10, $10, $10 ; tile 23 (7)
    db $3C, $3C, $42, $42, $42, $42, $3C, $3C, $42, $42, $42, $42, $42, $42, $3C, $3C ; tile 24 (8)
    db $3C, $3C, $42, $42, $42, $42, $42, $42, $3E, $3E, $02, $02, $42, $42, $3C, $3C ; tile 25 (9)
.fin:

SECTION "Engine: graphics", ROM0

;; Carga los tiles en VRAM y la paleta
;; Requiere LCD apagado
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
gfx_init::
    ;; Tile 0 en blanco (es el que se usa para borrar)
    ld hl, VRAM_TILES + TILE_VACIO * TILE_TAM
    ld bc, TILE_TAM
    ld d, 0
    call memset

    ;; Casilla 2x2 en los tiles 1..4
    ld hl, Casilla_placeholder
    ld de, VRAM_TILES + TILE_CASILLA * TILE_TAM
    ld bc, Casilla_placeholder.fin - Casilla_placeholder
    call memcpy

    ;; Define camino tile 5
    ld hl, Tile_camino
    ld de, VRAM_TILES + TILE_CAMINO * TILE_TAM
    ld bc, Tile_camino.fin - Tile_camino
    call memcpy

    ;; Define camino_inv tile 6
    ld hl, Tile_camino_inv
    ld de, VRAM_TILES + TILE_CAMINO_INV * TILE_TAM
    ld bc, Tile_camino_inv.fin - Tile_camino_inv
    call memcpy

    ;; Pollo 2x2
    ld hl, Tiles_pollo
    ld de, VRAM_TILES+TILE_POLLO*TILE_TAM
    ld bc, Tiles_pollo.fin-Tiles_pollo
    call memcpy

    ;; Strongman 2x2
    ld hl, Tiles_strong
    ld de, VRAM_TILES+TILE_STRONG*TILE_TAM
    ld bc, Tiles_strong.fin-Tiles_strong
    call memcpy

    ld hl, Tile_cursor
    ld de, VRAM_TILES+TILE_CURSOR*TILE_TAM
    ld bc, Tile_cursor.fin-Tile_cursor
    call memcpy

    ;; Cifras del 0 al 9
    ld hl, Tiles_numeros
    ld de, VRAM_TILES+TILE_NUM_0*TILE_TAM
    ld bc, Tiles_numeros.fin-Tiles_numeros
    call memcpy

    ld a, BGP_CONFIG
    ld [rBGP], a
    ld a, OBP0_CONFIG
    ld [rOBP0], a
    ret
