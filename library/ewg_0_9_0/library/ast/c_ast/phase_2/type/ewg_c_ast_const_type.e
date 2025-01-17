indexing

	description:

		"C const types"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2003/10/27 16:40:38 $"
	revision: "$Revision: 1.4 $"

class EWG_C_AST_CONST_TYPE

inherit

	EWG_C_AST_BASED_TYPE
		rename
			make as make_based_type
		redefine
			is_same_type,
			skip_consts_and_aliases,
			skip_consts,
			skip_const_pointer_and_array_types,
			is_const_type,
			corresponding_eiffel_type,
			skip_consts_and_pointers,
			skip_consts_aliases_and_arrays,
			skip_consts_aliases_and_pointers
		end


creation

	make

feature {NONE} -- Creation

	make (a_header_file_name: STRING; a_base: EWG_C_AST_TYPE) is
		require
			a_header_file_name_not_void: a_header_file_name /= Void
			a_base_not_void: a_base /= Void
		do
			make_based_type (Void, a_header_file_name, a_base)
		ensure
			base_set: base = a_base
			header_file_name_set: header_file_name = a_header_file_name
		end

feature

	is_same_type (other: EWG_C_AST_TYPE): BOOLEAN is
		local
			other_const: EWG_C_AST_CONST_TYPE
		do
			other_const ?= other
			if other_const /= Void then
				Result := is_same_based_type (other_const)
			end
		end

	append_anonymous_hash_string_to_string (a_string: STRING) is
		do
			a_string.append_string ("const_")
			base.append_hash_string_to_string (a_string)
		end

	skip_consts_and_aliases: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts_and_aliases
		end

	skip_consts: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts
		end

	skip_consts_and_pointers: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts_and_pointers
		end

	skip_consts_aliases_and_arrays: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts_aliases_and_arrays
		end

	skip_consts_aliases_and_pointers: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts_aliases_and_pointers
		end

	skip_const_pointer_and_array_types: EWG_C_AST_TYPE is
		do
			Result := base.skip_const_pointer_and_array_types
		end

	is_const_type: BOOLEAN is
		do
			Result := True
		end

	corresponding_eiffel_type: STRING is
		do
			Result := base.corresponding_eiffel_type
		end

feature -- Visitor Pattern

	process (a_processor: EWG_C_AST_TYPE_PROCESSOR) is
			-- Process `Current' using `a_processor'.
		do
			a_processor.process_const_type (Current)
		end

invariant

	is_anonymous: is_anonymous
	base_is_not_array_type: not base.is_array_type
			-- An array cannot be const
	base_is_not_function_type: not base.is_function_type
			-- An function cannot be const

end
