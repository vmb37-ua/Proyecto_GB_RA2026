;;==============================================================
;; Gestor de entidades (Entity Manager)
;; Solo sabe de entidades: reservar, liberar y recorrer.
;; Nada de dibujar, mover ni colisionar (eso son los sistemas)
;;==============================================================
INCLUDE "man/man_entity.inc"

;; ALIGN[8]: el array empieza en $xx00 y mide menos de 256 bytes
SECTION "Entity array", WRAM0, ALIGN[8]
entity_array::  ds ENTITY_ARRAY_SIZE

SECTION "Entity manager", ROM0

;; Libera todas las entidades (CMP = 0)
;; Usa: a, b, hl
;; Parametros entrada: -
;; Parametros salida: -
man_entity_init::
    ld hl, entity_array
    ld b, MAX_ENTITIES
    .loop:
        ld [hl], 0              ;; entity.CMP = 0: libre
        ld a, l                 ;; \ HL += SIZEOF_ENTITY
        add SIZEOF_ENTITY       ;; | (array alineado:
        ld l, a                 ;; / solo cambia L)
        dec b
        jr nz, .loop
    ret

;; Busca una entidad libre y la reserva
;; No toca el resto de campos: los rellena quien llama
;; Usa: a, bc, hl. NO modifica de
;; Parametros entrada: a-componentes de la nueva entidad (CMP_RENDER...)
;; Parametros salida: Z, hl-entidad ([hl] = a | CMP_ALIVE)
;;                    NZ, no hay entidades libres
man_entity_alloc::
    ld c, a
    ld hl, entity_array
    ld b, MAX_ENTITIES
    .next:
        bit CMP_ALIVE_BIT, [hl] ;; \ Esta viva?
        jr z, .found            ;; / No: esta libre, la cogemos
        ld a, l                 ;; \ HL += SIZEOF_ENTITY
        add SIZEOF_ENTITY       ;; |
        ld l, a                 ;; /
        dec b
        jr nz, .next
    or 1                        ;; Array lleno: NZ
    ret

    .found:
        ld a, c
        or CMP_ALIVE
        ld [hl], a              ;; entity.CMP = componentes | ALIVE
        xor a                   ;; Z: exito
        ret

;; Libera una entidad: deja de existir para todos los sistemas
;; Usa: a
;; Parametros entrada: de-entidad
;; Parametros salida: -
man_entity_free::
    xor a
    ld [de], a
    ret

;; Llama a una rutina por cada entidad viva
;; La rutina recibe de-entidad y puede modificar todos los registros
;; Usa: a, bc, de, hl
;; Parametros entrada: hl-rutina
;; Parametros salida: -
man_entity_for_each::
    ld de, entity_array
    ld b, MAX_ENTITIES
    .next:
        ld a, [de]
        bit CMP_ALIVE_BIT, a    ;; \ Esta viva?
        jr z, .skip             ;; / No: la saltamos

        push bc                 ;; \ Guardamos contador,
        push de                 ;; | entidad
        push hl                 ;; / y rutina
        call call_hl            ;; rutina(de = entidad)
        pop hl
        pop de
        pop bc

    .skip:
        ld a, e                 ;; \ DE += SIZEOF_ENTITY
        add SIZEOF_ENTITY       ;; | (array alineado:
        ld e, a                 ;; / solo cambia E)
        dec b
        jr nz, .next
    ret
