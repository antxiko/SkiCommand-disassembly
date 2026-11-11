#!/usr/bin/env python3
"""Las hojas de sprites y las animaciones de Ski Command, MONTADAS DESDE LA ROM (ninguna es una captura).

Los dibujos de los sprites (16 x 16) se cargan como los carga el juego (`sprites_carga`, 0x9851): los seis del
esquiador (0xA1CD) en 0x3800; despues `sprites_girados` (0x9635), desde donde lo dejo LDIRVM, pone los seis
siguientes (0xA28D) en 0x38C0 y otra vez girados de lado detras, en 0x3980 (cada mitad de 8 puntos con sus bits al
reves y las dos mitades cambiadas); los 46 del resto (0xA34D), desde 0x3A40. Al caerse, el juego
pone los tres del esquiador que se cae (0xA9ED) en 0x3C00, tambien con los girados (0x827B).

  esquiador.png    los 11 dibujos de 0x8910 (cuatro sprites: dy, dx, dibujo), con los colores de sus sprites
                   (0x8465: 4, 1, 6 y la sombra 1): recto, a la izquierda (3) y a la derecha (6), cada uno con el
                   despegue (+1) y en el aire (+2), y los dos de la caida (9 y 10)
  enemigos.png     los siete tipos (1-7, sus dos colores en 0x8E03) en sus cuatro tamanos (0x8E13: cuantos sprites
                   y dy, dx, dibujo, cual de los dos colores) y los cuatro dibujos del derribado (0x8E3F)
  aparato.png      el aparato en sus tres colores (0x8BDB) y cuatro tamanos (0x8BEE: el desplazamiento y los
                   dibujos por filas, 0x8BDE filas y sprites por fila) y tocado (los dibujos 4 a 7, en rojo oscuro: al
                   tocarlo, el byte de su color pasa a ser 6, 0x8FC6)
  objetos.png      los cinco objetos de la pista en sus cuatro tallas (0x9390: las casillas fila a fila; 0x9368 las
                   filas y las casillas de cada fila), con las casillas de la pista (0x9FED) y de la nieve (0xAA4D) y sus colores
  salto.gif        el salto, cuadro a cuadro como lo hace `salto` (0x885F): el despegue, 33 puntos arriba, la
                   espera, la bajada, el aterrizaje; la sombra cambia de tamano (0x4C, 0x50, 0x4C, 0x48)
  caida.gif        la caida (0x827B): los dibujos 9 y 10 cada 8 cuadros, cinco veces

Uso: hojas.py docs/imagenes | hojas.py cotejo
"""
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
import vdp          # noqa: E402

ORG = 0x8000
ROM = open(os.path.join(RAIZ, "skicommand.rom"), "rb").read()
FONDO = (40, 40, 48)


def b(a):
    return ROM[a - ORG]


def bloque(a, n):
    return ROM[a - ORG:a - ORG + n]


def w(a):
    return b(a) | b(a + 1) << 8


def s8(v):
    return v - 256 if v > 127 else v


def girados(datos):
    """Como sprites_girados (0x9635) y gira (0x96DA): cada sprite de 32 bytes, de lado."""
    out = bytearray()
    rev = lambda x: int("{:08b}".format(x)[::-1], 2)     # noqa: E731
    for k in range(0, len(datos), 32):
        s = datos[k:k + 32]
        out += bytes(rev(x) for x in s[16:32]) + bytes(rev(x) for x in s[0:16])
    return bytes(out)


def patrones(caida=False):
    """La tabla de dibujos de los sprites (VRAM 0x3800-0x3FFF) como la deja el juego."""
    t = bytearray(0x800)
    t[0x000:0x0C0] = bloque(0xA1CD, 0xC0)
    t[0x0C0:0x180] = bloque(0xA28D, 0xC0)                # sprites_girados sigue donde lo dejo LDIRVM...
    t[0x180:0x240] = girados(bloque(0xA28D, 0xC0))       # ...y detras, esos seis girados
    t[0x240:0x800] = bloque(0xA34D, 0x5C0)
    if caida:
        t[0x400:0x460] = bloque(0xA9ED, 0x60)
        t[0x460:0x4C0] = girados(bloque(0xA9ED, 0x60))
    return bytes(t)


def pinta(im, pat, n, x, y, color, escala=1):
    """El sprite n (16 x 16) en (x, y) con su color (el 0 no se pinta)."""
    if color == 0:
        return
    d = pat[n * 8:n * 8 + 32]
    c = vdp.PALETA[color]
    for fila in range(16):
        for col in range(16):
            byte = d[fila + (16 if col >= 8 else 0)]
            if (byte >> (7 - (col & 7))) & 1:
                for ey in range(escala):
                    for ex in range(escala):
                        px, py = (x + col) * escala + ex, (y + fila) * escala + ey
                        if 0 <= px < im.width and 0 <= py < im.height:
                            im.putpixel((px, py), c)


