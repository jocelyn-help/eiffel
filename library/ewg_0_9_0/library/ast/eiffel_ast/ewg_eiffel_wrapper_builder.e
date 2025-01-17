indexing

	description:

		"Builds Eiffel wrappers from C AST"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2005/02/14 20:02:49 $"
	revision: "$Revision: 1.14 $"

class EWG_EIFFEL_WRAPPER_BUILDER

inherit

	ANY

	EWG_SHARED_C_SYSTEM
		export {NONE} all end

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

	EWG_RENAMER
		export {NONE} all end

creation

	make

feature {NONE}

	make (a_error_handler: EWG_ERROR_HANDLER;
			a_directory_structure: EWG_DIRECTORY_STRUCTURE;
			a_include_header_file_name: STRING;
			a_eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET
			a_config_system: EWG_CONFIG_SYSTEM) is
		require
			a_error_handler_not_void: a_error_handler /= Void
			a_directory_structure_not_void: a_directory_structure /= Void
			a_include_header_file_name_not_void: a_include_header_file_name /= Void
			a_eiffel_wrapper_set_not_void: a_eiffel_wrapper_set /= Void
			a_config_system_not_void: a_config_system /= Void
		do
			error_handler := a_error_handler
			directory_structure := a_directory_structure
			include_header_file_name := a_include_header_file_name
			eiffel_wrapper_set := a_eiffel_wrapper_set
			config_system := a_config_system
		ensure
			error_handler_set: error_handler = a_error_handler
			directory_structure_set: directory_structure = a_directory_structure
			include_header_file_name_set: include_header_file_name = a_include_header_file_name
			eiffel_wrapper_set_set: eiffel_wrapper_set = a_eiffel_wrapper_set
			config_system_set: config_system = a_config_system
		end

feature {ANY} -- Basic Routines

	build is
			-- Build Eiffel AST from C AST.
		do
			if c_system.declarations.function_declaration_count > 0 then
				error_handler.start_task ("phase 3: wrapping declarations")
				error_handler.set_current_task_total_ticks (c_system.declarations.function_declaration_count)
				wrap_declarations
				error_handler.stop_task
			end

			if c_system.types.count > 0 then
				error_handler.start_task ("phase 3: selecting types to wrap")
				error_handler.set_current_task_total_ticks (c_system.types.count)
				find_types_to_wrap_according_to_config_file
				error_handler.stop_task
			end

			error_handler.start_task ("phase 3: wrapping types")
			from
			until
				config_system.number_of_types_whose_members_have_not_been_wrapped_yet = 0
			loop
				error_handler.set_current_task_total_ticks (eiffel_wrapper_set.type_wrapper_count)
				wrap_members_of_types
			end
			error_handler.stop_task

			if eiffel_wrapper_set.is_ffcall_needed then
				add_ffcall_callback_entry_struct
			end


			-- TODO: no progress indicator support yet
			eiffel_wrapper_set.resolve_callback_wrapper_name_clashes

			resolve_externals_for_callback_glue

			-- TODO: no progress indicator support yet
			eiffel_wrapper_set.resolve_function_wrapper_name_clashes

			-- TODO: struct, union enum clashes

			-- TODO: filter out redundant callback wrappers, like:
			-- void (*) (int i);
			-- void (*) (int j);
			-- they can be treated the same. less code will be generated
			-- and less naming clashes occure

			if eiffel_wrapper_set.struct_wrapper_count + eiffel_wrapper_set.union_wrapper_count > 0 then
				error_handler.start_task ("phase 3: resolving feature name clashes")
				error_handler.set_current_task_total_ticks (eiffel_wrapper_set.struct_wrapper_count + eiffel_wrapper_set.union_wrapper_count)
				resolve_feature_name_clashes
				error_handler.stop_task
			end
		end

