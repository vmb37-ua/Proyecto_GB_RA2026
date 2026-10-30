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
    ld a, [hl+]             ; Leemos lo que tarda el pollo en aparecer (espera), si es 0, es que ya no queda oleada o esta vacia
    or a
    jr z, .fin

    ;; La oleada no esta vacia, por lo que guardamos la espera del PRIMER POLLO
    ld [woleadaEspera], a
    xor a
    ld [woleadaFin], a ;; Ponemos que la oleada no esta vacia

    ;; Guardamos el puntero que apunta al primer pollo (el tipo de pollo)
    ld a, l
    ld [woleadaPtr], a
    ld a, h
    ld [woleadaPtr + 1], a
    ret

.fin:
    ld a, 1
    ld [woleadaFin], a
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
    ld a, [woleadaFin]
    or a
    ret nz                  ; Si woleadaFin es 1 (se acabo la oleada), no hacemos nada

    ld hl, woleadaEspera
    dec [hl]
    ret nz                  ; Si el contador de espera del pollo actual no es 0, decrementamos y salimos

    ;; Cargamos el puntero woleadaPtr (Siempre apunta al tipo de pollo en la oleada)
    ld a, [woleadaPtr]
    ld e, a
    ld a, [woleadaPtr + 1]
    ld d, a

    inc de                  ; DE ahora es fila
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; SE PUEDE OPTIMIZAR SOLO GUARDANDO LA NORMALIZACION                                       ;;
    ;; NO SE HACE POR SI MODIFICAMOS FILA_CARRIL0 (PRIMER CARRIL) NO TENGAMOS QUE MODIFICAR TODO;;
    ;; Cuando no tengamos que modificar nada mas lo podemos optimizar                           ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld a, [de]
    add FILA_CARRIL0 ;; Normalizamos a fila del tablero (x + 5)
    swap a ;; Pasamos a bit alto  - (x/fila) - (fila/x)
    or COL_ENTRADA ;; Le ponemos el bit bajo de la columna - (fila/columna) en a
    ld b, a

    ;; Comprobamos si la casilla de entrada esta ocupada
    call game_entidad_en
    jr z, .bloqueado        ; Si Z, la casilla esta ocupada

    ;; Si la casilla esta libre podemos crear el pollo
    dec de  ;;DE apunta a tipo             
    ld a, [de]              
    push de                 ; Guardarmos DE porque game_chicken_spawn lo modifica
    call game_chicken_spawn
    pop de 

    ;; Avanzamos a la siguiente espera:
    inc de                  ; DE -> carril
    inc de                  ; DE -> espera de la siguiente entrada
    ld a, [de]
    or a
    jr z, .terminar_oleada

    ld [woleadaEspera], a
    inc de                  ; DE -> tipo de la siguiente entrada (porque woleadaPTR apunta al tipo)
    ld a, e
    ld [woleadaPtr], a
    ld a, d
    ld [woleadaPtr + 1], a
    ret

.bloqueado:
    ld a, 1
    ld [woleadaEspera], a   ; Reintentar en el proximo frame
    ret

.terminar_oleada:
    ld a, 1
    ld [woleadaFin], a
    ret
