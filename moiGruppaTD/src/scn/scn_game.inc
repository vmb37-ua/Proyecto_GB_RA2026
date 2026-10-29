;;==============================================================
;; Escena del juego: constantes
;;==============================================================
IF !DEF(SCN_GAME_INC)
DEF SCN_GAME_INC = 1

;;--------------------------------------------------------------
;; Strongmen (torres)
;;--------------------------------------------------------------
;; Numero de frames totales que suman las animaciones del strongman
DEF N_FRAMES_STRONG = 4

;; Numero de tipos diferentes de strongmen que hay en el juego
DEF N_TIPOS_STRONG = 6


;;--------------------------------------------------------------
;; Pollos (enemigos)
;;--------------------------------------------------------------
DEF CHICKEN_A = 0
DEF CHICKEN_B = 1
DEF CHICKEN_C = 2

DEF PRESET_SIZE = 2      ;; Bytes por cada tipo en la tabla chickenPresetsTable

DEF COL_ENTRADA      = 9          ;; Columna de casilla por la que entran los pollos
DEF MOVE_MASK        = %00111111  ;; Los pollos avanzan 1 casilla cada 64 frames
DEF ATAQUE_MASK      = %00001111  ;; Pollos y strongmen se pegan cada 16 frames
DEF RECOMPENSA_POLLO = 2          ;; Proteina por cada pollo derrotado

;;--------------------------------------------------------------
;; Mapa: carriles de 2 filas (en tiles)
;;--------------------------------------------------------------
DEF FILA_CAMINO  = 10
DEF CAMINO_ANCHO = 20
DEF N_CARRILES   = 3
DEF FILA_CARRIL0 = FILA_CAMINO / 2  ;; Fila de CASILLA del primer carril (5)

;;--------------------------------------------------------------
;; Cursor del jugador
;;--------------------------------------------------------------
DEF BOARD_COLS = 7                ;; Columnas de casilla donde se colocan strongmen (0-6)
DEF BOARD_ROWS = N_CARRILES       ;; Una fila del tablero por carril
DEF MENU_SLOTS = 5
DEF FILA_MENU  = 0                ;; Fila de casilla del menu de compra (columnas 0..4)

;;--------------------------------------------------------------
;; Estado de la partida (wGameState)
;;--------------------------------------------------------------
DEF GAME_JUGANDO = 0
DEF GAME_PERDIDO = 1              ;; Un pollo ha llegado a la columna 0 y quiere seguir
DEF GAME_GANADO  = 2              ;; Oleada terminada y no queda ningun pollo vivo
DEF POS_FINAL    = $44            ;; Casilla donde se dibuja el resultado (fila 4, col 4)

ASSERT MENU_SLOTS <= N_TIPOS_STRONG   ;; Cada hueco del menu es un tipo de strongman

ENDC
