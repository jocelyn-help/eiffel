indexing

	description:

		"ECF compiler version conditions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2008, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-11-04 17:33:00 +0100 (Tue, 04 Nov 2008) $"
	revision: "$Revision: 6546 $"

class ET_ECF_COMPILER_VERSION_CONDITION

inherit

	ET_ECF_VERSION_CONDITION

create

	make

feature -- Status report

	is_enabled (a_state: ET_ECF_STATE): BOOLEAN is
			-- Does `a_state' fulfill current condition?
		do
			Result := is_included (a_state.ise_version)
		end

end
