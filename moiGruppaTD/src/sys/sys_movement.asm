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
    ;; Verificamos si la entidad se puede mover, tiene CMP_MOVE
    ld a, [de]              ; A = E_CMP
    and CMP_MOVE
    ret z

    ;; Optenemos E_POS (solo tenemos que sumarle al bit bajo)
    ld a, e
    add E_POS
    ld l, a
    ld h, d
    ld a, [hl]

    ;; Comprobamos si esta en la columna 0
    and $0F
    jr z, .gym

    ;; Calcular casilla de la izquierda (POS - 1, porque es (fila/columna))
    ld a, [hl]
    dec a
    ld b, a                 ; B = casilla izquierda

    call game_entidad_en
    ret z                   ; Si Z, la casilla esta ocupada, por lo que no se mueve

    ;; Si la casilla esta libre
    ld a, e
    add E_POS
    ld l, a
    ld h, d
    ld [hl], b              ; E_POS = POS - 1

    ;; Marcar ESTADO_MOVIDO en E_ESTADO
    ld a, e
    add E_ESTADO
    ld l, a
    ld h, d
    ;;or %10000000
    ;;ld [hl], a
    set ESTADO_MOVIDO_BIT, [hl]
    ret

.gym:
    ld a, GAME_PERDIDO
    ld [wGameState], a
    ret

;; EJERCICIO 8 (b): mueve todas las entidades con MOVE, pero solo 1 de cada 64 frames
;; (cuando frame_counter AND MOVE_MASK = 0)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_movement_update::
    ld a, [frame_counter]
        and MOVE_MASK
        ret nz                  ; Solo se ejecuta si los bits de MOVE_MASK son 0

        ld hl, sys_movement_one
        jp man_entity_for_each