feature {NONE} -- Wraping of declarations

	wrap_declarations is
			-- Go through all declarations in the C system and wrap them.
			-- Add types which are needed by those declarations to
			-- `members_for_type_wrapped_table'.
			--
			-- Note: Right now, there are only function declarations available
			--       from the C system.
			--       In the future, global variable declarations might be added.
		local
			cs: DS_LINEAR_CURSOR [EWG_C_AST_FUNCTION_DECLARATION]
		do
			from
				cs := c_system.declarations.new_function_declaration_cursor
				cs.start
			until
				cs.off
			loop
				config_system.try_shallow_wrap_declaration (cs.item,
																		  config_system.header_file_name,
																		  eiffel_wrapper_set)
				if eiffel_wrapper_set.has_wrapper_for_declaration (cs.item) then
					config_system.deep_wrap_declaration (cs.item,
																		  config_system.header_file_name,
																		  eiffel_wrapper_set)
				end
				error_handler.tick
				cs.forth
			end
		end

feature {NONE}

	find_types_to_wrap_according_to_config_file is
			-- Go through all types in the C system.
			-- And ask the config file what should be wrapped.
			-- All types that should be added
			-- Everything that should be wrapped will then be added to
			-- the corresponding `members_for_type_wrapped_table' list.
		local
			cs: DS_BILINEAR_CURSOR [EWG_C_AST_TYPE]
		do
			from
				cs := c_system.types.new_cursor
				cs.start
			until
				cs.off
			loop
				if
					not eiffel_wrapper_set.has_wrapper_for_type (cs.item)
				then
					config_system.try_shallow_wrap_type (cs.item,
																		  config_system.header_file_name,
																		  eiffel_wrapper_set)
				end
				error_handler.tick
				cs.forth
			end
		end

	wrap_members_of_types is
			-- For each type in `members_for_type_wrapped_table' that has
			-- its value set to `False' (meaning its members have not
			-- been wrapped yet) wrap its members and set the value to
			-- `True'.
		local
			cs: DS_HASH_TABLE_CURSOR [BOOLEAN, EWG_C_AST_TYPE]
		do
			from
				cs := config_system.new_shallow_wrapped_type_table_cursor
				cs.start
			until
				cs.off
			loop
				if cs.item = False then
					config_system.deep_wrap_type (cs.key,
																config_system.header_file_name,
																eiffel_wrapper_set)
				end
				cs.replace (True)
				error_handler.set_current_task_total_ticks (eiffel_wrapper_set.type_wrapper_count)
				if error_handler.current_task_ticks < error_handler.current_task_total_ticks then
					error_handler.tick
				end
				cs.forth
			end
		end

	add_ffcall_callback_entry_struct is
		local
			struct_type: EWG_C_AST_STRUCT_TYPE
			members: DS_ARRAYED_LIST [EWG_C_AST_DECLARATION]
			declaration: EWG_C_AST_DECLARATION
		do
			create members.make (2)
			create declaration.make ("class", c_system.types.void_pointer_type, "c/ewg_c_library/ewg_ffcall.h")
			members.put_last (declaration)
			create declaration.make ("feature", c_system.types.void_pointer_type, "c/ewg_c_library/ewg_ffcall.h")
			members.put_last (declaration)
			create struct_type.make ("ewg_ffcall_callback_entry", "c/ewg_c_library/ewg_ffcall.h", members)
			-- TODO: check if type needs wrapping resp. if it is wrappable at all
			config_system.force_shallow_wrap_type (struct_type,
																"c/ewg_c_library/ewg_ffcall.h",
																eiffel_wrapper_set)
			config_system.deep_wrap_type (struct_type,
													 "c/ewg_c_library/ewg_ffcall.h",
													 eiffel_wrapper_set)
		end

	resolve_externals_for_callback_glue is
			-- For every function callback add a stub setter and getter
			-- function declaration.
		local
			cs: DS_BILINEAR_CURSOR [EWG_CALLBACK_WRAPPER]
			pm_cs: DS_BILINEAR_CURSOR [EWG_C_AST_DECLARATION]
			callback: EWG_CALLBACK_WRAPPER
			getter: EWG_C_AST_FUNCTION_TYPE
			setter: EWG_C_AST_FUNCTION_TYPE
			caller: EWG_C_AST_FUNCTION_TYPE
			parameters: DS_ARRAYED_LIST[EWG_C_AST_DECLARATION]
			declaration: EWG_C_AST_DECLARATION
			eiffel_object_type: EWG_C_AST_EIFFEL_OBJECT_TYPE
			name: STRING
			function_declaration: EWG_C_AST_FUNCTION_DECLARATION
		do
			from
				cs := eiffel_wrapper_set.new_callback_wrapper_cursor
				cs.start
			until
				cs.off
			loop
				callback := cs.item
				-- create getter
				create parameters.make (0)
				create getter.make (directory_structure.relative_callback_c_glue_header_file_name,
										  c_system.types.void_pointer_type,
										  parameters)
				c_system.types.add_type (getter)
				getter ?= c_system.types.last_type
					check
						getter_not_void: getter /= Void
					end
				name := STRING_.make (4 + callback.mapped_eiffel_name.count + 5)
				name.append_string ("get_")
				name.append_string (callback.mapped_eiffel_name)
				name.append_string ("_stub")
				c_system.add_top_level_declaration_from_type_and_name (getter,
																						 name,
																						 directory_structure.relative_callback_c_glue_header_file_name)
				function_declaration ?= c_system.declarations.last_declaration
				check
					function_declaration_not_void: function_declaration /= Void
				end
				config_system.force_shallow_wrap_declaration (function_declaration,
																			 directory_structure.relative_callback_c_glue_header_file_name,
																			 eiffel_wrapper_set)
				callback.set_get_stub (eiffel_wrapper_set.function_wrapper_from_function_declaration (function_declaration))
				config_system.default_deep_wrap_declaration (function_declaration,
																		 directory_structure.relative_callback_c_glue_header_file_name,
																		 eiffel_wrapper_set)
				create parameters.make (2)
				name := eiffel_class_name_from_c_type_name (callback.mapped_eiffel_name)
				name.append_string ("_DISPATCHER")
				create eiffel_object_type.make (name)
				c_system.types.add_type (eiffel_object_type)
				eiffel_object_type ?= c_system.types.last_type
					check
						eiffel_object_type_not_void: eiffel_object_type /= Void
					end

				create declaration.make ("a_class", eiffel_object_type, directory_structure.relative_callback_c_glue_header_file_name)
				parameters.put_last (declaration)

				create declaration.make ("a_feature", c_system.types.void_pointer_type, directory_structure.relative_callback_c_glue_header_file_name)
				parameters.put_last (declaration)

				-- create setter
				create setter.make (directory_structure.relative_callback_c_glue_header_file_name,
										  c_system.types.void_type,
										  parameters)
				c_system.types.add_type (setter)
				setter ?= c_system.types.last_type
					check
						setter_not_void: setter /= Void
					end
				name := STRING_.make (4 + callback.mapped_eiffel_name.count + 6)
				name.append_string ("set_")
				name.append_string (callback.mapped_eiffel_name)
				name.append_string ("_entry")
				c_system.add_top_level_declaration_from_type_and_name (setter,
																						 name,
																						 directory_structure.relative_callback_c_glue_header_file_name)
				function_declaration ?= c_system.declarations.last_declaration
					check
						function_declaration_not_void: function_declaration /= Void
					end

				config_system.force_shallow_wrap_declaration (function_declaration,
																			 directory_structure.relative_callback_c_glue_header_file_name,
																			 eiffel_wrapper_set)
				callback.set_set_entry_struct (eiffel_wrapper_set.function_wrapper_from_function_declaration (function_declaration))
				config_system.default_deep_wrap_declaration (function_declaration,
																		 directory_structure.relative_callback_c_glue_header_file_name,
																		 eiffel_wrapper_set)

				-- create caller

				create parameters.make (1 + callback.c_pointer_type.function_type.members.count)
				create declaration.make ("a_function", c_system.types.void_pointer_type, directory_structure.relative_callback_c_glue_header_file_name)
				parameters.put_last (declaration)

				from
					pm_cs := callback.c_pointer_type.function_type.members.new_cursor
					pm_cs.start
				until
					pm_cs.off
				loop
					create declaration.make (pm_cs.item.declarator, pm_cs.item.type, directory_structure.relative_callback_c_glue_header_file_name)
					parameters.put_last (declaration)
					pm_cs.forth
				end
				create caller.make(directory_structure.relative_callback_c_glue_header_file_name,
										 callback.c_pointer_type.function_type.return_type,
										 parameters)
				c_system.types.add_type (caller)
				caller ?= c_system.types.last_type
					check
						caller_not_void: caller /= Void
					end
				name := STRING_.make (5 + callback.mapped_eiffel_name.count)
				name.append_string ("call_")
				name.append_string (callback.mapped_eiffel_name)
				c_system.add_top_level_declaration_from_type_and_name (caller,
																						 name,
																						 directory_structure.relative_callback_c_glue_header_file_name)
				function_declaration ?= c_system.declarations.last_declaration
					check
						function_declaration_not_void: function_declaration /= Void
					end

				config_system.force_shallow_wrap_declaration (function_declaration,
																			 directory_structure.relative_callback_c_glue_header_file_name,
																			 eiffel_wrapper_set)
				config_system.default_deep_wrap_declaration (function_declaration,
																		 directory_structure.relative_callback_c_glue_header_file_name,
																		 eiffel_wrapper_set)


				cs.forth
			end
		end


	resolve_feature_name_clashes is
		local
			cs: DS_LINEAR_CURSOR [EWG_COMPOSITE_WRAPPER]
		do
			from
				cs := eiffel_wrapper_set.new_struct_wrapper_cursor
				cs.start
			until
				cs.off
			loop
				cs.item.resolve_feature_name_clashes
				cs.forth
				error_handler.tick
			end

			from
				cs := eiffel_wrapper_set.new_union_wrapper_cursor
				cs.start
			until
				cs.off
			loop
				cs.item.resolve_feature_name_clashes
				cs.forth
				error_handler.tick
			end
		end

feature {NONE} -- Implementation

	error_handler: EWG_ERROR_HANDLER
			-- EWG error handler

	directory_structure: EWG_DIRECTORY_STRUCTURE
			-- Directory structure for wrappers

	include_header_file_name: STRING
			-- Header to be used in external clauses.

	eiffel_wrapper_set: EWG_EIFFEL_WRAPPER_SET
			-- Set containing all the wrappers to be generated

	config_system: EWG_CONFIG_SYSTEM
			-- Configuration which decides how to wrap what construct

invariant

	directory_structure_not_void: directory_structure /= Void

	error_handler_not_void: error_handler /= Void

	include_header_file_name_not_void: include_header_file_name /= Void

	eiffel_wrapper_set_not_void: eiffel_wrapper_set /= Void

	config_system_not_void: config_system /= Void

end
