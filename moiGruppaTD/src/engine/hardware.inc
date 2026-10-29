;;==============================================================
;; Registros y direcciones del hardware que usa el juego
;;==============================================================
IF !DEF(HARDWARE_INC)
DEF HARDWARE_INC = 1

DEF rP1   = $FF00                ;; Joypad
DEF rLCDC = $FF40
DEF rLY   = $FF44
DEF rBGP  = $FF47
DEF rOBP0 = $FF48                ;; Paleta de los sprites

DEF LCDC_ON_BIT = 7
DEF VBLANK_LINE = 144

DEF VRAM_TILES = $8000
DEF TILE_TAM   = 16             ;; Bytes por tile

DEF BG_MAP         = $9800      ;; Tilemap del fondo
DEF PANTALLA_ANCHO = 20         ;; Tiles visibles por fila
DEF PANTALLA_ALTO  = 18         ;; Filas visibles
DEF TILEMAP_ANCHO  = 32         ;; Tiles por fila en el tilemap

DEF LCDC_CONFIG = %10010011     ;; LCD on, tiles en $8000, BG on, sprites 8x8 on
DEF BGP_CONFIG  = %11100100     ;; 3=negro, 2=gris oscuro, 1=gris claro, 0=blanco
DEF OBP0_CONFIG = %11100100     ;; Igual, pero en los sprites el color 0 es transparente

DEF OAM_RAM      = $FE00        ;; 40 sprites de 4 bytes: Y, X, TILE, ATTR
DEF OAM_TAM      = 40 * 4
DEF OAM_Y_OFFSET = 16           ;; Y de la OAM = Y de la pantalla + 16
DEF OAM_X_OFFSET = 8            ;; X de la OAM = X de la pantalla + 8
DEF ATTR_XFLIP   = %00100000    ;; Sprite volteado en horizontal
DEF ATTR_YFLIP   = %01000000    ;; Sprite volteado en vertical

ENDC
