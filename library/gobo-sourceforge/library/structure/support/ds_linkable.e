indexing

	description:

		"Linkable cells with a reference to their right neighbor"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class DS_LINKABLE [G]

inherit

	DS_CELL [G]

create

	make

feature -- Access

	right: like Current
			-- Right neighbor

feature -- Element change

	put_right (other: like Current) is
			-- Put `other' to right of cell.
		require
			other_not_void: other /= Void
		do
			right := other
		ensure
			linked: right = other
		end

	forget_right is
			-- Remove right neighbor.
		do
			right := Void
		ensure
			forgotten: right = Void
		end

end
