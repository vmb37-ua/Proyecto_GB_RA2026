INCLUDE "man/man_entity.inc"
SECTION "System: movement and bites", ROM0
sys_physics_update::
    ld hl, sys_chicken_one
    call man_chickens_each
    ld hl, sys_shot_one
    jp man_shots_each
sys_shot_one::
    ld a, E_X
    call entity_field
    ld a, [hl]
    add 2
    ld [hl], a
    cp 160
    ret c
    xor a
    ld [de], a
    ret
sys_chicken_one::
    ;; A la izquierda del tablero pierde una vida y libera el slot.
    ld a, E_X
    call entity_field
    ld a, [hl]
    cp BOARD_X
    jr c, .escape
    sub BOARD_X
    cp BOARD_COLS * 16
    jr nc, .walk
    swap a
    and $0F
    ld b, a
    inc hl
    ld c, [hl]
    ld a, b
    push de
    call game_tower_slot
    ld a, [de]
    and a
    jr z, .empty
    ;; Torre en esta celda: el pollo deja de andar y ataca cada 60 frames.
    pop hl
    push hl
    ld bc, E_TIMER
    add hl, bc
    dec [hl]
    jr nz, .blocked
    ld [hl], 60
    pop hl
    push hl
    ld bc, E_DAMAGE
    add hl, bc
    ld b, [hl]
    inc de
    ld a, [de]
    sub b
    jr c, .destroy
    jr z, .destroy
    ld [de], a
.blocked
    pop de
    ret
.destroy
    dec de
    xor a
    ld [de], a
    call bg_draw_towers
    pop de
    ret
.empty
    pop de
.walk
    ld a, E_MOVE
    call entity_field
    dec [hl]
    ret nz
    dec hl
    ld a, [hl+]
    ld [hl], a
    ld a, E_X
    call entity_field
    dec [hl]
    ret
.escape
    xor a
    ld [de], a
    ld hl, wLives
    ld a, [hl]
    and a
    ret z
    dec [hl]
    ret
