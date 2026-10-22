IF !DEF(MAN_ENTITY_INC)
DEF MAN_ENTITY_INC = 1
INCLUDE "game.inc"
;; Registro compartido de 8 bytes. KIND=0 significa hueco libre.
DEF E_KIND = 0
DEF E_HP = 1
DEF E_DAMAGE = 2
DEF E_X = 3
DEF E_ROW = 4
DEF E_TIMER = 5
DEF E_SPEED = 6
DEF E_MOVE = 7
DEF ENTITY_SIZE = 8
;; Los iteradores avanzan exactamente un registro de ocho bytes.
ASSERT ENTITY_SIZE == 8
ENDC
