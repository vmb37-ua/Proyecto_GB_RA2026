# Moi Gruppa TD

Tower defense para Game Boy monocroma, en ensamblador LR35902/RGBDS.
Defiende cuatro carriles con strongmen frente a 24 pollos en tres oleadas.
El tablero tiene siete columnas por cuatro filas, como el selector original.

## Compilar en la maquina virtual

Con RGBDS y GNU Make disponibles (o GBTelera configurado con `GBT_PATH`):

```sh
cd moiGruppaTD
make clean
make
```

Abre `game.gb` con BGB u otro emulador DMG. Los simbolos y el mapa quedan
en `obj/game.sym` y `obj/game.map`. Para que BGB encuentre los simbolos junto
a la ROM: `cp obj/game.sym game.sym` despues de compilar.

El Makefile busca recursivamente los `.asm` y recompila cuando cambia un `.inc`.
No requiere archivos binarios de los challenges, bibliotecas de audio,
Python, PowerShell ni conversion de graficos para compilar: `src/assets/gfx.asm`
ya contiene todos los tiles.

**Estado de validacion:** fuentes reorganizadas y revisadas estaticamente.
No se ha compilado ni ejecutado la ROM en Windows por indicacion del usuario.
La sintaxis/enlazado con vuestra version de RGBDS, el comportamiento en emulador
y el equilibrio de la partida quedan pendientes de la prueba en la VM.
Seguir [`docs/PRUEBAS_VM.md`](docs/PRUEBAS_VM.md).

## Controles y reglas

| Control | Accion |
| --- | --- |
| Start en portada o resultado | Empezar una partida nueva |
| Cruceta en tablero | Elegir celda |
| A en tablero | Abrir catalogo para esa celda |
| Izquierda/derecha en catalogo | Elegir tipo de torre |
| A en catalogo | Comprar y colocar; vuelve al tablero si tiene exito |
| B en catalogo | Cancelar |
| Start durante la partida | Pausar/reanudar, tambien desde el catalogo |
| B en resultado | Volver al menu |

La seleccion avanza una celda por pulsacion. Para seguir moviendo hay que soltar
y volver a pulsar. Una casilla ocupada o sin saldo no cobra ni crea entidades;
el mensaje inferior avisa del fallo y se puede cambiar de tipo o cancelar.
Las torres no se pueden vender ni quitar: los pollos pueden destruirlas.

HUD: `P` proteina, `L` vidas, `W` oleada actual, `LEFT` enemigos pendientes
(por aparecer y vivos). Los iconos superiores muestran `BAS RAP HEA WAL PRO`,
con sus costes debajo. El marco delimita el tablero o el icono seleccionado.

Empiezas con 10 de proteina y 3 vidas. Recibes 1 cada 120 frames de simulacion
y 3 por pollo derrotado, hasta 99. Cada pollo que llega al extremo izquierdo
consume una vida. Ganas al resolver los 24 pollos conservando al menos una vida;
pierdes inmediatamente cuando las vidas llegan a cero. Pausar congela movimiento,
combate, apariciones y economia. Reiniciar limpia todas las entidades y contadores.

| Torre | Coste | Vida | Dano | Periodo (frames) |
| --- | ---: | ---: | ---: | ---: |
| BAS, equilibrada | 2 | 10 | 2 | 50 |
| RAP, rapida | 3 | 8 | 1 | 25 |
| HEA, pesada | 5 | 20 | 5 | 75 |
| WAL, muro | 3 | 40 | 0 | Sin disparos |
| PRO, generadora | 4 | 10 | 0 | +1 proteina cada 180 |

Las primeras ocho apariciones son pollos normales (vida 10, dano 1, un pixel
cada 8 frames); las siguientes ocho rapidos (5, 2, 4); las ultimas ocho pesados
(30, 5, 12). Se reparten ciclicamente por los cuatro carriles. Los periodos de
aparicion son 150/110/80 frames; el primero espera 180. Si no cabe un enemigo,
el sistema espera y reintenta sin consumir la oleada.

Los pollos se paran al entrar en una celda con torre y la atacan cada 60 frames.
Las torres ofensivas disparan solo si hay un enemigo por delante en su carril.
Los proyectiles avanzan 2 pixeles por frame, golpean una sola vez y desaparecen
al salir por la derecha. Los graficos son provisionales y originales del proyecto.
No hay musica, guardado ni niveles adicionales en esta version.

## Estructura, como ch5/ch6

```text
src/
  main.asm            Arranque y bucle input -> escena -> prerender -> render
  header.asm          Cabecera ROM ONLY, sin RAM externa ni bateria
  game.inc            Constantes de tablero, limites, escenas y tiles
  engine/             Hardware, memoria, joypad, LCD, DMA/OAM, texto, fondo y HUD
  man/                Gestores de escenas, entidades y estado de partida
  sys/                Input del juego, apariciones, ataques, movimiento,
                      colisiones, reglas, prerender y render
  scn/                Inicializacion/update de menu, juego, victoria y derrota
  assets/             Tablas de torres y graficos 2bpp
docs/                 Arquitectura y pruebas manuales para la VM
tools/                Generador opcional de graficos y comprobador estatico
```

La escena de juego ordena los sistemas; no contiene sus algoritmos. Cada escena
es una tabla `DB id / DW init, update`; el gestor se ocupa del cambio con LCD
apagado. Cada modulo reserva su estado. Los componentes de entidad usan offsets
compartidos, sin direcciones WRAM escritas a mano.

Esto adapta el patron de los challenges: no copia los despachos de ejercicios,
los `INCBIN` docentes ni sus rutinas dadas en binario. Nuestros algoritmos estan
en fuentes legibles. Ver [`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md) para
contratos, limites de memoria/video y equivalencias con el codigo anterior.

Para ajustar la partida: constantes generales en `game.inc`, torres en
`assets/towers.asm`, pollos y oleadas en `sys/sys_spawn.asm`.
El archivo `tools/generate_gfx.ps1` conserva los dibujos originales y regenera
`assets/gfx.asm`; no hace falta ejecutarlo en la VM. El comprobador
`tools/check_source.ps1` solo revisa etiquetas e includes, sin compilar ni jugar.

## Creditos

- GBTelera, ronaldo / Cheesetea / ByteRealms (@FranGallegoBR), 2024, licencia MIT:
  Makefile, `cfg/` y cabecera de cartucho originales. Se conservan sus avisos.
- Estructura de referencia: materiales docentes suministrados `../ch05-train/`
  y `../ch06-train/` (gestores, sistemas, escenas y separacion render/prerender).
- Codigo del juego y pixel art/fuente en `tools/generate_gfx.ps1`: proyecto
  Moi Gruppa TD. No se han incorporado sprites, musica ni binarios ajenos.
- RGBDS: herramientas del ensamblador/enlazador usadas por GBTelera.
