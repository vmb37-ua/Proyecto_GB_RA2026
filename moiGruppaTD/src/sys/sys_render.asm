SECTION "System: publish graphics", ROM0
;; Shadow OAM por DMA + 2 filas (40 tiles) por VBlank.
;; Toda la preparacion ocurre antes de esta espera, fuera de VRAM.
sys_render_update::
    call frame_wait
    ld a, HIGH(shadow_oam)
    call hDMA
    ld b, 2
.row
    push bc
    call bg_copy_row
    pop bc
    dec b
    jr nz, .row
    ret
