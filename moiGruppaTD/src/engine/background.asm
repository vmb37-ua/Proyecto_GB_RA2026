INCLUDE "man/man_entity.inc"
SECTION "Background data", WRAM0
bg_buffer:: ds 18 * 32
bg_render_row:: ds 1
SECTION "Engine: background", ROM0
bg_clear::
    xor a
    ld [bg_render_row], a
    ld hl, bg_buffer
    ld bc, 18 * 32
    ld d, 0
    jp mem_set
;; LCD apagado: publica el fondo completo al cambiar de escena.
bg_flush::
    ld hl, bg_buffer
    ld de, $9800
    ld bc, 18 * 32
    jp mem_copy
;; Solo durante VBlank: copia 20 tiles de una fila visible y avanza.
bg_copy_row::
    ld a, [bg_render_row]
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld d, h
    ld e, l
    ld bc, bg_buffer
    add hl, bc
    push hl
    ld hl, $9800
    add hl, de
    ld d, h
    ld e, l
    pop hl
    ld b, 20
.copy
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .copy
    ld a, [bg_render_row]
    inc a
    cp 18
    jr c, .store
    xor a
.store
    ld [bg_render_row], a
    ret
;; B=columna y C=fila del TABLERO -> HL=tile superior izquierdo en RAM.
;; Conserva BC y DE.
bg_grid_address::
    push de
    ld a, c
    add a
    add c
    add 5
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, b
    add a
    inc a
    ld e, a
    ld d, 0
    add hl, de
    ld de, bg_buffer
    add hl, de
    pop de
    ret
;; HL=destino, A=primer tile de bloque 2x2 consecutivo. Conserva BC,DE.
bg_block::
    ld [hl+], a
    inc a
    ld [hl], a
    push de
    ld de, 31
    add hl, de
    pop de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ret
;; Reconstruye las 28 celdas (solo RAM), tambien borra torres destruidas.
bg_draw_towers::
    ld c, 0
.row
    ld b, 0
.col
    call bg_grid_address
    ld a, TILE_FLOOR
    ld [hl+], a
    ld [hl], a
    push de
    ld de, 31
    add hl, de
    pop de
    ld [hl+], a
    ld [hl], a
    inc b
    ld a, b
    cp BOARD_COLS
    jr c, .col
    inc c
    ld a, c
    cp BOARD_ROWS
    jr c, .row
    ld hl, .tower
    jp man_towers_each
.tower
    ld a, E_X
    call entity_field
    ld a, [hl+]
    sub BOARD_X
    swap a
    and $0F
    ld b, a
    ld c, [hl]
    call bg_grid_address
    ld a, [de]
    dec a
    add a
    add a
    add TILE_TOWER
    jp bg_block
bg_game_init::
    call bg_clear
    ld de, .labels
    ld hl, bg_buffer
    call text_draw
    ld de, .names
    ld hl, bg_buffer + 32
    call text_draw
    ;; Catalogo: cinco iconos 2x2, con precio debajo.
    ld hl, bg_buffer + 2 * 32 + 1
    ld a, TILE_TOWER
    ld b, MENU_SLOTS
.icons
    push af
    push hl
    call bg_block
    pop hl
    ld de, 4
    add hl, de
    pop af
    add 4
    dec b
    jr nz, .icons
    ld de, .costs
    ld hl, bg_buffer + 4 * 32
    call text_draw
    jp bg_draw_towers
.labels db "P00 L03 W01 LEFT24", 0
.names db " BAS RAP HEA WAL PRO", 0
.costs db " 02  03  05  03  04", 0
