
DEF rLCDC = $FF40
DEF rLY   = $FF44
DEF rBGP  = $FF47

DEF VRAM_TILES = $8000
DEF TILE_TAM   = 16 ;; Bytes por tile

DEF LCDC_CONFIG = %10010001 ;; LCD on, tiles en $8000, BG on
DEF BGP_CONFIG  = %11100100 ;; 3=negro, 2=gris oscuro, 1=gris claro, 0=blanco

SECTION "Init", ROM0

init::
    ;; Inicializa la VRAM, la paleta y enciende el LCD
    ;; Usa: a, bc, de, hl
    ;; Parametros entrada: -
    ;; Parametros salida: -
    call .apagar_lcd

    ;; Tile 0 en blanco (es el que se usa para borrar)
    ld hl, VRAM_TILES
    ld bc, TILE_TAM
    ld d, 0
    call .memset

    ;; Casilla 2x2 en los tiles 1..4
    ld hl, Casilla_placeholder
    ld de, VRAM_TILES + TILE_TAM
    ld bc, Casilla_placeholder.fin - Casilla_placeholder
    call .memcpy

    ld a, BGP_CONFIG
    ld [rBGP], a

    ld a, LCDC_CONFIG
    ld [rLCDC], a
    ret

    .apagar_lcd:
        ;; Espera a VBLANK y apaga el LCD
        ;; Usa: a, hl
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld a, [rLY]
        cp 144
        jr c, .apagar_lcd
        ld hl, rLCDC
        res 7, [hl]
        ret

    .memcpy:
        ;; Copia bc bytes de hl a de
        ;; Usa: a, bc, de, hl
        ;; Parametros entrada: hl-origen, de-destino, bc-bytes (>0)
        ;; Parametros salida: -
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .memcpy
        ret

    .memset:
        ;; Rellena bc bytes desde hl con el valor d
        ;; Usa: a, bc, hl
        ;; Parametros entrada: hl-destino, bc-bytes (>0), d-valor
        ;; Parametros salida: -
        ld a, d
        ld [hl+], a
        dec bc
        ld a, b
        or c
        jr nz, .memset
        ret