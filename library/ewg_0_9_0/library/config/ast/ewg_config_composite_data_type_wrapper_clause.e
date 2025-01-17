indexing

	description:

		"Represents a wrapper clause that will generate composite data type wrappers"

	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/07/13 17:48:13 $"
	revision: "$Revision: 1.5 $"

deferred class EWG_CONFIG_COMPOSITE_DATA_TYPE_WRAPPER_CLAUSE

inherit

	EWG_CONFIG_WRAPPER_CLAUSE

	EWG_RENAMER
		export {NONE} all end

feature {ANY} -- Access

	accepts_declaration (a_declaration: EWG_C_AST_DECLARATION): BOOLEAN is
		do
			Result := False
		end

feature {ANY} -- Basic Routines

	shallow_wrap_declaration (a_declaration: EWG_C_AST_DECLARATION;
									  a_include_header_file_name: STRING;
									  a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET) is
		do
				check
					dead_end: False
				end
		end

	deep_wrap_type (a_type: EWG_C_AST_TYPE;
						 a_include_header_file_name: STRING;
						 a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET;
						 a_config_system: EWG_CONFIG_SYSTEM) is
		local
			composite_data_type: EWG_C_AST_COMPOSITE_DATA_TYPE
			composite_data_wrapper: EWG_COMPOSITE_DATA_WRAPPER
			cs: DS_BILINEAR_CURSOR [EWG_C_AST_DECLARATION]
			i: INTEGER
		do
			composite_data_type ?= a_type.skip_wrapper_irrelevant_types
				check
					composite_data_type_not_void: composite_data_type /= Void
				end
			composite_data_wrapper := a_eiffel_wrapper_set.composite_data_wrapper_from_composite_data_type (composite_data_type)
				check
					composite_data_wrapper_not_void: composite_data_wrapper /= Void
				end

			if composite_data_type.is_complete then
				from
					cs := composite_data_type.members.new_cursor
					cs.start
				until
					cs.off
				loop
					i := i + 1
					wrap_composite_data_type_member (composite_data_wrapper,
																cs.item,
																i,
																a_include_header_file_name,
																a_eiffel_wrapper_set,
																a_config_system)
					cs.forth
				end
			end
			a_config_system.mark_type_completely_wrapped (a_type)
		end

	deep_wrap_declaration (a_declaration: EWG_C_AST_DECLARATION;
								  a_include_header_file_name: STRING;
								  a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET;
								  a_config_system: EWG_CONFIG_SYSTEM) is
		do
				check
					dead_end: False
				end
		end

feature {NONE}

	wrap_composite_data_type_member (a_composite_data_wrapper: EWG_COMPOSITE_DATA_WRAPPER;
												a_member: EWG_C_AST_DECLARATION;
												a_index: INTEGER;
												a_include_header_file_name: STRING;
												a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET;
												a_config_system: EWG_CONFIG_SYSTEM) is
			-- Add wrapper for `a_member' to `a_composite_data_wrapper'.
			-- `a_member' is supposed to be the `a_index'-th member of `a_composite_data_type'.
		require
			a_composite_data_wrapper_not_void: a_composite_data_wrapper /= Void
			a_member_not_void: a_member /= Void
			a_member_is_member_of_composite_data_type: a_composite_data_wrapper.c_composite_data_type.members.has (a_member)
			a_index_greater_equal_one: a_index >= 1
			a_include_header_file_name_not_void: a_include_header_file_name /= Void
			a_eiffel_wrapper_set_not_void: a_eiffel_wrapper_set /= Void
			a_config_system_not_void: a_config_system /= Void
		local
			member_wrapper: EWG_MEMBER_WRAPPER
			struct_type: EWG_C_AST_STRUCT_TYPE
			struct_wrapper: EWG_STRUCT_WRAPPER
			wrappable_type: EWG_C_AST_TYPE
		do
			if
				not a_member.is_anonymous
			then
				if
					a_member.type.based_type_recursive.is_struct_type and
						a_member.type.total_pointer_indirections = 1
				then
					struct_type ?= a_member.type.based_type_recursive
						check
							base_must_be_struct: struct_type /= Void
						end
					a_config_system.force_shallow_wrap_type (a_member.type,
																		  a_include_header_file_name,
																		  a_eiffel_wrapper_set)
					-- we have a pointer to a struct (+/- consts and aliases)
					struct_wrapper := a_eiffel_wrapper_set.struct_wrapper_from_struct_type (struct_type)
					create {EWG_STRUCT_MEMBER_WRAPPER} member_wrapper.make (eiffel_parameter_name_from_c_parameter_name (a_member.declarator),
																							  a_include_header_file_name,
																							  a_member,
																							  struct_wrapper)
					a_composite_data_wrapper.add_member (member_wrapper)
				end
			end
			-- default mapping
			wrappable_type := a_member.type.skip_wrapper_irrelevant_types
			if
				(wrappable_type.can_be_wrapped or wrappable_type.has_built_in_wrapper)
			then

				a_config_system.force_shallow_wrap_type (a_member.type,
																	  a_include_header_file_name,
																	  a_eiffel_wrapper_set)

				create {EWG_NATIVE_MEMBER_WRAPPER} member_wrapper.make (eiffel_parameter_name_from_c_parameter_name (a_member.declarator),
																						  a_include_header_file_name,
																						  a_member)
				a_composite_data_wrapper.add_member (member_wrapper)
			end
		end

	default_eiffel_identifier_for_type (a_type: EWG_C_AST_TYPE): STRING is
		do
			if a_type.is_anonymous then
				Result := eiffel_class_name_from_c_type (a_type.closest_alias_type)
			else
				Result := eiffel_class_name_from_c_type (a_type)
			end
		end

	default_eiffel_identifier_for_declaration (a_declaration: EWG_C_AST_DECLARATION): STRING is
		do
				check
					dead_end: False
				end
		end

end
