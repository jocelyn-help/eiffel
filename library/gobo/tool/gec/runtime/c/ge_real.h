/*
	description:

		"C functions used to implement class REAL"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2006, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-09-13 20:19:54 +0200 (Thu, 13 Sep 2007) $"
	revision: "$Revision: 6067 $"
*/

#ifndef GE_REAL_H
#define GE_REAL_H

#include <math.h>

#ifndef GE_power
#define GE_power(x,y) pow((x),(y))
#endif
#define GE_ceiling(x) ceil(x)
#define GE_floor(x) floor(x)

#endif
