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
    call sys_cursor_init        ;; | el menu y la OAM vacia,
    call sys_input_init         ;; | el cursor al principio,
    call moneda_init            ;; | la proteina inicial,
    call game_estado_init       ;; | la partida empezando
    ld hl, Oleada1              ;; | y la oleada preparada
    jp game_oleada_init         ;; /

;; Actualiza la escena (una vez por ciclo)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
scene_game_update::
    call sys_input_update       ;; Actualizar el input del usuario en el modelo
    call game_oleada_update     ;; Salen pollos
    call sys_movement_update    ;; Los pollos avanzan
    call sys_combat_update      ;; Pollos y strongmen se pegan
    jp sys_render_update        ;; Renderizacion (espera a VBLANK)
