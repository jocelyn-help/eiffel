indexing

	description:

		"ECF internal universes (i.e. either systems or libraries)"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2008, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-10-26 20:29:45 +0100 (Sun, 26 Oct 2008) $"
	revision: "$Revision: 6539 $"

deferred class ET_ECF_INTERNAL_UNIVERSE

inherit

	ET_INTERNAL_UNIVERSE

	ET_ECF_SYSTEM_CONFIG

feature -- Access

	selected_target: ET_ECF_TARGET
			-- Selected target

feature -- Setting

	select_target (a_target: ET_ECF_TARGET; a_state: ET_ECF_STATE) is
			-- Select `a_target' in `a_state'.
			-- Update `clusters' and `libraries' accordingly.
		require
			not_selected_yet: selected_target /= Void
			a_target_not_void: a_target /= Void
			valid_target: targets /= Void and then targets.has (a_target)
			a_state_not_void: a_state /= Void
		do
			a_target.fill_universe (Current, a_state)
			selected_target := a_target
		ensure
			selected_target_set: selected_target = a_target
		end

invariant

	valid_selected_target: selected_target /= Void implies (targets /= Void and then targets.has (selected_target))

end
