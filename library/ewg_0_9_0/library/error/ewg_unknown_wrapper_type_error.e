indexing

	description:

		"Error: Unknown wrapper type"

	copyright: "Copyright (c) 2004, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/03/19 23:49:31 $"
	revision: "$Revision: 1.1 $"

class EWG_UNKNOWN_WRAPPER_TYPE_ERROR

inherit

	UT_ERROR
	
	EWG_CONFIG_ELEMENT_NAMES
		export {NONE} all end

	EWG_CONFIG_WRAPPER_TYPE_NAMES
		export {NONE} all end

creation

	make

feature {NONE} -- Initialization

	make (an_element: XM_ELEMENT; a_position: XM_POSITION) is
			-- Create an error reporting that the value of the attribute "type"
			-- in the "wrapper" elment `an_element' is unknown.
		require
			an_element_not_void: an_element /= Void
			an_element_has_option_as_name: STRING_.same_string (an_element.name, wrapper_element_name)
			an_element_has_name_attribute: an_element.has_attribute_by_name (type_attribute_name)
			a_name_attribute_not_empty: an_element.attribute_by_name (type_attribute_name).value.count > 0
			a_position_not_void: a_position /= Void
		do
			create parameters.make (1, 2)
			parameters.put (an_element.attribute_by_name (type_attribute_name).value, 1)
			parameters.put (a_position.out, 2)
		end

feature -- Access

	default_template: STRING is "wrapper type name '$1' in wrapper-element is unknown $2"
			-- Default template used to built the error message

	code: STRING is "EWG0004"
			-- Error code

end
