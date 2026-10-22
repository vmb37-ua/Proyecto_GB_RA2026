INCLUDE "man/man_entity.inc"
SECTION "Game state", WRAM0
wCursorState:: ds 1
wCursorCol:: ds 1
wCursorRow:: ds 1
wMenuSlot:: ds 1
wProtein:: ds 1
wLives:: ds 1
wSpawned:: ds 1
wSpawnTimer:: ds 1
wIncomeTimer:: ds 1
wPaused:: ds 1
wMessageTimer:: ds 1
wGameStateEnd:
SECTION "Manager: game", ROM0
game_init::
    ld hl, wCursorState
    ld bc, wGameStateEnd - wCursorState
    ld d, 0
    call mem_set
    call man_entity_init
    ld a, PROTEIN_INITIAL
    ld [wProtein], a
    ld a, 3
    ld [wLives], a
    ld a, 180
    ld [wSpawnTimer], a
    ld a, 120
    ld [wIncomeTimer], a
    ret
;; B=cantidad -> saldo saturado a 99. Destruye A.
protein_add::
    ld a, [wProtein]
    add b
    jr c, .cap
    cp PROTEIN_MAX + 1
    jr c, .store
.cap
    ld a, PROTEIN_MAX
.store
    ld [wProtein], a
    ret
;; B=coste. C=1 si insuficiente; en ese caso conserva saldo.
protein_sub::
    ld a, [wProtein]
    sub b
    ret c
    ld [wProtein], a
    ret
;; A=columna -> A=coordenada X en pixeles.
game_column_x::
    swap a
    add BOARD_X
    ret
;; A=fila -> A=coordenada Y en pixeles. Destruye B.
game_row_y::
    ld b, a
    add a
    add b
    add a
    add a
    add a
    add BOARD_Y
    ret
;; A=columna, C=fila -> DE=slot FIJO de torre (fila*7+col).
game_tower_slot::
    ld b, a
    ld a, c
    add a
    add a
    add a
    sub c
    add b
    ld h, 0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, Array_strong
    add hl, de
    ld d, h
    ld e, l
    ret
