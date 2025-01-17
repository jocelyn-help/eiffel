indexing

	description: "Class that covers the Single Unix Spec stdlib.h header."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"


class

	SAPI_STDLIB


inherit

	CAPI_STDLIB


feature -- C binding to various functions

	posix_mkstemp (a_template: POINTER): INTEGER is
			-- An open file descriptor if a unique filename could
			-- be created, or -1 otherwise
		require
			template_not_null: a_template /= default_pointer



		external "C"

		end

	posix_putenv (a_keyvalue: POINTER): INTEGER is
			-- Change or add an environment variable.
		require
			not_empty: a_keyvalue /= default_pointer
			-- `a_keyvalue' is a string of the form "name=value"
		external "C"
		end

	posix_realpath (a_path, a_resolved_path: POINTER): POINTER is
			-- Resolve a pathname.
		require
			valid_paths:
				a_path /= default_pointer and
				a_resolved_path /= default_pointer



		external "C"

		end


end