# --- lo que dicen las tablas ---------------------------------------------------------------------------------

COLORES_ESQUIADOR = [b(0x8465 + 4 * k + 3) for k in range(4)]      # 4, 1, 6, 1


def esquiador(n):
    """Los cuatro sprites del dibujo n: (dy, dx, dibujo, color)."""
    a = 0x8910 + 12 * n
    return [(s8(b(a + 3 * k)), s8(b(a + 3 * k + 1)), b(a + 3 * k + 2), COLORES_ESQUIADOR[k]) for k in range(4)]


def enemigo(tipo, talla, derribado=False):
    lista = w((0x8E3F if derribado else 0x8E13) + 2 * talla)
    n = b(lista)
    out = []
    for k in range(n):
        a = lista + 1 + 4 * k
        out.append((s8(b(a)), s8(b(a + 1)), b(a + 2), b(0x8E03 + 2 * tipo + b(a + 3))))
    return out


def aparato(dibujo, color, y=0x40):
    """Los sprites del aparato. El desplazamiento se suma como palabra (`add hl,de`, 0x8B59: la Y en el byte bajo y
    la X en el alto): el acarreo de la Y pasa a la X, y con un desplazamiento negativo el aparato sale un punto mas a
    la derecha de lo que dice la tabla (y es la Y del aparato, para saber si hay acarreo)."""
    lista = w(0x8BEE + 2 * dibujo)
    dy, dx = s8(b(lista)), s8(b(lista + 1))
    dx += 1 if y + b(lista) > 0xFF else 0
    filas, ancho = b(0x8BDE + 2 * dibujo), b(0x8BDE + 2 * dibujo + 1)
    out, k = [], 0
    for f in range(filas):
        for c in range(ancho):
            out.append((dy + 16 * f, dx + 16 * c, b(lista + 2 + k), color))
            k += 1
    return out


def objeto(n):
    """Las casillas del dibujo n (5 objetos x 4 tallas): (ancho, alto, [casillas fila a fila])."""
    alto, ancho = b(0x9368 + 2 * n), b(0x9368 + 2 * n + 1)     # tabla_par: C las filas, B las casillas de cada una
    p = w(0x9390 + 2 * n)
    return ancho, alto, list(bloque(p, ancho * alto))


def casilla(n):
    """El dibujo y los colores de la casilla n (las de la pista desde la 0, las de la nieve desde la 0x80)."""
    if n >= 0x80:
        k = n - 0x80
        return bloque(0xAA4D + 8 * k, 8), bloque(0xAC25 + 8 * k, 8)
    return bloque(0x9FED + 8 * n, 8), bloque(0xADFD + 8 * n, 8)


# --- las hojas ------------------------------------------------------------------------------------------------

def grupo(im, pat, sprites, x0, y0, escala):
    for dy, dx, n, c in reversed(sprites):
        pinta(im, pat, n, x0 + dx, y0 + dy, c, escala)


def hoja_esquiador(Image):
    pat = patrones(caida=True)
    E = 3
    im = Image.new("RGB", (11 * 40 * E, 56 * E), FONDO)
    for n in range(11):
        grupo(im, pat if n >= 9 else patrones(), esquiador(n)[:4 if n in (0, 3, 6) else 3], n * 40 + 20, 16, E)
    return im


def hoja_enemigos(Image):
    pat, E = patrones(), 3
    im = Image.new("RGB", (8 * 40 * E, 7 * 40 * E), FONDO)
    for t in range(1, 8):
        for s in range(4):
            grupo(im, pat, enemigo(t, s), s * 40 + 20, (t - 1) * 40 + 24, E)
            grupo(im, pat, enemigo(t, s, True), (s + 4) * 40 + 20, (t - 1) * 40 + 24, E)
    return im


def hoja_aparato(Image):
    pat, E = patrones(), 2
    im = Image.new("RGB", (4 * 64 * E, 4 * 64 * E), FONDO)
    for k in range(3):
        color = b(0x8BDB + k)
        for d in range(4):
            grupo(im, pat, aparato(d, color), d * 64 + 32, k * 64 + 40, E)
    for d in range(4, 8):                       # tocado: el byte del color pasa a ser 6 (0x8FC6)
        grupo(im, pat, aparato(d, 6), (d - 4) * 64 + 32, 3 * 64 + 40, E)
    return im


