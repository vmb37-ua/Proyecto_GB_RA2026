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
    ld a, [de]
    and CMP_MOVE
    ret z

    ld h, d
    ld a, e
    add E_POS
    ld l, a
    ld a, [hl]
    and $0F
    ret z                       ;; En la columna 0 no hay casilla izquierda

    ld a, [hl]
    dec a
    ld b, a
    call game_entidad_en
    ret nz

    inc l
    ld a, [hl]
    dec l
    cp KIND_STRONG
    ret nz
    ld c, l                     ;; C guarda el byte bajo del strongman

    ;; El pollo golpea al strongman
    ld a, e
    add E_DANO
    ld l, a
    ld b, [hl]
    ld a, c
    add E_VIDA
    ld l, a
    ld a, [hl]
    sub b
    jr z, .kill_strong
    jr c, .kill_strong
    ld [hl], a
    jr .counterattack

    .kill_strong:
        ld l, c
        call game_matar

    .counterattack:
        ;; El strongman devuelve el golpe aunque acabe de morir
        ld a, c
        add E_DANO
        ld l, a
        ld b, [hl]
        ld a, e
        add E_VIDA
        ld l, a
        ld a, [hl]
        sub b
        jr z, .kill_chicken
        jr c, .kill_chicken
        ld [hl], a
        ret

    .kill_chicken:
        ld l, e
        call game_matar
        ld b, RECOMPENSA_POLLO
        jp moneda_sumar

;; EJERCICIO 9 (b): combate de todos los pollos, pero solo 1 de cada 16 frames
;; (cuando frame_counter AND ATAQUE_MASK = 0)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_combat_update::
    ld a, [frame_counter]
    and ATAQUE_MASK
    ret nz

    ld hl, sys_combat_one
    jp man_entity_for_each
