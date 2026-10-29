;;==============================================================
;; Sistema de render (componente RENDER)
;; Dibuja en el fondo la casilla 2x2 de cada entidad, en su E_POS
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"

SECTION "System: render", ROM0

;; Borra toda la pantalla en la vista
;; Requiere LCD apagado
;; Usa: a, b, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_render_init::
    ld b, PANTALLA_ALTO
    ld hl, BG_MAP
    ld de, TILEMAP_ANCHO - PANTALLA_ANCHO
    .loop:
        call .borrar_fila_vista
        add hl, de
        dec b
        jr nz, .loop
    ret

    .borrar_fila_vista:
        ;; Borra la fila seleccionada (dentro de la vista)
        ;; Usa: a, hl
        ;; Parametros entrada: hl-dir de inicio de la fila
        ;; Parametros salida: hl-dir siguiente al ultimo tile borrado
        ld a, 0
        .borrar_tile:
            ld [hl], TILE_VACIO
            inc hl
            inc a
            cp PANTALLA_ANCHO
            jr nz, .borrar_tile
        ret

;; Dibuja UNA entidad: su casilla 2x2 en E_POS
;; Solo trabaja con entidades con el componente RENDER
;; Requiere LCD apagado o estar en VBLANK
;; Usa: a, bc, de, hl
;; Parametros entrada: de-entidad
;; Parametros salida: -
sys_render_one::
    ld a, [de]                  ;; \ Tiene RENDER?
    and CMP_RENDER              ;; |
    ret z                       ;; / No: no es para este sistema

    ld hl, E_POS                ;; \ A = entity.POS = %ffffcccc
    add hl, de                  ;; |
    ld a, [hl]                  ;; /

    ld b, a                     ;; \ C = columna * 2 (tiles)
    and $0F                     ;; |
    add a                       ;; |
    ld c, a                     ;; /

    ld a, b                     ;; \ HL = fila * 16
    and $F0                     ;; |
    ld l, a                     ;; |
    ld h, 0                     ;; /
    add hl, hl                  ;; \ HL = fila * 64 = fila * 2 * TILEMAP_ANCHO
    add hl, hl                  ;; /

    ld b, 0                     ;; \ HL += columna * 2
    add hl, bc                  ;; /
    ld bc, BG_MAP               ;; \ HL = dir del tilemap de la esquina sup-izq
    add hl, bc                  ;; /
    ;; jp .dibujar_casilla      ;; (justo debajo)

    .dibujar_casilla:
        ;; Dibuja una casilla 2x2 (tiles TILE_CASILLA..TILE_CASILLA+3)
        ;; Usa: a, de, hl
        ;; Parametros entrada: hl-dir del tilemap de la esquina superior izquierda
        ;; Parametros salida: -
        ld a, TILE_CASILLA
        ld [hl+], a                 ; (x,   y)   sup-izq
        inc a
        ld [hl], a                  ; (x+1, y)   sup-der
        ld de, TILEMAP_ANCHO - 1
        add hl, de                  ; baja una fila y vuelve a la columna x
        inc a
        ld [hl+], a                 ; (x,   y+1) inf-izq
        inc a
        ld [hl], a                  ; (x+1, y+1) inf-der
        ret

;; Espera a VBLANK y dibuja TODAS las entidades con RENDER
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_render_update::
    call wait_vblank
    ld hl, sys_render_one
    jp man_entity_for_each
