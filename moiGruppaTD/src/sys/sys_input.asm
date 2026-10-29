;;==============================================================
;; Sistema de input: cursor del jugador (tablero y menu de compra)
;; Actualiza el modelo con el input del usuario. Comprar es una regla
;; del juego: la hace game_comprar_strong (scn/scn_game_rules.asm)
;;==============================================================
INCLUDE "scn/scn_game.inc"

; ==============================================================================
; VARIABLES EN RAM (Globales para que el motor las pueda escribir)
; ==============================================================================
SECTION "CursorVars", WRAM0

wCursorState::  ds 1    ; 0 = Tablero, 1 = Menu Superior
wCursorCol::    ds 1    
wCursorRow::    ds 1    
wSelectedCol::  ds 1    
wSelectedRow::  ds 1    
wMenuSlot::     ds 1    

; Variables de botones (El motor externo debe escribir en ellas 0 o 1)
wPadUp::        ds 1
wPadDown::      ds 1
wPadLeft::      ds 1
wPadRight::     ds 1
wPadStart::     ds 1
wPadSelect::    ds 1
wPadA::         ds 1
wPadB::         ds 1

; ==============================================================================
; RUTINA PRINCIPAL: LÓGICA DEL SELECTOR
; ==============================================================================
SECTION "System: input", ROM0

;; Usa: a, bc, de, hl
;; Parametros entrada: -
;; Parametros salida: -
sys_input_update::
    ; Quite lo de leer desde aqui
    ; --- MÁQUINA DE ESTADOS ---
    ld   a, [wCursorState]
    or   a
    jr   nz, .modo_menu

; ==============================================================================
; ESTADO 0: NAVEGACIÓN POR EL TABLERO
; ==============================================================================
.modo_tablero:
    ; -- Mover Arriba --
    ld   a, [wPadUp]
    or   a
    jr   z, .tab_abajo
    ld   a, [wCursorRow]
    or   a
    jr   z, .tab_abajo
    dec  a
    ld   [wCursorRow], a

.tab_abajo:
    ; -- Mover Abajo --
    ld   a, [wPadDown]
    or   a
    jr   z, .tab_izq
    ld   a, [wCursorRow]
    cp   BOARD_ROWS - 1
    jr   nc, .tab_izq
    inc  a
    ld   [wCursorRow], a

.tab_izq:
    ; -- Mover Izquierda --
    ld   a, [wPadLeft]
    or   a
    jr   z, .tab_der
    ld   a, [wCursorCol]
    or   a
    jr   z, .tab_der
    dec  a
    ld   [wCursorCol], a

.tab_der:
    ; -- Mover Derecha --
    ld   a, [wPadRight]
    or   a
    jr   z, .tab_btnA
    ld   a, [wCursorCol]
    cp   BOARD_COLS - 1
    jr   nc, .tab_btnA
    inc  a
    ld   [wCursorCol], a

.tab_btnA:
    ; -- Confirmar Casilla (A) --
    ld   a, [wPadA]
    or   a
    ret  z
    
    ; Guardar posicion elegida y cambiar al menu superior
    ld   a, [wCursorCol]
    ld   [wSelectedCol], a
    ld   a, [wCursorRow]
    ld   [wSelectedRow], a

    ld   a, 1
    ld   [wCursorState], a
    xor  a
    ld   [wMenuSlot], a
    ret

; ==============================================================================
; ESTADO 1: NAVEGACIÓN EN EL MENÚ SUPERIOR DE COMPRA
; ==============================================================================
.modo_menu:
    ; -- Cancelar accion (B) --
    ld   a, [wPadB]
    or   a
    jr   z, .menu_izq
    xor  a
    ld   [wCursorState], a
    ret

.menu_izq:
    ; -- Seleccionar Izquierda --
    ld   a, [wPadLeft]
    or   a
    jr   z, .menu_der
    ld   a, [wMenuSlot]
    or   a
    jr   z, .menu_der
    dec  a
    ld   [wMenuSlot], a

.menu_der:
    ; -- Seleccionar Derecha --
    ld   a, [wPadRight]
    or   a
    jr   z, .menu_btnA
    ld   a, [wMenuSlot]
    cp   MENU_SLOTS - 1
    jr   nc, .menu_btnA
    inc  a
    ld   [wMenuSlot], a

.menu_btnA:
    ; -- Comprar unidad (A) --
    ld   a, [wPadA]
    or   a
    ret  z

    ; Paga y coloca el strongman (tipo wMenuSlot) en la casilla elegida
    call game_comprar_strong
    ret  c                      ; No hay saldo (o no hay hueco): seguimos en el menu

    ; Volver al tablero
    xor  a
    ld   [wCursorState], a
    ret

; ==============================================================================
; INICIALIZACIÓN
; ==============================================================================
;; Usa: a
;; Parametros entrada: -
;; Parametros salida: -
sys_input_init::
    xor  a
    ld   [wCursorState], a
    ld   [wCursorCol], a
    ld   [wCursorRow], a
    ld   [wMenuSlot], a
    ld   [wPadUp], a
    ld   [wPadDown], a
    ld   [wPadLeft], a
    ld   [wPadRight], a
    ld   [wPadA], a
    ld   [wPadB], a
    ld   [wPadStart], a
    ld   [wPadSelect], a
    ret

