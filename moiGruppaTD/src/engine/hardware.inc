;;==============================================================
;; Registros y direcciones del hardware que usa el juego
;;==============================================================
IF !DEF(HARDWARE_INC)
DEF HARDWARE_INC = 1

DEF rLCDC = $FF40
DEF rLY   = $FF44
DEF rBGP  = $FF47

DEF LCDC_ON_BIT = 7
DEF VBLANK_LINE = 144

DEF VRAM_TILES = $8000
DEF TILE_TAM   = 16             ;; Bytes por tile

DEF BG_MAP         = $9800      ;; Tilemap del fondo
DEF PANTALLA_ANCHO = 20         ;; Tiles visibles por fila
DEF PANTALLA_ALTO  = 18         ;; Filas visibles
DEF TILEMAP_ANCHO  = 32         ;; Tiles por fila en el tilemap

DEF LCDC_CONFIG = %10010001     ;; LCD on, tiles en $8000, BG on
DEF BGP_CONFIG  = %11100100     ;; 3=negro, 2=gris oscuro, 1=gris claro, 0=blanco

ENDC
