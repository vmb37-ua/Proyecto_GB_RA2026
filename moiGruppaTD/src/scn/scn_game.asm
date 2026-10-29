;;==============================================================
;; Escena: el juego
;; Su init y su update. El update solo decide el ORDEN de los sistemas (sys/)
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Scene: game", ROM0

;; Inicializa la escena: sin entidades, carriles, cursor y proteina
;; Requiere LCD apagado
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
scene_game_init::
    call man_entity_init        ;; \ Sin entidades,
    call sys_render_init        ;; | la pantalla con los carriles,
    call sys_input_init         ;; | el cursor al principio
    jp moneda_init              ;; / y la proteina inicial

;; Actualiza la escena (una vez por ciclo)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
scene_game_update::
    call sys_input_update       ;; Actualizar el input del usuario en el modelo
    call sys_movement_update    ;; Los pollos avanzan
    call sys_simulation_update  ;; Procedimiento del juego
    jp sys_render_update        ;; Renderizacion (espera a VBLANK)
