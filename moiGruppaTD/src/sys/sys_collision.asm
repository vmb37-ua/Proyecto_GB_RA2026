INCLUDE "man/man_entity.inc"
SECTION "System: projectile collisions", ROM0
sys_collision_update::
    ld hl, sys_collision_one
    jp man_shots_each
;; Un proyectil solo golpea UN pollo de su carril y se libera al tocarlo.
sys_collision_one::
    ld a, E_X
    call entity_field
    ld b, [hl]
    inc hl
    ld c, [hl]
    ld hl, Array_chickens
    push de
    ld d, MAX_CHICKENS
.loop
    push hl
    ld a, [hl]
    and a
    jr z, .skip
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    add 8
    cp b
    jr c, .skip
    ld a, b
    add 4
    cp [hl]
    jr c, .skip
    inc hl
    ld a, [hl]
    cp c
    jr nz, .skip
    pop hl
    pop de
    ;; HL=pollo, DE=proyectil. Desactiva disparo antes de aplicar dano.
    xor a
    ld [de], a
    inc de
    inc de
    ld a, [de]
    ld b, a
    inc hl
    ld a, [hl]
    sub b
    jr c, .kill
    jr z, .kill
    ld [hl], a
    ret
.kill
    dec hl
    ld [hl], 0
    ld b, 3
    jp protein_add
.skip
    pop hl
    ld a, l
    add ENTITY_SIZE
    ld l, a
    jr nc, .next
    inc h
.next
    dec d
    jr nz, .loop
    pop de
    ret
