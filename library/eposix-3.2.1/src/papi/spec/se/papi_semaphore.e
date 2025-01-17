indexing

	description: "Class that covers Posix semaphore.h."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"

class

	PAPI_SEMAPHORE


feature -- C binding

	posix_sem_close (a_sem: POINTER): INTEGER is
			-- Close a named semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_destroy (a_sem: POINTER): INTEGER is
			-- Destroy an unnamed semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_getvalue (a_sem: POINTER; sval: POINTER): INTEGER is
			-- Get the value of a semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_init (a_sem: POINTER; a_shared: BOOLEAN; a_value: INTEGER): INTEGER is
			-- Initialize an unnamed semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_open (a_name: POINTER; oflag: INTEGER; a_mode: INTEGER; a_value: INTEGER): POINTER is
			-- Initialize/open a named semaphore.
		require
			have_name: a_name /= default_pointer



		external "C"

		end

	posix_sem_post (a_sem: POINTER): INTEGER is
			-- Unlock a semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_trywait (a_sem: POINTER): INTEGER is
			-- Lock a semaphore.
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_sem_wait (a_sem: POINTER): INTEGER is
			-- Lock a semaphore
		require
			have_sem: a_sem /= default_pointer



		external "C"

		end

	posix_semaphores: BOOLEAN is
			-- Is _POSIX_SEMAPHORES defined?
		external "C"
		end

	posix_sem_t_size: INTEGER is
			-- Returns size of sem_t type.
		external "C"
		end

	SEM_FAILED: POINTER is
			-- Value returned when semaphore could not be created/opened.
		external "C"
		alias "const_sem_failed"
		end

end