def hoja_objetos(Image):
    E = 3
    im = Image.new("RGB", (4 * 72 * E, 5 * 44 * E), FONDO)
    for n in range(20):
        ancho, alto, cs = objeto(n)
        x0, y0 = (n % 4) * 72 + 4, (n // 4) * 44 + 4
        for k, c in enumerate(cs):
            dib, col = casilla(c)
            cx, cy = x0 + (k % ancho) * 8, y0 + (k // ancho) * 8
            for f in range(8):
                tinta, fondo = vdp.PALETA[col[f] >> 4], vdp.PALETA[col[f] & 15]
                for bit in range(8):
                    color = tinta if (dib[f] >> (7 - bit)) & 1 else fondo
                    for ey in range(E):
                        for ex in range(E):
                            im.putpixel(((cx + bit) * E + ex, (cy + f) * E + ey), color)
    return im


# --- las animaciones (cuadro a cuadro, como el codigo) ---------------------------------------------------------

def salto_cuadros():
    """(dibujo, Y, sombra) de cada cuadro del salto, desde que se pulsa (0x87EC y `salto`, 0x885F)."""
    dib, y, sombra, out = 1, 0, 0x48, []
    for cuenta in range(0, 92):
        if cuenta == 2:
            dib, sombra = 2, 0x4C
        elif 2 < cuenta < 0x23:
            y -= 1
            if cuenta == 0x1B:
                sombra = 0x50
        elif 0x2B <= cuenta < 0x4B:
            y += 1
            if cuenta == 0x33:
                sombra = 0x4C
        elif cuenta == 0x4B:
            dib, sombra = 1, 0x48
        elif cuenta == 0x5B:
            dib = 0
        out.append((dib, y, sombra))
    return out


def anima_salto(Image):
    pat, E = patrones(), 3
    cuadros = []
    for dib, y, sombra in salto_cuadros() + [(0, 0, 0x48)] * 20:
        im = Image.new("RGB", (48 * E, 80 * E), FONDO)
        base = 60
        pinta(im, pat, sombra, 24 - 8 + (-8 if dib else 0), base + 0x19 - 8, 1, E) if dib else None
        sprites = esquiador(dib)
        if dib == 0:
            grupo(im, pat, sprites, 24, base, E)
        else:
            grupo(im, pat, sprites[:3], 24, base + y, E)
        cuadros.append(im)
    return cuadros


def anima_caida(Image):
    pat, E = patrones(caida=True), 3
    cuadros, dib = [], 9
    for vuelta in range(5):
        im = Image.new("RGB", (48 * E, 48 * E), FONDO)
        grupo(im, pat, esquiador(dib)[:3], 24, 16, E)
        cuadros += [im] * 8
        dib = 10 if dib == 9 else 9
    return cuadros


def guarda_gif(cuadros, ruta, ms=1000 / 60):
    """Une los cuadros iguales seguidos y guarda el GIF con la duracion de cada uno."""
    imgs, durs = [], []
    for im in cuadros:
        if imgs and list(im.getdata()) == list(imgs[-1].getdata()):
            durs[-1] += ms
        else:
            imgs.append(im)
            durs.append(ms)
    imgs[0].save(ruta, save_all=True, append_images=imgs[1:], duration=[max(20, int(round(d))) for d in durs],
                 loop=0, disposal=1)


# --- el cotejo con openMSX ------------------------------------------------------------------------------------

def cotejo():
    """Lo montado contra lo que grabo openMSX (work/*.bin, la RAM 0xE800-0xF0FF):
    1) la tabla de dibujos de los sprites (VRAM 0x3800-0x3FFF) de cada cuadro, contra `patrones()` (fuera de la
       caida) o `patrones(True)` (durante ella);
    2) los sprites del esquiador en la copia de la tabla de sprites que compone el juego (0xE800; la de la VRAM,
       0x1B00, llega un cuadro despues) contra `esquiador()` con la Y, la X y el dibujo de la RAM (0xE8A0-0xE8A2);
    3) los del aparato (0xE8DA: Y, X, dibujo y color; sus sprites desde el 5, 0xE814) contra `aparato()`; tocado
       (los dibujos 4 a 7, con 6 en el byte del color: 0x8FC6), en los cuadros en que la copia ya los lleva;
    4) los objetos de la pista de tres casillas o mas: si cada uno sale entero en alguna tabla de nombres grabada.
    El juego compone los sprites y despues mueve (el aparato, un punto a la izquierda; el esquiador, al aterrizar,
    cambia de dibujo detras): si la copia no casa con el estado del cuadro, se mira el del cuadro anterior."""
    normal, caida = patrones(), patrones(True)
    tot = dict(patrones=0, pat_mal=0, esquiador=0, esq_mal=0, esq_antes=0, esq_sin_sombra=0, aparato=0, apa_mal=0,
               apa_antes=0, apa_fuera=0, tocado=0, tocado_mal=0)

    def esq(ram, n):
        y, x, dib = ram[0xA0], ram[0xA1], ram[0xA2]
        return [((y + dy) & 0xFF, (x + dx) & 0xFF, p) for dy, dx, p, _ in esquiador(dib)[:n]]

    def apa(ram):
        ay, ax, ad, ac = ram[0xDA], ram[0xDB], ram[0xDC], ram[0xDD]
        return [((ay + dy) & 0xFF, (ax + dx) & 0xFF, p, ac & 15) for dy, dx, p, _ in aparato(ad, ac, ay)]

    vistos = [False] * 20
    for grab in ("atraccion", "partida", "rondas"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        antes = None
        for c in vdp.cuadros(ruta):
            v, ram = c["vram"], c["ram"]
            tabla = v[0x3800:0x4000]
            if tabla == normal or tabla == caida:
                tot["patrones"] += 1
            elif any(tabla[0x240:0x400]) and tabla[0:0xC0] == normal[0:0xC0]:
                tot["pat_mal"] += 1
            sat = ram[0:0x80]              # la copia de la tabla de sprites que compone el juego (0xE800)
            if 0 < ram[0xA0] < 0xC0 and ram[0xA2] < 9 and sat[0] not in (0xC0, 0xD0):
                n = 3 if ram[0xA3] else 4
                hay = [tuple(sat[4 * k:4 * k + 3]) for k in range(n)]
                tot["esquiador"] += 1
                if hay != esq(ram, n):
                    if antes is not None and antes[0xA2] < 9 and hay[:3] == esq(antes, 3):
                        tot["esq_antes"] += 1
                    elif n == 4 and hay[:3] == esq(ram, 3) and hay[3][0] == 0xC0:
                        tot["esq_sin_sombra"] += 1          # la sombra, ya fuera (al acabar la ronda)
                    else:
                        tot["esq_mal"] += 1
            if (ram[0xDA] or ram[0xDB]) and ram[0xDC] < 8 and ram[0xDA] != 0xFF:   # (sin borrar, la RAM es 0xFF)
                quiero = apa(ram)
                if ram[0xDC] >= 4:                 # tocado: solo los cuadros en que ya lleva sus dibujos
                    if sat[0x16] == quiero[0][2]:
                        tot["tocado"] += 1
                        tot["tocado_mal"] += [tuple(sat[0x14 + 4 * k:0x17 + 4 * k]) + (sat[0x17 + 4 * k] & 15,)
                                              for k in range(len(quiero))] != quiero
                    antes = ram
                    continue
                hay = [tuple(sat[0x14 + 4 * k:0x17 + 4 * k]) + (sat[0x17 + 4 * k] & 15,) for k in range(len(quiero))]
                tot["aparato"] += 1
                if hay != quiero:
                    if antes is not None and antes[0xDC] < 8 and hay[:1] and hay == apa(antes)[:len(hay)]:
                        tot["apa_antes"] += 1
                    elif all(h[0] == 0xC0 for h in hay):
                        tot["apa_fuera"] += 1               # los sprites ya fuera (la demostracion acaba)
                    else:
                        tot["apa_mal"] += 1
            antes = ram
            # los objetos de la pista: cada dibujo entero (sus casillas fila a fila) en la tabla de nombres
            if c["regs"][1] & 0x40:
                nombres = v[0x1800:0x1B00]
                for n in range(20):
                    ancho, alto, cs = objeto(n)
                    if alto * ancho < 3 or vistos[n]:
                        continue
                    fila0 = bytes(cs[:ancho])
                    p = nombres.find(fila0)
                    while p >= 0:
                        if all(nombres[p + 32 * f:p + 32 * f + ancho] == bytes(cs[f * ancho:(f + 1) * ancho])
                               for f in range(alto) if p + 32 * f + ancho <= len(nombres)):
                            vistos[n] = True
                            break
                        p = nombres.find(fila0, p + 1)
    tot["objetos_vistos"] = sum(vistos)
    tot["objetos_grandes"] = sum(1 for n in range(20) if objeto(n)[0] * objeto(n)[1] >= 3)
    return tot


def main(argv):
    if argv and argv[0] == "cotejo":
        print(cotejo())
        return 0
    from PIL import Image
    salida = argv[0]
    os.makedirs(salida, exist_ok=True)
    for nombre, f in (("esquiador.png", hoja_esquiador), ("enemigos.png", hoja_enemigos),
                      ("aparato.png", hoja_aparato), ("objetos.png", hoja_objetos)):
        f(Image).save(os.path.join(salida, nombre))
        print(nombre, os.path.getsize(os.path.join(salida, nombre)))
    guarda_gif(anima_salto(Image), os.path.join(salida, "salto_cuadros.gif"))
    guarda_gif(anima_caida(Image), os.path.join(salida, "caida_cuadros.gif"))
    for f in ("salto_cuadros.gif", "caida_cuadros.gif"):
        print(f, os.path.getsize(os.path.join(salida, f)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
