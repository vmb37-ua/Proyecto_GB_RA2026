;;==============================================================
;; Escena del juego: reglas
;; Lo que es propio de ESTE juego (strongmen, pollos, comprar, fin de partida...).
;; Usa el gestor de entidades, pero no sabe recorrerlo ni dibujar
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game rules", ROM0

VidaStrongmen:  db 10, 20, 30, 40, 50, 60
DanoStrongmen:  db 1, 2, 3, 4, 5, 6
CosteStrongmen: db 2, 3, 4, 5, 6, 7

SECTION "Game state", WRAM0
wGameState:: ds 1               ;; GAME_JUGANDO, GAME_PERDIDO o GAME_GANADO

SECTION "Game rules (2)", ROM0

;; Devuelve en a la vida del tipo a
;; Usa: a, bc, hl
;; Parametros entrada: a-tipo strongman
;; Parametros salida: a-vida strongman
game_strong_vida:
    ld hl, VidaStrongmen
    jr game_leer_tabla

;; Devuelve en a el daño del tipo a
;; Usa: a, bc, hl
;; Parametros entrada: a-tipo strongman
;; Parametros salida: a-daño strongman
game_strong_dano:
    ld hl, DanoStrongmen
    ;; jr game_leer_tabla       ;; (justo debajo)

;; Devuelve en a el elemento a de la tabla hl
;; Usa: a, bc, hl
;; Parametros entrada: hl-tabla, a-indice
;; Parametros salida: a-tabla[a]
game_leer_tabla:
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl]
    ret

;; Coloca un strongman tipo a en la posicion b (ya normalizada, ver E_POS)
;; Crea una entidad KIND_STRONG con RENDER, su vida y su daño
;; Usa: a, bc, de, hl
;; Parametros entrada: a-tipo (0..N_TIPOS_STRONG-1), b-posicion
;; Parametros salida: Z, colocado (hl-entidad.POS)
;;                    NZ, no hay entidades libres
game_strong_colocar::
    ld d, a                     ;; \ man_entity_alloc no modifica DE:
    ld e, b                     ;; / D = tipo, E = posicion

    ld a, CMP_RENDER
    call man_entity_alloc       ;; HL = entidad (CMP ya escrito)
    ret nz                      ;; No hay hueco

    inc l                       ;; \ entity.KIND = KIND_STRONG
    ld [hl], KIND_STRONG        ;; | (array alineado: solo cambia L)
    inc l                       ;; /

    ASSERT N_FRAMES_STRONG == 4
    ld a, d                     ;; \ entity.ESTADO = tipo * N_FRAMES_STRONG
    add a                       ;; | (primer frame de la animacion de su tipo)
    add a                       ;; |
    ld [hl+], a                 ;; /

    push hl                     ;; \ entity.VIDA = VidaStrongmen[tipo]
    ld a, d                     ;; |
    call game_strong_vida       ;; |
    pop hl                      ;; |
    ld [hl+], a                 ;; /

    push hl                     ;; \ entity.DANO = DanoStrongmen[tipo]
    ld a, d                     ;; |
    call game_strong_dano       ;; |
    pop hl                      ;; |
    ld [hl+], a                 ;; /

    ld [hl], e                  ;; entity.POS = posicion

    xor a                       ;; Z: colocado
    ret

;; Tabla con los datos estaticos de los pollos: [Vida, Daño]
chickenPresetsTable:
    db 10, 1  ;tipo a
    db 5,  2  ;tipo b
    db 30, 5  ;tipo c

