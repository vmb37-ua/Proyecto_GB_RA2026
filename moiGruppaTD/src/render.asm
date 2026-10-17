DEF PANTALLA_INI = $9800
DEF PANTALLA_FIN = $9A33

DEF PANTALLA_ANCHO = 20 ;; Tiles visibles por fila
DEF PANTALLA_ALTO  = 18 ;; Filas visibles
DEF TILEMAP_ANCHO  = 32 ;; Tiles por fila en el tilemap

DEF VBLANK_DIR = $FF44

;; Indices en VRAM de los tiles de la casilla (cargados en init)
DEF TILE_VACIO     = 0
DEF TILE_CASILLA   = 1 ;; 1 sup-izq, 2 sup-der, 3 inf-izq, 4 inf-der

SECTION "Tiles", ROM0

;; Casilla 2x2. Se copia a VRAM a partir del tile TILE_CASILLA
Casilla_placeholder::
    db $FF, $FF, $E0, $E0, $C0, $C0, $C0, $C0, $80, $80, $80, $80, $80, $80, $80, $80 ; tile 1 (sup-izq)
    db $FF, $FF, $07, $07, $03, $03, $03, $03, $01, $01, $01, $01, $01, $01, $01, $01 ; tile 2 (sup-der)
    db $80, $80, $80, $80, $80, $80, $80, $80, $C0, $C0, $C0, $C0, $E0, $E0, $FF, $FF ; tile 3 (inf-izq)
    db $01, $01, $01, $01, $01, $01, $01, $01, $03, $03, $03, $03, $07, $07, $FF, $FF ; tile 4 (inf-der)
.fin::


SECTION "Render", ROM0

render::
    call .borrar_pantalla_vista

    ;; Ejemplo: dos casillas (ambas caben en el mismo VBLANK)
    call .esperar_vblank
    ld hl, PANTALLA_INI + 2 * TILEMAP_ANCHO + 4    ; columna 4, fila 2
    call .dibujar_casilla
    ld hl, PANTALLA_INI + 6 * TILEMAP_ANCHO + 10   ; columna 10, fila 6
    call .dibujar_casilla
    ret

    .esperar_vblank:
        ;; Espera hasta VBLANK
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
        ;; Parametros salida: hl-dir siguiente al ultimo tile borrado
        call .esperar_vblank
        ld a, 0
        .borrar_tile:
            ld [hl], TILE_VACIO
            inc hl
            inc a
            cp PANTALLA_ANCHO
            jr nz, .borrar_tile
        ret

    .borrar_pantalla_vista:
        ;; Borra toda pantalla en la vista
        ;; Usa: b, hl, de, a
        ;; Parametros entrada: -
        ;; Parametros salida: -
        ld b, PANTALLA_ALTO
        ld hl, PANTALLA_INI
        ld de, TILEMAP_ANCHO - PANTALLA_ANCHO
        .loop:
            call .borrar_fila_vista
            add hl, de
            dec b
            jr nz, .loop
        ret

    .dibujar_casilla:
        ;; Dibuja una casilla 2x2 (tiles TILE_CASILLA..TILE_CASILLA+3)
        ;; Requiere LCD apagado o estar en VBLANK
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

DEF TILE_NUM_0 = 5 ;; PLACEHOLDER: poner aqui el indice del tile de la cifra 0
 
;; Posicion del contador de moneda (en tiles; ocupa 2 de ancho). POR DETERMINAR
DEF HUD_MONEDA_COL  = 18
DEF HUD_MONEDA_FILA = 17
 
SECTION "Render numeros", ROM0
 
dibujar_numero::
    ;; Dibuja un numero de 00 a 99 con 2 tiles (siempre dos cifras: 7 -> "07").
    ;; Si a > 99 se dibuja 99. Espera por si mismo a VBLANK antes de escribir
    ;; Usa: a, bc, de, hl
    ;; Parametros entrada: a-numero (0-99), b-columna (0-19), c-fila (0-17), en tiles
    ;; Parametros salida: -
    cp 100
    jr c, .valido
    ld a, 99                        ;; Limite: evita tiles fuera de las cifras
    .valido:
    ld d, a                         ;; d = numero (se guarda mientras se calcula la dir)
 
    ;; hl = PANTALLA_INI + fila * TILEMAP_ANCHO + columna     (TILEMAP_ANCHO = 32)
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
    ld bc, PANTALLA_INI
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
        ld a, [VBLANK_DIR]
        cp 144
        jr c, .esperar_vblank
 
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl], a
    ret
 
dibujar_moneda::
    ;; Dibuja el saldo actual (wProtein) en la posicion del HUD
    ;; Usa: a, bc, de, hl
    ;; Parametros entrada: -
    ;; Parametros salida: -
    ld a, [wProtein]
    ld b, HUD_MONEDA_COL
    ld c, HUD_MONEDA_FILA
    call dibujar_numero
    ret
