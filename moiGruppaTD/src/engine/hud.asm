INCLUDE "man/man_entity.inc"
SECTION "Engine: HUD", ROM0
hud_update::
    ld a, [wProtein]
    ld hl, bg_buffer + 1
    call text_number
    ld a, [wLives]
    ld hl, bg_buffer + 5
    call text_number
    ld a, [wSpawned]
    srl a
    srl a
    srl a
    inc a
    cp 4
    jr c, .wave
    ld a, 3
.wave
    ld hl, bg_buffer + 9
    call text_number
    ld a, [wSpawned]
    ld b, a
    ld a, TOTAL_CHICKENS
    sub b
    ld b, a
    ld c, MAX_CHICKENS
    ld hl, Array_chickens
    ld de, ENTITY_SIZE
.count
    ld a, [hl]
    and a
    jr z, .next
    inc b
.next
    add hl, de
    dec c
    jr nz, .count
    ld a, b
    ld hl, bg_buffer + 16
    call text_number
    ld hl, bg_buffer + 17 * 32
    ld bc, 20
    ld d, 0
    call mem_set
    ld de, .normal
    ld a, [wMessageTimer]
    and a
    jr z, .pause
    ld de, .error
.pause
    ld a, [wPaused]
    and a
    jr z, .draw
    ld de, .paused
.draw
    ld hl, bg_buffer + 17 * 32
    jp text_draw
.normal db "A BUILD START PAUSE", 0
.error db "OCCUPIED OR NO P", 0
.paused db "PAUSED START RESUME", 0
