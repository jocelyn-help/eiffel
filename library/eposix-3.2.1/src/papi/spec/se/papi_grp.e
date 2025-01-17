indexing

	description: "Class that covers POSIX grp.h header."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"

class

	PAPI_GRP


feature -- POSIX C binding

	posix_getgrgid (a_gid: INTEGER): POINTER is
			-- Reads groups database based on group ID



		external "C"

		end

	posix_getgrnam (a_name: POINTER): POINTER is
			-- Reads group database based on group name



		external "C"

		end

	posix_gr_name (a_group: POINTER): POINTER is
			-- The name of the group
		external "C"
		end

	posix_gr_gid (a_group: POINTER): INTEGER is
			-- Group ID number
		external "C"
		end

	posix_gr_mem (a_group: POINTER): POINTER is
			-- Pointer to null-terminated array of char *. Each element
			-- of the array points to an individual member of the group
		external "C"
		end


end
