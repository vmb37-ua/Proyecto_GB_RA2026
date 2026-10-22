SECTION "Engine: memory", ROM0
;; HL=destino, BC=longitud (>0), D=valor. Destruye A,BC,HL.
mem_set::
    ld a, d
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, mem_set
    ret
;; HL=origen, DE=destino, BC=longitud (>0). Destruye A,BC,DE,HL.
mem_copy::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, mem_copy
    ret
engine_call_hl::
    jp hl
