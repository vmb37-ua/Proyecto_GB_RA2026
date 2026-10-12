
DEF PANTALLA_INI = $9800
DEF PANTALLA_FIN = $9A33

DEF VENTANA_TAM = 20

DEF VBLANK_DIR = $FF44

SECTION "Render", ROM0

render::
    call .borrar_pantalla
    ret

    .esperar_vblank:
        ld hl, VBLANK_DIR
        ld a, [hl]
        cp 144
        jr nz, .esperar_vblank
        ret

    .borrar_fila:
        ;; Dir inicio de la fila en hl
        push hl
        call .esperar_vblank
        pop hl
        ld a, 0
        .borrar_pixel:
            ld [hl], 0
            inc hl
            inc a
            cp VENTANA_TAM
            jr nz, .borrar_pixel
        
        ret

    .borrar_pantalla:
        ld b, VENTANA_TAM
        ld hl, PANTALLA_INI
        ld de, 12
        .loop:
            call .borrar_fila
            add hl, de
            dec b
            jr nz, .loop
        ret
            



