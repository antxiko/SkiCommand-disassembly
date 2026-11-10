# Por dentro

## Rehacer la ROM

`make verify` ensambla `src/skicommand.asm` con pasmo y sale la ROM de 16 KB
**byte a byte**. `make sanity` comprueba lo que el reensamblado no cubre: que
ningún byte declarado como datos se lea como código, que ningún punto de entrada
caiga en datos y que los 16.384 bytes estén explicados. `make test` pasa los
tests. La ROM no está en el repositorio: hace falta ponerla en la raíz como
`skicommand.rom` (el volcado de GoodMSX, `[!]`, sha1 `17d6db13...`).

| | bytes |
|---|---|
| código trazado | 6.260 |
| datos con nombre | 10.124 |
| sin explicar | 0 |

El listado lleva 1.287 comentarios en 3.155 instrucciones (40,8 %), 326 rutinas y
etiquetas, ninguna por debajo del 10 % comentada, y ninguna rutina llamada sin
nombre.

## El cartucho

16 KB en la **página 2** (0x8000-0xBFFF), con INIT en 0x8010 y el resto de la
cabecera a cero. Deja la página 0 con la BIOS y la 1 con el BASIC, y usa la BIOS
para todo.

## La BIOS que usa

Casi todo pasa por la BIOS: SCREEN 2 con CHGMOD, los registros con WRTVDP, la VRAM
con FILVRM, LDIRVM, LDIRMV, RDVRM y WRTVRM, el mando con GTSTCK y GTTRIG, la tecla
GRAPH con SNSMAT, y el PSG con WRTPSG y RDPSG. Por eso los choques y los enemigos
**leen la tabla de nombres** de la VRAM para saber qué hay en la pista.

## La interrupción

El juego pone en el gancho H.TIMI (0xFD9F) un `jp` y va cambiando su dirección
(0xFDA0) según lo que toque:

| | dirección | qué hace |
|---|---|---|
| `irq_musica` | 0x85A8 | la música y los contadores (título, carteles) |
| `irq_partida` | 0x8569 | un cuadro entero de juego |
| `irq_bonus` | 0x8599 | el recorrido, el disparo y las dianas del bonus |

Las tres acaban en `contadores` (0x85AB): el contador de cuadros (0xE881) y diez
cuentas (0xE883-0xE88C) que suben hasta 0xFF y allí se quedan. Las esperas del
juego miran esas cuentas.

## Cómo se ha hecho

El trazado sigue el código desde INIT, pero casi todo el juego cuelga de la
interrupción y de la tabla de órdenes de la música, que no se ven desde INIT. Lo
que falta se ha **medido en openMSX** (`tools/omsx_cobertura.tcl`: una
condición en cada instrucción apunta cada dirección nueva de la ROM), jugando y
en la demo, en un Philips VG 8020 y en C-BIOS: 2.487 direcciones ejecutadas, todas
dentro del código del listado. Las pantallas y las músicas salen de **ejecutar la
ROM** en `tools/z80run.py` con la BIOS a mano (`tools/bios.py`), y se cotejan con
lo grabado en openMSX.

## La RAM

| | |
|---|---|
| 0xE800-0xE87F | la tabla de sprites, a 0x1B00 en cada cuadro |
| 0xE881 | el contador de cuadros; 0xE882, el tramo de la ronda |
| 0xE8A0 / 0xE8A1 | la Y y la X del esquiador |
| 0xE8B0 | diez objetos de la pista |
| 0xE8DA | el aparato |
| 0xE8E2 | cuatro esquiadores enemigos |
| 0xE906 / 0xE90A | el récord y los puntos, entre 100 |
| 0xE90C / 0xE90E | la ronda y las vidas |
| 0xE914 | es la demo |
| 0xF000-0xF05F | el motor de sonido |
