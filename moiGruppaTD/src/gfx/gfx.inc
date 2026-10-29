;;==============================================================
;; Graficos: indices en VRAM de los tiles (cargados en gfx_init)
;;==============================================================
IF !DEF(GFX_INC)
DEF GFX_INC = 1

DEF TILE_VACIO      = 0
DEF TILE_CASILLA    = 1  ;; 1..4   Casilla placeholder (sup-izq, sup-der, inf-izq, inf-der)
DEF TILE_CAMINO     = 5  ;;        Borde de arriba del carril
DEF TILE_CAMINO_INV = 6  ;;        Borde de abajo del carril
DEF TILE_POLLO      = 7  ;; 7..10  Pollo 2x2 (sup-izq, sup-der, inf-izq, inf-der)
DEF TILE_STRONG     = 11 ;; 11..14 Strongman 2x2 (mismo orden)
DEF TILE_CURSOR     = 15 ;;        Esquina sup-izq del cursor (las otras 3: volteada)
DEF TILE_NUM_0      = 16 ;; 16..25 Cifras 0..9

ENDC
