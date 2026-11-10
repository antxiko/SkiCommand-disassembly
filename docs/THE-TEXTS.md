# The texts

Every text in the ROM, in English: there are no more. The game's font **has no
letter O**: every text has a zero in its place (C0PYRIGHT, R0UND, CASI0), and on
screen they look the same. Spaces are tile 0.

| Where | Text | Meaning |
|---|---|---|
| title (0x84BC, rows 2-3 and 6-7, in big letters) | CASIO | the publisher |
| | SKI COMMAND | the game |
| title (row 14) | PUSH TRIGGER 1 TO START GAME | press button 1 to start |
| title (row 22) | COPYRIGHT 1984 © CASIO | |
| before each round (0x8551) | ROUND 001 START | the round number |
| round cleared (0x8544) | PATTERN CLEAR | the course is over |
| no lives left (0x8560) | GAME OVER | |
| score panel (0x9997) | HIGH SCORE | |
| | 1UP | player 1 |
| | ROUND | |
| the bonus (0x95AA) | 3000, 2000, 1000 | the points of each target |

In the text table, between ROUND and START there are five spaces: that is where
`pinta_ronda` (0x9739) writes the number of the round. The © is tile 0x40.
