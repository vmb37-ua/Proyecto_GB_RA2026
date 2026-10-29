;;==============================================================
;; Escena: el juego
;; Su init y su update. El update solo decide el ORDEN de los sistemas (sys/)
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Scene: game", ROM0

;; Inicializa la escena: sin entidades, pantalla vacia y strongmen de ejemplo
;; Requiere LCD apagado
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
scene_game_init::
    call man_entity_init        ;; \ Sin entidades
    call sys_render_init        ;; / y la pantalla vacia

    ;; Ejemplo: dos strongmen
    ld a, 0                     ;; \ Tipo 0 en la casilla fila 1, columna 2
    ld b, (1 << 4) | 2          ;; | (tiles: columna 4, fila 2)
    call game_strong_colocar    ;; /
    ld a, 1                     ;; \ Tipo 1 en la casilla fila 3, columna 5
    ld b, (3 << 4) | 5          ;; | (tiles: columna 10, fila 6)
    jp game_strong_colocar      ;; /

;; Actualiza la escena (una vez por ciclo)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
scene_game_update::
    call sys_input_update       ;; Actualizar el input del usuario en el modelo
    call sys_simulation_update  ;; Procedimiento del juego
    jp sys_render_update        ;; Renderizacion (espera a VBLANK)
