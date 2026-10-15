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
ChickenPresetsTable:
    db 10, 1  
    db 5,  2  
    db 30, 5 

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
