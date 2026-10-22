INCLUDE "man/man_entity.inc"
SECTION "Prerender data", WRAM0
wOamNext: ds 2
wSpriteAttr: ds 1
wRenderX: ds 1
wRenderY: ds 1
SECTION "System: prepare graphics", ROM0
sys_prerender_update::
    call oam_clear
    ld a, [scene_id]
    cp SCENE_GAME
    ret nz
    ld hl, shadow_oam
    ld a, l
    ld [wOamNext], a
    ld a, h
    ld [wOamNext + 1], a
    xor a
    ld [wSpriteAttr], a
    ld hl, .chicken
    call man_chickens_each
    ld hl, .shot
    call man_shots_each
    call sys_prerender_cursor
    jp hud_update
.chicken
    ld a, [de]
    add TILE_CHICKEN - 1
    ld c, a
    jr .entity
.shot
    ld c, TILE_SHOT
.entity
    ld a, E_ROW
    call entity_field
    ld a, [hl]
    call game_row_y
    add 4
    ld b, a
    ld a, E_X
    call entity_field
    ld a, [hl]
    jp oam_emit
;; A=X, B=Y (pixeles de pantalla), C=tile. Conserva BC,DE.
oam_emit:
    push af
    ld a, [wOamNext]
    ld l, a
    ld a, [wOamNext + 1]
    ld h, a
    ld a, b
    add 16
    ld [hl+], a
    pop af
    add 8
    ld [hl+], a
    ld [hl], c
    inc hl
    ld a, [wSpriteAttr]
    ld [hl+], a
    ld a, l
    ld [wOamNext], a
    ld a, h
    ld [wOamNext + 1], a
    ret
sys_prerender_cursor:
    ld a, [wCursorState]
    and a
    jr nz, .menu
    ld a, [wCursorCol]
    call game_column_x
    ld [wRenderX], a
    ld a, [wCursorRow]
    call game_row_y
    jr .position
.menu
    ld a, [wMenuSlot]
    swap a
    add a
    add 8
    ld [wRenderX], a
    ld a, 16
.position
    ld [wRenderY], a
    ld b, a
    ld c, TILE_CURSOR
    ld a, [wRenderX]
    call oam_emit
    ld a, $20
    ld [wSpriteAttr], a
    ld a, [wRenderX]
    add 8
    call oam_emit
    ld a, [wRenderY]
    add 8
    ld b, a
    ld a, $40
    ld [wSpriteAttr], a
    ld a, [wRenderX]
    call oam_emit
    ld a, $60
    ld [wSpriteAttr], a
    ld a, [wRenderX]
    add 8
    jp oam_emit
