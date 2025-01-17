indexing

	description:

		"Eiffel argument or target components appearing in feature calls or agents"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-04-23 23:23:03 +0200 (Mon, 23 Apr 2007) $"
	revision: "$Revision: 5948 $"

deferred class ET_OPERAND

inherit

	ET_AST_NODE

feature -- Initialization

	reset is
			-- Reset operand as it was just after it was last parsed.
		do
		end

feature -- Status setting

	is_open_operand: BOOLEAN is
			-- Is current operand open?
		do
			-- Result := False
		end

feature -- Access

	index: INTEGER
			-- Index of operand in enclosing feature;
			-- Used to get dynamic information about this expression.

feature -- Setting

	set_index (i: INTEGER) is
			-- Set `index' to `i'.
		require
			i_nonnegative: i >= 0
		do
			index := i
		ensure
			index_set: index = i
		end

end
