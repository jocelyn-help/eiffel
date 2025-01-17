indexing

	description:
	
		"DTD event filter that can forward events to 'next' filter"
	
	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class XM_DTD_CALLBACKS_FILTER

inherit

	XM_DTD_CALLBACKS
	
	XM_DTD_CALLBACKS_SOURCE
		rename
			set_dtd_callbacks as set_next
		end

create

	make_null,
	set_next
	
feature  {NONE} -- Initialization

	make_null is
			-- Next is null processor.
		do
			create {XM_DTD_CALLBACKS_NULL} next.make
		end

feature -- Document type definition callbacks

	on_doctype (a_name: STRING; an_id: XM_DTD_EXTERNAL_ID; has_internal_subset: BOOLEAN) is
			-- Document type declaration.
		do
			next.on_doctype (a_name, an_id, has_internal_subset)
		end
		
	on_element_declaration (a_name: STRING; a_model: XM_DTD_ELEMENT_CONTENT) is
		do
			next.on_element_declaration (a_name, a_model)
		end
		
	on_attribute_declaration (an_element_name, a_name: STRING; a_model: XM_DTD_ATTRIBUTE_CONTENT) is
			-- Attribute declaration, one event per attribute.
		do
			next.on_attribute_declaration (an_element_name, a_name, a_model)
		end
		
	on_entity_declaration (entity_name: STRING; is_parameter: BOOLEAN; value: STRING;
				an_id: XM_DTD_EXTERNAL_ID; notation_name: STRING) is
			-- Entity declaration.
		do
			next.on_entity_declaration (entity_name, is_parameter, value, an_id, notation_name)
		end

	on_notation_declaration (notation_name: STRING; an_id: XM_DTD_EXTERNAL_ID) is
			-- Notation declaration.
		do
			next.on_notation_declaration (notation_name, an_id)
		end
	
	on_dtd_processing_instruction (a_name, a_content: STRING) is
			-- PI.
		do
			next.on_dtd_processing_instruction (a_name, a_content)
		end

	on_dtd_comment (a_content: STRING) is
			-- Comment.
		do
			next.on_dtd_comment (a_content)
		end
		
	on_dtd_end is
			-- End of DTD.
		do
			next.on_dtd_end
		end

feature -- Access

	next: XM_DTD_CALLBACKS
			-- Receiver for forwarded events

	set_next (a_next: like next) is
			-- Set receiver of forwarded events.
		do
			next := a_next
		end

invariant

	next_not_void: next /= Void

end
