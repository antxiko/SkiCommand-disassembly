# The music

Six tunes, on the three channels of the PSG. They are not recorded by hand:
`tools/musica.py` **runs the ROM's own sound engine** with `tools/z80run.py` -the
routine of each tune (0xBC64...) and, every frame, `sonido_cuadro` (0xB9B0)- and
logs what it writes to the PSG through the BIOS (WRTPSG and RDPSG).

**Checked against openMSX**: in the recorded games, the tone and volume registers
match the engine run frame by frame, **each piece in full**: 430, 287, 54, 162, 384
and 143 frames, **0 different**. The channels an effect takes away from the music
(the shot, the enemies) are not compared, nor the frames where the interrupt comes
while the previous one is still running (0xE880): the PSG snapshot is then from the
middle of a frame.

## The engine

Three channels at 0xF002, 0xF022 and 0xF042, 32 bytes each. A piece is a series of
**three-byte** groups: a note (its number, the duration and how long to wait for the
next one) or an order from 0xF2 to 0xFF, with two bytes of arguments: end, repeat a
section, jump, volume, envelope, noise, vibrato... (the table 0xBBF6). The notes come
from twelve periods of the lowest octave (0xBC24), halved for every octave. The
volume follows a 16-step **envelope** from a table (0xBC3C) or the PSG's own.

Channel 0xF002 plays on the PSG's channel C, 0xF022 on B and 0xF042 on A:
`sonido_cuadro` goes through them counting the PSG channel downwards. The effects use
B and A, and while they play the music is silent on that channel. In the demo the
engine does not play: the interrupt silences it.

| | Who asks for it | Length |
|---|---|---:|
| the start | round 1 when it begins (0x822C) | 7.2 s |
| the round | the round, every time it goes silent (0x86A7) | 4.8 s, and again |
| the crash | the crash (0x826B) | 0.9 s |
| PATTERN CLEAR | the round cleared (0x831B) | 2.7 s |
| the bonus | the bonus screen (0x8439) | 6.4 s |
| GAME OVER | no lives left (0x8301) | 2.4 s |

## The start

<audio controls src="audio/musica_salida.mp3"></audio>

## The round

<audio controls src="audio/musica_ronda.mp3"></audio>

## The crash

<audio controls src="audio/musica_caida.mp3"></audio>

## PATTERN CLEAR

<audio controls src="audio/musica_pattern_clear.mp3"></audio>

## The bonus

<audio controls src="audio/musica_bonus.mp3"></audio>

## GAME OVER

<audio controls src="audio/musica_game_over.mp3"></audio>
