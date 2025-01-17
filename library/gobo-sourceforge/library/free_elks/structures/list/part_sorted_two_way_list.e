indexing

	description:
		"Two-way lists, kept sorted"
	legal: "See notice at end of class."

	status: "See notice at end of class."
	names: sorted_two_way_list, sorted_struct, sequence;
	representation: linked;
	access: index, cursor, membership, min, max;
	contents: generic;
	date: "$Date: 2008-05-09 08:41:30 +0200 (Fri, 09 May 2008) $"
	revision: "$Revision: 6399 $"

class PART_SORTED_TWO_WAY_LIST [G -> PART_COMPARABLE] inherit

	TWO_WAY_LIST [G]
		undefine
			has, search, is_inserted
		redefine
			prune_all, extend, new_chain
		end

	PART_SORTED_LIST [G]
		undefine
			move, remove, before, go_i_th,
			isfirst, start, finish, readable,
			islast, first, prune, after,
			last, off, prune_all, copy, is_equal
		end

create
	make

create {PART_SORTED_TWO_WAY_LIST}
	make_sublist

feature -- Element change

	extend (v: like item) is
			-- Put `v' at proper position in list.
			-- The cursor ends up on the newly inserted
			-- item.
		do
			search_after (v)
			put_left (v)
			back
		end

feature -- Removal

	prune_all (v: like item) is
			-- Remove all items identical to `v'.
			-- (Reference or object equality,
			-- based on `object_comparison'.)
			-- Leave cursor `off'.
		do
			from
				start
				search (v)
			until
				off or else v < item
			loop
				remove
			end
			if not off then finish; forth end
		end


feature -- Status report

	sorted: BOOLEAN is
			-- is the structures topologically sorted
			-- i.e i < j implies not i_th (i) > i_th (j)
		local
			c: CURSOR
			prev: like item
		do
			Result := True
			if count > 1 then
				from
					c := cursor
					start
					check not off end
					prev := item
					forth
				until
					after or not Result
				loop
					Result := (prev <= item)
					prev := item
					forth
				end
				go_to (c)
			end
		end

feature -- Transformation

	sort is
			-- sort the list
			-- Has O(`count' * log (`count')) complexity.
			--| Uses comb-sort (BYTE February '91)
		local
			no_change: BOOLEAN
			gap: INTEGER
			left_cell, cell: like first_element
			left_cell_item, cell_item: like item
		do
			if not is_empty then
				from
					gap := count * 10 // 13
				until
					gap = 0
				loop
					from
						no_change := False
						go_i_th (1 + gap)
					until
						no_change
					loop
						no_change := True
						from
							left_cell := first_element
							cell := active -- position of first_element + gap
						until
							cell = Void
						loop
							if left_cell /= Void then
								left_cell_item := left_cell.item
								cell_item := cell.item
								if cell_item < left_cell_item then
										-- Swap `left_cell_item' with `cell_item'
									no_change := False
									cell.put (left_cell_item)
									left_cell.put (cell_item)
								end
								left_cell := left_cell.right
							end
							cell := cell.right
						end
					end
					gap := gap * 10 // 13
				end
			end
		end

feature {PART_SORTED_TWO_WAY_LIST} -- Implementation

	new_chain: like Current is
			-- A newly created instance of the same type.
			-- This feature may be redefined in descendants so as to
			-- produce an adequately allocated and initialized object.
		do
			create Result.make
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

end -- class PART_SORTED_TWO_WAY_LIST


