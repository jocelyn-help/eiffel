indexing

	description:
	"[
		Objects that perform time/date formatting
		in accordance with the XSLT functions:
			format-date()
			format-time()
			format-date-time()

		See http://www.w3.org/TR/xslt20/#format-date
		See also possible errata regarding time zones.
	]"
	library: "Gobo Eiffel String Library"
	copyright: "Copyright (c) 2007, Colin Adams and others"
	license: "MIT License"
	date: "$Date: 2008-10-06 09:53:14 +0200 (Mon, 06 Oct 2008) $"
	revision: "$Revision: 6531 $"

class ST_XSLT_FORMAT_DATE_TIME

inherit

	ANY

	UC_UNICODE_FACTORY
		export {NONE} all end

	DT_SHARED_WEEK_DAYS_FROM_MONDAY
		export {NONE} all end

	KL_SHARED_PLATFORM
		export {NONE} all end

	ST_XSLT_NUMBER_ROUTINES
		export {NONE} all end

	MA_SHARED_DECIMAL_CONTEXT
		export {NONE} all end

	MA_DECIMAL_CONTEXT_CONSTANTS
		export {NONE} all end

feature -- Access

	Default_language: STRING is "en"
			-- Language used if user does not supply one

	Default_calendar: STRING is "CE"
			-- Calendar used if user does not supply one

	Default_country: STRING is "US"
			-- Country used if user does not supply one

	Iso_calendar: STRING is "ISO"
			-- Calendar of ISO 8601

	Ad_calendar: STRING is "AD"
			-- Anno Domini (Christian Era);
			-- Same as "CE" except for the "E" modifier values

feature -- Basic operations

	format_date_time (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_picture, a_requested_language, a_requested_calendar, a_country: STRING) is
			-- Format the result.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			calendar_value_not_void: a_calendar_value /= Void
			picture_string_not_void: a_picture /= Void
			requested_language_not_void: a_requested_language /= Void
			requested_calendar_not_void: a_requested_calendar /= Void
			country_not_void: a_country /= Void
		local
			l_result_string, l_language, l_calendar: STRING
		do
			if a_picture.is_empty then
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make (""))
			else
				l_result_string := new_unicode_string_with_capacity (32)
				if not is_language_supported (a_requested_language) then
					l_language := language (a_requested_language)
					l_result_string := STRING_.appended_string (l_result_string, language_prefix (a_requested_language))
				else
					l_language := a_requested_language
				end
				if not is_calendar_supported (a_requested_calendar) then
					l_calendar := calendar (a_requested_calendar)
					l_result_string := STRING_.appended_string (l_result_string, calendar_prefix (a_requested_calendar, l_language))
				else
					l_calendar := a_requested_calendar
				end
				parse_picture_string (a_result, l_result_string, a_calendar_value, a_picture, l_language, l_calendar, a_country)
			end
		ensure
			a_result_not_empty: a_result.item /= Void
		end

