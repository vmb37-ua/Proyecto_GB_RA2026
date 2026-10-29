;;==============================================================
;; Sistema de movimiento (componente MOVE)
;; Mueve los pollos hacia la izquierda por su carril
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: movement", ROM0

;;--------------------------------------------------------------
;; EJERCICIO 8 (a)
;;--------------------------------------------------------------
;; Mueve UNA entidad con MOVE una casilla a la izquierda:
;; - Si esta en la columna 0: ha llegado a la casa -> wGameState = GAME_PERDIDO
;; - Si la casilla de su izquierda esta ocupada, no se mueve (sys_combat se encarga)
;; - Si no: POS - 1 y marca ESTADO_MOVIDO (sys_render borrara la casilla vieja)
;; Usa: a, bc, de, hl
;; Parametros entrada: de-entidad
;; Parametros salida: -
sys_movement_one::
    ;; ◉◉TU CÓDIGO◉◉
    ret

;; EJERCICIO 8 (b): mueve todas las entidades con MOVE, pero solo 1 de cada 64 frames
;; (cuando frame_counter AND MOVE_MASK = 0)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_movement_update::
    ;; ◉◉TU CÓDIGO◉◉
    ret
