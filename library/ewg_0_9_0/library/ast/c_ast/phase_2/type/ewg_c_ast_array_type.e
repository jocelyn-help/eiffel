indexing

	description:

		"C arrays"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/04/20 21:09:15 $"
	revision: "$Revision: 1.4 $"

class EWG_C_AST_ARRAY_TYPE

inherit

	EWG_C_AST_BASED_TYPE
		rename
			make as make_based_type
		redefine
			is_same_type,
			total_pointer_and_array_indirections,
			is_array_type,
			corresponding_eiffel_type,
			has_type_as_base_with_no_pointer_or_array_types_inbetween_indirect,
			number_of_pointer_or_array_types_between_current_and_type_recursive,
			skip_consts_aliases_and_arrays,
			skip_const_pointer_and_array_types
		end

creation

	make,
	make_with_size

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
			size_not_defined: not is_size_defined
		end

	make_with_size (a_header_file_name: STRING; a_base: EWG_C_AST_TYPE; a_size: STRING) is
		require
			a_header_file_name_not_void: a_header_file_name /= Void
			a_base_not_void: a_base /= Void
			a_size_not_void: a_size /= Void
			a_size_not_empty: a_size.count > 0
		do
			make_based_type (Void, a_header_file_name, a_base)
			size := a_size
		ensure
			base_set: base = a_base
			header_file_name_set: header_file_name = a_header_file_name
			size_defined: is_size_defined
			size_set: size = a_size
		end

feature

	size: STRING
			-- Size of current array as unparsed string

	is_size_defined: BOOLEAN is
			-- Does current array have a defined size ?
		do
			Result := size /= Void
		end

	is_same_type (other: EWG_C_AST_TYPE): BOOLEAN is
		local
			other_array: EWG_C_AST_ARRAY_TYPE
		do
			other_array ?= other
			if other_array /= Void then
				if Current = other then
					Result := true
				else
					Result := is_same_based_type (other_array)
					if Result then
						Result := is_size_defined = other_array.is_size_defined
						if Result and is_size_defined then
							Result := string_equality_tester.test (size, other_array.size)
						end
					end
				end
			end
		end

	append_anonymous_hash_string_to_string (a_string: STRING) is
		do
			a_string.append_string ("array_")
			base.append_hash_string_to_string (a_string)
		end

	total_pointer_and_array_indirections: INTEGER is
			-- Number of total pointer and array indirections
		do
			Result := 1 + base.skip_consts_and_aliases.total_pointer_and_array_indirections
		end

	is_array_type: BOOLEAN is
		do
			Result := True
		end

	corresponding_eiffel_type: STRING is
		do
			Result := "POINTER"
		end

	has_type_as_base_with_no_pointer_or_array_types_inbetween_indirect (a_type: EWG_C_AST_TYPE): BOOLEAN is
		do
			Result := False
		end

	skip_consts_aliases_and_arrays: EWG_C_AST_TYPE is
		do
			Result := base.skip_consts_aliases_and_arrays
		end

	skip_const_pointer_and_array_types: EWG_C_AST_TYPE is
		do
			Result := base.skip_const_pointer_and_array_types
		end

feature -- Visitor Pattern

	process (a_processor: EWG_C_AST_TYPE_PROCESSOR) is
			-- Process `Current' using `a_processor'.
		do
			a_processor.process_array_type (Current)
		end

feature {EWG_C_AST_BASED_TYPE}

	number_of_pointer_or_array_types_between_current_and_type_recursive (a_type: EWG_C_AST_TYPE; a_indirections: INTEGER): INTEGER is
		local
			base_based_type: EWG_C_AST_BASED_TYPE
		do
			if base = a_type then
				Result := a_indirections + 1
			else
				base_based_type ?= base
				if base_based_type /= Void then
					Result := base_based_type.number_of_pointer_or_array_types_between_current_and_type_recursive (a_type, a_indirections + 1)
				end
			end
		end

invariant

	is_anonymous: is_anonymous
	size_defined_equals_size_not_void: is_size_defined = (size /= Void)
	size_defined_implies_size_not_empty: is_size_defined implies size.count > 0

end
