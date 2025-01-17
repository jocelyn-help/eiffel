indexing

	description:

		"Eiffel entity declarations"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2007, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-07-09 05:53:21 +0200 (Mon, 09 Jul 2007) $"
	revision: "$Revision: 6003 $"

deferred class ET_ENTITY_DECLARATION

inherit

	ET_AST_NODE

feature -- Access

	name: ET_IDENTIFIER is
			-- Name
		deferred
		ensure
			name_not_void: Result /= Void
		end

	type: ET_TYPE is
			-- Type
		deferred
		ensure
			type_not_void: Result /= Void
		end

feature -- Status report

	is_last_entity: BOOLEAN is
			-- Is current entity the last entity in an
			-- entity declaration group?
		do
			Result := True
		end

end
