indexing

	description:

		"C code validator"

	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/04/20 21:09:22 $"
	revision: "$Revision: 1.4 $"


class DRC_C_CODE_VALIDATOR

inherit

	DRC_IO_PROCESSOR

creation

	make,
	make_from_string

feature {NONE} -- Implementation

	create_process is
		do
			create process.make ("/usr/bin/gcc",
										<<"-fsyntax-only", "-x", "c", "-c", "-Wall", "-">>)
			process.set_capture_error (True)
			process.set_capture_input (True)
		end
	
end
