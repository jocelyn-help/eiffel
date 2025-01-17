indexing
	description: "[
		Constants used by memory management.
		This class may be used as ancestor by classes needing its facilities.
		]"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2007-02-18 12:15:30 +0100 (Sun, 18 Feb 2007) $"
	revision: "$Revision: 5897 $"

class
	MEM_CONST

feature -- Access

	Total_memory: INTEGER is 0
			-- Code for all the memory managed
			-- by the garbage collector

	Eiffel_memory: INTEGER is 1
			-- Code for the Eiffel memory managed
			-- by the garbage collector

	C_memory: INTEGER is 2
			-- Code for the C memory managed
			-- by the garbage collector

	Full_collector: INTEGER is 0
			-- Statistics for full collections

	Incremental_collector: INTEGER is 1;
			-- Statistics for incremental collections

end
