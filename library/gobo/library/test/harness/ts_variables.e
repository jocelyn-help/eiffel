indexing

	description:

		"Test variables"

	library: "Gobo Eiffel Test Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class TS_VARIABLES

inherit

	ANY

	KL_SHARED_STRING_EQUALITY_TESTER
		export {NONE} all end

create

	make

feature {NONE} -- Initialization

	make is
			-- Create a new empty variables.
		do
			create variables.make_map (10)
			variables.set_key_equality_tester (string_equality_tester)
		end

feature -- Status report

	has (a_name: STRING): BOOLEAN is
			-- Has variable named `a_name' been defined?
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		do
			Result := variables.has (a_name)
		end

feature -- Access

	value (a_name: STRING): STRING is
			-- Value of variable `a_name'
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
			has_variable: has (a_name)
		do
			Result := variables.item (a_name)
		ensure
			value_not_void: Result /= Void
		end

	new_cursor: DS_HASH_TABLE_CURSOR [STRING, STRING] is
			-- Cursor to traverse variables
		do
			Result := variables.new_cursor
		ensure
			new_cursor_not_void: Result /= Void
		end

feature -- Setting

	set_value (a_name, a_value: STRING) is
			-- Set variable `a_name' to `a_value'.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
			a_value_not_void: a_value /= Void
		do
			variables.force (a_value, a_name)
		ensure
			has_variable: has (a_name)
			value_set: value (a_name) = a_value
		end

feature {NONE} -- Implementation

	variables: DS_HASH_TABLE [STRING, STRING]
			-- Defined variables

invariant

	variables_not_void: variables /= Void
	no_void_variable_name: not variables.has (Void)
	no_void_variable_value: not variables.has_item (Void)

end
