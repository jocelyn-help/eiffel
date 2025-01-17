indexing

	description:

		"Imported routines that ought to be in class ARRAY"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class KL_IMPORTED_ARRAY_ROUTINES

feature -- Access

	ANY_ARRAY_: KL_ARRAY_ROUTINES [ANY] is
			-- Routines that ought to be in class ARRAY
		once
			create Result
		ensure
			any_array_routines_not_void: Result /= Void
		end

	INTEGER_ARRAY_: KL_ARRAY_ROUTINES [INTEGER] is
			-- Routines that ought to be in class ARRAY
		once
			create Result
		ensure
			integer_array_routines_not_void: Result /= Void
		end

	BOOLEAN_ARRAY_: KL_ARRAY_ROUTINES [BOOLEAN] is
			-- Routines that ought to be in class ARRAY
		once
			create Result
		ensure
			boolean_array_routines_not_void: Result /= Void
		end

	STRING_ARRAY_: KL_ARRAY_ROUTINES [STRING] is
			-- Routines that ought to be in class ARRAY
		once
			create Result
		ensure
			string_array_routines_not_void: Result /= Void
		end

	ARRAY_SPECIAL_INTEGER_: KL_ARRAY_ROUTINES [SPECIAL [INTEGER]] is
			-- Routines that ought to be in class ARRAY
		once
			create Result
		ensure
			special_integer_array_routines_not_void: Result /= Void
		end

end
