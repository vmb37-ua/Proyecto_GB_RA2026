;;==============================================================
;; Escena del juego: fin de la partida (ganar o perder)
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game end", ROM0

;;--------------------------------------------------------------
;; EJERCICIO 10 (a)
;;--------------------------------------------------------------
;; Cuenta los pollos vivos: KIND_CHICKEN, CMP_ALIVE y VIDA != 0
;; Usa: a, bc, hl
;; Parametros entrada: -
;; Parametros salida: a-numero de pollos vivos
game_pollos_vivos::
    ;; ◉◉TU CÓDIGO◉◉
    xor a                       ;; (provisional: ninguno)
    ret

;;--------------------------------------------------------------
;; EJERCICIO 10 (b)
;;--------------------------------------------------------------
;; Ha acabado la partida?
;; - Si wGameState != GAME_JUGANDO: si (Z)
;; - Si la oleada ha terminado (wOleadaFin = 1) y no quedan pollos vivos:
;;   wGameState = GAME_GANADO, si (Z)
;; - Si no: no (NZ)
;; Usa: a, bc, hl
;; Parametros entrada: -
;; Parametros salida: Z, ha acabado. NZ, sigue
game_check_end::
    ;; ◉◉TU CÓDIGO◉◉
    or 1                        ;; (provisional: no acaba nunca)
    ret

;;--------------------------------------------------------------
;; EJERCICIO 10 (c)
;;--------------------------------------------------------------
;; Pantalla final: apaga el LCD, borra la pantalla (sys_render_init) y la OAM,
;; dibuja en POS_FINAL un strongman (GAME_GANADO) o un pollo (GAME_PERDIDO),
;; y enciende el LCD
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
game_pantalla_final::
    ;; ◉◉TU CÓDIGO◉◉
    ret
