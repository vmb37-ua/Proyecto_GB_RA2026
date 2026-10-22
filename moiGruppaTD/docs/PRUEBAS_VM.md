# Pruebas pendientes en la maquina virtual

Esta lista es el criterio de aceptacion manual. No se ha ejecutado el juego ni
se ha compilado en Windows. Si algo falla, guardar el mensaje de RGBDS o una
captura y anotar la accion que lo provoco.

1. **Compilacion limpia:** dentro de `moiGruppaTD`, `make clean` y `make`.
   Esperado: sin errores, `game.gb` y `obj/game.sym`/`obj/game.map` generados.
   Si hay error, conservar la salida completa del primer archivo que falla.
2. **Arranque:** abrir `game.gb` como DMG. Deben verse portada e instrucciones,
   sin sprites basura. Pulsar Start: tablero de 7x4, cinco iconos y P10/L03.
3. **Limites e input:** recorrer las cuatro esquinas. No sale del tablero.
   Mantener una direccion no recorre todas las casillas: funciona por pulsacion.
   Soltar y pulsar mueve una celda. A abre catalogo, B vuelve sin cobrar.
4. **Compra:** elegir BAS, confirmar con A. El saldo baja exactamente 2, aparece
   una torre en la casilla elegida y el cursor vuelve al tablero. Intentar otra
   torre sobre ella: no cobra y muestra aviso. Comprar hasta no tener saldo y
   repetir: no se crea entidad ni desborda el contador.
5. **Economia:** esperar sin pausa; P sube 1 cada 120 pasos. Comprar PRO: genera
   renta adicional. Ningun incremento supera 99. En BGB, opcionalmente poner
   `wProtein=98` y esperar renta o una baja para comprobar la saturacion.
6. **Combate:** poner BAS en cada fila. Los pollos aparecen por la derecha,
   recorren su carril y reciben disparos solo de ese carril. Cada baja da 3 de
   proteina. Un disparo se consume al impactar y no golpea a dos pollos.
7. **Torres:** RAP dispara mas a menudo; HEA hace mas dano; WAL no dispara y
   aguanta mas. Un pollo que entra en una torre deja de avanzar, la muerde y
   vuelve a caminar cuando la destruye. La celda vuelve a poder comprarse.
8. **Pausa:** Start con enemigos visibles, tambien con catalogo abierto. Durante
   varios segundos no cambian enemigos, vida, proteina ni numero pendiente.
   Start reanuda sin crear ni cobrar una torre por ese boton.
9. **Derrota:** empezar de nuevo y no colocar torres. Cada pollo que atraviesa
   el lado izquierdo resta una vida; al tercero aparece GAME OVER. No se congela
   la CPU. B lleva a portada y Start permite otra partida.
10. **Reinicio:** desde resultado, Start. P10, L03, sin torres/disparos anteriores,
    primera oleada normal y espera inicial. Repetir varias veces.
11. **Victoria y pools:** defender hasta resolver 24 pollos. W avanza 1..3 y
    LEFT cuenta tanto vivos como pendientes. No se gana mientras quede un pollo.
    Al acabar con vidas positivas aparece YOU WIN. Comprobar que la saturacion
    de enemigos/disparos no bloquea el juego ni pisa memoria.
12. **Video:** con las comprobaciones de acceso VRAM/OAM del emulador activadas,
    verificar que no avisa de accesos prohibidos. Cursor y enemigos deben verse
    estables. HUD/torres pueden tardar hasta 9 frames en actualizarse (fondo por
    filas). Comprobar transiciones, compra, destruccion y pausa.

Para depurar, cargar los simbolos y vigilar `scene_id`, `wProtein`, `wLives`,
`wSpawned`, `wSpawnTimer`, `wPaused`, `Array_strong`, `Array_chickens`,
`Array_shots`, `shadow_oam` y `bg_render_row`. Cada entidad son ocho bytes;
el primer byte a cero significa libre. No hay breakpoints `ld b,b` en el juego.

Con la ROM funcionando, ajustar costes/periodos si la partida resulta demasiado
facil o dificil. El equilibrio aun no esta probado y no se debe confundir con
un fallo del ensamblador o del modelo de entidades.
