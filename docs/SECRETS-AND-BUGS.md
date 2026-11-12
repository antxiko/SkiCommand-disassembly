# Secrets and bugs

What was searched for in the code, and what was found. A bug only goes here if it has been checked: by running the
game's own routine (`tools/bios.py`) or against the openMSX recordings.

## Secrets: none hidden

- **No hidden keys.** The game reads the controls in one place (`mando`, 0x8600): the cursors and the two joysticks
  (GTSTCK), button 1 or the space bar, and button 2 or the GRAPH key, read with SNSMAT in row 6 (0x866A). There is no
  other keyboard read in the whole ROM: no key held at start-up, no code on the title.
- **The one reward that is not on screen**: once the flying machine has been hit and is blowing up, a second shot
  within 8 dots of it gives an **extra life** (`disparo_aparato`, 0x8F58). It is told in [The game](THE-GAME.html).
- **No unused screens or texts**: every text in the ROM is on [The texts](THE-TEXTS.html), and every one is shown.

## Bug: the score past 999,900

The points are kept divided by 100 in two bytes (0xE90A) and `cifras` (0x9760) turns them into five figures, with
the zeros behind. But `pinta_puntos` (0x9754) writes **six characters starting from the second figure**: the one
for the tens of thousands, which is only needed past 9,999 (999,900 points), is never shown. The high score is
held below that (`marcador`, 0x9435: no more than 9,999), so it never shows wrong; the score of the game does.

Running the game's own routine here with three scores:

| points | on screen |
|---|---|
| 999,900 | `999900` |
| 1,000,000 | `000000` |
| 1,234,500 | `234500` |

So a player who goes past 999,900 sees the counter start again from zero, while the high score stays at 999,900.

## Other things that go wrong, told in [Curiosities](CURIOSITIES.html)

- **Frames that run late**: when an interrupt arrives with the previous one still running, only the music plays
  and that game frame is lost (`irq_solo_musica`): 205 of 13,000 frames in the recording of three rounds.
- **Copies that run over**: three pattern loads use fixed lengths longer than their data and copy what follows
  (the bonus colours, 0x518 bytes; the small and big letters), into tiles that are not seen.
- **Music orders that would reset the MSX**: entries 0xF8 and 0xF7 of the order table (0xBBF6) point to address 0;
  no piece uses them.
