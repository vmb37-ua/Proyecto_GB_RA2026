INCLUDE "game.inc"
SECTION "Scene state", WRAM0
scene_id:: ds 1
scene_current:: ds 2
SECTION "Manager: scenes", ROM0
;; HL = tabla DB id / DW init, update. Cada init dibuja con LCD apagado.
scene_change::
    call screen_off
    ld a, [hl+]
    ld [scene_id], a
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld [scene_current], a
    ld a, [hl]
    ld [scene_current + 1], a
    ld h, d
    ld l, e
    call engine_call_hl
    call sys_prerender_update
    call bg_flush
    ld a, HIGH(shadow_oam)
    call hDMA
    jp screen_on
scene_update::
    ld a, [scene_current]
    ld l, a
    ld a, [scene_current + 1]
    ld h, a
    jp hl
