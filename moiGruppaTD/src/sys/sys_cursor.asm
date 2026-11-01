;;==============================================================
;; Sistema del cursor: el menu de compra y el cursor (sprites)
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: cursor", ROM0

;;--------------------------------------------------------------
;; EJERCICIO 3
;;--------------------------------------------------------------
;; Deja la OAM sin sprites (toda a 0) y dibuja el menu de compra:
;; un strongman (TILE_STRONG) en cada hueco, casillas (FILA_MENU, 0..MENU_SLOTS-1)
;; Requiere LCD apagado
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_cursor_init::
    ;; OAM a 0: un sprite con Y = 0 no se ve
    ld hl, OAM_RAM
    ld bc, OAM_TAM
    ld d, 0
    call memset
 
    ;; E = posicion del hueco actual (%ffffcccc)
    ld e, FILA_MENU << 4
    .bucle:
    ld a, e
    call sys_render_pos_dir         ;; HL = direccion del tilemap (no toca DE)
    ld a, TILE_STRONG
    call sys_render_casilla         ;; dibuja el strongman 2x2 (no toca DE)
    inc e                           ;; siguiente hueco (columna + 1)
    ld a, e
    cp (FILA_MENU << 4) | MENU_SLOTS
    jr nz, .bucle

    ret

;;--------------------------------------------------------------
;; EJERCICIO 4
;;--------------------------------------------------------------
;; Coloca el cursor (sprites 0..3 de la OAM) en las 4 esquinas de su casilla:
;;   Tablero (wCursorState = 0): fila FILA_CARRIL0 + wCursorRow, columna wCursorCol
;;   Menu    (wCursorState = 1): fila FILA_MENU, columna wMenuSlot
;; Esquina   Y      X      TILE         ATTR
;; sup-izq   y      x      TILE_CURSOR  0
;; sup-der   y      x+8    TILE_CURSOR  ATTR_XFLIP
;; inf-izq   y+8    x      TILE_CURSOR  ATTR_YFLIP
;; inf-der   y+8    x+8    TILE_CURSOR  ATTR_XFLIP | ATTR_YFLIP
;; con y = fila * 16 + OAM_Y_OFFSET, x = columna * 16 + OAM_X_OFFSET
;; Requiere estar en VBLANK
;; Usa: a, bc, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_cursor_update::
    ;; B = fila, C = columna (de casilla)
    ld a, [wCursorState]
    or a
    jr nz, .menu
 
    ld a, [wCursorRow]              ;; Tablero
    add FILA_CARRIL0
    ld b, a
    ld a, [wCursorCol]
    ld c, a
    jr .coordenadas
 
.menu:
    ld b, FILA_MENU                 ;; Menu
    ld a, [wMenuSlot]
    ld c, a
 
.coordenadas:
    ld a, b                         ;; B = y = fila * 16 + OAM_Y_OFFSET
    swap a
    add OAM_Y_OFFSET
    ld b, a
    ld a, c                         ;; C = x = columna * 16 + OAM_X_OFFSET
    swap a
    add OAM_X_OFFSET
    ld c, a
 
    ld hl, OAM_RAM
 
    ;; Sprite 0: sup-izq (y, x)
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ld a, TILE_CURSOR
    ld [hl+], a
    xor a
    ld [hl+], a
 
    ;; Sprite 1: sup-der (y, x+8)
    ld a, b
    ld [hl+], a
    ld a, c
    add 8
    ld [hl+], a
    ld a, TILE_CURSOR
    ld [hl+], a
    ld a, ATTR_XFLIP
    ld [hl+], a
 
    ;; Sprite 2: inf-izq (y+8, x)
    ld a, b
    add 8
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ld a, TILE_CURSOR
    ld [hl+], a
    ld a, ATTR_YFLIP
    ld [hl+], a
 
    ;; Sprite 3: inf-der (y+8, x+8)
    ld a, b
    add 8
    ld [hl+], a
    ld a, c
    add 8
    ld [hl+], a
    ld a, TILE_CURSOR
    ld [hl+], a
    ld a, ATTR_XFLIP | ATTR_YFLIP
    ld [hl+], a

    ret
