indexing

	description:

		"Tests two declarations for beeing equal"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2003/11/02 03:54:04 $"
	revision: "$Revision: 1.2 $"

class EWG_C_AST_DECLARATION_EQUALITY_TESTER [G -> EWG_C_AST_DECLARATION]

inherit

	KL_EQUALITY_TESTER [G]
		redefine
			test
		end

feature -- Status report

	test (v, u: G): BOOLEAN is
			-- Are `v' and `u' considered equal?
		do
			if v = u then
				Result := True
			elseif v = Void then
				Result := (u = Void)
			elseif u = Void then
				Result := False
			else
				Result := v.is_same_declaration (u)
			end
		end

end
