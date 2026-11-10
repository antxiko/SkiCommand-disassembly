# Ski Command - commented disassembly

*(También [en castellano](README.es.md).)*

The commented disassembly of **Ski Command** (Casio, 1984) for the MSX: a 16 KB cartridge at 0x8000.

- **100%** of the binary explained: 6,260 bytes of code and 10,124 of named data, not one byte unassigned.
- **40.8%** of the listing commented, 326 routines and labels, none below 10% of comments.
- The listing reassembles into the original ROM **byte for byte**.
- The logo, the title, the course with its four stretches of snow and the bonus come from running the ROM, checked dot by dot against openMSX; the game, the jump, the bends, the flying machine, the crash, PATTERN CLEAR, the bonus and GAME OVER, played in GIF; the six tunes, from its own sound engine and identical to openMSX frame by frame.

The site: <https://antxiko.github.io/SkiCommand-disassembly/>
(in Spanish: <https://antxiko.github.io/SkiCommand-disassembly/es/>).

## Rebuilding it

The ROM image is not distributed. Put yours in the root as `skicommand.rom` (sha256 `c843e81c...`) and run `make`. The details, in [UNDER THE HOOD](docs/UNDER-THE-HOOD.md).

## Legal

The game belongs to Casio and its rights holders. The `LICENSE` covers only the tools, comments, analysis and documentation here. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
