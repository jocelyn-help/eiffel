indexing

	description: "Unbounded stacks implemented as linked lists"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	names: linked_stack, dispenser, linked_list;
	representation: linked;
	access: fixed, lifo, membership;
	contents: generic;
	date: "$Date: 2008-11-09 11:56:12 +0100 (Sun, 09 Nov 2008) $"
	revision: "$Revision: 6548 $"

class LINKED_STACK [G] inherit

	STACK [G]
		undefine
			replace, copy, is_equal
		select
			remove, put, item
		end

	LINKED_LIST [G]
		rename
			item as ll_item,
			remove as ll_remove,
			put as ll_put
		export
			{NONE} all
			{LINKED_STACK}
				cursor, start, forth, go_to, index, first_element,
				last_element, valid_cursor, ll_item
			{ANY}
				count, readable, writable, extendible,
				make, wipe_out, off, after
		undefine
			readable, writable, fill,
			append, linear_representation,
			prune_all, is_inserted
		redefine
			extend, force, duplicate
		end

create

	make

feature -- Access

	item: G is
			-- Item at the first position
		local
			f: like first_element
		do
			check
				not_empty: not is_empty
			end
			f := first_element
			check
				f_attached: f /= Void
			end
			Result := f.item
		end

feature -- Element change

	force (v: like item) is
			-- Push `v' onto top.
		do
			put_front (v)
		end

	extend (v: like item) is
			-- Push `v' onto top.
		do
			put_front (v)
		end

	put (v: like item) is
		do
			put_front (v)
		end

feature -- Removal

	remove is
			-- Remove item on top.
		do
			start
			ll_remove
		end

feature -- Conversion

	linear_representation: ARRAYED_LIST [G] is
			-- Representation as a linear structure
			-- (order is reverse of original order of insertion)
		local
			old_cursor: CURSOR
		do
			old_cursor := cursor
			from
				create Result.make (count)
				start
			until
				after
			loop
				Result.extend (ll_item)
				forth
			end
			go_to (old_cursor)
		end

feature -- Duplication

	duplicate (n: INTEGER): ?like Current is
			-- New stack containing the `n' latest items inserted
			-- in current stack.
			-- If `n' is greater than `count', identical to current stack.
		require else
			positive_argument: n > 0
		local
			counter: INTEGER
			old_cursor: CURSOR
			list: LINKED_LIST [G]
		do
			if not is_empty then
				old_cursor := cursor
				from
					create Result.make
					list := Result
					start
				until
					after or counter = n
				loop
					list.finish
					list.put_right (ll_item)
					counter := counter + 1
					forth
				end
				go_to (old_cursor)
			end
		end

indexing
	library:	"EiffelBase: Library of reusable components for Eiffel."
	copyright:	"Copyright (c) 1984-2008, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"







end -- class LINKED_STACK



