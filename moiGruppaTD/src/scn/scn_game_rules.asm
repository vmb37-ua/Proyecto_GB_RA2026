;;==============================================================
;; Escena del juego: reglas
;; Lo que es propio de ESTE juego (strongmen, pollos, comprar, fin de partida...).
;; Usa el gestor de entidades, pero no sabe recorrerlo ni dibujar
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game rules", ROM0

VidaStrongmen: db 10, 20, 30, 40, 50, 60
DanoStrongmen: db 1, 2, 3, 4, 5, 6

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

;; Paga y coloca un strongman en la casilla elegida con el cursor
;; Tipo = wMenuSlot, casilla = (wSelectedRow, wSelectedCol)
;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: NC, comprado. C, no hay saldo o no hay entidades libres
game_comprar_strong::
    ld a, [wProtein]            ;; \ Hay saldo suficiente?
    cp COSTE_STRONG             ;; | (se mira antes de colocar: si no hay
    ret c                       ;; / hueco no se cobra)

    ld a, [wSelectedRow]        ;; \ B = posicion = %ffffcccc
    swap a                      ;; |
    ld b, a                     ;; |
    ld a, [wSelectedCol]        ;; |
    or b                        ;; |
    ld b, a                     ;; /
    ld a, [wMenuSlot]           ;; A = tipo
    call game_strong_colocar
    jr z, .pagar
    scf                         ;; No hay hueco: C
    ret

    .pagar:
        ld b, COSTE_STRONG
        jp moneda_restar        ;; Hay saldo: NC

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

;; Ha acabado la partida?
;; Usa: a
;; Parametros entrada: -
;; Parametros salida: Z, la partida ha acabado. NZ, sigue
game_check_end::
    or 1                        ;; De momento no acaba nunca: NZ
    ret
