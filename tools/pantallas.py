#!/usr/bin/env python3
"""Las pantallas de Ski Command, EJECUTANDO la ROM (tools/bios.py: el Z80 con la BIOS que usa):

  - el titulo: INIT (0x8010) hasta la espera del boton (0x80A8): CASIO y SKI COMMAND en letras
    grandes, PUSH TRIGGER 1 TO START GAME y el COPYRIGHT;
  - la pista: `ronda` (0x80CD) hasta el bucle de la ronda (0x8255), con la espera del cartel ROUND
    (0x8192) saltada; la ronda 1, y despues los cuatro tramos de la nieve (`tramo_dibujos`, 0x97B7,
    con 0xE882 = 0, 4, 8 y 12);
  - el bonus: desde 0x8323 (tras PATTERN CLEAR) hasta la espera del recorrido (0x845C), sobre lo que
    dejo la ronda: el bonus no recarga la fuente ni las casillas que no usa.

logotipo.png, la cabecera de la web: CASIO y SKI COMMAND del titulo.

Cada pantalla se coteja con la VRAM que grabo openMSX en el cuadro que se diga: la imagen sin
sprites punto a punto, la tabla de nombres, los dibujos y los colores.

Uso: pantallas.py <dir> [cotejo]
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from bios import Msx        # noqa: E402

RAIZ = os.path.dirname(AQUI)
# (grabacion, cuadro): el titulo de la demostracion, la ronda 1 recien pintada y el bonus recien pintado
COTEJO = {"titulo": ("atraccion", 300), "pista": ("rondas", 300), "bonus": ("rondas", 4070)}


def nueva():
    rom = open(os.path.join(RAIZ, "skicommand.rom"), "rb").read()
    return Msx(rom, 0x8000)


def salta_cartel(m):
    m.mem[0xE884] = 0xFF


def ejecuta():
    out = {}
    m = nueva()
    m.sp = 0xF300
    m.hasta(0x8010, 0x80A8)
    out["titulo"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    m.mem[0xE90C] = 0                       # la ronda 1 recien empezada (0x80C5)
    m.hasta(0x80C5, 0x8255, {0x8192: salta_cartel})
    out["pista"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    for tramo in (4, 8, 12):
        m.mem[0xE882] = tramo
        m.llama(0x97B7)
        out["pista_tramo%d" % tramo] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    # el bonus no vuelve a cargar la fuente ni las casillas 3 y 0x0C-0x5F: se quedan las de la ronda
    m.sp = 0xF300
    m.hasta(0x8323, 0x845C)
    out["bonus"] = (bytes(m.vdp.vram), bytes(m.vdp.regs))
    return out


def cotejo(pant):
    grabs = {}
    for nom, (grab, n) in COTEJO.items():
        if grab not in grabs:
            grabs[grab] = list(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin"), ram_n=0x900))
        suya = grabs[grab][n]
        v, regs = pant[nom]
        nombres = [a - 0x1800 for a in range(0x1800, 0x1B00) if v[a] != suya["vram"][a]]
        dibujos = sum(1 for a in range(0x0000, 0x1800) if v[a] != suya["vram"][a])
        colores = sum(1 for a in range(0x2000, 0x3800) if v[a] != suya["vram"][a])
        t1, t2 = vdp.tela(v, regs, False), vdp.tela(suya["vram"], suya["regs"], False)
        puntos = [(x // 8, y // 8) for y in range(192) for x in range(256) if t1[y][x] != t2[y][x]]
        print("%-8s contra %s/%d: puntos distintos %d de 49152 (en %d celdas: %s); nombres %d (%s); "
              "dibujos %d bytes, colores %d"
              % (nom, grab, n, len(puntos), len(set(puntos)), sorted(set((y, x) for x, y in puntos))[:20],
                 len(nombres), [(a // 32, a % 32) for a in nombres[:12]], dibujos, colores))


def main(argv):
    pant = ejecuta()
    for nom, (v, regs) in pant.items():
        if nom == "titulo":
            continue
        vdp.imagen(v, regs, 2, con_sprites=False).save(os.path.join(argv[0], "%s.png" % nom))
    v, regs = pant["titulo"]
    vdp.imagen(v, regs, 4, con_sprites=False).crop((0, 16, 1024, 256)).save(
        os.path.join(argv[0], "logotipo.png"))
    if len(argv) > 1:
        cotejo(pant)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
