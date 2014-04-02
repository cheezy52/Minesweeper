This is a terminal-based implementation of the game "Minesweeper".  Find all the buried mines and flag them safely, but step carefully or it'll be the last step you take!

To make a move, input the coordinates in "row, column" format, prefixed by which command you wish to perform on that square (e.g. "r, 3, 4" will Reveal the 3rd row, 4th column).  Available commands are "(r)eveal", "(f)lag", "(u)nflag", or "(s)ave and quit".  Saving the game does not require a coordinate argument (so, to save your game, simply type "s" and hit Enter).

The game is won when all mines are flagged and all non-mine spaces are revealed.