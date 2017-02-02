note
	description: "Summary description for {SHARED_APP_LOGGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_APP_LOGGER

feature -- Access

	logger: detachable separate APP_LOGGER
		do
			separate logger_cell as cell do
				Result := cell.item
			end
		end

feature {NONE} -- Implementation

	logger_cell: separate CELL [detachable separate APP_LOGGER]
		once ("process")
			create Result.put (Void)
		end

feature -- Element change

	initialize_logger (a_location: PATH)
		local
			l_logger: APP_LOGGER
		do
			create l_logger.make (a_location)
			separate logger_cell as cell do
				cell.replace (l_logger)
			end
		end

	set_logger (a_logger: like logger)
		do
			separate logger_cell as cell do
				cell.replace (a_logger)
			end
		end

	set_log_level (a_log_level: INTEGER)
		do
			if attached logger as l_logger then
				separate l_logger as sep_logger do
					sep_logger.set_log_level (a_log_level)
				end
			end
		end

feature -- Status report

	is_logging_enabled: BOOLEAN
			-- Is logging enabled
		do
			if attached logger as l_logger then
				separate l_logger as sep_logger do
					Result := sep_logger.is_logging_enabled
				end
			end
		end

feature -- Basic operation	

	log (a_string: STRING; priority: INTEGER)
			-- Logs `a_string'
		do
			if attached logger as l_logger then
				separate l_logger as sep_logger do
					sep_logger.log (a_string, priority)
				end
			end
		end

	log_display (a_string: STRING; priority: INTEGER; to_file, to_display: BOOLEAN)
			-- Combined file and display log
		do
			if attached logger as l_logger then
				separate l_logger as sep_logger do
					sep_logger.log_display (Current, a_string, priority, to_file, to_display)
				end
			end
		end

end
