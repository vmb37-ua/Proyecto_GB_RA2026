# Arquitectura

## Antes y despues

El prototipo no tenia un ciclo de juego completo: `init_player` restauraba cursor
y saldo en cada iteracion; las variables de botones no se conectaban a P1;
`simulation` y `check_end` eran stubs; faltaba `place_tower_on_grid`; se reservaba
`Array_pollos` pero se usaba `Array_chickens`; y habia tamanos/definiciones
contradictorios. La busqueda de torre libre podia salir del array. El tipo del
pollo se perdia en la busqueda de hueco, y las rutinas de presets no cargaban el
valor que prometian. El render borraba el fondo fila a fila durante varios frames.

| Prototipo | Responsabilidad actual |
| --- | --- |
| `main.asm` con RAM y logica mezcladas | Solo arranque y ciclo de frame |
| `init.asm` | `engine/` + init de cada escena/modulo |
| `user_input.asm` | `engine/joypad.asm` lee botones; `sys/sys_input.asm` decide acciones |
| `strongmen.asm`, `chicken.asm` | Arrays/layout en `man/`, presets en `assets/`, comportamiento en `sys/` |
| `protein.asm` | Operaciones acotadas en `man/man_game.asm`, renta en `sys/sys_rules.asm` |
| `render.asm` | Preparacion en RAM, texto/HUD, fondo persistente y sprites por DMA |
| `simulation.asm`, `check_end.asm` | Sistemas llamados por `scn/scn_game.asm` |

Las versiones antiguas siguen recuperables en Git. Los ejemplos docentes no se
han modificado y no forman parte de las fuentes de compilacion de este juego.

## Ciclo y escenas

1. `input_update` lee P1 y calcula flancos (`held` y `pressed`).
2. `scene_update` llama al update de la escena actual.
3. En juego: input/pausa, renta, apariciones, ataques, movimiento/mordiscos,
   colisiones de proyectil, victoria/derrota. En pausa se salta la simulacion.
4. `sys_prerender_update` prepara sprites y HUD en WRAM.
5. `sys_render_update` espera un VBlank nuevo, transfiere OAM y dos filas del fondo.

Un cambio de escena apaga el LCD de forma segura, llama a su init, prepara y
publica todo el fondo/OAM y vuelve a encenderlo. Solo el cambio de escena apaga
el LCD. No se usan interrupciones ni `HALT`; la pila empieza en `$E000`.

## Entidades y contratos

Los tres arrays comparten registros de ocho bytes (`man/man_entity.inc`):

| Offset | Campo | Torres | Pollos | Proyectiles |
| ---: | --- | --- | --- | --- |
| 0 | KIND | 0 libre, 1..5 tipo | 0 libre, 1..3 tipo | 0 libre, 1 activo |
| 1 | HP | Vida | Vida | Reservado |
| 2 | DAMAGE | Dano | Dano del mordisco | Dano del disparo |
| 3 | X | Pixel horizontal | Pixel horizontal | Pixel horizontal |
| 4 | ROW | Carril 0..3 | Carril 0..3 | Carril 0..3 |
| 5 | TIMER | Recarga | Recarga de mordisco | Reservado |
| 6 | SPEED | Periodo de disparo/renta | Periodo de movimiento | Reservado |
| 7 | MOVE | Reservado | Cuenta atras de movimiento | Reservado |

Las 28 torres usan slots fijos: `fila*7+columna`; no hay busqueda sin limite.
Pollos y disparos usan pools de 8. KIND=0 libera una entidad. Cada alta escribe
los ocho campos y cada reinicio limpia los tres arrays. El dano comprueba carry
y cero para evitar que la vida se desborde al restar.

`man_entity_each`: DE=array, B=capacidad, HL=callback; llama solo a activos con
DE apuntando al registro y protege los registros de iteracion. El callback puede
destruir registros. `entity_field`: DE=entidad, A=offset -> HL=campo, conserva BC/DE.
`man_entity_free`: devuelve Z y HL=hueco o NZ si lleno.
Las rutinas especificas documentan entradas/salidas y carry cuando corresponde.

## Video y memoria

- 28 torres de 16x16 en el fondo. Columna X=`8+16*col`, Y=`40+24*fila`.
- Pollos y disparos son sprites 8x8. El cursor usa cuatro esquinas 8x8.
- Shadow OAM alineada a 256 bytes; DMA copiada a HRAM y ejecutada desde ahi.
- Pools: 352 bytes. Fondo en RAM: 576. Shadow OAM: 160. Estado adicional pequeno.
  Pila al final de WRAM; sin bancos ni RAM externa.
- 68 tiles 2bpp (1088 bytes), cargados con LCD apagado. Fuente a partir del tile 32.
- Maximo 8 pollos + 8 disparos + 4 esquinas = 20 sprites de 40.
- Maximo 2 pollos y 4 disparos por carril. Con el cursor son como maximo 8 sprites
  coincidentes en una linea del tablero, por debajo del limite de 10.
- En VBlank se copian 160 bytes por DMA y dos filas de 20 tiles del fondo.
  No se reconstruye ni se borra VRAM durante la simulacion.
- El fondo se publica por turnos: una vuelta tarda 9 frames. El HUD y las torres
  pueden tardar hasta esa vuelta en reflejar un cambio; las dos mitades de una
  torre pueden actualizarse en frames distintos. Los enemigos/disparos/cursor
  actualizan su OAM cada frame. Esto evita copiar 576 bytes de golpe en VBlank.

Los tiempos y limites estan planteados para DMG; falta confirmarlos con el
emulador de la VM. Una escena muy cargada podria consumir mas de un frame de
preparacion: `frame_wait` siempre espera el siguiente VBlank, sin escribir VRAM
fuera de ese periodo. Los periodos de juego cuentan pasos de simulacion.
