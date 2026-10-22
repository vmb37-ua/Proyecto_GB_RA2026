INCLUDE "man/man_entity.inc"
SECTION "System: game rules", ROM0
sys_income_update::
    ld hl, wIncomeTimer
    dec [hl]
    ret nz
    ld [hl], 120
    ld b, 1
    jp protein_add
;; Primero derrota; victoria solo cuando han salido TODOS y no queda ninguno.
game_check_end::
    ld a, [wLives]
    and a
    jr z, .lose
    ld a, [wSpawned]
    cp TOTAL_CHICKENS
    ret c
    ld hl, Array_chickens
    ld b, MAX_CHICKENS
    ld de, ENTITY_SIZE
.check
    ld a, [hl]
    and a
    ret nz
    add hl, de
    dec b
    jr nz, .check
    ld hl, scene_win
    jp scene_change
.lose
    ld hl, scene_gameover
    jp scene_change
