indexing

	description:

		"Eiffel static call instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2007-01-26 19:55:25 +0100 (Fri, 26 Jan 2007) $"
	revision: "$Revision: 5877 $"

class ET_STATIC_CALL_INSTRUCTION

inherit

	ET_STATIC_FEATURE_CALL
		redefine
			is_instruction
		end

	ET_INSTRUCTION
		undefine
			reset
		end

create

	make

feature -- Status report

	is_instruction: BOOLEAN is True
			-- Is current call an instruction?

feature -- Conversion

	as_expression: ET_STATIC_CALL_EXPRESSION is
			-- `Current' viewed as an expression
		do
			check not_expression: False end
		end

	as_instruction: ET_STATIC_CALL_INSTRUCTION is
			-- `Current' viewed as an instruction
		do
			Result := Current
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_static_call_instruction (Current)
		end

end
