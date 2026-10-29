;;==============================================================
;; Sistema de render (componente RENDER)
;; Dibuja en el fondo la casilla 2x2 de cada entidad, en su E_POS
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: render", ROM0

;; Borra toda la pantalla en la vista y dibuja el fondo (los carriles)
;; Requiere LCD apagado
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_render_init::
    ld b, PANTALLA_ALTO
    ld hl, BG_MAP
    ld de, TILEMAP_ANCHO - PANTALLA_ANCHO
    .loop:
        call .borrar_fila_vista
        add hl, de
        dec b
        jr nz, .loop

    ld e, N_CARRILES
    ;; jr .dibujar_carriles     ;; (justo debajo)

    .dibujar_carriles:
        ;; Dibuja carriles de 2 filas: borde de arriba (TILE_CAMINO)
        ;; y borde de abajo (TILE_CAMINO_INV), empezando en FILA_CAMINO
        ;; Usa: a, bc, d, e, hl
        ;; Parametros entrada: e-numero de carriles (>0)
        ;; Parametros salida: -
        ld hl, BG_MAP + FILA_CAMINO * TILEMAP_ANCHO
        .carril:
            ;; Fila de arriba
            ld bc, CAMINO_ANCHO
            ld d, TILE_CAMINO
            call memset
            ld bc, TILEMAP_ANCHO - CAMINO_ANCHO
            add hl, bc

            ;; Fila de abajo
            ld bc, CAMINO_ANCHO
            ld d, TILE_CAMINO_INV
            call memset
            ld bc, TILEMAP_ANCHO - CAMINO_ANCHO
            add hl, bc
            dec e
            jr nz, .carril
        ret

    .borrar_fila_vista:
        ;; Borra la fila seleccionada (dentro de la vista)
        ;; Usa: a, hl
        ;; Parametros entrada: hl-dir de inicio de la fila
        ;; Parametros salida: hl-dir siguiente al ultimo tile borrado
        ld a, 0
        .borrar_tile:
            ld [hl], TILE_VACIO
            inc hl
            inc a
            cp PANTALLA_ANCHO
            jr nz, .borrar_tile
        ret

;;--------------------------------------------------------------
;; CODIGO COMUN
;;--------------------------------------------------------------

;; Primer tile de cada KIND (indice: E_KIND)
TilesKind:
    db TILE_VACIO               ;; 0 (no se usa)
    db TILE_POLLO               ;; KIND_CHICKEN
    db TILE_STRONG              ;; KIND_STRONG

;; Direccion del tilemap de la esquina sup-izq de una casilla
;; Usa: a, bc, hl
;; Parametros entrada: a-posicion %ffffcccc
;; Parametros salida: hl-direccion = BG_MAP + fila * 64 + columna * 2
sys_render_pos_dir::
    ld b, a                     ;; \ C = columna * 2 (tiles)
    and $0F                     ;; |
    add a                       ;; |
    ld c, a                     ;; /
    ld a, b                     ;; \ HL = fila * 16
    and $F0                     ;; |
    ld l, a                     ;; |
    ld h, 0                     ;; /
    add hl, hl                  ;; \ HL = fila * 64 = fila * 2 * TILEMAP_ANCHO
    add hl, hl                  ;; /
    ld b, 0                     ;; \ HL += columna * 2
    add hl, bc                  ;; /
    ld bc, BG_MAP               ;; \ HL += inicio del tilemap
    add hl, bc                  ;; /
    ret

;; Dibuja una casilla 2x2 con 4 tiles consecutivos (sup-izq, sup-der, inf-izq, inf-der)
;; Requiere LCD apagado o estar en VBLANK
;; Usa: a, bc, hl
;; Parametros entrada: hl-dir de la esquina sup-izq, a-primer tile
;; Parametros salida: -
sys_render_casilla::
    ld [hl+], a                 ;; (x,   y)   sup-izq
    inc a
    ld [hl], a                  ;; (x+1, y)   sup-der
    ld bc, TILEMAP_ANCHO - 1
    add hl, bc                  ;; baja una fila y vuelve a la columna x
    inc a
    ld [hl+], a                 ;; (x,   y+1) inf-izq
    inc a
    ld [hl], a                  ;; (x+1, y+1) inf-der
    ret

;; Dibuja el fondo de una casilla de carril (borra lo que hubiera)
;; Requiere LCD apagado o estar en VBLANK
;; Usa: a, bc, hl
;; Parametros entrada: hl-dir de la esquina sup-izq
;; Parametros salida: -
sys_render_fondo::
    ld a, TILE_CAMINO
    ld [hl+], a
    ld [hl], a
    ld bc, TILEMAP_ANCHO - 1
    add hl, bc
    ld a, TILE_CAMINO_INV
    ld [hl+], a
    ld [hl], a
    ret

;; Espera a VBLANK y dibuja: cursor, HUD y TODAS las entidades con RENDER
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_render_update::
    call wait_vblank
    call sys_cursor_update      ;; Ej. 4 (OAM: solo en VBLANK)
    call hud_update             ;; Ej. 6b
    ld hl, sys_render_one
    jp man_entity_for_each

;;--------------------------------------------------------------
;; EJERCICIO 2
;;--------------------------------------------------------------
;; Dibuja UNA entidad con RENDER:
;; 1. Si esta muerta (VIDA = 0): dibuja el fondo en su casilla y la libera.
;; 2. Si se ha movido (ESTADO_MOVIDO): quita la marca y dibuja el fondo en la
;;    casilla de su derecha (de donde viene).
;; 3. Dibuja su casilla con el primer tile de su KIND (tabla TilesKind).
;; Requiere estar en VBLANK
;; Usa: a, bc, de, hl
;; Parametros entrada: de-entidad
;; Parametros salida: -
sys_render_one::
    ;; ◉◉TU CÓDIGO◉◉
    ret
