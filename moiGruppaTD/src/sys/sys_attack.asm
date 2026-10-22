INCLUDE "man/man_entity.inc"
SECTION "System: tower attacks", ROM0
sys_attack_update::
    ld hl, sys_attack_one
    jp man_towers_each
sys_attack_one::
    ld a, [de]
    cp 4
    ret z
    ld a, E_TIMER
    call entity_field
    ld a, [hl]
    and a
    jr z, .ready
    dec [hl]
    ret nz
.ready
    ld a, [de]
    cp 5
    jr nz, .weapon
    ld b, 1
    call protein_add
    jr .reload
.weapon
    ld a, E_X
    call entity_field
    ld b, [hl]
    inc hl
    ld c, [hl]
    push de
    call game_find_target
    pop de
    ret nc
    call game_spawn_shot
    ret c
.reload
    ld a, E_SPEED
    call entity_field
    ld a, [hl]
    dec hl
    ld [hl], a
    ret

;; B=X minima, C=fila -> CARRY y HL=pollo, NC si no hay objetivo.
;; Destruye A,DE,HL; conserva BC.
game_find_target::
    ld hl, Array_chickens
    ld d, MAX_CHICKENS
.loop
    push hl
    ld a, [hl]
    and a
    jr z, .skip
    inc hl
    inc hl
    inc hl
    ld a, [hl+]
    cp b
    jr c, .skip
    ld a, [hl]
    cp c
    jr nz, .skip
    pop hl
    scf
    ret
.skip
    pop hl
    ld a, l
    add ENTITY_SIZE
    ld l, a
    jr nc, .carry_done
    inc h
.carry_done
    dec d
    jr nz, .loop
    and a
    ret

;; DE=torre. Conserva DE. Carry si pool lleno o cuatro tiros en fila.
game_spawn_shot::
    ld a, E_ROW
    call entity_field
    ld c, [hl]
    push de
    ld de, Array_shots
    ld b, MAX_SHOTS
    ld h, 0
.count
    ld a, [de]
    and a
    jr z, .next
    push hl
    ld a, E_ROW
    call entity_field
    ld a, [hl]
    pop hl
    cp c
    jr nz, .next
    inc h
.next
    ld a, e
    add ENTITY_SIZE
    ld e, a
    jr nc, .same_page
    inc d
.same_page
    dec b
    jr nz, .count
    ld a, h
    cp 4
    jr nc, .full
    ld de, Array_shots
    ld b, MAX_SHOTS
    call man_entity_free
    jr nz, .full
    pop de
    ;; HL=shot libre, DE=torre. Copia dano, X y fila.
    ld [hl], 1
    inc hl
    ld [hl], 1
    inc hl
    push hl
    ld a, E_DAMAGE
    call entity_field
    ld b, [hl]
    inc hl
    ld a, [hl+]
    add 12
    ld c, a
    ld a, [hl]
    pop hl
    ld [hl], b
    inc hl
    ld [hl], c
    inc hl
    ld [hl+], a
    xor a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret
.full
    pop de
    scf
    ret
