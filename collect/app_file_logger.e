note
	description: "Summary description for {APP_FILE_LOGGER}."
	date: "$Date$"
	revision: "$Revision$"

class
	APP_FILE_LOGGER

inherit
	APP_LOGGER

create
	make

feature {NONE} -- Initialization

	make (a_log_path: PATH)
			-- Initialize log on file
		do
			path := a_log_path
			create log_file.make_with_path (a_log_path)
			if log_file.exists or else log_file.is_access_writable then
				log_file.open_append
			end
		end

feature -- Status report

	is_logging_enabled: BOOLEAN
		do
			Result := log_file.exists and then log_file.is_open_write
		end

feature -- Access

	path: PATH

	log_file: APP_FILE_LOG

feature -- Basic operation

	close
		do
			log_file.close
		end

feature {NONE} -- Implementation		

	write (a_message: separate STRING_8)
			-- Logs `a_string' for `a_level`.
		do
			log_file.put_separate_string (a_message)
		end

end
