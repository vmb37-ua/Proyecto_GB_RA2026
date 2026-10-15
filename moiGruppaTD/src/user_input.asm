SECTION "User input", ROM0

; ==============================================================================
; CONSTANTES Y VARIABLES DEL JUGADOR
; ==============================================================================
DEF BOARD_COLS  = 7             ; Limite de casillas horizontales
DEF BOARD_ROWS  = 4             ; Limite de casillas verticales
DEF MENU_SLOTS  = 5             ; Opciones en el menu de compra superior

SECTION "CursorVars", WRAM0
wCursorState:   ds 1            ; Maquina de estados: 0 = Tablero, 1 = Menu Superior
wCursorCol:     ds 1            ; Posicion X en el tablero (0 a 6)
wCursorRow:     ds 1            ; Posicion Y en el tablero (0 a 3)
wMenuSlot:      ds 1            ; Posicion X en el menu de compra (0 a 4)
wProtein:       ds 1            ; Dinero/Proteina del jugador

wInputHeld:     ds 1            ; Registro de botones que se mantienen pulsados
wInputPressed:  ds 1            ; Registro de botones pulsados en este fotograma (flanco)

SECTION "CursorLogic", ROM0
; ==============================================================================
; RUTINA PRINCIPAL: LÓGICA DEL JUGADOR
; ==============================================================================
user_input::
    ; --------------------------------------------------------------------------
    ; 1. LECTURA DEL HARDWARE DEL MANDO (Joypad en $FF00)
    ; --------------------------------------------------------------------------
    ; Leer la cruceta direccional (escribiendo $20 en $FF00)
    ld   a, $20
    ld   [$FF00], a
    ld   a, [$FF00]             ; Leer varias veces seguidas da tiempo al
    ld   a, [$FF00]             ; hardware a estabilizar la señal de rebote
    cpl                         ; Invertir bits (1 = pulsado, 0 = soltado)
    and  $0F                    ; Quedarnos solo con los 4 bits de respuesta
    swap a                      ; Mover la cruceta a los 4 bits altos (bits 4-7)
    ld   b, a                   ; Guardar temporalmente en B

    ; Leer los botones A, B, Select, Start (escribiendo $10 en $FF00)
    ld   a, $10
    ld   [$FF00], a
    ld   a, [$FF00]
    ld   a, [$FF00]
    cpl
    and  $0F                    ; Quedarnos con los 4 bits bajos (bits 0-3)
    or   b                      ; Combinar los botones (0-3) con la cruceta en B (4-7)
    ld   b, a                   ; B contiene ahora el estado completo del mando
    
    ; Apagar el mando para ahorrar bateria (escribiendo $30)
    ld   a, $30
    ld   [$FF00], a
    
    ; Calcular el flanco de subida (input_pressed): botones recien pulsados
    ld   a, [wInputHeld]        ; Leer lo que estaba pulsado en el frame anterior
    cpl                         ; Invertirlo
    and  b                      ; Comparar con lo pulsado ahora (A = (NOT Held) AND Nuevo)
    ld   [wInputPressed], a     ; Guardar el resultado (solo vale 1 si acaba de pulsarse)
    ld   a, b
    ld   [wInputHeld], a        ; Actualizar el historial para el frame que viene

    ; --------------------------------------------------------------------------
    ; 2. MÁQUINA DE ESTADOS DEL CURSOR
    ; --------------------------------------------------------------------------
    ld   a, [wCursorState]      ; Mirar si estamos en el tablero (0) o en el menu (1)
    or   a                      ; or a evalua A. Si A no es 0, desactiva el flag Z
    jr   nz, .modo_menu         ; Si Z=0 (era 1), salta a la logica del menu

; ==============================================================================
; ESTADO 0: NAVEGACIÓN POR EL TABLERO
; ==============================================================================
.modo_tablero:
    ld   a, [wInputPressed]     ; Cargar botones recien pulsados
    
    ; -- Mover Arriba (Cruceta = Bit 6) --
    bit  6, a                   ; ¿Se ha pulsado Arriba?
    jr   z, .tab_abajo          ; Si no, saltar a comprobar Abajo
    ld   a, [wCursorRow]        ; Cargar fila actual
    or   a                      ; ¿Es la fila 0?
    jr   z, .tab_abajo          ; Si es 0, no podemos subir mas
    dec  a                      ; Restar 1 a la fila
    ld   [wCursorRow], a        ; Guardar nueva posicion

.tab_abajo:
    ; -- Mover Abajo (Cruceta = Bit 7) --
    ld   a, [wInputPressed]
    bit  7, a                   ; ¿Se ha pulsado Abajo?
    jr   z, .tab_izq
    ld   a, [wCursorRow]
    cp   BOARD_ROWS - 1         ; ¿Hemos llegado a la ultima fila (3)?
    jr   nc, .tab_izq           ; Si Fila >= 3, no podemos bajar mas
    inc  a                      ; Sumar 1 a la fila
    ld   [wCursorRow], a

