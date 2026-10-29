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

    ld a, BGP_CONFIG
    ld [rBGP], a
    ret
