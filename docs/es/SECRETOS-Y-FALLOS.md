# Secretos y fallos

Lo que se ha buscado en el código y lo que se ha encontrado. Un fallo solo entra aquí si está comprobado:
ejecutando la propia rutina del juego (`tools/bios.py`) o contra las grabaciones de openMSX.

## Secretos: ninguno escondido

- **Ninguna tecla escondida.** El juego lee los mandos en un solo sitio (`mando`, 0x8600): los cursores y los dos
  joysticks (GTSTCK), el botón 1 o la barra espaciadora, y el botón 2 o la tecla GRAPH, leída con SNSMAT en la fila 6
  (0x866A). No hay ninguna otra lectura del teclado en toda la ROM: ninguna tecla pulsada al encender, ningún código
  en el título.
- **El único premio que no se ve en pantalla**: cuando al aparato ya le han dado y está estallando, un segundo disparo
  a menos de 8 puntos de él da una **vida más** (`disparo_aparato`, 0x8F58). Se cuenta en [La partida](LA-PARTIDA.html).
- **Ni pantallas ni textos sin usar**: todos los textos de la ROM están en [Los textos](LOS-TEXTOS.html), y todos
  salen.

## Fallo: los puntos pasados los 999.900

Los puntos se guardan divididos entre 100 en dos bytes (0xE90A) y `cifras` (0x9760) los pasa a cinco cifras, con los
ceros detrás. Pero `pinta_puntos` (0x9754) escribe **seis caracteres empezando por la segunda cifra**: la de las
decenas de millar, que solo hace falta pasados los 9.999 (999.900 puntos), no se ve nunca. El récord se queda por
debajo (`marcador`, 0x9435: no más de 9.999), así que nunca sale mal; los puntos de la partida, sí.

Ejecutando aquí la propia rutina del juego con tres puntuaciones:

| puntos | en pantalla |
|---|---|
| 999.900 | `999900` |
| 1.000.000 | `000000` |
| 1.234.500 | `234500` |

Así que quien pase de 999.900 ve el contador volver a empezar desde cero, mientras el récord se queda en 999.900.

## Otras cosas que fallan, contadas en [Curiosidades](CURIOSIDADES.html)

- **Cuadros que llegan tarde**: cuando llega una interrupción con la anterior aún en marcha, solo suena la música y
  ese cuadro de juego se pierde (`irq_solo_musica`): 205 de 13.000 cuadros en la grabación de tres rondas.
- **Copias que se pasan**: tres cargas de dibujos usan longitudes fijas mayores que sus datos y copian lo que viene
  detrás (los colores del bonus, 0x518 bytes; las letras pequeñas y las grandes), a casillas que no se ven.
- **Órdenes de música que reiniciarían el MSX**: las entradas 0xF8 y 0xF7 de la tabla de órdenes (0xBBF6) apuntan a
  la dirección 0; ninguna pieza las usa.
