# Under the hood

## Rebuilding the ROM

`make verify` assembles `src/skicommand.asm` with pasmo and the 16 KB ROM comes out
**byte for byte**. `make sanity` checks what reassembling does not cover: that no
byte declared as data is read as code, that no entry point falls in data and that all
16,384 bytes are explained. `make test` runs the tests. The ROM is not in the
repository: it has to be placed in the root as `skicommand.rom` (the GoodMSX dump,
`[!]`, sha1 `17d6db13...`).

| | bytes |
|---|---|
| traced code | 6,260 |
| named data | 10,124 |
| unexplained | 0 |

The listing has 1,287 comments on 3,155 instructions (40.8%), 326 routines and labels,
none below 10% commented, and no called routine without a name.

## The cartridge

16 KB in **page 2** (0x8000-0xBFFF), with INIT at 0x8010 and the rest of the header at
zero. It leaves page 0 with the BIOS and page 1 with BASIC, and uses the BIOS for
everything.

## The BIOS it uses

Almost everything goes through the BIOS: SCREEN 2 with CHGMOD, the registers with
WRTVDP, the VRAM with FILVRM, LDIRVM, LDIRMV, RDVRM and WRTVRM, the joystick with GTSTCK
and GTTRIG, the GRAPH key with SNSMAT, and the PSG with WRTPSG and RDPSG. That is why
the collisions and the enemies **read the name table** from the VRAM to know what is on
the course.

## The interrupt

The game puts a `jp` in the H.TIMI hook (0xFD9F) and keeps changing its address
(0xFDA0) as needed:

| | address | what it does |
|---|---|---|
| `irq_musica` | 0x85A8 | the music and the counters (title, signs) |
| `irq_partida` | 0x8569 | a whole frame of the game |
| `irq_bonus` | 0x8599 | the path, the shot and the targets of the bonus |

All three end in `contadores` (0x85AB): the frame counter (0xE881) and ten counters
(0xE883-0xE88C) that go up to 0xFF and stay there. The game's waits look at them.

## How it was done

The trace follows the code from INIT, but almost the whole game hangs off the
interrupt and the table of music orders, which cannot be seen from INIT. The rest
has been **measured in openMSX** (`tools/omsx_cobertura.tcl`: a condition on
every instruction logs every new ROM address), playing and in the demo, on a Philips
VG 8020 and on C-BIOS: 2,487 addresses executed, all of them inside the code of the
listing. The screens and the tunes come from **running the ROM** in `tools/z80run.py`
with a hand-made BIOS (`tools/bios.py`), and are checked against what openMSX
recorded.

## The RAM

| | |
|---|---|
| 0xE800-0xE87F | the sprite table, sent to 0x1B00 every frame |
| 0xE881 | the frame counter; 0xE882, the stretch of the round |
| 0xE8A0 / 0xE8A1 | the skier's Y and X |
| 0xE8B0 | ten objects on the course |
| 0xE8DA | the flying machine |
| 0xE8E2 | four enemy skiers |
| 0xE906 / 0xE90A | the high score and the points, divided by 100 |
| 0xE90C / 0xE90E | the round and the lives |
| 0xE914 | it is the demo |
| 0xF000-0xF05F | the sound engine |
