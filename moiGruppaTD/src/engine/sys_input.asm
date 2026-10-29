;;==============================================================
;; Joypad: lee los botones y escribe wPad* (1 = recien pulsado)
;;==============================================================
INCLUDE "engine/hardware.inc"     ;; añadir alli: DEF rP1 = $FF00

DEF P1_DPAD    = $20              ;; Selecciona la cruceta
DEF P1_BOTONES = $10              ;; Selecciona A, B, Select, Start
DEF P1_NADA    = $30              ;; No selecciona nada

SECTION "Joypad data", WRAM0
joypad_anterior: ds 1             ;; Botones pulsados en el frame anterior

SECTION "Engine: joypad", ROM0

;; Guarda en la variable \2 un 1 si el bit \1 de C esta a 1, si no un 0
MACRO GUARDAR_BOTON
    xor a
    bit \1, c
    jr z, .no\@
    inc a
.no\@:
    ld [\2], a
ENDM

;; Sin botones pulsados al empezar
;; Usa: a
input_init::
    xor a
    ld [joypad_anterior], a
    ret

;; Lee el joypad (una vez por frame)
;; Usa: a, b, c
input_update::
    ld a, P1_DPAD             ;; \ Cruceta -> nibble alto de B
    ldh [rP1], a              ;; |
    ldh a, [rP1]              ;; | (varias lecturas: se estabiliza)
    ldh a, [rP1]              ;; |
    cpl                       ;; | 1 = pulsado
    and $0F                   ;; |
    swap a                    ;; |
    ld b, a                   ;; /

    ld a, P1_BOTONES          ;; \ Botones -> nibble bajo de B
    ldh [rP1], a              ;; |
    ldh a, [rP1]              ;; |
    ldh a, [rP1]              ;; |
    ldh a, [rP1]              ;; |
    ldh a, [rP1]              ;; |
    cpl                       ;; |
    and $0F                   ;; |
    or b                      ;; |
    ld b, a                   ;; / B = pulsados ahora: %AbArIzDe StSeBA

    ld a, P1_NADA             ;; Deja el joypad sin seleccionar
    ldh [rP1], a

    ld a, [joypad_anterior]   ;; \ C = recien pulsados = ahora AND NOT antes
    cpl                       ;; |
    and b                     ;; |
    ld c, a                   ;; |
    ld a, b                   ;; |
    ld [joypad_anterior], a   ;; /

    GUARDAR_BOTON 4, wPadRight
    GUARDAR_BOTON 5, wPadLeft
    GUARDAR_BOTON 6, wPadUp
    GUARDAR_BOTON 7, wPadDown
    GUARDAR_BOTON 0, wPadA
    GUARDAR_BOTON 1, wPadB
    GUARDAR_BOTON 2, wPadSelect
    GUARDAR_BOTON 3, wPadStart
    ret