feature {NONE} -- Implementation

	is_traditional: BOOLEAN
			-- Does current specifier request traditional numbering?

	is_ordinal: BOOLEAN
			-- Does current specifier request ordinal numbering?

	minimum_width: INTEGER
			-- Minimum width for current variable marker

	maximum_width: INTEGER
			-- Maximum width for current variable marker

	primary_modifier: STRING
			-- Specifier in current variable marker

	parse_picture_string (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_picture, a_language, a_calendar, a_country: STRING) is
			-- Parse `a_picture' and format output.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			picture_string_not_empty: a_picture /= Void and then not a_picture.is_empty
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
		local
			i, l_count, l_open, l_close: INTEGER
			l_finished, l_finished_inner: BOOLEAN
		do
			from
				i := 1
				l_count := a_picture.count
			until
				l_finished
			loop
				from
					l_finished_inner := False
				until
					i > l_count or else l_finished_inner
				loop
					if a_picture.index_of ('[', i) = i then
						l_open := i
						l_finished_inner := True
					else
						a_result_string.insert_character (a_picture.item (i), a_result_string.count + 1)
						if a_picture.index_of (']', i) = i then
							i := i + 1
							if a_picture.index_of (']', i) /= i then
								a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error ("] must be doubled in picture string", "XTDE1340"))
								l_finished := True
								l_finished_inner := True
							end
						end
					end
					i := i + 1
				end
				if i > l_count then
					l_finished := True
					if l_open > 0 and l_close = 0 then
						a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error ("] not found after [ in picture string", "XTDE1340"))
					end
				elseif not l_finished then
					if a_picture.index_of ('[', i) = i then
						a_result_string.insert_character ('[', a_result_string.count + 1)
						i := i + 1
					else
						l_close := a_picture.index_of (']', i)
						if l_close = 0 then
							a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error ("] not found after [ in picture string", "XTDE1340"))
							l_finished := True
						else
							format_marker (a_result, a_result_string, a_calendar_value, a_picture.substring (l_open + 1, l_close - 1), a_language, a_calendar, a_country)
							if a_result.item /= Void then
								l_finished := True
							else
								i := l_close + 1
							end
						end
					end
				end
			end
			if a_result.item = Void then
					-- no error
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make (a_result_string))
			end
		end

	format_marker (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_marker, a_language, a_calendar, a_country: STRING) is
			-- Parse `a_marker' and format output by appending to `a_result_string'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			marker_not_void: a_marker /= Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
		local
			l_specifier: CHARACTER
			l_modifiers: STRING
			l_invalid: BOOLEAN
		do
			if a_marker.is_empty then
				l_invalid := True
			elseif not is_valid_specifier (a_marker.item (1)) then
				l_invalid := True
			else
				l_specifier := a_marker.item (1)
				l_modifiers := a_marker.substring (2, a_marker.count)
				STRING_.left_adjust (l_modifiers)
				STRING_.right_adjust (l_modifiers)
			end
			if l_invalid then
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (STRING_.concat ("The picture string has an invalid variable marker: ", a_marker), "XTDE1340"))
			else
				parse_and_format_marker (a_result, a_result_string, a_calendar_value, l_specifier, l_modifiers, a_language, a_calendar, a_country)
			end
		end

	parse_and_format_marker (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_specifier: CHARACTER; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format `a_calendar_value' according to `a_specifier' and `some_modifiers' by appending to `a_result_string'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			valid_specifier: is_valid_specifier (a_specifier)
			modifiers_exist: some_modifiers /= Void
		do
			inspect a_specifier
			when 'Y' then
				format_year (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'M' then
				format_month (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'D' then
				format_day_in_month (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'd' then
				format_day_in_year (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'F' then
				format_day_of_week (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'W' then
				format_week_in_year (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'w' then
				format_week_in_month (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'H' then
				format_hour (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'h' then
				format_hour_in_half_day (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'P' then
				format_am_pm (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'm' then
				format_minute (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 's' then
				format_second (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'f' then
				format_millisecond (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'Z' then
				format_time_zone (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'z' then
				format_gmt_offset (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			when 'C' then
				format_calendar_name (a_result, a_result_string, some_modifiers, a_language, a_calendar, a_country)
			when 'E' then
				format_era (a_result, a_result_string, a_calendar_value, some_modifiers, a_language, a_calendar, a_country)
			end
		end

	check_not_date_value (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_message: STRING) is
			-- Check `a_calendar_value' is not an xs:date.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			calendar_value_not_void: a_calendar_value /= Void
			message_not_empty: a_message /= Void and then not a_message.is_empty
		do
			if a_calendar_value.is_xpath_date then
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1350"))
			end
		end

	check_not_time_value (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_message: STRING) is
			-- Check `a_calendar_value' is not an xs:time.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			calendar_value_not_void: a_calendar_value /= Void
			message_not_empty: a_message /= Void and then not a_message.is_empty
		do
			if a_calendar_value.is_xpath_time then
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1350"))
			end
		end

	ordinal_attribute_value: STRING is
			-- Value of xsl:number "ordinal" attribute
		do
			if is_ordinal then
				Result := "yes"
			else
				Result := ""
			end
		ensure
			result_not_void: Result /= Void
		end

	letter_attribute_value: STRING is
			-- Value of xsl:number "letter_value" attribute
		do
			if is_traditional then
				Result := "traditional"
			else
				Result := ""
			end
		ensure
			result_not_void: Result /= Void
		end

	format_year (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format year from `a_calendar_value' and append to `a_result_string'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "Y specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.absolute_year)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_month (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format month from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_integer: INTEGER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "M specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", True)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					l_integer := a_calendar_value.month
					if is_name_modifier then
						l_string := correctly_cased_name (l_numberer.month_name (l_integer, minimum_width, maximum_width))
					else
						create l_number.make_from_integer (l_integer)
						l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
						if l_string.count < minimum_width then
							if is_decimal_format then
								l_string := prepended_with_zeros (l_string)
							else
								l_string := appended_with_blanks (l_string)
							end
						elseif l_string.count > maximum_width then
							l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
						end
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_day_in_month (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format day-in-month from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "D specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.day_in_month)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_day_in_year (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format day-in-year from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "d specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.day_in_year)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
				end
				if not ANY_.same_types (a_result_string, l_string) then
					l_string := new_unicode_string (l_string)
				end
				STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
			end
		end

	format_day_of_week (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format day-of-week from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
			l_iso_day_number: INTEGER
		do
			check_not_time_value (a_result, a_calendar_value, "F specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "n", True)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					l_iso_day_number := a_calendar_value.week_day_number
					if is_name_modifier then
						l_string := correctly_cased_name (l_numberer.day_name (l_iso_day_number, minimum_width, maximum_width))
					else
						create l_number.make_from_integer (week_day_number (l_iso_day_number, a_calendar, a_country))
						l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
						if l_string.count < minimum_width then
							if is_decimal_format then
								l_string := prepended_with_zeros (l_string)
							else
								l_string := appended_with_blanks (l_string)
							end
						elseif l_string.count > maximum_width then
							l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
						end
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_week_in_year (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format week-in-year from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "W specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.week_in_year)
						-- TODO: this is result in ISO calendar - adjust for others, if you can find out what they are!
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
				end
				if not ANY_.same_types (a_result_string, l_string) then
					l_string := new_unicode_string (l_string)
				end
				STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
			end
		end

	format_week_in_month (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format week-in-month from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_time_value (a_result, a_calendar_value, "w specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.week_in_month)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
				end
				if not ANY_.same_types (a_result_string, l_string) then
					l_string := new_unicode_string (l_string)
				end
				STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
			end
		end

	format_hour (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format hour-in-day from `a_calendar_value' using 24-hour clock.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_date_value (a_result, a_calendar_value, "H specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.hour)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_hour_in_half_day (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format hour-in-half-day from `a_calendar_value' using 12-hour clock.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_date_value (a_result, a_calendar_value, "h specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.half_day_hour)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_am_pm (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format AM/PM marker from `a_calendar_value' using 24-hour clock.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
		do
			check_not_date_value (a_result, a_calendar_value, "P specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "n", True)
				if a_result.item = Void then
					if not is_name_modifier then
						primary_modifier := "n"
					end
					l_numberer := selected_numberer (a_language)
					l_string := correctly_cased_name (l_numberer.half_day_name (a_calendar_value.minutes_in_day, minimum_width, maximum_width))
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_minute (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format minute-in-hour from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_date_value (a_result, a_calendar_value, "m specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "01", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.minute)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_second (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format second-in-hour from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_date_value (a_result, a_calendar_value, "s specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "01", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.second)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_millisecond (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format fractional seconds from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: a_modifiers /= Void
		local
			l_string: STRING
			l_numberer: ST_XSLT_NUMBERER
			l_number: MA_DECIMAL
		do
			check_not_date_value (a_result, a_calendar_value, "f specifier not allowed for format-date()")
			if a_result.item = Void then
				check_modifiers (a_result, a_modifiers, "1", False)
				if a_result.item = Void then
					l_numberer := selected_numberer (a_language)
					create l_number.make_from_integer (a_calendar_value.millisecond)
					l_string := l_numberer.formatted_string (l_number, primary_modifier, 0, "", letter_attribute_value, ordinal_attribute_value)
					if l_string.count < minimum_width then
						l_string := appended_with_zeros (l_string)
					elseif l_string.count > maximum_width then
						l_number := l_number / one_thousand
						l_number := l_number.rescale (0 - maximum_width, shared_half_even_context)
						l_string := l_number.to_scientific_string
						if l_string.count > 2 then
								-- chop off 0.
							l_string := l_string.substring (3, l_string.count)
						end
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	one_thousand: MA_DECIMAL is
			-- One thousand
		once
			create Result.make_from_integer (1000)
		ensure
			result_not_void: Result /= Void
		end

	format_time_zone (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format time zone as an offset from UTC, or as the conventional name from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
		do
			if a_calendar_value.zoned then
				check_modifiers (a_result, some_modifiers, "1", True)
				if a_result.item = Void then
					if is_decimal_format then
						l_string := a_calendar_value.time_zone_description
					else
							-- TODO
						l_string := "???"
					end
					if l_string.count < minimum_width then
						if is_decimal_format then
							l_string := prepended_with_zeros (l_string)
						else
							l_string := appended_with_blanks (l_string)
						end
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_gmt_offset (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format time zone as an offset from GMT from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
		do
			if a_calendar_value.zoned then
				check_modifiers (a_result, some_modifiers, "1", False)
				if a_result.item = Void then
					l_string := STRING_.concat ("GMT", a_calendar_value.time_zone_description)
					if l_string.count < minimum_width then
						l_string := appended_with_blanks (l_string)
					elseif l_string.count > maximum_width then
						l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
					end
					if not ANY_.same_types (a_result_string, l_string) then
						l_string := new_unicode_string (l_string)
					end
					STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
				end
			end
		end

	format_calendar_name (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format calendar name.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
		do
			check_modifiers (a_result, some_modifiers, "n", True)
			if not is_name_modifier then
				primary_modifier := "n"
			end
			if a_result.item = Void then
				if maximum_width <= 2 then
					l_string := a_calendar
				else
					l_string := calendar_name (a_calendar)
				end
				l_string := correctly_cased_name (l_string)
				if l_string.count < minimum_width then
					l_string := appended_with_blanks (l_string)
				elseif l_string.count > maximum_width then
					l_string := l_string.substring (l_string.count - maximum_width + 1, l_string.count)
				end
				if not ANY_.same_types (a_result_string, l_string) then
					l_string := new_unicode_string (l_string)
				end
				STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
			end
		end

	format_era (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_result_string: STRING; a_calendar_value: ST_XPATH_CALENDAR_VALUE; some_modifiers, a_language, a_calendar, a_country: STRING) is
			-- Format time zone as an offset from GMT from `a_calendar_value'.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			result_string_not_void: a_result_string /= Void
			calendar_value_not_void: a_calendar_value /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			modifiers_exist: some_modifiers /= Void
		local
			l_string: STRING
		do
			check_not_time_value (a_result, a_calendar_value, "E specifier not allowed for format-time()")
			if a_result.item = Void then
				check_modifiers (a_result, some_modifiers, "n", True)
				if not is_name_modifier then
					primary_modifier := "n"
				end
				if a_result.item = Void then
					if a_calendar_value.is_xpath_time then
						a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error ("Era is not available with time values", "XTDE1350"))
					else
						l_string := era (a_calendar_value, a_language, a_calendar, a_country)
						l_string := correctly_cased_name (l_string)
						if l_string.count < minimum_width then
							l_string := appended_with_blanks (l_string)
						end
						if not ANY_.same_types (a_result_string, l_string) then
							l_string := new_unicode_string (l_string)
						end
						STRING_.append_substring_to_string (a_result_string, l_string, 1, l_string.count)
					end
				end
			end
		end

	is_decimal_format: BOOLEAN is
			-- Does `primary_modifier' indicate a decimal format?
		do
			Result := is_zeros_plus_one (primary_modifier) or (primary_modifier.count = 1 and then is_one (primary_modifier.item_code (1)))
		end

	check_modifiers (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; some_modifiers, a_default: STRING; use_names: BOOLEAN) is
			-- Check `some_modifiers' for syntax errors.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			modifiers_exist: some_modifiers /= Void
			default_modifier_not_empty: a_default /= Void and then not a_default.is_empty
		local
			a_splitter: ST_SPLITTER
			a_modifier, a_message: STRING
			some_components: DS_LIST [STRING]
			an_index: INTEGER
		do
			is_traditional := False
			is_ordinal := False
			minimum_width := 1
			maximum_width := Platform.Maximum_integer
			primary_modifier := Void
			if not some_modifiers.is_empty then
				create a_splitter.make_with_separators (",")
				some_components := a_splitter.split_greedy (some_modifiers)
				if some_components.count > 2 then
					a_message := STRING_.concat ("More than one comma present in '", some_modifiers)
					a_message := STRING_.appended_string (a_message, "'")
					a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1340"))
				elseif some_components.count = 2 then
					a_modifier := some_components.item (1)
					if a_modifier.count /= 1 or else (a_modifier.item (1) /= 'i' and a_modifier.item (1) /= 'I') then
							-- widths are ignored for roman numerals
						set_widths (a_result, some_components.item (2))
					end
				else
					a_modifier := some_modifiers
					if is_zeros_plus_one (a_modifier) then
						minimum_width := a_modifier.count
						maximum_width := a_modifier.count
					else
						minimum_width := 1
						maximum_width := Platform.Maximum_integer
					end
				end
				if a_result.item = Void then
					STRING_.left_adjust (a_modifier)
					STRING_.right_adjust (a_modifier)
					an_index := a_modifier.index_of ('t', 1)
					if an_index > 0 then
						if an_index = a_modifier.count then
							is_traditional := True
						else
							a_message := STRING_.concat ("Misplaced 't' in '", a_modifier)
							a_message := STRING_.appended_string (a_message, "'")
							a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1340"))
						end
					end
					an_index := a_modifier.index_of ('o', 1)
					if an_index > 0 then
						if an_index = a_modifier.count then
							is_ordinal := True
						else
							a_message := STRING_.concat ("Misplaced 'o' in '", a_modifier)
							a_message := STRING_.appended_string (a_message, "'")
							a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1340"))
						end
					end
				end
				if a_result.item = Void then
					if is_traditional or else is_ordinal then
						a_modifier := a_modifier.substring (1, a_modifier.count - 1)
					end
					if not a_modifier.is_empty then
						set_primary_modifier (a_modifier, use_names)
					end
				end
			end
			if a_result.item = Void and then primary_modifier = Void then
				primary_modifier := a_default
			end
		ensure
			primary_modifier_set: a_result.item = Void implies primary_modifier /= Void and then not primary_modifier.is_empty
		end

	set_primary_modifier (a_modifier: STRING; use_names: BOOLEAN) is
			-- Set `primary_modifier' to `a_modifier' if valid.
		require
			modifier_not_empty: a_modifier /= Void and then not a_modifier.is_empty
		do
			primary_modifier := Void
			if
				is_zeros_plus_one (a_modifier)
				or (a_modifier.count = 1 and then is_one (a_modifier.item_code (1)))
				or STRING_.same_string (a_modifier, "A")
				or STRING_.same_string (a_modifier, "a")
				or STRING_.same_string (a_modifier, "I")
				or STRING_.same_string (a_modifier, "i")
				or STRING_.same_string (a_modifier, "W")
				or STRING_.same_string (a_modifier, "w")
				or STRING_.same_string (a_modifier, "Ww")
			then
				primary_modifier := a_modifier
			elseif
				STRING_.same_string (a_modifier, "Nn")
				or else STRING_.same_string (a_modifier, "N")
				or else STRING_.same_string (a_modifier, "n")
			then
				if use_names then
					primary_modifier := a_modifier
				end
			end
		end

	set_widths (a_result: DS_CELL [ST_FORMAT_DATE_TIME_RESULT]; a_width: STRING) is
			-- Set widths.
		require
			a_result_not_void: a_result /= Void
			a_result_empty: a_result.item = Void
			widths_not_empty: a_width /= Void and then not a_width.is_empty
		local
			a_splitter: ST_SPLITTER
			a_message, l_string: STRING
			some_components: DS_LIST [STRING]
		do
			create a_splitter.make_with_separators ("-")
			if a_width.index_of ('+', 1) > 0 then
				a_message := STRING_.concat ("Plus sign present in '", a_width)
				a_message := STRING_.appended_string (a_message, "'")
				a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1340"))
			else
				some_components := a_splitter.split_greedy (a_width)
				if some_components.count > 2 then
					a_message := STRING_.concat ("Two many hyphens in '", a_width)
					a_message := STRING_.appended_string (a_message, "'")
					a_result.put (create {ST_FORMAT_DATE_TIME_RESULT}.make_error (a_message, "XTDE1340"))
				elseif some_components.count = 2 then
					l_string := some_components.item (1)
					STRING_.left_adjust (l_string)
					STRING_.right_adjust (l_string)
					if STRING_.same_string (l_string, "*") then
						minimum_width := 1
					elseif l_string.is_integer then
						minimum_width := l_string.to_integer
					end
					l_string := some_components.item (2)
					STRING_.left_adjust (l_string)
					STRING_.right_adjust (l_string)
					if STRING_.same_string (l_string, "*") then
						maximum_width := Platform.Maximum_integer
					elseif l_string.is_integer then
						maximum_width := l_string.to_integer
					end
				else
					l_string := a_width
					STRING_.left_adjust (l_string)
					STRING_.right_adjust (l_string)
					if STRING_.same_string (l_string, "*") then
						minimum_width := 1
					elseif l_string.is_integer then
						minimum_width := l_string.to_integer
					end
					maximum_width := Platform.Maximum_integer
				end
			end
		end

	is_valid_specifier (a_specifier: CHARACTER): BOOLEAN is
			-- Is `a_specifier' a valid format specifier?
		do
			inspect
				a_specifier
			when
				'Y', 'M', 'D', 'd', 'F', 'W', 'w', 'H', 'h',
				'P', 'm', 's', 'f', 'Z', 'z', 'C', 'E'
			 then
				Result := True
			else
				Result := False
			end
		end

	is_language_supported (a_requested_language: STRING): BOOLEAN is
			-- Is `a_requested_language' supported by implementation?
		require
			requested_language_not_void: a_requested_language /= Void
		do
				-- TODO: change when multiple languages are supported
			Result := STRING_.same_string (a_requested_language, Default_language)
		end

	language (a_requested_language: STRING): STRING is
			-- Language to be used for output
		require
			requested_language_not_void: a_requested_language /= Void
			requested_language_not_supported: not is_language_supported (a_requested_language)
		do
			Result := Default_language
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	language_prefix (a_requested_language: STRING): STRING is
			-- Language prefix to be emitted
		require
			requested_language_not_void: a_requested_language /= Void
			requested_language_not_supported: not is_language_supported (a_requested_language)
		do
			Result := "[Language: en]"
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	is_calendar_supported (a_requested_calendar: STRING): BOOLEAN is
			-- Is `a_requested_calendar' supported by implementation?
		require
			requested_calendar_not_void: a_requested_calendar /= Void
		do
				-- TODO: change when more calendars are supported
			Result := STRING_.same_string (a_requested_calendar, Default_calendar) or STRING_.same_string (a_requested_calendar, Ad_calendar)
		end

	calendar (a_requested_calendar: STRING): STRING is
			-- Calendar to be used for output
		require
			requested_calendar_not_void: a_requested_calendar /= Void
			requested_calendar_not_supported: not is_calendar_supported (a_requested_calendar)
		do
			Result := Default_calendar
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	calendar_prefix (a_requested_calendar, a_language: STRING): STRING is
			-- Calendar prefix to be emitted
		require
			requested_calendar_not_void: a_requested_calendar /= Void
			requested_calendar_not_supported: not is_calendar_supported (a_requested_calendar)
			language_not_void: a_language /= Void
			language_is_supported: is_language_supported (a_language)
		do
				-- TODO: change when additional languages are supported
			Result := "[Calendar: CE]"
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	calendar_name (a_calendar: STRING): STRING is
			-- Full name for `a_calendar'
		require
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			is_calendar_supported: is_calendar_supported (a_calendar)
		do
			if STRING_.same_string (a_calendar, Default_calendar) then
				Result := "Common Era"
			elseif STRING_.same_string (a_calendar, Ad_calendar) then
				Result := "Christian Era"
			end
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	week_day_number (a_day: INTEGER; a_calendar, a_country: STRING): INTEGER is
			-- Number of day in week for `a_calendar' in `a_country'
		require
				-- Monday = 1
			valid_iso_day_number: a_day >= 1 and then a_day <= 7
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
		do
			if STRING_.same_string (a_calendar, Iso_calendar) then
				Result := a_day
			else
					-- For now, assuming Sunday =1, Saturday = 7, for all calendars and countries
					-- TODO: correct this
				Result := week_days_from_monday.week_day_from_code (a_day).as_week_day_from_sunday.code
			end
		end

	is_name_modifier: BOOLEAN is
			-- Is `primary_modifier' a name request?
		do
			if
				STRING_.same_string (primary_modifier, "n")
				or else STRING_.same_string (primary_modifier, "N")
				or else STRING_.same_string (primary_modifier, "Nn")
			 then
				Result := True
			end
		end

	correctly_cased_name (a_name: STRING): STRING is
			-- `a_name' cased according to `primary_modifier'
		require
			name_not_void: a_name /= Void
--			is_capitalized: First letter upper-case, others in lower-case
			valid_name_modifier: is_name_modifier
		do
				-- TODO: correct this for Unicode captialization
			if STRING_.same_string (primary_modifier, "n") then
				Result := a_name.as_lower
			elseif STRING_.same_string (primary_modifier, "N") then
				Result := a_name.as_upper
			else
				check
					capitalized: STRING_.same_string (primary_modifier, "Nn")
						-- from pre-condition `valid_name_modifier'
				end
				Result := a_name
			end
		end

	era (a_calendar_value: ST_XPATH_CALENDAR_VALUE; a_language, a_calendar, a_country: STRING): STRING is
			-- Era
		require
			calendar_value_not_void: a_calendar_value /= Void
			calendar_not_empty: a_calendar /= Void and then not a_calendar.is_empty
			country_not_void: a_country /= Void
			language_not_empty: a_language /= Void and then not a_language.is_empty
			language_is_supported: is_language_supported (a_language)
		local
			a_year: INTEGER
		do
				-- TODO: other calendars and countries, and language
			a_year := a_calendar_value.year
			if STRING_.same_string (a_calendar, Default_calendar) then
				if a_year > 0 then
					if maximum_width >= 10 then
						Result := "Common Era"
					else
						Result := "CE"
					end
				else
					if maximum_width >= 17 then
						Result := "Before Common Era"
					else
						Result := "BCE"
					end
				end
			elseif STRING_.same_string (a_calendar, Ad_calendar) then
				if a_year > 0 then
					if maximum_width >= 11 then
						Result := "Anno Domini"
					else
						Result := "AD"
					end
				else
					if maximum_width >= 13 then
						Result := "Before Christ"
					else
						Result := "BC"
					end
				end
			else
				Result := "Unknown"
			end
		ensure
			not_empty: Result /= Void and then not Result.is_empty
		end

	prepended_with_zeros (a_string: STRING): STRING is
			-- Left-padded version of `a_string'
		require
			string_not_void: a_string /= Void
			short_string: a_string.count < minimum_width
		do
			create Result.make_filled ('0', minimum_width - a_string.count)
			Result := STRING_.appended_string (Result, a_string)
		ensure
			minimum_width: Result.count = minimum_width
		end

	appended_with_blanks (a_string: STRING): STRING is
			-- Right-padded version of `a_string'
		require
			string_not_void: a_string /= Void
			short_string: a_string.count < minimum_width
		do
			create Result.make_filled (' ', minimum_width - a_string.count)
			Result := STRING_.concat (a_string, Result)
		ensure
			minimum_width: Result.count = minimum_width
		end

	appended_with_zeros (a_string: STRING): STRING is
			-- Right-padded version of `a_string'
		require
			string_not_void: a_string /= Void
			short_string: a_string.count < minimum_width
		do
			create Result.make_filled ('0', minimum_width - a_string.count)
			Result := STRING_.concat (a_string, Result)
		ensure
			minimum_width: Result.count = minimum_width
		end

	shared_half_even_context: MA_DECIMAL_CONTEXT is
			-- Decimal context for use by rounded-half-even
		once
			create Result.make (shared_decimal_context.digits, Round_half_even)
		end

end
