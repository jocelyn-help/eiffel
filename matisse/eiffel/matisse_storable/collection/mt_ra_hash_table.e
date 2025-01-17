note
	description: "MATISSE-Eiffel Binding: define the HASH_TABLE class with key of type MtAttribute and value of type MtRelationship"
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
	MT_RA_HASH_TABLE [G -> MT_OBJECT, H -> HASHABLE]

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
		local
			mt_obj: MT_STORABLE
		do
			relationship.persister.mark_container_modified (oid)
			ht_put (new, key)
			if is_persistent and then inserted then
				mt_obj ?= new
				if mt_obj /= Void then
					check_persistence (mt_obj)
				end
			end
		end

	force (new: G; key: H)
		local
			mt_obj: MT_STORABLE
		do
			relationship.persister.mark_container_modified (oid)
			ht_force (new, key)
			if is_persistent then
				mt_obj ?= new
				if mt_obj /= Void then
					check_persistence (mt_obj)
				end
			end
		end

	extend (new: G; key: H)
		local
			mt_obj: MT_STORABLE
		do
			relationship.persister.mark_container_modified (oid)
			ht_extend (new, key)
			if is_persistent then
				mt_obj ?= new
				if mt_obj /= Void then
					check_persistence (mt_obj)
				end
			end
		end

	replace (new: G; key: H)
		local
			mt_obj: MT_STORABLE
		do
			relationship.persister.mark_container_modified (oid)
			ht_replace (new, key)
			if is_persistent and then replaced then
				mt_obj ?= new
				if mt_obj /= Void then
					check_persistence (mt_obj)
				end
			end
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
							ht_put (default_value, all_keys.item (i))
						else
							ht_put (all_values.item (value_indexes.item (i)), all_keys.item (i))
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
			key_att, index_att, has_default_att: MT_ATTRIBUTE
			value_rs: MT_RELATIONSHIP
			default_key: H
			default_value: G
			i, values_count, index, key_count: INTEGER
			indexes: ARRAY [INTEGER]
			mt_keys_type, mt_values_type: INTEGER
			a_linear: ARRAYED_LIST [MT_OBJECT]
		do
			mt_keys_type := mt_property_type_of_keys
			mt_values_type := mt_property_type_of_values

			create all_keys.make (1, count)
			create all_values.make (1, count)
			create indexes.make (1, count)
			values_count := 0
			from
				i := 0
			until
				i = keys.count
					-- item at upper is used for default key
			loop
				if keys.item (i) /= default_key then
					key_count := key_count + 1
					all_keys.put (keys.item (i), key_count)
					if content.item (i) = default_value then
						indexes.put (0, key_count)
					else
						index := first_index_of (content.item (i), all_values)
						if index = 0 then
							values_count := values_count + 1
							indexes.put (values_count, key_count)
							all_values.put (content.item (i), values_count)
						else
							indexes.put (index, key_count)
						end
					end
				end
				i := i + 1
			end

			create has_default_att.make_from_names ("has_default", "HASH_TABLE", persister.mtdb)
			if has_default then
				has_default_att.set_boolean_value (Current, True)
				all_keys.put (default_key, count)
				if default_key_value = default_value then
					indexes.put (0, count)
				else
					index := first_index_of (default_key_value, all_values)
					if index = 0 then
						values_count := values_count + 1
						indexes.put (values_count, count)
						all_values.put (default_key_value, values_count)
					else
						indexes.put (index, count)
					end
				end
			else
				has_default_att.set_boolean_value (Current, False)
			end

			create index_att.make_from_names ("value_index", "HASH_TABLE", persister.mtdb)
			index_att.set_integer_array_value (Current, indexes)

			create key_att.make_from_names ("att_keys", "HASH_TABLE", persister.mtdb)
			key_att.set_dynamic_value (Current, all_keys)

			create value_rs.make_from_names ("obj_values", "HASH_TABLE", persister.mtdb)
			if values_count = 0 then
				create all_values.make (1, 0)
				a_linear ?= all_values.linear_representation
			else
				a_linear ?= all_values.subarray (1, values_count).linear_representation
			end
			if a_linear /= Void then
				value_rs.set_successors (Current, a_linear)
			end
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
			rel: MT_MULTI_RELATIONSHIP
		do
			create rel.make_from_names ("obj_values", "HASH_TABLE", persister.mtdb)
			Result ?= successors (rel)
		end
end -- class MT_RA_HASH_TABLE

