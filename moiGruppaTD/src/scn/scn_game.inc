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

;; Proteina que cuesta colocar un strongman (de momento, igual para todos)
DEF COSTE_STRONG = 2

;;--------------------------------------------------------------
;; Pollos (enemigos)
;;--------------------------------------------------------------
DEF CHICKEN_A = 0
DEF CHICKEN_B = 1
DEF CHICKEN_C = 2

DEF PRESET_SIZE = 2  ;; Bytes por cada tipo en la tabla chickenPresetsTable

;;--------------------------------------------------------------
;; Mapa: carriles de 2 filas (en tiles)
;;--------------------------------------------------------------
DEF FILA_CAMINO  = 10
DEF CAMINO_ANCHO = 20
DEF N_CARRILES   = 3

;;--------------------------------------------------------------
;; Cursor del jugador
;;--------------------------------------------------------------
DEF BOARD_COLS  = 7
DEF BOARD_ROWS  = 4
DEF MENU_SLOTS  = 5

ASSERT MENU_SLOTS <= N_TIPOS_STRONG   ;; Cada hueco del menu es un tipo de strongman

ENDC
