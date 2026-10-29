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
DEF E_ESTADO      RB 1      ;; 2  Frame actual de la animacion
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
DEF CMP_ALIVE_BIT  = 7
;; Mascaras de CMP
DEF CMP_RENDER     = 1 << CMP_RENDER_BIT    ;; Se dibuja en su casilla (E_POS)
DEF CMP_ALIVE      = 1 << CMP_ALIVE_BIT

;; KIND
DEF KIND_CHICKEN = 1
DEF KIND_STRONG  = 2

ENDC
