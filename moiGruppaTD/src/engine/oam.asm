INCLUDE "engine/hardware.inc"
SECTION "Shadow OAM", WRAM0, ALIGN[8]
shadow_oam:: ds 160
SECTION "DMA in HRAM", HRAM
hDMA:: ds 10
SECTION "Engine: OAM", ROM0
dma_init::
    ld hl, .code
    ld de, hDMA
    ld bc, .end - .code
    jp mem_copy
.code
    ldh [rDMA], a
    ld a, 40
.wait
    dec a
    jr nz, .wait
    ret
.end
oam_clear::
    ld hl, shadow_oam
    ld bc, 160
    ld d, 0
    jp mem_set
