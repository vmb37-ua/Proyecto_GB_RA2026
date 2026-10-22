INCLUDE "engine/hardware.inc"
SECTION "Joypad data", WRAM0
input_held:: ds 1
input_pressed:: ds 1
SECTION "Engine: joypad", ROM0
input_init::
    xor a
    ld [input_held], a
    ld [input_pressed], a
    ret
;; Bits: Down Up Left Right Start Select B A. Solo flancos en pressed.
input_update::
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    swap a
    ld b, a
    ld a, $10
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    or b
    ld b, a
    ld a, [input_held]
    cpl
    and b
    ld [input_pressed], a
    ld a, b
    ld [input_held], a
    ld a, $30
    ldh [rP1], a
    ret
