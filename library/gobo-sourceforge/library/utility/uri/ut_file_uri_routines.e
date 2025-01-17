indexing

	description:

		"Convert file: URI to and from local filesystem names"

	library: "Gobo Eiffel Utility Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-02-03 18:55:34 +0100 (Sat, 03 Feb 2007) $"
	revision: "$Revision: 5887 $"

class UT_FILE_URI_ROUTINES

inherit

	ANY

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	KL_SHARED_STANDARD_FILES
		export {NONE} all end

feature -- Filename

	uri_to_filename (a_uri: UT_URI): STRING is
			-- Convert URI to filename and then to string using the
			-- current filesystem rules.
		require
			a_uri_not_void: a_uri /= Void
		do
			Result := file_system.pathname_to_string (uri_to_pathname (a_uri))
			if a_uri.has_path_base then
				Result := file_system.pathname (Result, uri_component_to_pathname (a_uri.path_base_item))
			end
			debug ("file_uri")
				std.output.put_string ("uri_to_filename: ")
				std.output.put_string (a_uri.full_reference)
				std.output.put_string (" ")
				std.output.put_string (a_uri.path)
				std.output.put_string (" -> ")
				std.output.put_string (Result)
				std.output.put_new_line
			end
		ensure
			filename_not_void: Result /= Void
		end

	filename_to_uri (a_string: STRING): UT_URI is
			-- Convert filename in the current filesystem convention
			-- to a file: URI.
		require
			a_string_not_void: a_string /= Void
		do
			Result := pathname_to_uri (file_system.string_to_pathname (file_system.dirname (a_string)))
			Result.set_path_base (pathname_to_uri_component (file_system.basename (a_string)))
			debug ("file_uri")
				std.output.put_string ("filename_to_uri: ")
				std.output.put_string (a_string)
				std.output.put_string (" -> ")
				std.output.put_string (Result.full_reference)
				std.output.put_new_line
			end
		ensure
			uri_not_void: Result /= Void
		end

feature -- Pathname

	uri_to_pathname (a_uri: UT_URI): KL_PATHNAME is
			-- Convert `a_uri' to a pathname.
		require
			a_uri_not_void: a_uri /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [UT_URI_STRING]
			a_possible_drive: STRING
			a_segment: STRING
		do
			create Result.make
			if a_uri.has_authority and then not a_uri.authority_item.decoded.same_string (Localhost_authority) then
				Result.set_hostname (a_uri.authority)
			end
			Result.set_relative (not a_uri.has_absolute_path)
			a_cursor := a_uri.path_items.new_cursor
			a_cursor.start
			if not a_cursor.after then
					-- First item might be a drive name.
				a_possible_drive := uri_component_to_pathname (a_cursor.item)
				if a_uri.has_absolute_path and then is_drive (a_possible_drive) then
					Result.set_drive (a_possible_drive)
				else
					Result.append_name (a_possible_drive)
				end
					-- Remaining items.
				from a_cursor.forth until a_cursor.after loop
					a_segment := uri_component_to_pathname (a_cursor.item)
					Result.append_name (a_segment)
					a_cursor.forth
				end
			end
			debug ("file_uri")
				std.output.put_string ("uri_to_pathname ")
				std.output.put_string (a_uri.full_reference)
				std.output.put_character (' ')
				std.output.put_string (file_system.pathname_to_string (Result))
				std.output.put_new_line
			end
		ensure
			pathname_not_void: Result /= Void
		end

	pathname_to_uri (a_pathname: KI_PATHNAME): UT_URI is
			-- Create a file: URI from a file system path name
		require
			a_pathname_not_void: a_pathname /= Void
			not_relative_with_host: a_pathname.is_relative implies a_pathname.hostname = Void
		local
			a_path: DS_ARRAYED_LIST [UT_URI_STRING]
			i, nb: INTEGER
		do
			if a_pathname.is_relative then
				create Result.make_relative
				check no_hostname_when_relative: a_pathname.hostname = Void end
			else
				create Result.make_absolute (File_scheme)
				if a_pathname.hostname /= Void then
					Result.set_authority (hostname_to_authority (a_pathname.hostname))
					-- removed for correct canonization - CPA - 20061221: else
					--	Result.set_authority (hostname_to_authority (Localhost_authority))
				else
					-- added for correct canonization - CPA - 20070203:
					Result.set_authority (hostname_to_authority (""))
				end
			end
			nb := a_pathname.count
			if a_pathname.sharename /= Void then
				create a_path.make (nb + 2)
			else
				create a_path.make (nb + 1)
			end
			if a_pathname.drive /= Void then
					-- If drive present first item is path.
				a_path.put_last (pathname_to_uri_component (a_pathname.drive))
			elseif a_pathname.sharename /= Void then
				a_path.put_last (pathname_to_uri_component (a_pathname.sharename))
			end
			from i := 1 until i > nb loop
				a_path.put_last (pathname_to_uri_component (a_pathname.item (i)))
				i := i + 1
			end
			Result.set_path_items (not a_pathname.is_relative, a_path)
			debug ("file_uri")
				std.output.put_string ("pathname_to_uri ")
				std.output.put_string (file_system.pathname_to_string (a_pathname))
				std.output.put_character (' ')
				std.output.put_string (Result.full_reference)
				std.output.put_new_line
			end
		ensure
			uri_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	pathname_to_uri_component, hostname_to_authority (a_string: STRING): UT_URI_STRING is
			-- Convert KL_PATHNAME item to URI string
			-- (Default to UTF-8 charset)
		require
			a_string_not_void: a_string /= Void
		do
			create Result.make_decoded_utf8 (a_string)
		ensure
			uri_component_not_void: Result /= Void
		end

	uri_component_to_pathname (a_uri_string: UT_URI_STRING): STRING is
			-- Convert string used in URI component to pathname string
		require
			a_uri_string_not_void: a_uri_string /= Void
		do
			Result := a_uri_string.decoded_utf8
		ensure
			pathname_not_void: Result /= Void
		end

	is_drive (a_drive: STRING): BOOLEAN is
			-- Can this component be a drive name?
		require
			a_drive_not_void: a_drive /= Void
		do
			Result := file_system.string_to_pathname (a_drive).drive /= Void
		end

feature {NONE} -- Constants

	Localhost_authority: STRING is "localhost"
	File_scheme: STRING is "file"

end
