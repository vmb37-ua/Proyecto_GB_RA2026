
DEF PANTALLA_INI = $9800
DEF PANTALLA_FIN = $9A33

DEF VENTANA_TAM = 20

DEF VBLANK_DIR = $FF44

SECTION "Render", ROM0

render::
    call .borrar_pantalla_vista
    ret

    .esperar_vblank:
        ;; Espera hasta VBALNK
        ;; Usa: a
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld a, [VBLANK_DIR]
        cp 144
        jr nz, .esperar_vblank
        ret

    .borrar_fila_vista:
        ;; Borra la fila seleccionada (dentro de la vista)
        ;; Usa: a, hl
        ;; Parametros entrada: hl-dir de inicio de la fila
        ;; Parametros salida: -
        call .esperar_vblank
        ld a, 0
        .borrar_pixel:
            ld [hl], 0
            inc hl
            inc a
            cp VENTANA_TAM
            jr nz, .borrar_pixel
        ret

    .borrar_pantalla_vista:
        ;; Borra toda pantalla en la vista
        ;; Usa: b, hl, de
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld b, VENTANA_TAM
        ld hl, PANTALLA_INI
        ld de, 12
        .loop:
            call .borrar_fila_vista
            add hl, de
            dec b
            jr nz, .loop
        ret
            



