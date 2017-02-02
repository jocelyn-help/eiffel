note
	description: "Summary description for {COLLECT_APPLICATION_CONFIG}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COLLECT_CONFIGURATION

create
	make

feature {NONE} -- Initialization

	make (a_loc: PATH)
		do
			location := a_loc
			credential_file_path := a_loc.extended (credential_file_name)
			log_path := a_loc.extended ("log").extended ("collect.log")
			read_credentials
		end

	report_error (err: STRING)
		do
			has_error := True
		end

feature -- Access

	has_error: BOOLEAN

	location: PATH

	credential_file_path: PATH

	credential_file_name: STRING_8 = "credentials.conf"

	is_utc_set: BOOLEAN assign set_is_utc_set

	use_testing_ws: BOOLEAN assign set_use_testing_ws

	log_level: INTEGER

	log_path: PATH

feature -- Access: Credentials

	username: detachable STRING
	password: detachable STRING

feature -- Operation: Credentials	

	read_credentials
			-- Read wsrem credentials from file
		local
			cfg_file: PLAIN_TEXT_FILE
		do
			create cfg_file.make_with_path (credential_file_path)

				-- Trivial config file --> switch to preferences library
			if cfg_file.exists and then cfg_file.is_access_readable then
				cfg_file.open_read
				cfg_file.read_line
				username := cfg_file.last_string
				cfg_file.read_line
				password := cfg_file.last_string
				cfg_file.close
			else
				report_error ("missing credentials.")
			end
		end

feature -- Change

	set_is_utc_set (b: BOOLEAN)
		do
			is_utc_set := b
		end

	set_use_testing_ws (b: BOOLEAN)
		do
			use_testing_ws := b
		end

	set_log_level (n: INTEGER)
		do
			log_level := n
		end

	set_log_path (p: PATH)
		do
			log_path := p
		end

invariant
	credential_file_path_not_empty: not credential_file_path.is_empty

end
