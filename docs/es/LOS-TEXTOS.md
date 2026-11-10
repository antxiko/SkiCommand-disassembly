# Los textos

Todos los textos de la ROM, en inglés: no hay más. La fuente del juego **no
tiene la letra O**: todos los textos llevan un cero en su lugar (C0PYRIGHT,
R0UND, CASI0), y en pantalla se ven iguales. Los espacios son la casilla 0.

| Dónde | Texto | Traducción |
|---|---|---|
| título (0x84BC, filas 2-3 y 6-7, en letras grandes) | CASIO | CASIO |
| | SKI COMMAND | SKI COMMAND |
| título (fila 14) | PUSH TRIGGER 1 TO START GAME | PULSA EL BOTÓN 1 PARA EMPEZAR |
| título (fila 22) | COPYRIGHT 1984 © CASIO | COPYRIGHT 1984 © CASIO |
| antes de cada ronda (0x8551) | ROUND 001 START | RONDA 001: SALIDA |
| la ronda superada (0x8544) | PATTERN CLEAR | RECORRIDO SUPERADO |
| sin vidas (0x8560) | GAME OVER | FIN DE LA PARTIDA |
| el marcador (0x9997) | HIGH SCORE | RÉCORD |
| | 1UP | JUGADOR 1 |
| | ROUND | RONDA |
| el bonus (0x95AA) | 3000, 2000, 1000 | los puntos de cada diana |

En la tabla de textos, entre ROUND y START hay cinco espacios: ahí escribe el
número de la ronda `pinta_ronda` (0x9739). El © es la casilla 0x40.
