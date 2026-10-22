INCLUDE "engine/hardware.inc"
SECTION "Engine: graphics initialization", ROM0
gfx_init::
    ld hl, gfx_tiles
    ld de, $8000
    ld bc, gfx_tiles_end - gfx_tiles
    call mem_copy
    ld a, %11100100
    ldh [rBGP], a
    ldh [rOBP0], a
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    ret
