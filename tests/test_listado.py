"""Lo que se afirma de la ROM, comprobado contra sus bytes.

Corre con la ROM delante y sin ella: cuando no esta, la imagen se rehace desde
las filas defb/defw del listado, que si viaja con el repositorio. Sin la ROM
solo se comprueba lo que cae en datos.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "skicommand.rom")
ASM = os.path.join(RAIZ, "src", "skicommand.asm")
NOTAS = os.path.join(RAIZ, "src", "skicommand.notes")
ORG = 0x8000
TAM = 16384

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(TAM)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()
    return imagen_desde_el_listado()


def b(a):
    return lee()[a - ORG]


def w(a):
    rom = lee()
    return rom[a - ORG] | (rom[a - ORG + 1] << 8)


def instruccion(dirr):
    """La instruccion del listado en esa direccion (sin el comentario)."""
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^\t(\S.*?)\s*;([0-9a-f]{4})", ln)
            if m and int(m.group(2), 16) == dirr:
                return m.group(1).replace("\t", " ").strip()
    return None


class Cabecera(unittest.TestCase):
    def test_ab_e_init_en_0x8010(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(w(0x8002), 0x8010)
        self.assertEqual(rom[4:16], bytes(12))

    def test_son_16_kb(self):
        self.assertEqual(len(lee()), TAM)


class LaInterrupcion(unittest.TestCase):
    def test_tres_interrupciones_por_h_timi(self):
        self.assertEqual([instruccion(0x824F), instruccion(0x8252)], ["ld hl,08569h", "ld (0fda0h),hl"])
        self.assertEqual([instruccion(0x8456), instruccion(0x8459)], ["ld hl,08599h", "ld (0fda0h),hl"])
        self.assertEqual([instruccion(0x981F), instruccion(0x9822)], ["ld hl,085a8h", "ld (0fda0h),hl"])

    def test_vuelve_a_0x0d02_sin_ret(self):
        self.assertEqual([instruccion(0x85C1), instruccion(0x85C2)], ["pop bc", "jp 00d02h"])
        self.assertEqual([instruccion(0x85C5), instruccion(0x85C6)], ["pop bc", "ld hl,00d02h"])


class LaPartida(unittest.TestCase):
    def test_record_inicial_y_vida_extra_de_100_en_100(self):
        self.assertEqual(instruccion(0x802D), "ld hl,00064h")
        self.assertEqual(instruccion(0x8036), "ld hl,00064h")
        self.assertEqual(instruccion(0x9464), "ld hl,00064h")

    def test_cuatro_vidas(self):
        self.assertEqual(instruccion(0x8051), "ld a,004h")

    def test_seis_dificultades(self):
        d = [list(lee()[0x84A4 - ORG + 4 * k:0x84A8 - ORG + 4 * k]) for k in range(6)]
        self.assertEqual(d, [[255, 1, 255, 15], [0, 1, 255, 15], [0, 2, 1, 15],
                             [0, 2, 1, 7], [0, 3, 1, 7], [0, 3, 2, 7]])

    def test_las_direcciones_de_gtstck(self):
        self.assertEqual(list(lee()[0x868D - ORG:0x8696 - ORG]), [0, 2, 3, 1, 9, 8, 12, 4, 6])

    def test_los_textos_con_cero_por_o(self):
        t = lee()[0x8544 - ORG:0x8569 - ORG]
        self.assertEqual(t, b"PATTERN\x00CLEARR0UND\x00\x00\x00\x00\x00STARTGAME\x000VER")

    def test_seis_carteles_de_la_presentacion(self):
        p, n = 0x84BC, 0
        while p < 0x8544:
            p += 3 + b(p + 2)
            n += 1
        self.assertEqual((n, p), (6, 0x8544))


class Sonido(unittest.TestCase):
    def test_catorce_ordenes_dos_que_no_existen(self):
        t = [w(0xBBF6 + 2 * k) for k in range(14)]
        self.assertEqual(t[7:9], [0, 0])
        self.assertTrue(all(0xBB19 <= x < 0xBBF6 for x in t[:7] + t[9:]))

    def test_doce_periodos_de_mas_grave_a_mas_agudo(self):
        t = [w(0xBC24 + 2 * k) for k in range(12)]
        self.assertEqual(t[0], 0x0D5C)
        self.assertTrue(all(x > y for x, y in zip(t, t[1:])))


class ElListado(unittest.TestCase):
    def test_densidad_y_flojas(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertGreaterEqual(int(m.group(2)) * 100, 40 * int(m.group(1)))
        self.assertIn("---- 0 rutinas por debajo del 10 %", salida)

    def test_ningun_call_sin_nombre(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "sin_bautizar.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        self.assertTrue(salida.startswith("0 rutinas sin bautizar"), salida[:200])

    def test_cada_comentario_en_su_instruccion(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "valida_c.py"), ASM, NOTAS],
            capture_output=True, text=True, check=True).stdout
        self.assertIn("0 fuera de sitio, 0 repetidos", salida)


if __name__ == "__main__":
    unittest.main()
