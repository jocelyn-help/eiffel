indexing

	description:

		"Standard output files containing extended ASCII characters %
		%(8-bit code between 0 and 255). The character '%N' is automatically %
		%converted to the line separtor of the underlying file system when %
		%written to the standard output file."

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2001-2008, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-10-05 12:21:37 +0200 (Sun, 05 Oct 2008) $"
	revision: "$Revision: 6530 $"

class KL_STDOUT_FILE

inherit

	KI_TEXT_OUTPUT_STREAM

	KL_OPERATING_SYSTEM
		export {NONE} all end

	CONSOLE
		rename
			make as old_make,
			put_boolean as old_put_boolean,
			put_character as old_put_character,
			put_string as old_put_string,
			put_integer as old_put_integer,
			put_new_line as old_put_new_line,
			is_open_write as old_is_open_write,
			flush as old_flush,
			append as old_append,
			close as old_close
		export
			{CONSOLE}
				open_read,
				extendible,
				file_pointer,
				count,
				old_close,
				is_closed,
				old_put_string,
				old_is_open_write
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make is
			-- Create a new standard output file.
		do
			make_open_stdout ("stdout")
		ensure
			name_set: name.is_equal ("stdout")
			is_open_write: is_open_write
		end

feature -- Access

	eol: STRING is "%N"
			-- Line separator

feature -- Status report

	is_open_write: BOOLEAN is
			-- Is standard output file opened in write mode?
		do
			Result := old_is_open_write
		end

feature -- Output

	put_character (c: CHARACTER) is
			-- Write `c' to standard output file.
		do
			old_put_character (c)
		end

	put_string (a_string: STRING) is
			-- Write `a_string' to standard output file.
			-- Note: If `a_string' is a UC_STRING or descendant, then
			-- write the bytes of its associated UTF unicode encoding.
		local
			a_string_string: STRING
		do
			a_string_string := STRING_.as_string (a_string)
			old_put_string (a_string_string)
		end

feature -- Basic operations

	flush is
			-- Flush buffered data to disk.
		do
			old_flush
		end

end
