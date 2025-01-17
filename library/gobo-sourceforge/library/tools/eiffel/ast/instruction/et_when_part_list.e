indexing

	description:

		"Eiffel lists of inspect when parts"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-09-06 16:51:05 +0200 (Sat, 06 Sep 2008) $"
	revision: "$Revision: 6497 $"

class ET_WHEN_PART_LIST

inherit

	ET_AST_NODE

	ET_HEAD_LIST [ET_WHEN_PART]

create

	make, make_with_capacity

feature -- Initialization

	reset is
			-- Reset when parts as they were when they were last parsed.
		local
			i, nb: INTEGER
		do
			nb := count - 1
			from i := 0 until i > nb loop
				storage.item (i).reset
				i := i + 1
			end
		end

feature -- Access

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if not is_empty then
				Result := first.position
			else
				Result := tokens.null_position
			end
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		do
			if not is_empty then
				Result := first.first_leaf
			end
		end

	last_leaf: ET_AST_LEAF is
			-- Last leaf node in current node
		do
			if not is_empty then
				Result := last.last_leaf
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if not is_empty then
				Result := last.break
			end
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_when_part_list (Current)
		end

feature {NONE} -- Implementation

	fixed_array: KL_SPECIAL_ROUTINES [ET_WHEN_PART] is
			-- Fixed array routines
		once
			create Result
		end

end
