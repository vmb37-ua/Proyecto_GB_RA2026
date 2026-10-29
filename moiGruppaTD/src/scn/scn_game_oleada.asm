;;==============================================================
;; Escena del juego: la oleada de pollos
;; Una oleada es una lista de entradas de 3 bytes:
;;   db espera, tipo, carril
;; espera = frames hasta que sale ese pollo (1-255), contados desde el anterior.
;; Una espera = 0 marca el final de la oleada.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Oleada data", WRAM0
wOleadaPtr::    ds 2            ;; Direccion del TIPO de la entrada actual
wOleadaEspera:: ds 1            ;; Frames que faltan para que salga
wOleadaFin::    ds 1            ;; 1 = ya no quedan pollos por salir

SECTION "Oleada", ROM0

;; La oleada del nivel (CODIGO COMUN)
Oleada1::
    db 180, CHICKEN_A, 1
    db  90, CHICKEN_A, 0
    db  90, CHICKEN_B, 2
    db 120, CHICKEN_A, 1
    db  60, CHICKEN_C, 0
    db  60, CHICKEN_B, 2
    db 0

;;--------------------------------------------------------------
;; EJERCICIO 7 (a)
;;--------------------------------------------------------------
;; Prepara una oleada: si la primera espera es 0, wOleadaFin = 1.
;; Si no: wOleadaFin = 0, wOleadaEspera = primera espera y wOleadaPtr apunta a su tipo
;; Usa: a, hl
;; Parametros entrada: hl-oleada
;; Parametros salida: -
game_oleada_init::
    ;; ◉◉TU CÓDIGO◉◉
    ld a, 1                     ;; (provisional: oleada vacia)
    ld [wOleadaFin], a
    ret

;;--------------------------------------------------------------
;; EJERCICIO 7 (b)
;;--------------------------------------------------------------
;; Una vez por frame. Si la oleada no ha terminado, descuenta la espera. Al llegar a 0:
;; - Si la casilla de entrada (FILA_CARRIL0 + carril, COL_ENTRADA) esta ocupada,
;;   espera 1 frame mas (wOleadaEspera = 1) y lo vuelve a intentar.
;; - Si no, crea el pollo y pasa a la siguiente entrada (o termina si su espera es 0)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
game_oleada_update::
    ;; ◉◉TU CÓDIGO◉◉
    ret
