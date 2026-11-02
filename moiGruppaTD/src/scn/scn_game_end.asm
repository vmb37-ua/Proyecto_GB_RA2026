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
    ld hl, entity_array
    ld b, MAX_ENTITIES
    ld c, 0                     ;; Contador de pollos vivos
    .loop:
        bit CMP_ALIVE_BIT, [hl]
        jr z, .next

        inc l
        ld a, [hl]
        dec l
        cp KIND_CHICKEN
        jr nz, .next

        ld a, l
        add E_VIDA
        ld l, a
        ld a, [hl]
        or a
        jr z, .restore
        inc c

    .restore:
        ld a, l
        sub E_VIDA
        ld l, a
    .next:
        ld a, l
        add SIZEOF_ENTITY
        ld l, a
        dec b
        jr nz, .loop

    ld a, c
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
    ld a, [wGameState]
    cp GAME_JUGANDO
    jr nz, .finished

    ld a, [wOleadaFin]
    cp 1
    jr nz, .playing

    call game_pollos_vivos
    or a
    jr nz, .playing

    ld a, GAME_GANADO
    ld [wGameState], a
    .finished:
        xor a                   ;; Z: la partida ha acabado
        ret

    .playing:
        or 1                    ;; NZ: la partida sigue
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
    call screen_off
    call sys_render_init

    ld hl, OAM_RAM
    ld bc, OAM_TAM
    ld d, 0
    call memset

    ld e, TILE_POLLO
    ld a, [wGameState]
    cp GAME_GANADO
    jr nz, .draw
    ld e, TILE_STRONG

    .draw:
        ld a, POS_FINAL
        call sys_render_pos_dir
        ld a, e
        call sys_render_casilla
        jp screen_on
