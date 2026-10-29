;;==============================================================
;; Sistema de combate
;; Los pollos pegan al strongman de su izquierda y el strongman les devuelve el golpe
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: combat", ROM0

;;--------------------------------------------------------------
;; EJERCICIO 9 (a)
;;--------------------------------------------------------------
;; Si DE es un pollo (MOVE) y en la casilla de su izquierda hay un strongman:
;;   strongman.VIDA -= pollo.DANO      (si VIDA <= DANO: game_matar)
;;   pollo.VIDA     -= strongman.DANO  (si VIDA <= DANO: game_matar y
;;                                      moneda_sumar RECOMPENSA_POLLO)
;; Usa: a, bc, de, hl
;; Parametros entrada: de-entidad
;; Parametros salida: -
sys_combat_one::
    ;; ◉◉TU CÓDIGO◉◉
    ret

;; EJERCICIO 9 (b): combate de todos los pollos, pero solo 1 de cada 16 frames
;; (cuando frame_counter AND ATAQUE_MASK = 0)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_combat_update::
    ;; ◉◉TU CÓDIGO◉◉
    ret
