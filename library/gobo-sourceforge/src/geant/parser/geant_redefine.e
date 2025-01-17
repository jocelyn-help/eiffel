indexing

	description:

		"Redefines"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2002, Sven Ehrke and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class GEANT_REDEFINE

create

	make

feature {NONE} -- Initialization

	make is
			-- Initialize 'redefine'.
		do
		end

feature -- Status report

	is_executable: BOOLEAN is
			-- Can element be executed?
		do
			Result := name /= Void and then name.count > 0
		ensure
			name_not_void: Result implies name /= Void
			name_not_empty: Result implies name.count > 0
		end

feature -- Access

	name: STRING
			-- Name of target to be redefined

feature -- Setting

	set_name (a_name: like name) is
			-- Set `name' to `a_name'.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		do
			name := a_name
		ensure
			name_set: name = a_name
		end

end
