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
    ;; ◉◉TU CÓDIGO◉◉
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
    ;; ◉◉TU CÓDIGO◉◉
    ret
