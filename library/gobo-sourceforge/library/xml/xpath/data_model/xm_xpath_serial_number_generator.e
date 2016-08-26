indexing

	description:

		"Objects that provide a unique serial number"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class XM_XPATH_SERIAL_NUMBER_GENERATOR

inherit

	KL_SHARED_EXCEPTIONS
	
	-- CAUTION: this implementation is limited to no more than 2x Platform.Maximum_integer
	--          differing ids

create {XM_XPATH_SHARED_SERIAL_NUMBER_GENERATOR}

	make

feature {NONE} -- Initialization

	make is
			-- Do nothing
		do
		end

feature -- Access

	last_generated_serial_number: INTEGER -- change this to INTEGER_64
			-- Result of `generate_next_serial_number'

feature -- Element change

	
	generate_next_serial_number is
			-- Generate next number in sequence
		do
			last_generated_serial_number := last_generated_serial_number + 1
			if last_generated_serial_number = 0 then -- wrap around
				Exceptions.raise ("Wrap around of serial number generator")
			end
		end
	
end
	