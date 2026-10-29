;;==============================================================
;; HUD: numeros en pantalla (el saldo de proteina)
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"

;; Posicion del contador de moneda (en tiles; ocupa 2 de ancho). POR DETERMINAR
DEF HUD_MONEDA_COL  = 18
DEF HUD_MONEDA_FILA = 17
;; Posicion del coste del strongman del hueco wMenuSlot (2 de ancho)
DEF HUD_COSTE_COL   = 0
DEF HUD_COSTE_FILA  = 17

SECTION "HUD", ROM0

;; Dibuja un numero de 00 a 99 con 2 tiles (siempre dos cifras: 7 -> "07").
;; Si a > 99 se dibuja 99. Espera por si mismo a VBLANK antes de escribir
;; Usa: a, bc, de, hl
;; Parametros entrada: a-numero (0-99), b-columna (0-19), c-fila (0-17), en tiles
;; Parametros salida: -
hud_dibujar_numero::
    cp 100
    jr c, .valido
    ld a, 99                        ;; Limite: evita tiles fuera de las cifras
    .valido:
    ld d, a                         ;; d = numero (se guarda mientras se calcula la dir)

    ;; hl = BG_MAP + fila * TILEMAP_ANCHO + columna     (TILEMAP_ANCHO = 32)
    ld h, 0
    ld l, c
    add hl, hl                      ;; hl = fila * 2
    add hl, hl                      ;; * 4
    add hl, hl                      ;; * 8
    add hl, hl                      ;; * 16
    add hl, hl                      ;; * 32
    ld c, b
    ld b, 0
    add hl, bc                      ;; + columna
    ld bc, BG_MAP
    add hl, bc                      ;; + inicio del tilemap

    ;; Separar cifras: b = decenas, a = unidades
    ld a, d
    ld b, 0
    .decenas:
        cp 10
        jr c, .tiles
        sub 10
        inc b
        jr .decenas
    .tiles:
    add TILE_NUM_0
    ld c, a                         ;; c = tile de las unidades
    ld a, b
    add TILE_NUM_0
    ld b, a                         ;; b = tile de las decenas

    .esperar_vblank:                ;; VRAM solo accesible en VBLANK (LY >= 144)
        ld a, [rLY]
        cp VBLANK_LINE
        jr c, .esperar_vblank

    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl], a
    ret

;; Dibuja el saldo actual (wProtein) en la posicion del HUD
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
hud_dibujar_moneda::
    ld a, [wProtein]
    ld b, HUD_MONEDA_COL
    ld c, HUD_MONEDA_FILA
    jp hud_dibujar_numero

;;--------------------------------------------------------------
;; EJERCICIO 6 (b)
;;--------------------------------------------------------------
;; Dibuja el HUD: el saldo (wProtein) en (HUD_MONEDA_COL, HUD_MONEDA_FILA)
;; y el coste del strongman del hueco wMenuSlot en (HUD_COSTE_COL, HUD_COSTE_FILA)
;; Requiere estar en VBLANK
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
hud_update::
    ;; ◉◉TU CÓDIGO◉◉
    ret
