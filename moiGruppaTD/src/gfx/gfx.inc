;;==============================================================
;; Graficos: indices en VRAM de los tiles (cargados en gfx_init)
;;==============================================================
IF !DEF(GFX_INC)
DEF GFX_INC = 1

DEF TILE_VACIO     = 0
DEF TILE_CASILLA   = 1 ;; 1 sup-izq, 2 sup-der, 3 inf-izq, 4 inf-der
DEF TILE_CAMINO     = 5 ;; Borde de arriba del carril
DEF TILE_CAMINO_INV = 6 ;; Borde de abajo del carril
DEF TILE_NUM_0      = 5 ;; PLACEHOLDER: poner aqui el indice del tile de la cifra 0

ENDC
