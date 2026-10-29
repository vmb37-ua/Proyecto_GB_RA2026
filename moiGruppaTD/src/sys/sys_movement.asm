;;==============================================================
;; Sistema de movimiento (componente MOVE)
;; Mueve los pollos hacia la izquierda por su carril
;;==============================================================
INCLUDE "man/man_entity.inc"

SECTION "System: movement", ROM0

;; Mueve UNA entidad a la izquierda (la entidad no tiene por que estar activa)
;; Solo trabaja con entidades con el componente MOVE
;; Usa: a
;; Parametros entrada: de-entidad
;; Parametros salida: -
sys_movement_one::
    ld a, [de]                  ;; \ Tiene MOVE?
    and CMP_MOVE                ;; |
    ret z                       ;; / No: no es para este sistema

    ;; Necesitamos saber si podemos mover la chicken a la izquierda
        ;; - Limite de mapa¿
        ;; - Colision?
    ret

;; Mueve todas las entidades con MOVE que estan en pantalla ahora mismo
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_movement_update::
    ld hl, sys_movement_one
    jp man_entity_for_each
