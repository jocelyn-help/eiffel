note
	description: "MATISSE-Eiffel Binding: define the HASH_TABLE class with key and value of type MtAttribute"
	license: "[
	The contents of this file are subject to the Matisse Interfaces 
	Public License Version 1.0 (the 'License'); you may not use this 
	file except in compliance with the License. You may obtain a copy of
	the License at http://www.matisse.com/pdf/developers/MIPL.html

	Software distributed under the License is distributed on an 'AS IS'
	basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See 
	the License for the specific language governing rights and
	limitations under the License.

	The Original Code was created by Matisse Software Inc. 
	and its successors.

	The Initial Developer of the Original Code is Matisse Software Inc. 
	Portions created by Matisse Software are Copyright (C) 
	Matisse Software Inc. All Rights Reserved.

	Contributor(s): Kazuhiro Nakao
                   Didier Cabannes
                   Neal Lester
                   Luca Paganotti
	]"

class
	MT_AA_HASH_TABLE [G, H -> HASHABLE]

inherit
	MT_HASH_TABLE [G, H]
		redefine
			load_successors,
			store_updates,
			get_all_keys,
			get_all_values,
			put, force, extend,
			replace, replace_key
		end

create
	make

feature -- Redefinition of HASH_TABLE API

	put (new: G; key: H)
		do
			relationship.persister.mark_container_modified (oid)
			ht_put (new, key)
				-- ht_put is necessary for 'load_successors'
		end

	force (new: G; key: H)
		do
			relationship.persister.mark_container_modified (oid)
			ht_force (new, key)
		end

	extend (new: G; key: H)
		do
			relationship.persister.mark_container_modified (oid)
			ht_extend (new, key)
		end

	replace (new: G; key: H)
		do
			relationship.persister.mark_container_modified (oid)
			ht_replace (new, key)
		end

	replace_key (new_key: H; old_key: H)
		do
			relationship.persister.mark_container_modified (oid)
			ht_replace_key (new_key, old_key)
		end

feature

	load_successors
		local
			all_keys: ARRAY [H]
			all_values: ARRAY [G]
			value_indexes: ARRAY [INTEGER]
			i: INTEGER
			default_value: G
		do
	--		SM, 01/25/99: do not see the use of this line and worst, it implies errors
	--		relationship.persister.clear_all_properties_when_obsolete_wo_class (predecessor)
			if not successors_loaded then
				successors_loaded := True
				if is_persistent then
					from
						start_loading
						all_keys := get_all_keys
						all_values := get_all_values
						value_indexes := get_value_indexes
						i := all_keys.lower
					until
						i > all_keys.upper
					loop
						if value_indexes.item (i) = 0 then
							ht_force (default_value, all_keys.item (i))
						else
							ht_force (all_values.item (value_indexes.item (i)), all_keys.item (i))
						end
						i := i + 1
					end
				end
			end
		end

	store_updates
		local
			all_keys: ARRAY [H]
			all_values: ARRAY [G]
			key_att, value_att, index_att, has_default_att: MT_ATTRIBUTE
			default_key: H
			i, j: INTEGER
			indexes: ARRAY [INTEGER]
		do
			create all_keys.make (1, count)
			create all_values.make (1, count)
			create indexes.make (1, count)
			create key_att.make_from_names ("att_keys", "HASH_TABLE", persister.mtdb)
			create value_att.make_from_names ("att_values", "HASH_TABLE", persister.mtdb)
			create index_att.make_from_names ("value_index", "HASH_TABLE", persister.mtdb)
			from
				j := 1
				i := 0
			until
				i = keys.count
			loop
				if keys.item (i) /= default_key then
					all_keys.put (keys.item (i), j)
					all_values.put (content.item (i), j)
					indexes.put (j, j)
					j := j + 1
				end
				i := i + 1
			end
			create has_default_att.make ("HASH_TABLE__has_default", persister.mtdb)
			if has_default then
				check
					i = keys.count - 1
					j = all_keys.upper
				end
				has_default_att.set_boolean_value (Current, True)
				all_keys.put (default_key, j)
				all_values.put (default_key_value, j)
				indexes.put (j, j)
			else
				has_default_att.set_boolean_value (Current, False)
			end

			key_att.set_dynamic_value (Current, all_keys)
			value_att.set_dynamic_value (Current, all_values)
			index_att.set_dynamic_value (Current, indexes)
		end

feature {NONE}

	get_all_keys: ARRAY [H]
		local
			att: MT_ATTRIBUTE
		do
			create att.make_from_names ("att_keys", "HASH_TABLE", persister.mtdb)
			Result ?= att.get_value (Current)
		end

	get_all_values: ARRAY [G]
		local
			att: MT_ATTRIBUTE
		do
			create att.make_from_names ("att_values", "HASH_TABLE", persister.mtdb)
			Result ?= att.get_value (Current)
		end

end -- class MT_AA_HASH_TABLE

