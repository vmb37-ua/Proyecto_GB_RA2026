INCLUDE "man/man_entity.inc"
SECTION "Entity arrays", WRAM0
Array_strong:: ds MAX_TOWERS * ENTITY_SIZE
Array_chickens:: ds MAX_CHICKENS * ENTITY_SIZE
Array_shots:: ds MAX_SHOTS * ENTITY_SIZE
SECTION "Manager: entities", ROM0
man_entity_init::
    ld hl, Array_strong
    ld bc, (MAX_TOWERS + MAX_CHICKENS + MAX_SHOTS) * ENTITY_SIZE
    ld d, 0
    jp mem_set
;; DE=entidad, A=campo -> HL=direccion. Conserva DE y BC.
entity_field::
    ld h, 0
    ld l, a
    add hl, de
    ret
;; DE=array, B=capacidad -> Z y HL=hueco; NZ si lleno. Acotado.
man_entity_free::
    ld h, d
    ld l, e
.loop
    ld a, [hl]
    and a
    ret z
    push de
    ld de, ENTITY_SIZE
    add hl, de
    pop de
    dec b
    jr nz, .loop
    or 1
    ret
;; DE=array, B=capacidad, HL=callback(DE). Solo registros activos.
;; El callback puede destruir registros; no debe cambiar SP.
man_entity_each::
.loop
    push bc
    push de
    push hl
    ld a, [de]
    and a
    call nz, engine_call_hl
    pop hl
    pop de
    pop bc
    ld a, e
    add ENTITY_SIZE
    ld e, a
    jr nc, .next
    inc d
.next
    dec b
    jr nz, .loop
    ret
man_chickens_each::
    ld de, Array_chickens
    ld b, MAX_CHICKENS
    jp man_entity_each
man_towers_each::
    ld de, Array_strong
    ld b, MAX_TOWERS
    jp man_entity_each
man_shots_each::
    ld de, Array_shots
    ld b, MAX_SHOTS
    jp man_entity_each
