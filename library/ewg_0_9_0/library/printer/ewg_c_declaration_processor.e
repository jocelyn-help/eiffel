indexing

	description:

		"Abstract C declarator"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/02/27 12:18:32 $"
	revision: "$Revision: 1.2 $"

class EWG_C_DECLARATION_PROCESSOR

inherit

	EWG_C_AST_TYPE_PROCESSOR

	EWG_PRINTER

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	EWG_SHARED_C_SYSTEM
		export {NONE} all end

	EWG_C_CALLING_CONVENTION_CONSTANTS
		export {NONE} all end

feature -- Acccess

	declarator: STRING
			-- Declarator for declaration to generate

feature {EWG_C_AST_TYPE_PROCESSOR} -- Processing

	process_primitive_type (a_type: EWG_C_AST_PRIMITIVE_TYPE) is
		do
			output_stream.put_string (a_type.name)
			if should_print_const then
				output_stream.put_character (' ')
				print_const
			end
			if has_declarator then
				output_stream.put_character (' ')
			end
			print_declarator
		end

	process_eiffel_object_type (a_type: EWG_C_AST_EIFFEL_OBJECT_TYPE) is
		do
			process (c_system.types.void_pointer_type)
		end

	process_alias_type (a_type: EWG_C_AST_ALIAS_TYPE) is
		do
			output_stream.put_string (a_type.name)
			if should_print_const then
				output_stream.put_character (' ')
				print_const
			end
			if has_declarator then
				output_stream.put_character (' ')
			end
			print_declarator
		end

	process_pointer_type (a_type: EWG_C_AST_POINTER_TYPE) is
		do
			if last_type /= Void and then last_type.is_const_type then
				prepend_to_declarator ("*const ")
			else
				prepend_to_declarator ("*")
			end

			last_type := a_type
			process (a_type.base)
		end

	process_array_type (a_type: EWG_C_AST_ARRAY_TYPE) is
		do
			append_to_declarator ("[")
			if a_type.is_size_defined then
				append_to_declarator (a_type.size)
			end
			append_to_declarator ("]")
			if should_print_const then
				print_const
				output_stream.put_character (' ')
			end
			last_type := a_type
			process (a_type.base)
		end

	process_const_type (a_type: EWG_C_AST_CONST_TYPE) is
		do
			last_type := a_type
			process (a_type.base)
		end

	process_function_type (a_type: EWG_C_AST_FUNCTION_TYPE) is
		local
			declaration_printer: EWG_C_DECLARATION_PRINTER
			declaration_list_printer: EWG_C_DECLARATION_LIST_PRINTER
			l_declarator: STRING
		do
			if a_type.calling_convention = stdcall then
				prepend_to_declarator ("__stdcall ")
			elseif a_type.calling_convention = fastcall then
				prepend_to_declarator ("__fastcall ")
			end
			if should_print_const then
				prepend_to_declarator ("const ")
			end
			if last_type /= Void and then last_type.is_pointer_type then
				prepend_to_declarator ("(")
			end
			if last_type /= Void and then last_type.is_pointer_type then
				append_to_declarator (")")
			end
			create declaration_printer.make_string (text_after_declarator)
			create declaration_list_printer.make_string (text_after_declarator, declaration_printer)
			append_to_declarator (" (")
			if a_type.members.count > 0 then
				declaration_list_printer.print_declaration_list (a_type.members)
				if a_type.has_ellipsis_parameter then
					append_to_declarator (", ...")
				end
			else
				if not a_type.has_ellipsis_parameter then
					declaration_printer.print_declaration_from_type (c_system.types.void_type, "")
				end
			end
			append_to_declarator (")")
			create l_declarator.make (text_before_declarator.count + declarator.count + text_after_declarator.count)
			l_declarator.append_string (text_before_declarator)
			l_declarator.append_string (declarator)
			l_declarator.append_string (text_after_declarator)
			create declaration_printer.make (output_stream)
			declaration_printer.print_declaration_from_type (a_type.return_type, l_declarator)
		end

	process_struct_type (a_type: EWG_C_AST_STRUCT_TYPE) is
		do
			if a_type.is_anonymous then
					check
						has_perfect_alias: a_type.has_perfect_alias_type
					end
				process (a_type.closest_alias_type)
			else
				output_stream.put_string ("struct ")
				output_stream.put_string (a_type.name)
				if should_print_const then
					output_stream.put_character (' ')
					print_const
				end
				if has_declarator then
					output_stream.put_character (' ')
				end
				print_declarator
			end
		end

	process_union_type (a_type: EWG_C_AST_UNION_TYPE) is
		do
			if a_type.is_anonymous then
					check
						has_perfect_alias: a_type.has_perfect_alias_type
					end
				process (a_type.closest_alias_type)
			else
				output_stream.put_string ("union ")
				output_stream.put_string (a_type.name)
				if should_print_const then
					output_stream.put_character (' ')
					print_const
				end
				if has_declarator then
					output_stream.put_character (' ')
				end
				print_declarator
			end
		end

	process_enum_type (a_type: EWG_C_AST_ENUM_TYPE) is
		do
			if a_type.is_anonymous then
					check
						has_perfect_alias: a_type.has_perfect_alias_type
					end
				process (a_type.closest_alias_type)
			else
				output_stream.put_string ("enum ")
				output_stream.put_string (a_type.name)
				if should_print_const then
					output_stream.put_character (' ')
					print_const
				end
				if has_declarator then
					output_stream.put_character (' ')
				end
				print_declarator
			end
		end

