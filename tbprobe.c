/*
This Software is distributed with the following X11 License,
sometimes also known as MIT license.
 
Copyright (c) 2010 Miguel A. Ballicora

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
*/

#include <stdlib.h>
#include <stdio.h>
#include "gtb-probe.h"

int main (void)
{
	/*--------------------------------------*\
	|   Probing info to provide
	\*--------------------------------------*/

	int	stm;				/* side to move */
	int	epsquare;			/* target square for an en passant capture */
	int	castling;			/* castling availability, 0 => no castles */
	unsigned int  ws[17];	/* list of squares for white */
	unsigned int  bs[17];	/* list of squares for black */
	unsigned char wp[17];	/* what white pieces are on those squares */
	unsigned char bp[17];	/* what black pieces are on those squares */

	/*--------------------------------------*\
	|   Probing info requested
	\*--------------------------------------*/

	int tb_available;			/* 0 => FALSE, 1 => TRUE */
	unsigned info = tb_UNKNOWN;	/* default, no tbvalue */
	unsigned pliestomate;	


	/*--------------------------------------*\
	|   Initialization info to be provided
	\*--------------------------------------*/

	int verbosity = 0;		/* initialization 0 = non-verbose, 1 = verbose */
	int	scheme = tb_CP4;	/* compression scheme to be used */
	char ** Tbpaths;		/* paths where files will be searched */
	size_t cache_size = 32*1024*1024; /* 32 MiB in this example */

	/*--------------------------------------*\
	|   Initialization:
	|   Include something like this at
	|   the beginning of the program.   
	\*--------------------------------------*/

	Tbpaths = tbpaths_init();
	Tbpaths = tbpaths_add (Tbpaths, "/media/bigdisk/gtb--4/");
	Tbpaths = tbpaths_add (Tbpaths, "/media/bigdisk/gtb--1/");

	tb_init (verbosity, scheme, Tbpaths);

	tbcache_init(cache_size);

	tbstats_reset();

	/*--------------------------------------*\
	|
	|   ASSIGNING POSITIONAL VALUES for
	|   one probing example
	|
	|   Position we try to probe:
	|   
	|   1r6/6k1/8/8/8/8/1P6/1KR5 w - - 0 1
	|   
	\*--------------------------------------*/

#if 1
	stm      = tb_WHITE_TO_MOVE;/* 0 = white to move, 1 = black to move */
	epsquare = tb_NOSQUARE;		/* no ep available */
	castling = tb_NOCASTLE;		/* no castling available */

	ws[0] = tb_B1;
	ws[1] = tb_C1;
	ws[2] = tb_B2;
	ws[3] = tb_NOSQUARE;		/* it marks the end of list */

	wp[0] = tb_KING;
	wp[1] = tb_ROOK;
	wp[2] = tb_PAWN;
	wp[3] = tb_NOPIECE;			/* it marks the end of list */

	bs[0] = tb_G7;
	bs[1] = tb_B8;
	bs[2] = tb_NOSQUARE;		/* it marks the end of list */

	bp[0] = tb_KING;
	bp[1] = tb_ROOK;
	bp[2] = tb_NOPIECE;			/* it marks the end of list */

#else

	stm      = tb_WHITE_TO_MOVE;/* 0 = white to move, 1 = black to move */
	epsquare = tb_NOSQUARE;		/* no ep available */
	castling = tb_NOCASTLE;		/* no castling available */

	ws[0] = tb_A1;
	ws[1] = tb_B1;
	ws[2] = tb_A2;
	ws[3] = tb_NOSQUARE;		/* it marks the end of list */

	wp[0] = tb_KING;
	wp[1] = tb_ROOK;
	wp[2] = tb_KNIGHT;
	wp[3] = tb_NOPIECE;			/* it marks the end of list */

	bs[0] = tb_E5;
	bs[1] = tb_F6;
	bs[2] = tb_NOSQUARE;		/* it marks the end of list */

	bp[0] = tb_KING;
	bp[1] = tb_BISHOP;
	bp[2] = tb_NOPIECE;			/* it marks the end of list */

#endif

	/*--------------------------------------*\
	|
	|      		PROBING TBs
	|   
	\*--------------------------------------*/

	tb_available = tb_probe_hard (stm, epsquare, castling, ws, bs, wp, bp, &info, &pliestomate);

	if (tb_available) {

		printf ("1r6/6k1/8/8/8/8/1P6/1KR5 w - - 0 1\n");

		if (info == tb_DRAW)
			printf ("Draw\n");
		else if (info == tb_WMATE && stm == tb_WHITE_TO_MOVE)
			printf ("White mates, plies=%u\n", pliestomate);
		else if (info == tb_BMATE && stm == tb_BLACK_TO_MOVE)
			printf ("Black mates, plies=%u\n", pliestomate);
		else if (info == tb_WMATE && stm == tb_BLACK_TO_MOVE)
			printf ("Black is mated, plies=%u\n", pliestomate);
		else if (info == tb_BMATE && stm == tb_WHITE_TO_MOVE)
			printf ("White is mated, plies=%u\n", pliestomate);         
		else {
			printf ("FATAL ERROR, This should never be reached\n");
			exit(EXIT_FAILURE);
		}
	} else {
		printf ("Tablebase info not available\n");   
	}


	/*--------------------------------------*\
	|	Clean up at the end of the program
	\*--------------------------------------*/

	tbcache_done();

	tb_done();

	Tbpaths = tbpaths_done(Tbpaths);

	/*--------------------------------------*\
	|         		Return
	\*--------------------------------------*/

	if (tb_available)
		return EXIT_SUCCESS;
	else
		return EXIT_FAILURE;
} 
