indexing

	description:

		"Get static type of an XML node object without a reverse assignment"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2001, Andreas Leitner and others"
	license: "MIT License"
	date: "$Date: 2008-05-13 16:59:07 +0200 (Tue, 13 May 2008) $"
	revision: "$Revision: 6413 $"

class XM_NODE_TYPER

inherit

	XM_NODE_PROCESSOR
		redefine
			process_element,
			process_character_data,
			process_processing_instruction,
			process_document,
			process_comment,
			process_attribute
		end

feature

	process_element (a: XM_ELEMENT) is
			-- Element.
		do
			reset
			element := a
			composite := a
		end

	process_character_data (a: XM_CHARACTER_DATA) is
			-- Character data.
		do
			reset
			character_data := a
		end

	process_processing_instruction (a: XM_PROCESSING_INSTRUCTION) is
			-- Processing instruction.
		do
			reset
			processing_instruction := a
		end

	process_document (a: XM_DOCUMENT) is
			-- Root.	
		do
			reset
			document := a
			composite := a
		end

	process_comment (a: XM_COMMENT) is
			-- Comment.
		do
			reset
			comment := a
		end

	process_attribute (a: XM_ATTRIBUTE) is
			-- Attribute.
		do
			reset
			xml_attribute := a
		end

feature -- Status report

	is_element: BOOLEAN is
			-- Element?
		do
			Result := element /= Void
		end

	is_character_data: BOOLEAN is
			-- Character data?
		do
			Result := character_data /= Void
		end

	is_processing_instruction: BOOLEAN is
			-- Processing instruction?
		do
			Result := processing_instruction /= Void
		end

	is_document: BOOLEAN is
			-- Document?
		do
			Result := document /= Void
		end

	is_comment: BOOLEAN is
			-- Comment?
		do
			Result := comment /= Void
		end

	is_attribute: BOOLEAN is
			-- Attribute?
		do
			Result := xml_attribute /= Void
		end

feature -- Access

	element: XM_ELEMENT
			-- Element
			-- require type_ok: is_element
			-- ensure not_void: Result /= Void

	character_data: XM_CHARACTER_DATA
			-- Character data
			-- require type_ok: is_character_data
			-- ensure not_void: Result /= Void

	processing_instruction: XM_PROCESSING_INSTRUCTION
			-- Processing instruction
			-- require type_ok: is_processing_instruction
			-- ensure not_void: Result /= Void

	document: XM_DOCUMENT
			-- Document
			-- require type_ok: is_document
			-- ensure not_void: Result /= Void

	comment: XM_COMMENT
			-- Comment
			-- require type_ok: is_comment
			-- ensure not_void: Result /= Void

	xml_attribute: XM_ATTRIBUTE
			-- Attribute
			-- require type_ok: is_attribute
			-- ensure not_void: Result /= Void

feature -- Status report

	is_composite: BOOLEAN is
			-- Composite?
		do
			Result := composite /= Void
		ensure
			consistent: Result = (is_element or is_document)
		end

feature -- Access

	composite: XM_COMPOSITE
			-- Composite
			-- require type_ok: is_composite
			-- ensure not_void: Result /= Void

feature {NONE} -- Implementation

	reset is
			-- Reset.
		do
			element := Void
			character_data := Void
			processing_instruction := Void
			document := Void
			comment := Void
			xml_attribute := Void

			composite := Void
		end

end