;; Crea un pollo tipo a en la posicion b (ya normalizada, ver E_POS)
;; Crea una entidad KIND_CHICKEN con RENDER y MOVE, su vida y su daño
;; Usa: a, bc, de, hl
;; Parametros entrada: a-ID del tipo de pollo (CHICKEN_A, CHICKEN_B...), b-posicion
;;                     (la posicion depende de como definamos la logica de los niveles)
;; Parametros salida: Z, creado (hl-entidad.POS)
;;                    NZ, no hay entidades libres
game_chicken_spawn::
    ld d, a                     ;; \ man_entity_alloc no modifica DE:
    ld e, b                     ;; / D = tipo, E = posicion

    ld a, CMP_RENDER | CMP_MOVE
    call man_entity_alloc       ;; HL = entidad (CMP ya escrito)
    ret nz                      ;; No hay hueco

    inc l                       ;; \ entity.KIND = KIND_CHICKEN
    ld [hl], KIND_CHICKEN       ;; |
    inc l                       ;; /
    ld [hl], 0                  ;; entity.ESTADO = primer frame
    inc l

    push hl                     ;; Guardamos la entidad
    ASSERT PRESET_SIZE == 2
    ld a, d                     ;; \ HL = chickenPresetsTable + ID * PRESET_SIZE
    add a                       ;; |
    ld c, a                     ;; |
    ld b, 0                     ;; |
    ld hl, chickenPresetsTable  ;; |
    add hl, bc                  ;; /
    ld a, [hl+]                 ;; \ B = Vida
    ld b, a                     ;; |
    ld c, [hl]                  ;; / C = Daño
    pop hl                      ;; Recuperamos la entidad

    ld a, b
    ld [hl+], a                 ;; entity.VIDA
    ld a, c
    ld [hl+], a                 ;; entity.DANO
    ld [hl], e                  ;; entity.POS

    xor a                       ;; Z: creado
    ret

;;--------------------------------------------------------------
;; CODIGO COMUN
;;--------------------------------------------------------------

;; Empieza la partida
;; Usa: a
game_estado_init::
    ld a, GAME_JUGANDO
    ld [wGameState], a
    ret

;; Devuelve en a el coste del tipo a
;; Usa: a, bc, hl
;; Parametros entrada: a-tipo strongman
;; Parametros salida: a-coste
game_strong_coste::
    ld hl, CosteStrongmen
    jr game_leer_tabla

;; Mata una entidad: VIDA = 0 y solo le queda RENDER (deja de moverse y de pegar).
;; sys_render borra su casilla y la libera
;; Usa: a
;; Parametros entrada: hl-entidad
;; Parametros salida: hl-entidad
game_matar::
    ld [hl], CMP_ALIVE | CMP_RENDER
    ld a, l                     ;; \ entity.VIDA = 0
    add E_VIDA                  ;; |
    ld l, a                     ;; |
    ld [hl], 0                  ;; /
    sub E_VIDA                  ;; \ HL = entidad otra vez
    ld l, a                     ;; /
    ret

;;--------------------------------------------------------------
;; EJERCICIO 5
;;--------------------------------------------------------------
;; Busca una entidad VIVA (CMP_ALIVE y VIDA != 0) que este en la casilla b
;; Usa: a, c, hl. NO modifica b ni de
;; Parametros entrada: b-posicion
;; Parametros salida: Z, hl-entidad encontrada
;; NZ, la casilla esta libre
game_entidad_en::
    ld c, 0
    ld hl, entity_array
    .loop:
        ld a, [hl]
        bit CMP_ALIVE_BIT, a
        jr z, .pasar

        inc l
        inc l
        inc l
        ld a, [hl]
        cp 0
        dec hl
        dec hl
        dec hl
        jr z, .pasar

        inc l
        inc l
        inc l
        inc l
        inc l
        ld a, [hl]
        cp b
        dec hl
        dec hl
        dec hl
        dec hl
        dec hl
        jr z, .encontrado

    .pasar:
        inc c
        ld a, l
        add SIZEOF_ENTITY
        ld l, a
        ld a, c
        cp MAX_ENTITIES
        jr nz, .loop
        or 1
        ret
    
    .encontrado:
        ;; hl ya apunta al byte inicial de la entidad (CMP)
        xor a
        ret

;;--------------------------------------------------------------
;; EJERCICIO 6 (a)
;;--------------------------------------------------------------
;; Paga y coloca un strongman en la casilla elegida con el cursor
;; Tipo = wMenuSlot, casilla = (FILA_CARRIL0 + wSelectedRow, wSelectedCol)
;; No hace nada si la casilla esta ocupada o no hay saldo suficiente
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: NC, comprado. C, no se ha comprado
game_comprar_strong::
    ;; ◉◉TU CÓDIGO: copia aqui el codigo del enunciado y corrigelo◉◉
    scf                         ;; (provisional: nunca se compra)
    ret
