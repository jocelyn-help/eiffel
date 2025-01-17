indexing

	description:

		"Data structures whose items are accessible through keys"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 2000-2008, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-09-28 20:40:54 +0200 (Sun, 28 Sep 2008) $"
	revision: "$Revision: 6526 $"

deferred class DS_TABLE [G, K]

inherit

	DS_CONTAINER [G]

	KL_VALUES [G, K]
		undefine
			is_equal,
			copy
		end

feature -- Access

	infix "@", item (k: K): G is
			-- Item associated with `k'
		require
			has_k: has (k)
		deferred
		end

	value (k: K): G is
			-- Item associated with `k';
			-- Return default value if no such item
		require else
			True
		do
			if has (k) then
				Result := item (k)
			end
		end

feature -- Status report

	valid_key (k: K): BOOLEAN is
			-- Is `k' a valid key?
		deferred
		end

	has (k: K): BOOLEAN is
			-- Is there an item associated with `k'?
		deferred
		ensure
			valid_key: Result implies valid_key (k)
		end

feature -- Element change

	replace (v: G; k: K) is
			-- Replace item associated with `k' by `v'.
		require
			has_k: has (k)
		deferred
		ensure
			replaced: item (k) = v
			same_count: count = old count
		end

	put (v: G; k: K) is
			-- Associate `v' with key `k'.
		require
			valid_key: valid_key (k)
		deferred
		ensure
			inserted: has (k) and then item (k) = v
			same_count: (old has (k)) implies (count = old count)
			one_more: (not old has (k)) implies (count = old count + 1)
		end

	put_new (v: G; k: K) is
			-- Associate `v' with key `k'.
		require
			valid_key: valid_key (k)
			new_item: not has (k)
		deferred
		ensure
			one_more: count = old count + 1
			inserted: has (k) and then item (k) = v
		end

	swap (k, l: K) is
			-- Exchange items associated with `k' and `l'.
		require
			valid_k: has (k)
			valid_l: has (l)
		local
			v: G
		do
			v := item (k)
			replace (item (l), k)
			replace (v, l)
		ensure
			same_count: count = old count
			new_k: item (k) = old item (l)
			new_l: item (l) = old item (k)
		end

feature -- Removal

	remove (k: K) is
			-- Remove item associated with `k'.
		require
			valid_key: valid_key (k)
		deferred
		ensure
			same_count: (not old has (k)) implies (count = old count)
			one_less: (old has (k)) implies (count = old count - 1)
			removed: not has (k)
		end

feature -- Iteration

	do_all_with_key (an_action: PROCEDURE [ANY, TUPLE [G, K]]) is
			-- Apply `an_action' to every item.
			-- `an_action' receives the item and its key.
			-- (Semantics not guaranteed if `an_action' changes the structure.)
		require
			an_action_not_void: an_action /= Void
		deferred
		end

	do_if_with_key (an_action: PROCEDURE [ANY, TUPLE [G, K]]; a_test: FUNCTION [ANY, TUPLE [G, K], BOOLEAN]) is
			-- Apply `an_action' to every item that satisfies `a_test'.
			-- `an_action' and `a_test' receive the item and its key.
			-- (Semantics not guaranteed if `an_action' or `a_test' change the structure.)
		require
			an_action_not_void: an_action /= Void
			a_test_not_void: a_test /= Void
		deferred
		end

	there_exists_with_key (a_test: FUNCTION [ANY, TUPLE [G, K], BOOLEAN]): BOOLEAN is
			-- Is `a_test' true for at least one item and its key?
			-- (Semantics not guaranteed if `a_test' changes the structure.)
		require
			a_test_not_void: a_test /= Void
		deferred
		end

	for_all_with_key (a_test: FUNCTION [ANY, TUPLE [G, K], BOOLEAN]): BOOLEAN is
			-- Is `a_test' true for all items and their keys?
			-- (Semantics not guaranteed if `a_test' changes the structure.)
		require
			a_test_not_void: a_test /= Void
		deferred
		end

end
