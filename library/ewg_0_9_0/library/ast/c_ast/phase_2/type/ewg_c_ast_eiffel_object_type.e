indexing

	description:

		"'void*' type that is actually a pointer to an Eiffel object"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2003/10/27 16:40:38 $"
	revision: "$Revision: 1.2 $"

			-- TODO: should actually be inheriting from C_AST_POINTER
			-- Plus, its name should reflect that it represents values
			-- who are references to eiffel objects (C_AST_EIFFEL_OBJECT_POINTER)
class EWG_C_AST_EIFFEL_OBJECT_TYPE

inherit

	EWG_C_AST_SIMPLE_TYPE
		rename
			make as make_simple_type
		redefine
			corresponding_eiffel_type,
			is_same_type,
			is_eiffel_object_type
		end

creation

	make

feature

	make (a_eiffel_class_name: STRING) is
		require
			a_eiffel_class_name_not_void: a_eiffel_class_name /= Void
		do
			make_simple_type (Void, "header_file_unknown")
			eiffel_class_name := a_eiffel_class_name
		end

feature

	eiffel_class_name: STRING

feature

	is_same_type (other: EWG_C_AST_TYPE): BOOLEAN is
		local
			other_eiffel: EWG_C_AST_EIFFEL_OBJECT_TYPE
		do
			other_eiffel ?= other
			if other_eiffel /= Void then
				Result := Current = other_eiffel or else equal (eiffel_class_name, other_eiffel.eiffel_class_name)
			end
		end

	is_eiffel_object_type: BOOLEAN is
		do
			Result := True
		end

feature -- Visitor Pattern

	process (a_processor: EWG_C_AST_TYPE_PROCESSOR) is
			-- Process `Current' using `a_processor'.
		do
			a_processor.process_eiffel_object_type (Current)
		end

feature

	corresponding_eiffel_type: STRING is
		do
			Result := eiffel_class_name
		end

	append_anonymous_hash_string_to_string (a_string: STRING) is
		do
			a_string.append_string (eiffel_class_name)
		end

invariant

	eiffel_class_name_not_void: eiffel_class_name /= Void
	is_anonymous: is_anonymous

end
