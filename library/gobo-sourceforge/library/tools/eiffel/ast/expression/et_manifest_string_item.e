indexing

	description:

		"Eiffel manifest strings which appear in a comma-separated list of manifest strings"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

deferred class ET_MANIFEST_STRING_ITEM

inherit

	ET_AST_NODE

feature -- Access

	manifest_string: ET_MANIFEST_STRING is
			-- Manifest string in comma-separated list
		deferred
		ensure
			manifest_string_not_void: Result /= Void
		end

end
