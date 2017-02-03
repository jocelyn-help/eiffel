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
			create <NONE> Result.put (Void)
		end

feature -- Element change

	initialize_logger (a_location: PATH)
		local
			l_logger: APP_LOGGER
		do
			create {APP_FILE_LOGGER} l_logger.make (a_location)
--			create {APP_LOG_WRITER_FILE_LOGGER} l_logger.make (a_location)
			separate logger_cell as cell do
				cell.replace (l_logger)
			end
			if l_logger.is_logging_enabled then
				log_information_display ("Log system initialized", True, True)
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
					sep_logger.set_level (a_log_level)
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
					sep_logger.put (a_string, priority)
				end
			end
		end

feature -- Logging

	log_emergency (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_emergency)
		end

	log_alert (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_alert)
		end

	log_critical (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_critical)
		end

	log_error (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_error)
		end

	log_warning (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_warning)
		end

	log_notice (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_notice)
		end

	log_information (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_information)
		end

	log_debug (a_message: STRING)
		do
			log (a_message, {APP_LOGGER}.level_debug)
		end

feature -- Custom log

	log_emergency_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_emergency, to_file, to_display)
		end

	log_alert_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_alert, to_file, to_display)
		end

	log_critical_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_critical, to_file, to_display)
		end

	log_error_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_error, to_file, to_display)
		end

	log_warning_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_warning, to_file, to_display)
		end

	log_notice_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_notice, to_file, to_display)
		end

	log_information_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_information, to_file, to_display)
		end

	log_debug_display (a_string: STRING; to_file, to_display: BOOLEAN)
		do
			log_display (a_string, {APP_LOGGER}.level_debug, to_file, to_display)
		end

	log_display (a_string: STRING; priority: INTEGER; to_file, to_display: BOOLEAN)
			-- Combined file and display log
		local
			s: STRING
		do
			create s.make (a_string.count + 15)
			if attached {EXCEPTIONS} Current as e and then attached e.class_name as cn then
				s.prepend ("{" + cn + "} ")
			else
				s.prepend ("{NO_CLASS_NAME} ")
			end
			s.append (a_string)
			if to_display then
				io.put_string (s)
				io.put_new_line
			end
			if to_file then
				log (s, priority)
			end
		end

end
