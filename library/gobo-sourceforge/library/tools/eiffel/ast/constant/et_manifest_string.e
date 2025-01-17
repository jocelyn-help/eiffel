indexing

	description:

		"Eiffel manifest strings"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-07-03 23:43:10 +0200 (Thu, 03 Jul 2008) $"
	revision: "$Revision: 6444 $"

deferred class ET_MANIFEST_STRING

inherit

	ET_CONSTANT
		undefine
			first_position, last_position
		redefine
			reset, is_string_constant,
			manifest_constant_convert_feature
		end

	ET_MANIFEST_STRING_ITEM
		undefine
			first_position, last_position
		end

	ET_INDEXING_TERM
		undefine
			first_position, last_position
		end

	ET_EXTERNAL_LANGUAGE
		undefine
			first_position, last_position
		end

	ET_EXTERNAL_ALIAS
		undefine
			first_position, last_position
		end

	ET_OBSOLETE
		undefine
			first_position, last_position
		end

	ET_AST_LEAF
		rename
			make as make_leaf,
			make_with_position as make_leaf_with_position
		redefine
			position, first_position, first_leaf
		end

feature -- Initialization

	reset is
			-- Reset constant as it was just after it was last parsed.
		do
			type := Void
			if cast_type /= Void then
				cast_type.type.reset
			end
		end

feature -- Status report

	is_string_constant: BOOLEAN is True
			-- Is current constant a STRING constant?

feature -- Access

	value: STRING is
			-- String value
		deferred
		end

	literal: STRING is
			-- Literal value
		deferred
		end

	cast_type: ET_TARGET_TYPE
			-- Cast type

	type: ET_CLASS
			-- Type of manifest string;
			-- Void if not determined yet

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if cast_type /= Void then
				Result := cast_type.position
			else
				Result := Current
			end
		end

	first_position: ET_POSITION is
			-- Position of first character of current node in source code
		do
			if cast_type /= Void then
				Result := cast_type.first_position
			else
				Result := Current
			end
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		do
			if cast_type /= Void then
				Result := cast_type.first_leaf
			else
				Result := Current
			end
		end

	manifest_string: ET_MANIFEST_STRING is
			-- Manifest string
		do
			Result := Current
		end

feature -- Setting

	set_cast_type (a_type: like cast_type) is
			-- Set `cast_type' to `a_type'.
		do
			cast_type := a_type
		ensure
			cast_type_set: cast_type = a_type
		end

	set_type (a_type: like type) is
			-- Set `type' to `a_type'.
		do
			type := a_type
		ensure
			type_set: type = a_type
		end

feature -- Type conversion

	manifest_constant_convert_feature (a_source_type: ET_TYPE_CONTEXT; a_target_type: ET_TYPE_CONTEXT): ET_CONVERT_FEATURE is
			-- Implicit feature to convert `Current' of type `a_source_type' to `a_target_type'.
			-- This is only possible when there is no explicit type case and the value of the
			-- constant can be represented in `a_target_type'.
			-- Void if no such feature or when not possible.
		local
			l_target_base_class: ET_CLASS
			l_system: ET_SYSTEM
		do
			if cast_type = Void then
-- TODO: check that the value of `Current' can be represented in `a_target_type'.
				l_target_base_class := a_target_type.base_class
				if not l_target_base_class.is_preparsed then
					-- No conversion to non-existing type.
				else
					l_system := l_target_base_class.current_system
					if l_target_base_class = l_system.string_8_class then
						Result := l_system.string_8_convert_feature
					elseif l_target_base_class = l_system.string_32_class then
						Result := l_system.string_32_convert_feature
					end
				end
			end
		end

invariant

	literal_not_void: literal /= Void
	value_not_void: value /= Void

end
