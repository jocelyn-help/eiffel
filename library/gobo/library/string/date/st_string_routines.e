indexing

	description:

		"Routines on strings and characters."

	library: "Gobo Eiffel String Library"
	copyright: "Copyright (c) 2007, Colin Adams and others"
	license: "MIT License"
	date: "$Date: 2008-10-06 09:53:14 +0200 (Mon, 06 Oct 2008) $"
	revision: "$Revision: 6531 $"

class ST_STRING_ROUTINES

inherit

	ANY

	ST_IMPORTED_UNICODE_CHARACTER_CLASS_ROUTINES
		export {NONE} all end

feature -- Status report

	is_all_whitespace (chars: STRING): BOOLEAN is
			-- Does `chars' consist only of XML white-space characters?
		local
			counter: INTEGER
		do
			from
				counter := 1
				Result := True
			variant
				chars.count + 1 - counter
			until
				Result = False or else counter > chars.count
			loop
				if not is_xml_space (chars.item_code (counter)) then
					Result := False
				end
				counter := counter + 1
			end
		end

	is_alphanumeric (a_character_code: INTEGER): BOOLEAN is
			-- Does `a_character_code' represent an alphanumeric character?
		require
			positive_character_code: a_character_code > 0
		do
			Result := unicode_character_class.unicode.valid_code (a_character_code)
				and then (unicode_character_class.is_letter (a_character_code)
							 or else unicode_character_class.is_number (a_character_code))
		end

	is_xml_space (a_code: INTEGER): BOOLEAN is
			-- Does `a_code' represent an XML space?
		do
			Result := a_code = 32 or a_code = 9 or a_code = 10 or a_code = 13
		end

end
	
