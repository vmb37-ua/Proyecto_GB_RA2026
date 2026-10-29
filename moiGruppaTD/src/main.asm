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

;; Las entidades (pollos y strongmen) estan en man/man_entity.asm

SECTION "Entry point", ROM0[$150]

;; Inicializa la consola: graficos con el LCD apagado y la escena del juego
;; Usa: a, bc, de, hl
init_console::
   call screen_off         ;; \ Con el LCD apagado:
   call gfx_init           ;; | tiles y paleta
   call scene_game_init    ;; / y la escena del juego
   jp screen_on

main::
   call init_console ;; Inicialización del programa

   ;; Por cada ciclo
   game_mainloop:
      call scene_game_update ;; Input, simulación y renderización
      call game_check_end    ;; Ha acabado la partida? (Z) -> game_end
   jr nz, game_mainloop

   game_end:

   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