.tab_izq:
    ; -- Mover Izquierda (Cruceta = Bit 5) --
    ld   a, [wInputPressed]
    bit  5, a                   ; ¿Se ha pulsado Izquierda?
    jr   z, .tab_der
    ld   a, [wCursorCol]
    or   a                      ; ¿Es la columna 0?
    jr   z, .tab_der            ; Tope izquierdo alcanzado
    dec  a
    ld   [wCursorCol], a

.tab_der:
    ; -- Mover Derecha (Cruceta = Bit 4) --
    ld   a, [wInputPressed]
    bit  4, a                   ; ¿Se ha pulsado Derecha?
    jr   z, .tab_btnA
    ld   a, [wCursorCol]
    cp   BOARD_COLS - 1         ; ¿Hemos llegado a la ultima columna (6)?
    jr   nc, .tab_btnA          ; Tope derecho alcanzado
    inc  a
    ld   [wCursorCol], a

.tab_btnA:
    ; -- Confirmar Casilla (Boton A = Bit 0) --
    ld   a, [wInputPressed]
    bit  0, a                   ; ¿Se ha pulsado A?
    ret  z                      ; Si no se pulso nada mas, termina la rutina aqui
    
    ; Si pulsa A: Cambiamos la maquina de estados para ir al Menu de compra
    ld   a, 1
    ld   [wCursorState], a      ; Pasar al Estado 1 (Menu)
    xor  a                      ; Poner A a 0 rapidamente
    ld   [wMenuSlot], a         ; Inicializar el cursor del menu en el slot 0
    ret

; ==============================================================================
; ESTADO 1: NAVEGACIÓN EN EL MENÚ SUPERIOR DE COMPRA
; ==============================================================================
.modo_menu:
    ld   a, [wInputPressed]

    ; -- Cancelar accion (Boton B = Bit 1) --
    bit  1, a                   ; ¿Se pulso B para cancelar?
    jr   z, .menu_izq
    xor  a                      ; Poner A a 0
    ld   [wCursorState], a      ; Devolver el estado a 0 (Tablero) sin hacer nada
    ret

.menu_izq:
    ; -- Seleccionar unidad anterior (Izquierda = Bit 5) --
    bit  5, a
    jr   z, .menu_der
    ld   a, [wMenuSlot]
    or   a                      ; ¿Estamos en la primera unidad (slot 0)?
    jr   z, .menu_der           ; Si es 0, no podemos ir mas a la izquierda
    dec  a
    ld   [wMenuSlot], a

.menu_der:
    ; -- Seleccionar unidad siguiente (Derecha = Bit 4) --
    ld   a, [wInputPressed]
    bit  4, a
    jr   z, .menu_btnA
    ld   a, [wMenuSlot]
    cp   MENU_SLOTS - 1         ; ¿Estamos en la ultima unidad?
    jr   nc, .menu_btnA
    inc  a
    ld   [wMenuSlot], a

.menu_btnA:
    ; -- Comprar unidad elegida (Boton A = Bit 0) --
    ld   a, [wInputPressed]
    bit  0, a
    ret  z                      ; Si no se pulso A, termina

    ; Logica basica de pago (asumiendo que todos valen 2 monedas por ahora)
    ld   a, [wProtein]          ; Mirar cuantas monedas/proteinas tenemos
    cp   2                      ; Comparar con el coste (2)
    ret  c                      ; Si hay Acarreo (Carry=1), Proteina < 2. Retorna sin comprar.

    sub  2                      ; Restar las 2 monedas del coste
    ld   [wProtein], a          ; Guardar el nuevo saldo

    ; ---- Crear torre ----
    ; call crear_strongman_en_array 
    
    ; Al terminar la compra, devolver el control al tablero automaticamente
    xor  a
    ld   [wCursorState], a
    ret


; ==============================================================================
; INICIALIZACIÓN DEL JUGADOR (Llamar una vez al arrancar el juego)
; ==============================================================================
init_player::
    xor  a                      ; Poner A = 0
    ld   [wCursorState], a      ; Empezar en Estado Tablero (0)
    ld   [wCursorCol], a        ; Columna 0
    ld   [wCursorRow], a        ; Fila 0
    ld   [wMenuSlot], a         ; Slot 0
    ld   [wInputHeld], a        ; Limpiar historial del mando
    ld   [wInputPressed], a
    
    ld   a, 10                  ; Dar 10 monedas/proteinas iniciales
    ld   [wProtein], a
    ret