;;==============================================================
;; Pantalla: wait_vblank, screen_off y screen_on
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Engine: screen", ROM0

;; Espera hasta VBLANK
;; ⚠️ Con el LCD apagado LY no cambia y no vuelve nunca
;; Usa: a
;; Parametros entrada: -
;; Parametros salida: -
wait_vblank::
    ld a, [rLY]
    cp VBLANK_LINE
    jr nz, wait_vblank
    ret

;; Espera a VBLANK y apaga el LCD (si ya esta apagado, no hace nada)
;; Usa: a, hl
;; Parametros entrada: -
;; Parametros salida: -
screen_off::
    ld hl, rLCDC
    bit LCDC_ON_BIT, [hl]
    ret z
    call wait_vblank
    res LCDC_ON_BIT, [hl]
    ret

;; Enciende el LCD con la configuracion del juego
;; Usa: a
;; Parametros entrada: -
;; Parametros salida: -
screen_on::
    ld a, LCDC_CONFIG
    ld [rLCDC], a
    ret
