indexing

	description: "Class that covers Standard C stdio.h."

	author: "Berend de Boer"
	date: "$Date: 2007/11/22 $"
	revision: "$Revision: #2 $"

class

	CAPI_STDIO


feature {NONE} -- file system routines

	posix_rename (old_path, new_path: POINTER): INTEGER is
			-- Renames a file
		require
			have_old_path: old_path /= default_pointer
			have_new_path: new_path /= default_pointer

		external "C blocking"



		end

	posix_remove (filename: POINTER): INTEGER is
			-- Removes a file from a directory
		require
			have_filename: filename /= default_pointer

		external "C blocking"



		end

	posix_tmpfile: POINTER is
			-- Creates a temporary file

		external "C blocking"



		end


feature {NONE} -- C binding for stream functions

	posix_clearerr (a_stream: POINTER) is
			-- Clears end-of-file and error indicators for a stream
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		ensure
			-- not posix_feof and not posix_ferror
		end

	posix_fclose (a_stream: POINTER): INTEGER is
			-- Closes an open stream
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_feof (a_stream: POINTER): BOOLEAN is
			-- Tests the end-of-file indicator for a stream
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_ferror (a_stream: POINTER): BOOLEAN is
			-- Tests the error indicator for a stream
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_fflush (a_stream: POINTER): INTEGER is
			-- Updates `a_stream'. If `a_stream' is nil, all open streams
			-- are updated.

		external "C blocking"



		end

	posix_fgetc (a_stream: POINTER): INTEGER is
			-- Reads a character from a stream
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fgetpos (a_stream, pos: POINTER): INTEGER is
			-- Gets the current file position
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_fgets (s: POINTER; n: INTEGER; a_stream: POINTER): POINTER is
			-- Reads at most one less than `n' characters from a stream.
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		ensure
			-- Result = default_pointer implies errno.is_not_ok
		end

	posix_fopen (path, a_mode: POINTER): POINTER is
			-- Opens a stream
		require
			valid_mode: a_mode /= default_pointer
		external "C"
		end

	posix_fprintf_double (a_stream: POINTER; d: DOUBLE): INTEGER is
			-- do a fprintf (a_stream, "%f, d)
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fprintf_int (a_stream: POINTER; i: INTEGER): INTEGER is
			-- do a fprintf (a_stream, "%d", i)
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fprintf_real (a_stream: POINTER; r: REAL): INTEGER is
			-- do a fprintf (a_stream, "%f, r)
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fputc (c: INTEGER; a_stream: POINTER): INTEGER is
			-- Writes a character to a stream
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fputs (s: POINTER; a_stream: POINTER): INTEGER is
			-- Writes a stringn to a stream
		require
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_fread (buf: POINTER; size, nmemb: INTEGER; a_stream: POINTER): INTEGER is
			-- Reads an array from a stream
		require
			valid_buffer: buf /= default_pointer
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_freopen (path, a_mode: POINTER; a_stream: POINTER): POINTER is
			-- Closes and then opens a stream
		require
			valid_mode: a_mode /= default_pointer
			valid_stream: a_stream /= default_pointer
		external "C"
		ensure
			-- Result = default_pointer implies error occurred
		end

	posix_fseek (a_stream: POINTER; offset: INTEGER; whence: INTEGER): INTEGER is
			-- Sets file position
		require
			valid_stream: a_stream /= default_pointer
			-- valid_offset: whence = 0 implies offset >= 0
		external "C"
		end

	posix_fscanf_double (a_stream, dp: POINTER): INTEGER is
			-- do a fscanf(a_stream, "%lf", dp)
		require
			valid_stream: a_stream /= default_pointer
			valid_double_pointer: dp /= default_pointer

		external "C blocking"



		end

	posix_fscanf_integer (a_stream, ip: POINTER): INTEGER is
			-- do a fscanf(a_stream, "%d", ip)
		require
			valid_stream: a_stream /= default_pointer
			valid_integer_pointer: ip /= default_pointer

		external "C blocking"



		end

	posix_fscanf_real (a_stream, rp: POINTER): INTEGER is
			-- do a fscanf(a_stream, "%f", rp)
		require
			valid_stream: a_stream /= default_pointer
			valid_real_pointer: rp /= default_pointer

		external "C blocking"



		end

	posix_fsetpos (a_stream, pos: POINTER): INTEGER is
			-- Sets the file position for a stream
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_ftell (a_stream: POINTER): INTEGER is
			-- Gets the position indicator for a stream
		require
			valid_stream: a_stream /= default_pointer
			-- file position should be less than LONG_MAX
		external "C"
		end

	posix_fwrite (buf: POINTER; size, nmemb: INTEGER; a_stream: POINTER): INTEGER is
			-- Writes an array to a stream
		require
			valid_buffer: buf /= default_pointer
			valid_stream: a_stream /= default_pointer

		external "C blocking"



		end

	posix_rewind (a_stream: POINTER) is
			-- Sets the file position to the beginning of the file
			-- the error indicator is also cleared
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_setbuf (a_stream: POINTER; buf: POINTER) is
			-- Determines how a stream will be buffered
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_setvbuf (a_stream: POINTER; buf: POINTER; a_mode, size:
						INTEGER): INTEGER is
			-- Determines how a stream will be buffered
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end

	posix_ungetc (c: INTEGER; a_stream: POINTER): INTEGER is
			-- Pushes a character back onto a stream
		require
			valid_stream: a_stream /= default_pointer
		external "C"
		end


feature {NONE} -- C binding for object sizes

	posix_fpos_t_size: INTEGER is
			-- size of a fpos_t structure
		external "C"
		end


end
