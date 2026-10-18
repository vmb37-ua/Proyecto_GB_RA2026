DEF TAM_ARRAY_STRONG
DEF B_STRONG = 4
DEF N_STRONG_ARRAY = TAM_ARRAY_STRONG / B_STRONG

;; Numero de frames totales que suman las animaciones del strongman
DEF N_FRAMES_STRONG = 4

;; Numero de tipos diferentes de strongmen que hay en el juego
DEF N_TIPOS_STRONG = 6

SECTION "Strongmen", ROM0

VidaStrongmen: DB 10 DB 20 DB 30 DB 40 DB 50 DB 60

DanoStrongmen: DB 1 DB 2 DB 3 DB 4 DB 5 DB 6

;; Inicializa el array de strongmen a 0 en su estado
;; Modifica hl, a
initStrongArray:
    ld hl, Array_strong
    ld a, 0

    .loop:
        ld [hl+], 0
        inc hl
        inc hl
        inc hl
        
        inc a
        cp 40
        jr nz, .loop
        ret

;; Devuelve la posicion en hl del primer hueco del array de strongmen
;; Utiliza a, hl
;; Salida: hl -> Primer hueco
buscarSiguienteStrong:
    ld hl, Array_strong
    .loop:
        ld a, [hl]
        cp 0
        ret z
        inc hl
        inc hl
        inc hl
        inc hl
        jr .loop
        ret

;; Devuelve en a la vida del tipo a
;; Entrada: a -> Tipo strongman
;; Salida: a -> Vida strongman
;; Utiliza: hl, a, b, c
recuperarVidaTipo:
    ld hl, VidaStrongmen
    ld b, 0
    ld c, a
    add hl, bc
    ret

;; Devuelve en a el daño del tipo a
;; Entrada: a -> Tipo strongman
;; Salida: a -> Daño strongman
;; Utiliza: hl, a, b, c
recuperarDanoTipo:
    ld hl, DanoStrongmen
    ld b, 0
    ld c, a
    add hl, bc
    ret

;; Coloca un strongman tipo a en la posición b (ya normalizada)
;; Paramtros de entrada: a, b
;; Utiliza hl, a, b, c
colocarStrongman:
    push af
    call buscarSiguienteStrong
    pop af
    ld [hl+], (N_TIPOS_STRONG-1)*N_FRAMES_STRONG+1
    ld c, a
    
    push hl
    push bc
    call recuperarVidaTipo
    pop bc
    pop hl
    ld [hl+], a
    
    ld a, c
    push hl
    push bc
    call recuperarVidaTipo
    pop bc
    pop hl
    ld [hl+], a
    
    ld [hl], b
    ret
    
