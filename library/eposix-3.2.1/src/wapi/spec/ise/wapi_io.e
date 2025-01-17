indexing

	description: "Class that covers Windows direct.h."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"

class

	WAPI_IO


feature -- C binding file descriptor routines

	posix_access (a_path: POINTER; amode: INTEGER): INTEGER is
			-- Tests for file accessibility
		require
			valid_path: a_path /= default_pointer

		external "C blocking"



		end

	posix_create (a_path: POINTER; oflag, mode: INTEGER): INTEGER is
			-- Creates a new file or rewrites an existing one
			-- does not call `creat' but `open'!

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_close (fildes: INTEGER): INTEGER is
			-- Closes a file.

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_dup (fildes: INTEGER): INTEGER is
			-- Duplicate an open file descriptor.
		external "C"
		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_dup2 (fildes, fildes2: INTEGER): INTEGER is
			-- Duplicate an open file descriptor.
		external "C"
		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_isatty (fildes: INTEGER): BOOLEAN is
			-- Determines if a file descriptor is associated with a terminal
		external "C"
		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_lseek (fildes: INTEGER; offset, whence: INTEGER): INTEGER is
			-- Repositions read/write file offset
		external "C"
		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_open (a_path: POINTER; oflag: INTEGER): INTEGER is
			-- Open a file.

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_read (fildes: INTEGER; buf: POINTER; nbyte: INTEGER): INTEGER is
			-- Read from a file.

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end

	posix_setmode (fildes: INTEGER; a_mode: INTEGER): INTEGER is
			-- Sets the file translation mode
		external "C"
		end

	posix_write (fildes: INTEGER; buf: POINTER; nbyte: INTEGER): INTEGER is
			-- Write to a file.

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end

end -- class WAPI_IO
