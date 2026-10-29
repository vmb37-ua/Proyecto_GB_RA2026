EXPORT Array_chickens
DEF TAM_ARRAY_CHICKENS = 160 ;; EMPIEZA EN $C000
DEF B_CHICKEN = 4
DEF N_CHICKEN_ARRAY = TAM_ARRAY_CHICKENS / B_CHICKEN

; Tipos de pollo
DEF CHICKEN_A = 0
DEF CHICKEN_B = 1
DEF CHICKEN_C = 2

DEF PRESET_SIZE = 2  ; Bytes por cada tipo en la tabla

SECTION "Chickens", ROM0
; Tabla con los datos estáticos: [Vida, Daño]
chickenPresetsTable:
    db 10, 1  ;tipo a
    db 5,  2  ;tipo b
    db 30, 5  ;tipo c

initChickenArray::
    ld hl, Array_chickens  ;; Posicion inicial del array
    ld a,N_CHICKEN_ARRAY   ;; Cargamos el valor 40 en A, que es el número de pollos en el array (160 bytes / 4 bytes por pollo)

	.loop:
	    ld [hl], 0              ;; Ponemos en 0 el estado del pollo
	    inc hl                 

	    ld [hl], 0              ;; Ponemos en 0 la vida del pollo
	    inc hl

	    ld [hl], 0              ;; Ponemos en 0 el daño del pollo
	    inc hl

	    ld [hl], 0              ;; Ponemos en 0 la posición del pollo
	    inc hl

	    dec a 
	    jp nz, .loop  
	    ret

findFreeChicken::
    ld hl, Array_chickens
    ld b, N_CHICKEN_ARRAY
    ld de, B_CHICKEN 

	.loop:
	    ld a, [hl]                  ; Estado
	    and a                       ; Si el estado es 0, hemos encontrado hueco
	    ret z                       

	    add hl, de                
	    dec b                       
	    jr nz, .loop
	    or 1
	    ret

; Recibe:
;   - A : ID del tipo de pollo (0, 1, 2...)

spawnChicken::
	;BUSCAR HUECO
	call findFreeChicken
	jr z, .save_chicken
	ret
	.save_chicken:
	    ld [hl], 1          ; Estado = 1
	    inc hl              ; HL - Vida


	    push hl             ; Guardamos la posición actual de WRAM en la pila
	    
	    ld e, a
	    ld d, 0             ; DE = ID del pollo
	    
	    ; Multiplicamos  * 2 (desplazamos bit a la izquierda)
	    sla e
	    rl d                ; DE = ID * 2

	    ld hl, chickenPresetsTable
	    add hl, de          ; HL - Direccion de la tabla de tipos

	    ld a, [hl+]         ; Vida
	    ld b, a             ; B = Vida
	    ld c, [hl]          ; C = Daño

	    pop hl              ; Recuperamos la dirección de WRAM en HL

	    ld a, b
	    ld [hl+], a         ; Escribir Vida en WRAM
	    ld a, c
	    ld [hl+], a         ; Escribir Daño en WRAM

	    ;Posicion, depende de como definamos al logica de los niveles
	    ret
;Movemos una chicken de memoria (la chicken no tiene porque estar activa)
;Recibe hl, primer byte del chicken en array de chickens, (hl - estado de x chicken)
moveLeftChicken::
	; Necesitamos saber si podemos mover la chicken a la izquierda
		; - Limite de mapa¿
		; - Colision?
;;Mueve todas las chicken que estan en pantalla ahora mismo.
moveAllActiveChicken::