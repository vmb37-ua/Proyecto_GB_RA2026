;;==============================================================
;; Gestor de entidades: estructura y componentes
;;==============================================================
IF !DEF(MAN_ENTITY_INC)
DEF MAN_ENTITY_INC = 1
;;--------------------------------------------------------------
;; Entidades: array de MAX_ENTITIES entidades de SIZEOF_ENTITY bytes
;; Pollos (enemigos) y strongmen (torres) comparten el mismo array:
;; los distingue E_KIND
;;--------------------------------------------------------------
DEF MAX_ENTITIES = 40
RSRESET
DEF E_CMP         RB 1      ;; 0  Componentes de la entidad (bitflags). 0 = libre
DEF E_KIND        RB 1      ;; 1  Que es: KIND_CHICKEN, KIND_STRONG
DEF E_ESTADO      RB 1      ;; 2  Bit 7: se ha movido este frame (ESTADO_MOVIDO).
                            ;;    Bits 0-6: frame actual de la animacion
DEF E_VIDA        RB 1      ;; 3  Vida
DEF E_DANO        RB 1      ;; 4  Daño
DEF E_POS         RB 1      ;; 5  Casilla 2x2 (normalizada): %ffffcccc
                            ;;    ffff = fila (0-8), cccc = columna (0-9)
DEF SIZEOF_ENTITY RB 0      ;; = 6
DEF ENTITY_ARRAY_SIZE = MAX_ENTITIES * SIZEOF_ENTITY

;; El array esta alineado (ALIGN[8]) y cabe en 256 bytes:
;; pasar de una entidad a otra (o de un campo a otro) solo cambia L
ASSERT ENTITY_ARRAY_SIZE <= 256

;; Bits de CMP. CMP = 0 → la entidad esta LIBRE
DEF CMP_RENDER_BIT = 0
DEF CMP_MOVE_BIT   = 1
DEF CMP_ALIVE_BIT  = 7
;; Mascaras de CMP
DEF CMP_RENDER     = 1 << CMP_RENDER_BIT    ;; Se dibuja en su casilla (E_POS)
DEF CMP_MOVE       = 1 << CMP_MOVE_BIT      ;; Avanza por el carril (los pollos)
DEF CMP_ALIVE      = 1 << CMP_ALIVE_BIT

;; E_ESTADO
DEF ESTADO_MOVIDO_BIT = 7   ;; La pone sys_movement y la quita sys_render (borra la casilla vieja)
DEF ESTADO_MOVIDO     = 1 << ESTADO_MOVIDO_BIT

;; Una entidad con VIDA = 0 esta MUERTA: ya no hace nada.
;; sys_render borra su casilla y la libera (ver game_matar)

;; KIND
DEF KIND_CHICKEN = 1
DEF KIND_STRONG  = 2

ENDC
