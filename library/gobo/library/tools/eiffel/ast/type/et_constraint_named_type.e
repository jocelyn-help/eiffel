indexing

	description:

		"Eiffel types which appear in constraints of formal %
		%generic parameters. The names of the types have not %
		%been resolved yet, they may be names of classes or %
		%of formal generic parameters."

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-04-10 14:53:01 +0200 (Thu, 10 Apr 2008) $"
	revision: "$Revision: 6346 $"

class ET_CONSTRAINT_NAMED_TYPE

inherit

	ET_CONSTRAINT_TYPE

create

	make

feature {NONE} -- Initialization

	make (a_type_mark: like type_mark; a_name: like name) is
			-- Create a new constraint named type.
		require
			a_name_not_void: a_name /= Void
		do
			type_mark := a_type_mark
			name := a_name
		ensure
			type_mark_set: type_mark = a_type_mark
			name_set: name = a_name
		end

feature -- Access

	name: ET_IDENTIFIER
			-- Name of type

	type_mark: ET_TYPE_MARK
			-- 'expanded', 'reference' or 'separate' keyword,
			-- or '!' or '?' symbol

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if type_mark /= Void then
				Result := type_mark.position
			else
				Result := name.position
			end
		end

feature -- Conversion

	resolved_syntactical_constraint (a_formals: ET_FORMAL_PARAMETER_LIST;
		a_parser: ET_EIFFEL_PARSER_SKELETON): ET_TYPE is
			-- Version of current type, appearing in the constraint of
			-- one of the formal generic parameters in `a_formals', where
			-- class names and formal generic parameter names have been
			-- resolved (i.e. replaced by the corresponding Class_type,
			-- Tuple_type and Formal_parameter_type)
		do
			Result := a_parser.resolved_constraint_named_type (Current, a_formals)
		end

invariant

	name_not_void: name /= Void

end
