;; ==============================================================================
;; MONEDA DEL JUEGO (proteina)
;;
;; moneda_init lo pone inicial a PROTEIN_INITIAL
;; moneda_sumar suma b al saldo y lo deja en PROTEIN_MAX si se pasa
;; moneda_restar resta b solo si hay saldo suficiente, si no lo deja igual y pone el carry a 1
;; El modulo es el dueño de su dato (wProtein): solo estas rutinas lo escriben
;; ==============================================================================
;; Ejemplos:
;;
;;   Enemigo derrotado:   ld b, 3
;;                        call moneda_sumar
;;
;;   Construir torre:     ld b, 2
;;                        call moneda_restar
;;                        ret c              ;; carry=1 -> no hay saldo, no construir
;; ==============================================================================
;;

DEF PROTEIN_INITIAL = 10
DEF PROTEIN_MAX = 99

SECTION "Protein data", WRAM0

wProtein::      ds 1    ;; Saldo de proteina

SECTION "Protein", ROM0

;; Usa: a
;; Parametros entrada: -
;; Parametros salida: -
moneda_init::

    ld a, PROTEIN_INITIAL
    ld [wProtein], a
    ret
 
;; Usa: a
;; Parametros entrada: b-cantidad
;; Parametros salida: -
moneda_sumar::

    ld a, [wProtein]
    add b
    jr c, .desborda                  
    cp PROTEIN_MAX + 1
    jr c, .guardar                  
    .desborda:
        ld a, PROTEIN_MAX
    .guardar:
        ld [wProtein], a
        ret
 
;; Usa: a
;; Parametros entrada: b-cantidad
;; Parametros salida: NC, restado. C, no hay saldo suficiente (no cambia)
moneda_restar::

    ld a, [wProtein]
    sub b
    ret c                          
    ld [wProtein], a                
    ret
