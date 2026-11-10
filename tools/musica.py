#!/usr/bin/env python3
"""Las musicas de Ski Command, EJECUTANDO su propio motor de sonido (ver
motor_musica.py).

El motor va en la interrupcion: `musica_cuadro` (0x85CA) llama a
`sonido_cuadro` (0xB9B0) en cada cuadro, fuera de la demo. Cada musica la pone
su rutina (0xBC64...), que calla antes el sonido (`sonido_calla`, 0xB969) y
deja sus piezas en los canales 0xF002, 0xF022 y 0xF042. El motor llega al PSG
por la BIOS (WRTPSG y RDPSG), que aqui se atrapan.

Uso:  musica.py registros N [cuadros] | mp3 N f.mp3 | todas docs/audio | cotejo
      (N es el numero de la pieza en PIEZAS)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (rutina, fichero, quien la pide)
PIEZAS = [
    (0xBC64, "musica_salida.mp3", "la ronda 1 al empezar (0x822C)"),
    (0xBC7E, "musica_ronda.mp3", "la ronda, cada vez que se calla (0x86A7)"),
    (0xBCB4, "musica_caida.mp3", "el choque (0x826B)"),
    (0xBCBE, "musica_pattern_clear.mp3", "PATTERN CLEAR (0x831B)"),
    (0xBC88, "musica_bonus.mp3", "la presentacion del bonus (0x8439)"),
    (0xBC9A, "musica_game_over.mp3", "GAME OVER (0x8301)"),
]

CFG = dict(rom="skicommand.rom", org=0x8000, sp=0xF300,
           init=[(0xB969, {})], frame=0xB9B0, pide=0xBC64,
           ram=(0xF000, 0xF060), hz=60, max_s=300, cuadros_previos=0)


def cfg_de(n):
    return dict(CFG, pide=PIEZAS[n][0])


def cotejo():
    """Cuadro a cuadro, los tonos (registros 0-5) y los volumenes (8-10) del motor
    ejecutado contra los del PSG que grabo openMSX al entrar en cada interrupcion
    (work/*.bin, con la RAM 0xE800-0xF0FF). La pieza empieza en la interrupcion en
    la que el puntero del canal 0 (0xF002) pasa a ser el suyo; se coteja mientras
    no empiece otra, y en cada canal solo mientras sigue con la pieza: los efectos
    (el disparo, los enemigos) cogen los canales 1 y 2."""
    import vdp
    rom = open(os.path.join(RAIZ, CFG["rom"]), "rb").read()
    w = lambda a: rom[a - 0x8000] | (rom[a - 0x7FFF] << 8)
    principio = {n: w(r + 4) for n, (r, _, _) in enumerate(PIEZAS)}   # ld de,PIEZA tras call sonido_calla
    out = []
    for grab in ("rondas", "partida"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        cs = list(vdp.cuadros(ruta, ram_n=0x900))
        p0 = lambda k: cs[k]["ram"][0x802] | (cs[k]["ram"][0x803] << 8)
        for n in range(len(PIEZAS)):
            k0 = next((k for k in range(1, len(cs)) if p0(k) == principio[n] and p0(k - 1) != principio[n]), None)
            if k0 is None or any(o[0] == n for o in out):
                continue
            cuadros, _ = motor_musica.ejecuta(cfg_de(n), rom, 0, 60 * 120)
            z = motor_musica.arranca(cfg_de(n), rom, 0)
            base = [z.mem[0xF002 + 0x20 * c] | z.mem[0xF003 + 0x20 * c] << 8 for c in range(3)]
            regs = list(cs[k0]["psg"])
            malos, mirados = [], 0
            for k, escr in enumerate(cuadros):
                for r, v in escr:
                    if r < 16:
                        regs[r] = v
                j = k0 + 1 + k
                if j >= len(cs) or (k > 0 and p0(j) != principio[n] and p0(j) in principio.values()):
                    break
                ram = cs[j]["ram"]
                if ram[0x80] or cs[j - 1]["ram"][0x80]:
                    # 0xE880: la interrupcion de antes aun corria (el cuadro de juego se ha pasado de
                    # largo y esta entra encima): la foto del PSG es de mitad de cuadro, y la siguiente aun va un
                    # cuadro tarde
                    continue
                mirados += 1
                # un canal que ha cogido un efecto (su principio ya no es el de la pieza) no se mira; el canal
                # de la RAM c suena en el canal 2 - c del PSG (sonido_cuadro va del 2 al 0 con 0xF002 primero)
                sigue = lambda jj, c: (cs[jj]["ram"][0x802 + 0x20 * c] | cs[jj]["ram"][0x803 + 0x20 * c] << 8) == base[c]
                canales = [c for c in range(3) if base[c] and all(sigue(jj, c) for jj in (j - 1, j, min(j + 1, len(cs) - 1)))]
                if any(cs[j]["psg"][r] != regs[r] for c in canales for r in (2 * (2 - c), 2 * (2 - c) + 1, 10 - c)):
                    malos.append(k)
            out.append((n, grab, k0, mirados, malos))
    return out


def main(argv):
    if argv and argv[0] == "cotejo":
        for n, grab, k0, mirados, malos in cotejo():
            print("%-26s %s, empieza en el cuadro %d: %d cuadros mirados, %d distintos %s"
                  % (PIEZAS[n][1], grab, k0, mirados, len(malos), malos[:8]))
        return 0
    if argv and argv[0] == "todas":
        os.makedirs(argv[1], exist_ok=True)
        for n, (_, fichero, _) in enumerate(PIEZAS):
            motor_musica.main(cfg_de(n), ["mp3", "0", os.path.join(argv[1], fichero)])
        return 0
    if argv and argv[0] in ("mp3", "registros"):
        n = int(argv[1], 0)
        return motor_musica.main(cfg_de(n), [argv[0], "0"] + argv[2:])
    return motor_musica.main(CFG, argv)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
