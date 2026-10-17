DEF PANTALLA_INI = $9800
DEF PANTALLA_FIN = $9A33

DEF PANTALLA_ANCHO = 20 ;; Tiles visibles por fila
DEF PANTALLA_ALTO  = 18 ;; Filas visibles
DEF TILEMAP_ANCHO  = 32 ;; Tiles por fila en el tilemap

DEF VBLANK_DIR = $FF44

;; Indices en VRAM de los tiles de la casilla (cargados en init)
DEF TILE_VACIO     = 0
DEF TILE_CASILLA   = 1 ;; 1 sup-izq, 2 sup-der, 3 inf-izq, 4 inf-der

SECTION "Tiles", ROM0

;; Casilla 2x2. Se copia a VRAM a partir del tile TILE_CASILLA
Casilla_placeholder::
    db $FF, $FF, $E0, $E0, $C0, $C0, $C0, $C0, $80, $80, $80, $80, $80, $80, $80, $80 ; tile 1 (sup-izq)
    db $FF, $FF, $07, $07, $03, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01 ; tile 2 (sup-der)
    db $80, $80, $80, $80, $80, $80, $80, $80, $C0, $C0, $C0, $C0, $E0, $E0, $FF, $FF ; tile 3 (inf-izq)
    db $01, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03, $03, $07, $07, $FF, $FF ; tile 4 (inf-der)
.fin::

Tile_camino::
    db $55, $FF, $99, $F7, $55, $AA, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $66, $00 ; tile 5
.fin::

Tile_camino_inv::
    db $66, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $55, $AA, $99, $F7, $55, $FF ; tile 6
.fin::

SECTION "Render", ROM0

render::
    call .borrar_pantalla_vista

    ;; Ejemplo: dos casillas (ambas caben en el mismo VBLANK)
    call .esperar_vblank
    ld hl, PANTALLA_INI + 2 * TILEMAP_ANCHO + 4    ; columna 4, fila 2
    call .dibujar_casilla
    ld hl, PANTALLA_INI + 6 * TILEMAP_ANCHO + 10   ; columna 10, fila 6
    call .dibujar_casilla
    ret

    .esperar_vblank:
        ;; Espera hasta VBLANK
        ;; Usa: a
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld a, [VBLANK_DIR]
        cp 144
        jr nz, .esperar_vblank
        ret

    .borrar_fila_vista:
        ;; Borra la fila seleccionada (dentro de la vista)
        ;; Usa: a, hl
        ;; Parametros entrada: hl-dir de inicio de la fila
        ;; Parametros salida: hl-dir siguiente al ultimo tile borrado
        call .esperar_vblank
        ld a, 0
        .borrar_tile:
            ld [hl], TILE_VACIO
            inc hl
            inc a
            cp PANTALLA_ANCHO
            jr nz, .borrar_tile
        ret

    .borrar_pantalla_vista:
        ;; Borra toda pantalla en la vista
        ;; Usa: b, hl, de, a
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld b, PANTALLA_ALTO
        ld hl, PANTALLA_INI
        ld de, TILEMAP_ANCHO - PANTALLA_ANCHO
        .loop:
            call .borrar_fila_vista
            add hl, de
            dec b
            jr nz, .loop
        ret

    .dibujar_casilla:
        ;; Dibuja una casilla 2x2 (tiles TILE_CASILLA..TILE_CASILLA+3)
        ;; Requiere LCD apagado o estar en VBLANK
        ;; Usa: a, de, hl
        ;; Parametros entrada: hl-dir del tilemap de la esquina superior izquierda
        ;; Parametros salida: -
        ld a, TILE_CASILLA
        ld [hl+], a                 ; (x,   y)   sup-izq
        inc a
        ld [hl], a                  ; (x+1, y)   sup-der
        ld de, TILEMAP_ANCHO - 1
        add hl, de                  ; baja una fila y vuelve a la columna x
        inc a
        ld [hl+], a                 ; (x,   y+1) inf-izq
        inc a
        ld [hl], a                  ; (x+1, y+1) inf-der
        ret
