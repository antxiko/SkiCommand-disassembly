#!/usr/bin/env python3
"""EL CONTENIDO de la web de esta ROM: lo unico que es de este juego.

jekyll.py y make_web.py son la maquinaria y no llevan dentro el nombre de
ningun juego: lo leen de aqui.

Todas las cifras de aqui estan medidas sobre esta ROM, con las herramientas
de tools/: CODIGO y DATOS los imprime tools/presupuesto.py (make sanity),
INSTRUCCIONES, COMENTARIOS y RUTINAS los da tools/densidad.py (make densidad:
"de N" rutinas, "N instrucciones, M comentarios").
"""

NOMBRE = "Ski Command"
EDITOR = "Casio"
ANIO = 1984
REPOSITORIO = "https://github.com/antxiko/SkiCommand-disassembly"
SHA1 = "17d6db13d7d76fbd110f53b168ab0001c7e65817"

CODIGO = 6260
DATOS = 10124
RUTINAS = 326
INSTRUCCIONES = 3155
COMENTARIOS = 1287


def densidad(idioma):
    """El porcentaje comentado, con la coma o el punto de cada idioma."""
    d = "%.1f" % (100.0 * COMENTARIOS / INSTRUCCIONES)
    return d.replace(".", ",") if idioma == "es" else d


PIE_LEGAL = {
    "es": "<em>Ski Command</em> es un juego de Casio para MSX, de 1984, en un cartucho "
          "de 16 KB. Todos los derechos sobre el juego siguen siendo de sus "
          "titulares. Este trabajo es de preservaci&oacute;n, estudio y "
          "documentaci&oacute;n, y la imagen de la ROM no se distribuye.",
    "en": "<em>Ski Command</em> is a 1984 Casio game for the MSX, on a 16 KB cartridge. "
          "All rights in the game remain with their holders. This is preservation, "
          "study and documentation work, and the ROM image is not distributed.",
}

PORTADA = {
    "es": dict(
        titulo="Ski Command - desensamblado comentado",
        claim="Un comando baja esquiando entre &aacute;rboles, esquiadores enemigos y "
              "un aparato que suelta cosas desde el aire: la pista y sus cuatro tramos "
              "de nieve, el bonus y el t&iacute;tulo desde los bytes de la ROM, "
              "cotejados punto a punto con openMSX; la partida, el salto, las curvas, "
              "el aparato, la ca&iacute;da y el bonus jugados en GIF, y las seis "
              "m&uacute;sicas de su propio motor, id&eacute;nticas a openMSX cuadro a cuadro.",
        ficha=["Casio - <b>(c) 1984</b>",
               "Cartucho de <b>16 KB</b> en 0x8000",
               "<b>MSX</b>", "Volcado <b>17d6db13...</b>"],
        aviso="<b>Aqu&iacute; no hay capturas del juego.</b> El logotipo y las "
              "pantallas salen de ejecutar la ROM (cotejadas con openMSX), y los "
              "GIF son la ROM <b>funcionando en openMSX</b>: en cada cuadro se "
              "apuntan la VRAM y los registros del VDP, y <b>c&oacute;digo nuestro "
              "los pinta</b>.",
    ),
    "en": dict(
        titulo="Ski Command - commented disassembly",
        claim="A commando skis downhill between trees, enemy skiers and a flying "
              "machine that drops things from the air: the course and its four stretches "
              "of snow, the bonus and the title from the ROM's bytes, checked dot by dot "
              "against openMSX; the game, the jump, the bends, the flying machine, the "
              "crash and the bonus played in GIF, and the six tunes from its own engine, "
              "identical to openMSX frame by frame.",
        ficha=["Casio - <b>(c) 1984</b>",
               "<b>16 KB</b> cartridge at 0x8000",
               "<b>MSX</b>", "Dump <b>17d6db13...</b>"],
        aviso="<b>There are no screenshots of the game here.</b> The logo and the "
              "screens come from running the ROM (checked against openMSX), and the "
              "GIFs are the ROM <b>running in openMSX</b>: on every frame the VRAM and "
              "the VDP registers are logged, and <b>our own code paints them</b>.",
    ),
}

PAGINAS = [
    [("THE-GAME.html", "LA-PARTIDA.html", "The game", "La partida",
      "the skier, the shot, the jump, the controls, the points and the lives, as the "
      "code has them",
      "el esquiador, el disparo, el salto, los mandos, los puntos y las vidas, como los "
      "tiene el c&oacute;digo"),
     ("THE-COURSE.html", "LA-PISTA.html", "The course", "La pista",
      "the screen from the ROM, its four stretches of snow, the bends, the trees and "
      "rocks, and the six difficulties",
      "la pantalla desde la ROM, sus cuatro tramos de nieve, las curvas, los &aacute;rboles "
      "y las rocas, y las seis dificultades"),
     ("THE-ENEMIES.html", "LOS-ENEMIGOS.html", "The enemies", "Los enemigos",
      "the enemy skiers, the flying machine and what it drops, played in GIF",
      "los esquiadores enemigos, el aparato y lo que suelta, jugados en GIF"),
     ("THE-SPRITES.html", "LOS-SPRITES.html", "The sprites", "Los sprites",
      "the skier, the enemies, the flying machine and the course objects, put together from the ROM tables, and "
      "the jump and the crash frame by frame",
      "el esquiador, los enemigos, el aparato y los objetos de la pista, montados desde las tablas de la ROM, y el "
      "salto y la ca&iacute;da cuadro a cuadro"),
     ("THE-SEQUENCES.html", "LAS-SECUENCIAS.html", "The sequences", "Las secuencias",
      "the title, the demo, PATTERN CLEAR, the bonus, the crash and GAME OVER",
      "el t&iacute;tulo, la demo, PATTERN CLEAR, el bonus, la ca&iacute;da y el GAME OVER"),
     ("THE-TEXTS.html", "LOS-TEXTOS.html", "The texts", "Los textos",
      "every text in the ROM, with its translation",
      "todos los textos de la ROM, con su traducci&oacute;n"),
     ("THE-MUSIC.html", "LA-MUSICA.html", "The music", "La m&uacute;sica",
      "the six tunes, from its own sound engine and checked against openMSX",
      "las seis m&uacute;sicas, de su propio motor de sonido y cotejadas con openMSX")],
    [("CURIOSITIES.html", "CURIOSIDADES.html", "Curiosities", "Curiosidades",
      "the jump into the middle of the BIOS, the copies that run over, the font without an "
      "O, the orders that do not exist and the frames that run late",
      "el salto al medio de la BIOS, las copias que se pasan, la fuente sin O, las "
      "&oacute;rdenes que no existen y los cuadros que llegan tarde"),
     ("SECRETS-AND-BUGS.html", "SECRETOS-Y-FALLOS.html", "Secrets and bugs", "Secretos y fallos",
      "what was searched for and found: no hidden keys, and a score that loses its first figure past 999,900",
      "lo que se ha buscado y lo encontrado: ninguna tecla escondida, y unos puntos que pierden la primera cifra "
      "pasados los 999.900")],
    [("UNDER-THE-HOOD.html", "POR-DENTRO.html", "Under the hood", "Por dentro",
      "rebuilding the ROM, the BIOS it uses, the interrupt, the RAM, the sound engine "
      "and the tools",
      "rehacer la ROM, la BIOS que usa, la interrupci&oacute;n, la RAM, el motor de "
      "sonido y las herramientas")],
]

# Repositorio nuevo: no hay paginas viejas que redirigir.
VIEJAS = {}

LOGOTIPO = "logotipo.png"
