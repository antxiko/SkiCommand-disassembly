#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl, grabados con
comun/casio/lanza_graba.ps1 en C-BIOS_MSX1_JP, -ram "0xE800 0x900"), pintados con tools/vdp.py.

Los cuadros salen de la RAM grabada: 0xE90C la ronda, 0xE90E las vidas, 0xE8F9 la ronda acabada,
0xE8FA el choque, 0xE8A3 el salto, 0xE8A8 la curva, 0xE8DA el aparato, 0xE8AA el aparato tocada,
0xE860 lo que cae. En `rondas` el esquiador no choca (tools/guiones/rondas.tcl se salta los dos
sitios que apuntan el choque).

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta, cada)
TRAMOS = [
    ("titulo.gif", "atraccion", 120, 640, 4),         # CASIO SKI COMMAND y PUSH TRIGGER
    ("demo.gif", "atraccion", 660, 1500, 3),          # la demo: la maquina juega al azar
    ("ronda.gif", "rondas", 280, 1000, 2),            # ROUND 001 START, la salida y los primeros enemigos
    ("salto.gif", "rondas", 590, 700, 1),             # el salto de 600 a 691
    ("curva.gif", "rondas", 790, 1580, 4),            # la curva de 802 a 1565
    ("aparato.gif", "rondas", 7130, 7290, 1),            # sale en 7139, tocado en 7250
    ("cae.gif", "rondas", 9040, 9160, 1),             # lo que cae, de 9060 a 9148 (ronda 3)
    ("pattern_clear.gif", "rondas", 3870, 4070, 2),   # la ronda acaba en 3889
    ("bonus.gif", "rondas", 4070, 4390, 2),           # el recorrido y las tres dianas
    ("caida.gif", "partida", 1190, 1420, 2),          # el choque en 1203
    ("game_over.gif", "partida", 2700, 2880, 2),      # la ultima vida en 2723
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta, cada in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=cada, tope_ms=4000)
        print("%-20s %4d imagenes, %5.1f s, %8d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))


if __name__ == "__main__":
    main(sys.argv[1])
