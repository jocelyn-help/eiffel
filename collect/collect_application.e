note
	description : "collect application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	COLLECT_APPLICATION

inherit
	WSF_DEFAULT_SERVICE [COLLECT_EXECUTION]
		redefine
			initialize
		end

	SHARED_APP_LOGGER

	SHARED_COLLECT_CONFIGURATION

	ARGUMENTS

	EXCEPTIONS
	EXECUTION_ENVIRONMENT
		rename
			command_line as env_command_line,
			launch as env_launch
		end

	LOG_PRIORITY_CONSTANTS
	DEFAULTS

	MEMORY



create
	make_and_launch

feature {NONE} -- Initialization

	initialize
			-- Initialize current service
		local
			idx:  INTEGER
			cfg_location: PATH
			cfg: COLLECT_CONFIGURATION
		do
			if attached separate_word_option_value ("-config") as cfg_loc then
				create cfg_location.make_from_string (cfg_loc)
			elseif attached home_directory_path as l_home then
				create cfg_location.make_from_string (l_home.out + "/.collect/")
			else
				create cfg_location.make_empty
			end
			create cfg.make (cfg_location)
			set_config (cfg)

			-- garbage collection
			collection_on
			set_memory_threshold (40000000)
			set_collection_period (5)
			set_coalesce_period (5)
			set_max_mem (80000000)

				-- Take into account command line arguments
			idx := index_of_word_option ("h")
			if idx > 0 then
				usage
				die (0)
			end

			idx := index_of_word_option ("p")
			if idx > 0 then
				port := argument (idx + 1).to_integer
			else
				port := default_port
			end
			set_service_option ("port", port)

			initialize_logger (cfg.log_path)
			idx := index_of_word_option ("l")
			if idx > 0 then
				set_log_level (argument (idx + 1).to_integer)
			else
				set_log_level (log_error)
			end

			cfg.use_testing_ws := index_of_word_option ("t") > 0
			cfg.is_utc_set := index_of_word_option ("u") > 0

			check_remws_session (cfg)
		end

	check_remws_session (cfg: COLLECT_CONFIGURATION)
		local
			l_remws_session: REMWS_SESSION
		do
			-- must check if logged in remws
			-- login management
			if attached cfg.username as u and attached cfg.password as p then
				create l_remws_session.make (u, p)
				if not l_remws_session.is_logged_in then
					-- do login
					l_remws_session.do_login
					if not l_remws_session.is_logged_in then
						log_display ("FATAL error: unable to login", log_critical, True, True)
						die(0)
					else
						log_display ("logged in with token " +
						             l_remws_session.token.id +
						             " expiring upon " +
						             l_remws_session.token.expiry.formatted_out (default_date_time_format),
						             log_information, True, True)
					end
				end
			else
				io.error.put_string ("Missing username and password for remws service!")
--				log_display ("Missing username and password for remws service!", log_critical, True, True)
				die(0)
			end
		end

feature -- Usage

	usage
			-- little help on usage
		do
			print ("collect network remws gateway%N")
			print ("Agenzia Regionale per la Protezione Ambientale della Lombardia%N")
			print ("collect [-p <port_number>][-l <log_level>][-t][-u][-h]%N%N")
			print ("%T<port_number> is the network port on which collect will accept connections%N")
			print ("%T<log_level>   is the logging level that will be used%N")
			print ("%T--config      configuration location%N")
			print ("%T-t            uses the testing web service%N")
			print ("%T-u            the box running collect is in UTC%N")
			print ("%T-h			prints this text%N")
			print ("%TThe available logging levels are:%N")
			print ("%T%T " + log_debug.out       + " --> debug-level messages%N")
			print ("%T%T " + log_information.out + " --> informational%N")
			print ("%T%T " + log_notice.out      + " --> normal but significant condition%N")
			print ("%T%T " + log_warning.out     + " --> warning conditions%N")
			print ("%T%T " + log_error.out       + " --> error conditions%N")
			print ("%T%T " + log_critical.out    + " --> critical conditions%N")
			print ("%T%T " + log_alert.out       + " --> action must be taken immediately%N")
			print ("%T%T " + log_emergency.out   + " --> system is unusable%N%N")
		end

feature -- Attributes

	port:         INTEGER
			-- Listening port



end
