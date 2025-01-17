indexing

	description: "Class that covers Standard C stdlib.h."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"

class

	CAPI_STDLIB


feature {NONE} -- dynamic memory

	posix_calloc (num_of_elements, element_size: INTEGER): POINTER is
			-- Allocates and zeroes memory
		require
			valid_args: num_of_elements >= 0 and element_size >= 0
		external "C"
		ensure
			-- a_size = 0 implies Result = default_pointer
		end

	posix_free (p: POINTER) is
			-- Deallocates dynamic memory
		require
			-- any p including NULL is valid
		external "C"
		end

	posix_malloc (a_size: INTEGER): POINTER is
			-- Allocates dynamic memory
		require
			-- any p including NULL is valid
			valid_size: a_size >= 0
		external "C"
		ensure
			-- a_size = 0 implies Result = default_pointer
			-- returns default_pointer when no memory
		end

	posix_realloc(p: POINTER; a_size: INTEGER): POINTER is
			-- Changes the size of a memory object
		require
			-- any p including NULL is valid
			valid_size: a_size >= 0
		external "C"
		ensure
			-- a_size = 0 implies Result = default_pointer
		end;


feature {NONE} -- miscellaneous

	posix_abort is
			-- Causes abnormal process termination
		external "C"
		end

	posix_exit (a_status: INTEGER) is
			-- cause normal program termination
			-- `a_status' is returned to its parent
		external "C"
		end

	posix_getenv (a_name: POINTER): POINTER is
			-- Gets the environment variable
		external "C"
		end

	posix_system (a_string: POINTER): INTEGER is
			-- pass a command to the shell



		external "C"

		end


feature {NONE} -- random numbers

	posix_rand: INTEGER is
			-- return pseudo-random integer between 0 and `RAND_MAX'
		external "C"
		end

	posix_srand (a_seed: INTEGER) is
			-- `a_seed' is used for new sequence of psuedo-raondom
			-- integers
		external "C"
		end


end -- class CAPI_STDLIB
