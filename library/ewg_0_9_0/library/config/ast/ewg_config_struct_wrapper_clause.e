indexing

	description:

		"Represents a wrapper clause that will generate struct wrappers"

	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/03/26 21:56:23 $"
	revision: "$Revision: 1.3 $"

class EWG_CONFIG_STRUCT_WRAPPER_CLAUSE

inherit

	EWG_CONFIG_COMPOSITE_DATA_TYPE_WRAPPER_CLAUSE

creation

	make

feature {ANY} -- Access

	accepts_type (a_type: EWG_C_AST_TYPE): BOOLEAN is
		local
			skipped_type: EWG_C_AST_TYPE
		do
			skipped_type := a_type.skip_wrapper_irrelevant_types
			Result := skipped_type.is_struct_type and skipped_type.can_be_wrapped
		end

feature {ANY} -- Basic Routines
	
	shallow_wrap_type (a_type: EWG_C_AST_TYPE;
							 a_include_header_file_name: STRING;
							 a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET) is
		local
			struct_type: EWG_C_AST_STRUCT_TYPE
			struct_wrapper: EWG_STRUCT_WRAPPER
			member_list: DS_ARRAYED_LIST [EWG_MEMBER_WRAPPER]
		do
			struct_type ?= a_type.skip_wrapper_irrelevant_types
				check
					struct_type_not_void: struct_type /= Void
				end
			create member_list.make_default
			create struct_wrapper.make (eiffel_identifier_for_type (struct_type),
												 a_include_header_file_name,
												 struct_type,
												 member_list)
			a_eiffel_wrapper_set.add_wrapper (struct_wrapper)
		end
	
end


	
