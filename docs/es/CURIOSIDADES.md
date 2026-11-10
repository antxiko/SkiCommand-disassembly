# Curiosidades

## El salto al medio de la BIOS

El juego entero corre en la **interrupción**: cada cuadro, la BIOS llama al gancho
H.TIMI (0xFD9F) y el juego mueve allí al esquiador, la pista, los enemigos y la
música. Pero al acabar no vuelve con un `ret`: saca de la pila la vuelta a la
BIOS y **salta a 0x0D02** (`contadores`, 0x85AB), una dirección del interior de la
rutina de interrupción de la BIOS del MSX, más allá de la lectura del teclado.
Así se ahorra ese trabajo en cada cuadro.

Es un atajo que depende de cómo está escrita la BIOS por dentro. En openMSX el
juego funciona igual con la BIOS de un Philips VG 8020 que con C-BIOS (con las dos
se ha medido y grabado la partida).

## Un cuadro que no cabe en un cuadro

Como todo va en la interrupción, el juego se protege de que una llegue antes de
que acabe la anterior: 0xE880 dice que la interrupción está corriendo, y si llega
otra encima solo suena la música (`irq_partida`, 0x8569). Pasa: en la grabación de
tres rondas, en **205 de 13.000 cuadros** (el 1,6 %) la interrupción llega con la
anterior aún corriendo, y ese cuadro de juego se pierde.

## Copias que se pasan de largo

Las cargas de dibujos a la VRAM llevan longitudes fijas, y varias leen más de lo
que hay:

- los colores del bonus (0x9D37) se copian con **0x518 bytes**, que siguen por el
  campo del bonus, las casillas de la pista y las del marcador, hasta 0xA24F;
- las letras pequeñas (0xB7F4) se copian con 0x180 bytes y acaban **dentro del
  motor de sonido** (0xB974);
- las letras grandes (0xB774, 0xE0 bytes) se meten en la fuente.

Lo que sobra va a casillas que esa pantalla no usa y no se ve.

## La fuente sin O

La fuente del juego no tiene la letra O: todos los textos llevan un cero (CASI0,
R0UND, C0PYRIGHT). En la tabla de los textos (0x8544) se lee PATTERN CLEAR,
R0UND, START y GAME 0VER.

## Órdenes que no existen

La tabla de las órdenes de la música (0xBBF6) tiene catorce entradas, de la 0xFF a
la 0xF2, pero la 0xF8 y la 0xF7 valen 0x0000: una pieza que las usara saltaría a
la dirección 0 y reiniciaría el MSX. Ninguna de las piezas las usa (ni la 0xFE,
que no hace nada).

## Los puntos, de cien en cien

Los puntos se guardan divididos entre 100 en dos bytes (0xE90A), y en pantalla se
añaden dos ceros: un enemigo vale 1, el aparato 2, una diana del bonus 30. El récord
no pasa de 9.999 (999.900 en pantalla, `marcador`, 0x9435).
