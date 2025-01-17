indexing

	description:

		"Local system clocks (precision to the millisecond)"

	remark: "With SmartEiffel under Windows the millisecond part may be stuck to zero."
	library: "Gobo Eiffel Time Library"
	copyright: "Copyright (c) 2001-2004, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-09-28 20:36:52 +0200 (Sun, 28 Sep 2008) $"
	revision: "$Revision: 6525 $"

class DT_SYSTEM_CLOCK

inherit

	DT_CLOCK

	DT_GREGORIAN_CALENDAR
		export {NONE} all end

	KL_SYSTEM_CLOCK
		export {NONE} all end

create

	make

feature -- Setting

	set_time_to_now (a_time: DT_TIME) is
			-- Set `a_time' to current local time.
		do
			set_local_time
			if second >= Seconds_in_minute then
				second := Seconds_in_minute - 1
			end
			a_time.set_precise_hour_minute_second (hour, minute, second, millisecond)
		end

	set_date_to_now (a_date: DT_DATE) is
			-- Set `a_date' to current local date.
		do
			set_local_time
			a_date.set_year_month_day (year, month, day)
		end

	set_date_time_to_now (a_date_time: DT_DATE_TIME) is
			-- Set `a_date_time' to current local date time.
		do
			set_local_time
			if second >= Seconds_in_minute then
				second := Seconds_in_minute - 1
			end
			a_date_time.set_year_month_day (year, month, day)
			a_date_time.set_precise_hour_minute_second (hour, minute, second, millisecond)
		end

end
