# Ski Command - desensamblado comentado

*(Also [in English](README.md).)*

El desensamblado comentado de **Ski Command** (Casio, 1984) para MSX: un cartucho de 16 KB en 0x8000.

- **100 %** del binario explicado: 6.260 bytes de código y 10.124 de datos con nombre, ni un byte sin asignar.
- **40,8 %** del listado comentado, 326 rutinas y etiquetas, ninguna por debajo del 10 % de comentarios.
- El listado se reensambla en la ROM original **byte a byte**.
- El logotipo, el título, la pista con sus cuatro tramos de nieve y el bonus salen de ejecutar la ROM, cotejados punto a punto con openMSX; la partida, el salto, las curvas, el aparato, la caída, PATTERN CLEAR, el bonus y el GAME OVER, jugados en GIF; las seis músicas, de su propio motor de sonido e idénticas a openMSX cuadro a cuadro.

La web: <https://antxiko.github.io/SkiCommand-disassembly/es/>
(en inglés: <https://antxiko.github.io/SkiCommand-disassembly/>).

## Reproducirlo

La imagen de la ROM no se distribuye. Pon la tuya en la raíz como `skicommand.rom` (sha256 `c843e81c...`) y ejecuta `make`. El detalle, en [POR DENTRO](docs/es/POR-DENTRO.md).

## Legal

El juego es de Casio y de sus titulares. La licencia de `LICENSE` cubre solo las herramientas, los comentarios, el análisis y la documentación de aquí. Mira [AVISO-LEGAL.md](AVISO-LEGAL.md).
