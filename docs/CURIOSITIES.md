# Curiosities

## The jump into the middle of the BIOS

The whole game runs in the **interrupt**: every frame the BIOS calls the H.TIMI hook
(0xFD9F) and the game moves the skier, the course, the enemies and the music there.
But when it is done it does not return with a `ret`: it takes the return address to
the BIOS off the stack and **jumps to 0x0D02** (`contadores`, 0x85AB), an address
inside the MSX BIOS interrupt routine, past the keyboard scan. That way it saves
that work on every frame.

It is a shortcut that depends on how the BIOS is written inside. In openMSX the game
works the same with the BIOS of a Philips VG 8020 and with C-BIOS (the game has been
measured and recorded with both).

## A frame that does not fit in a frame

Since everything runs in the interrupt, the game guards against one arriving before
the previous one is over: 0xE880 says the interrupt is running, and if another one
comes on top only the music plays (`irq_partida`, 0x8569). It happens: in the
recording of three rounds, in **205 out of 13,000 frames** (1.6%) the interrupt comes
while the previous one is still running, and that game frame is lost.

## Copies that run over

The pattern loads to the VRAM use fixed lengths, and several read more than there is:

- the bonus colours (0x9D37) are copied with **0x518 bytes**, which run on through
  the bonus field, the course tiles and the score panel tiles, up to 0xA24F;
- the small letters (0xB7F4) are copied with 0x180 bytes and end **inside the sound
  engine** (0xB974);
- the big letters (0xB774, 0xE0 bytes) run into the font.

What is left over goes to tiles that screen does not use and is not seen.

## The font without an O

The game's font has no letter O: every text has a zero instead (CASI0, R0UND,
C0PYRIGHT). In the text table (0x8544) it reads PATTERN CLEAR, R0UND, START and
GAME 0VER.

## Orders that do not exist

The table of music orders (0xBBF6) has fourteen entries, from 0xFF to 0xF2, but 0xF8
and 0xF7 hold 0x0000: a piece using them would jump to address 0 and reset the MSX.
None of the pieces uses them (nor 0xFE, which does nothing).

## Points, a hundred at a time

The points are stored divided by 100 in two bytes (0xE90A), and two zeros are added
on screen: an enemy is worth 1, the flying machine 2, a bonus target 30. The high
score does not go past 9,999 (999,900 on screen, `marcador`, 0x9435).
