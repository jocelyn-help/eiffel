indexing
	description: "Factory for creating SYSTEM_STRING instances."
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2008, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2008-10-25 22:32:57 +0200 (Sat, 25 Oct 2008) $"
	revision: "$Revision: 6537 $"

class
	SYSTEM_STRING_FACTORY

feature -- Conversion

	from_string_to_system_string (a_str: READABLE_STRING_GENERAL): SYSTEM_STRING is
			-- Convert `a_str' to an instance of SYSTEM_STRING.
		require
			is_dotnet: {PLATFORM}.is_dotnet
			a_str_not_void: a_str /= Void
		do
			create Result
		ensure
			from_string_to_system_string_not_void: Result /= Void
		end

	read_system_string_into (a_str: SYSTEM_STRING; a_result: STRING_GENERAL) is
			-- Fill `a_result' with `a_str' content.
		require
			is_dotnet: {PLATFORM}.is_dotnet
			a_str_not_void: a_str /= Void
			a_result_not_void: a_result /= Void
			a_result_valid: a_result.count = a_str.length
		do
		end

	read_system_string_into_area_8 (a_str: SYSTEM_STRING; a_area: SPECIAL [CHARACTER_8]) is
			-- Fill `a_result' with `a_str' content.
		require
			is_dotnet: {PLATFORM}.is_dotnet
			a_str_not_void: a_str /= Void
			a_area_not_void: a_area /= Void
			a_area_valid: a_area.count >= a_str.length
		do
		end

	read_system_string_into_area_32 (a_str: SYSTEM_STRING; a_area: SPECIAL [CHARACTER_32]) is
			-- Fill `a_area' with `a_str' content.
		require
			is_dotnet: {PLATFORM}.is_dotnet
			a_str_not_void: a_str /= Void
			a_area_not_void: a_area /= Void
			a_area_valid: a_area.count >= a_str.length
		do
		end

end
