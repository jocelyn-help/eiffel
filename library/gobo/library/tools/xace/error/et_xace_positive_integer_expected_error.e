indexing

	description:

		"Error: Expected positive integer value in attribute error"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class ET_XACE_POSITIVE_INTEGER_EXPECTED_ERROR

inherit

	ET_XACE_ERROR

create

	make

feature {NONE} -- Initialization

	make (an_element: XM_ELEMENT; an_attribute_name: STRING; an_actual_value: STRING; a_position: XM_POSITION) is
			-- Create an error reporting that the value of attribute `an_attribute_name'
			-- in element `an_element' should be a positive integer value.
		require
			an_element_not_void: an_element /= Void
			an_attribute_name_not_void: an_attribute_name /= Void
			an_attribute_name_not_empty: an_attribute_name.count > 0
			an_actual_value_not_void: an_actual_value /= Void
			a_position_not_void: a_position /= Void
		do
			create parameters.make (1, 4)
			parameters.put (an_element.name, 1)
			parameters.put (an_attribute_name, 2)
			parameters.put (an_actual_value, 3)
			parameters.put (a_position.out, 4)
		end

feature -- Access

	default_template: STRING is "attribute '$2' in element '$1' should have a positive integer value $4"
			-- Default template used to built the error message

	code: STRING is "XA0009"
			-- Error code

end
