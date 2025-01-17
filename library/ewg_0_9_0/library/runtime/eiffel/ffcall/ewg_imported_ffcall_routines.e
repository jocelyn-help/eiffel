indexing

	description:

		"Imported ffcall routines"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/02/27 12:25:54 $"
	revision: "$Revision: 1.1 $"

class EWG_IMPORTED_FFCALL_ROUTINES

feature {ANY} -- Access

	FFCALL_: EWG_EXTERNAL_FFCALL_ROUTINES is
			-- FFCALL external routines
		once
			create Result
		ensure
			result_not_void: Result /= Void
		end

end
