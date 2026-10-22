INCLUDE "engine/hardware.inc"
SECTION "Engine: screen", ROM0
screen_off::
    ldh a, [rLCDC]
    bit 7, a
    ret z
    call frame_wait
    xor a
    ldh [rLCDC], a
    ret
screen_on::
    ld a, %10010011
    ldh [rLCDC], a
    ret
;; Espera un VBlank NUEVO. Interrupciones desactivadas: no usar HALT.
frame_wait::
    ldh a, [rLY]
    cp 144
    jr nc, frame_wait
.visible
    ldh a, [rLY]
    cp 144
    jr c, .visible
    ret
