;;==============================================================
;; Memoria: memcpy, memset y call_hl
;;==============================================================

SECTION "Engine: memory", ROM0

;; Copia bc bytes de hl a de
;; Usa: a, bc, de, hl
;; Parametros entrada: hl-origen, de-destino, bc-bytes (>0)
;; Parametros salida: -
memcpy::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, memcpy
    ret

;; Rellena bc bytes desde hl con el valor d
;; Usa: a, bc, hl
;; Parametros entrada: hl-destino, bc-bytes (>0), d-valor
;; Parametros salida: -
memset::
    ld a, d
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, memset
    ret

;; Salta a la rutina cuya direccion esta en hl ("call call_hl" = "call hl")
;; El ret de la rutina vuelve a la instruccion siguiente al call
;; Parametros entrada: hl-rutina
call_hl::
    jp hl