feature {NONE}

	text_before_declarator: STRING
			-- Text to output before `declarator'

	text_after_declarator: STRING
			-- Text to output after  `declarator'

	reset is
		do
			declarator := clone ("")
			text_before_declarator := clone ("")
			text_after_declarator := clone ("")
			last_type := Void
		ensure
			declarator_not_void: declarator /= Void
			declarator_is_empty: declarator.count = 0
			text_before_declarator_not_void: text_before_declarator /= Void
			text_before_declarator_is_empty: text_before_declarator.count = 0
			text_after_declarator_not_void: text_after_declarator /= Void
			text_after_declarator_is_empty: text_after_declarator.count = 0
		end

	last_type: EWG_C_AST_TYPE
			-- Last type that was processed

	process (a_type: EWG_C_AST_TYPE) is
			-- Process `a_type'.
		require
			a_type_not_void: a_type /= Void
			a_type_valid: a_type.is_named_recursive or a_type.based_type_recursive.is_function_type or a_type.based_type_recursive.is_eiffel_object_type or a_type.based_type_recursive.has_perfect_alias_type
			declarator_not_void: declarator /= Void
		do
			a_type.process (Current)
		end

	prepend_to_declarator (a_string: STRING) is
			-- Prepend `a_string' to `text_before_declarator'.
		require
			a_string_not_void: a_string /= Void
			a_string_not_empty: a_string.count > 0
			text_before_declarator_not_void: text_before_declarator /= Void
		local
			new_text_before_declarator: STRING
		do
			new_text_before_declarator := STRING_.make (a_string.count + text_before_declarator.count)
			new_text_before_declarator.append_string (a_string)
			new_text_before_declarator.append_string (text_before_declarator)
			text_before_declarator := new_text_before_declarator
		ensure
			text_before_declarator_size: text_before_declarator.count = a_string.count + old text_before_declarator.count
			a_string_prepended: STRING_.same_string (text_before_declarator.substring (1, a_string.count), a_string)
			old_string_follows: STRING_.same_string (text_before_declarator.substring (a_string.count + 1, text_before_declarator.count), old clone(text_before_declarator))
		end

	append_to_declarator (a_string: STRING) is
			-- Append `a_string' to `text_after_declarator'.
		require
			a_string_not_void: a_string /= Void
			a_string_not_empty: a_string.count > 0
			text_after_declarator_not_void: text_after_declarator /= Void
		do
			text_after_declarator.append_string (a_string)
		ensure
			text_after_declarator_size: text_after_declarator.count = a_string.count + old text_after_declarator.count
		end

	print_declarator is
		require
			text_before_declarator_not_void: text_before_declarator /= Void
			text_after_declarator_not_void: text_after_declarator /= Void
			declarator_not_void: declarator /= Void
		do
			output_stream.put_string (text_before_declarator)
			output_stream.put_string (declarator)
			output_stream.put_string (text_after_declarator)
		end

	print_const is
			-- Print "const".
		require
			should_print_const
		do
			output_stream.put_string ("const")
		end

	should_print_const: BOOLEAN is
		do
			Result := last_type /= Void and then last_type.is_const_type
		end

	has_declarator: BOOLEAN is
		require
			declarator_not_void: declarator /= Void
		do
			Result := declarator.count > 0
		end

end
