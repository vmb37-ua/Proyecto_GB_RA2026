;; ==============================================================================
;; MONEDA DEL JUEGO (proteina)
;;
;; protein_init lo pone inicial a PROTEIN_INITIAL
;; protein_add suma b al saldo y lo deja en PROTEIN_MAX si se pasa
;; protein_sub resta b solo si hay salto suficiente, si no lo deja igual y pone el carry a 1
;; ==============================================================================
;; Ejemplos:
;;
;;   Enemigo derrotado:   ld b, 3
;;                        call protein_add
;;
;;   Construir torre:     ld b, 2
;;                        call protein_sub
;;                        ret c              ;; carry=1 -> no hay saldo, no construir
;; ==============================================================================
;;

DEF PROTEIN_INITIAL = 10
DEF PROTEIN_MAX = 99

SECTION "Protein", ROM0

moneda_init::

    ld a, PROTEIN_INITIAL
    ld [wProtein], a
    ret
 
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
 
moneda_restar::

    ld a, [wProtein]
    sub b
    ret c                          
    ld [wProtein], a                
    ret
