note
	description: "Summary description for {APP_LOGGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	APP_LOGGER

feature -- Access

	level: INTEGER
			-- Possible log levels	emergency < alter < critical < error < warning < notice < information < debug
            -- Default `0`, no logging at all.
            -- See `is_accepted_level`

feature -- Constants

	level_emergency: INTEGER = 2
			-- System is unusable

	level_alert: INTEGER = 4
			-- Action must be taken immediately

	level_critical: INTEGER = 8
			-- Critical conditions

	level_error: INTEGER = 16
			-- Error conditions

	level_warning: INTEGER = 32
			-- Warning conditions

	level_notice: INTEGER = 64
			-- Normal but significant condition

	level_information: INTEGER = 128
			-- Informational

	level_debug: INTEGER = 256
			-- Debug-level messages

feature -- Change

	is_valid_log_level (lev: INTEGER): BOOLEAN
		do
			Result := lev >= 0 and lev <= level_debug
		end

	set_level (a_log_level: INTEGER)
		require
			is_valid_log_level (a_log_level)
		do
			level := a_log_level
		end

feature -- Basic operation

	is_accepted_level (a_level: INTEGER): BOOLEAN
			-- Is `a_level` accepted to process the logging?
		do
			Result := a_level <= level
		end

	put (a_message: separate STRING_8; a_level: INTEGER)
			-- Logs `a_string' for `a_level`.
		require
			is_valid_log_level (a_level)
		do
			if is_accepted_level (a_level) then
				write (a_message)
			end
		end

	close
		require
			is_logging_enabled
		deferred
		end

feature {NONE} -- Implementation

	write (a_message: separate STRING_8)
		deferred
		end

feature -- Logging

	put_emergency (a_message: separate STRING)
		do
			put (a_message, level_emergency)
		end

	put_alert (a_message: separate STRING)
		do
			put (a_message, level_alert)
		end

	put_critical (a_message: separate STRING)
		do
			put (a_message, level_critical)
		end

	put_error (a_message: separate STRING)
		do
			put (a_message, level_error)
		end

	put_warning (a_message: separate STRING)
		do
			put (a_message, level_warning)
		end

	put_notice (a_message: separate STRING)
		do
			put (a_message, level_notice)
		end

	put_information (a_message: separate STRING)
		do
			put (a_message, level_information)
		end

	put_debug (a_message: separate STRING)
		do
			put (a_message, level_debug)
		end

feature -- Status report

	is_logging_enabled: BOOLEAN
		deferred
		end

end
