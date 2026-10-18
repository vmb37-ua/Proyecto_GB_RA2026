;;----------LICENSE NOTICE-------------------------------------------------------------------------------------------------------;;
;;  This file is part of GBTelera: A Gameboy Development Framework                                                               ;;
;;  Copyright (C) 2024 ronaldo / Cheesetea / ByteRealms (@FranGallegoBR)                                                         ;;
;;                                                                                                                               ;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ;;
;; files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,    ;;
;; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the         ;;
;; Softwareis furnished to do so, subject to the following conditions:                                                           ;;
;;                                                                                                                               ;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.;;
;;                                                                                                                               ;;
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ;;
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ;;
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ;;
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ;;
;;-------------------------------------------------------------------------------------------------------------------------------;;

DEF TAM_ARRAY_POLLOS = 120
DEF TAM_ARRAY_STRONG = 120

SECTION "Data", WRAM0

;; 1 estado ($00 no existe, resto animación), 1 vida, 1 daño, 1 posicion
Array_chickens:: ds 160

;; 1 estado ($00 no existe, resto animación), 1 vida, 1 daño, 1 posicion
Array_strong:: ds 160

SECTION "Entry point", ROM0[$150]

main::

   

   call init ;; Inicialización del programa
   
   ;; Por cada ciclo
   game_mainloop:
      call render ;; Renderización
      call check_end ;; Ha acabado la partida? -> Llama a game_end
      call user_input ;; Actualizar el input del usuario en el modelo
      call simulation ;; Procedimiento del juego
   jr game_mainloop

   game_end:

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
