# La música

Seis músicas, en los tres canales del PSG. No están grabadas a mano:
`tools/musica.py` **ejecuta el motor de sonido de la propia ROM** con
`tools/z80run.py` -la rutina de cada música (0xBC64...) y, en cada cuadro,
`sonido_cuadro` (0xB9B0)- y apunta lo que escribe en el PSG a través de la BIOS
(WRTPSG y RDPSG).

**Cotejadas con openMSX**: en las partidas grabadas, los registros de tono y de
volumen coinciden cuadro a cuadro con los del motor ejecutado, **cada pieza
entera**: 430, 287, 54, 162, 384 y 143 cuadros, **0 distintos**. No se miran los
canales que un efecto le quita a la música (el disparo, los enemigos), ni los
cuadros en que la interrupción llega con la anterior aún corriendo (0xE880): la
foto del PSG es entonces de mitad de cuadro.

## El motor

Tres canales en 0xF002, 0xF022 y 0xF042, de 32 bytes cada uno. Una pieza son
grupos de **tres bytes**: una nota (su número, la duración y lo que espera hasta
la siguiente) o una orden de 0xF2 a 0xFF, con dos bytes de argumentos: acabar,
repetir un trozo, saltar, el volumen, la envolvente, el ruido, el vibrato... (la
tabla 0xBBF6). Las notas salen de doce periodos de la octava más grave (0xBC24),
partidos por dos por cada octava. El volumen sigue una **envolvente** de 16 pasos
de una tabla (0xBC3C) o la del propio PSG.

El canal 0xF002 suena en el canal C del PSG, el 0xF022 en el B y el 0xF042 en el
A: `sonido_cuadro` los recorre con el número del canal del PSG contando hacia
atrás. Los efectos van en el B y el A, y mientras suenan la música calla en ese
canal. En la demo el motor no suena: la interrupción lo calla.

| | Quién la pide | Duración |
|---|---|---:|
| la salida | la ronda 1 al empezar (0x822C) | 7,2 s |
| la ronda | la ronda, cada vez que se calla (0x86A7) | 4,8 s, y vuelve a empezar |
| la caída | el choque (0x826B) | 0,9 s |
| PATTERN CLEAR | la ronda superada (0x831B) | 2,7 s |
| el bonus | la presentación del bonus (0x8439) | 6,4 s |
| GAME OVER | sin vidas (0x8301) | 2,4 s |

## La salida

<audio controls src="../audio/musica_salida.mp3"></audio>

## La ronda

<audio controls src="../audio/musica_ronda.mp3"></audio>

## La caída

<audio controls src="../audio/musica_caida.mp3"></audio>

## PATTERN CLEAR

<audio controls src="../audio/musica_pattern_clear.mp3"></audio>

## El bonus

<audio controls src="../audio/musica_bonus.mp3"></audio>

## GAME OVER

<audio controls src="../audio/musica_game_over.mp3"></audio>
