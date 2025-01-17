indexing

	description: "Class that covers the Single Unix Spec sys/select.h header."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"


class

	SAPI_SELECT


feature -- Select functions

	posix_select (a_maxfdp1: INTEGER; a_readset, a_writeset, an_exceptset: POINTER; a_timeout: POINTER): INTEGER is
			-- Wait for a number of descriptors to change status.
			-- `a_maxfdp`' is the highest-numbered descriptor in any of
			-- the three sets, plus 1.
			-- If `a_timeout' is 0, function returns immediately (polling).
			-- If `a_timeout' is `default_pointer' function can block
			-- indefinitely.
			-- Returns -1 on error or else the number of descriptors that
			-- are ready.
		require
			a_maxfdp1_not_negative: a_maxfdp1 >= 0
			maxfd_implies_descriptors: a_maxfdp1 >= 1 implies (a_readset /= default_pointer or else a_writeset /= default_pointer or else an_exceptset /= default_pointer)

		external "C blocking"



		ensure
			-- Result = -1 implies errno.is_not_ok
		end


feature -- File descriptor set functions

	posix_fd_clr (a_fd: INTEGER; a_fdset: POINTER) is
			-- Clears the bit for the file descriptor `a_fd' in the file
			-- descriptor set `fdset'.
		require
			valid_descriptor: a_fd >= 0 and then a_fd < FD_SETSIZE
			valid_descriptor_set: a_fdset /= default_pointer
		external "C"
		end

	posix_fd_isset (a_fd: INTEGER; a_fdset: POINTER): BOOLEAN is
			-- Returns a non-zero value if the bit for the file
			-- descriptor `a_fd' is set in the file descriptor set by
			-- `a_fdset', and 0 otherwise.
		require
			valid_descriptor: a_fd >= 0 and then a_fd < FD_SETSIZE
			valid_descriptor_set: a_fdset /= default_pointer
		external "C"
		end

	posix_fd_set (a_fd: INTEGER; a_fdset: POINTER) is
			-- Sets the bit for the file descriptor `a_fd' in the file
			-- descriptor set `a_fdset'.
		require
			valid_descriptor: a_fd >= 0 and then a_fd < FD_SETSIZE
			valid_descriptor_set: a_fdset /= default_pointer
		external "C"
		end

	posix_fd_zero (a_fdset: POINTER) is
			-- Initialize the file descriptor set `a_fdset' to have zero
			-- bits for all file descriptors.
		require
			valid_descriptor_set: a_fdset /= default_pointer
		external "C"
		end

	posix_fd_set_size: INTEGER is
			-- Size of a fd_set struct.
		external "C"
		end

	FD_SETSIZE: INTEGER is
			-- Maximum number of file descriptors in an fd_set structure
		external "C"
		alias "const_fd_setsize"
		end


end
