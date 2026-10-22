INCLUDE "man/man_entity.inc"
SECTION "System: spawning", ROM0
sys_spawn_update::
    ld a, [wSpawned]
    cp TOTAL_CHICKENS
    ret nc
    ld hl, wSpawnTimer
    dec [hl]
    ret nz
    call game_spawn_chicken
    jr c, .retry
    ld hl, wSpawned
    inc [hl]
    ld a, [hl]
    cp 8
    ld a, 150
    jr c, .store
    ld a, [hl]
    cp 16
    ld a, 110
    jr c, .store
    ld a, 80
.store
    ld [wSpawnTimer], a
    ret
.retry
    ld a, 1
    jr .store

;; Un maximo de dos pollos por carril mantiene la legibilidad/OAM.
;; C=1 si no hay hueco o el carril esta lleno; no consume la oleada.
game_spawn_chicken::
    ld a, [wSpawned]
    and 3
    ld c, a
    ld de, Array_chickens
    ld b, MAX_CHICKENS
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
    jr nc, .no_carry
    inc d
.no_carry
    dec b
    jr nz, .count
    ld a, h
    cp 2
    jr nc, .full
    ld de, Array_chickens
    ld b, MAX_CHICKENS
    call man_entity_free
    jr nz, .full
    ld a, [wSpawned]
    srl a
    srl a
    srl a
    inc a
    ld [hl+], a
    dec a
    push hl
    ld l, a
    ld h, 0
    ld d, h
    ld e, l
    add hl, hl
    add hl, de
    ld de, .presets
    add hl, de
    ld b, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld e, [hl]
    pop hl
    ld a, b
    ld [hl+], a
    ld a, d
    ld [hl+], a
    ld a, 144
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ld a, 60
    ld [hl+], a
    ld a, e
    ld [hl+], a
    ld [hl], a
    and a
    ret
.full
    scf
    ret
.presets
    db 10, 1, 8
    db 5, 2, 4
    db 30, 5, 12
