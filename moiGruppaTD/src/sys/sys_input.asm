INCLUDE "engine/hardware.inc"
INCLUDE "man/man_entity.inc"
SECTION "System: input", ROM0
sys_input_update::
    ld a, [input_pressed]
    bit BTN_START, a
    jr z, .unpaused
    ld a, [wPaused]
    xor 1
    ld [wPaused], a
.unpaused
    ld a, [wPaused]
    and a
    ret nz
    ld a, [wCursorState]
    and a
    jp nz, .menu
    ld hl, wCursorCol
    ld a, [input_pressed]
    bit BTN_LEFT, a
    jr z, .right
    ld a, [hl]
    and a
    jr z, .right
    dec [hl]
.right
    ld a, [input_pressed]
    bit BTN_RIGHT, a
    jr z, .up
    ld a, [hl]
    cp BOARD_COLS - 1
    jr nc, .up
    inc [hl]
.up
    ld hl, wCursorRow
    ld a, [input_pressed]
    bit BTN_UP, a
    jr z, .down
    ld a, [hl]
    and a
    jr z, .down
    dec [hl]
.down
    ld a, [input_pressed]
    bit BTN_DOWN, a
    jr z, .confirm
    ld a, [hl]
    cp BOARD_ROWS - 1
    jr nc, .confirm
    inc [hl]
.confirm
    ld a, [input_pressed]
    bit BTN_A, a
    ret z
    ld a, 1
    ld [wCursorState], a
    ret
.menu
    ld a, [input_pressed]
    bit BTN_B, a
    jr z, .menu_left
    xor a
    ld [wCursorState], a
    ret
.menu_left
    ld hl, wMenuSlot
    ld a, [input_pressed]
    bit BTN_LEFT, a
    jr z, .menu_right
    ld a, [hl]
    and a
    jr z, .menu_right
    dec [hl]
.menu_right
    ld a, [input_pressed]
    bit BTN_RIGHT, a
    jr z, .buy
    ld a, [hl]
    cp MENU_SLOTS - 1
    jr nc, .buy
    inc [hl]
.buy
    ld a, [input_pressed]
    bit BTN_A, a
    ret z
    jp game_place_tower

;; Compra atomica: valida celda y saldo ANTES de crear o cobrar.
game_place_tower::
    ld a, [wCursorRow]
    ld c, a
    ld a, [wCursorCol]
    call game_tower_slot
    ld a, [de]
    and a
    jr nz, .fail
    ld a, [wMenuSlot]
    add a
    add a
    ld l, a
    ld h, 0
    ld bc, tower_presets
    add hl, bc
    ld b, [hl]
    push hl
    call protein_sub
    pop hl
    jr c, .fail
    inc hl
    ld a, [wMenuSlot]
    inc a
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [wCursorCol]
    call game_column_x
    ld [de], a
    inc de
    ld a, [wCursorRow]
    ld [de], a
    inc de
    ld a, 1
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    xor a
    ld [de], a
    ld [wCursorState], a
    jp bg_draw_towers
.fail
    ld a, 60
    ld [wMessageTimer], a
    ret
