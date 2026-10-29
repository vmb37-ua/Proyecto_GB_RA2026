;;==============================================================
;; Contador de frames
;; Dato publico del motor: cualquiera lo lee, solo frame_tick lo escribe
;;==============================================================
SECTION "Frame data", WRAM0
frame_counter:: ds 1            ;; Frames desde el principio (da la vuelta)

SECTION "Engine: frame", ROM0

;; Usa: a
frame_init::
    xor a
    ld [frame_counter], a
    ret

;; Un frame mas. Lo llama el bucle principal una vez por frame
;; Usa: hl
frame_tick::
    ld hl, frame_counter
    inc [hl]
    ret
