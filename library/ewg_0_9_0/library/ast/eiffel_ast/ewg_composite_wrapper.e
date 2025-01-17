indexing

	description:

		"Deferred common base for classes that wrap C composites"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/11/11 17:25:31 $"
	revision: "$Revision: 1.10 $"

class EWG_COMPOSITE_WRAPPER

inherit

	EWG_ABSTRACT_WRAPPER
		rename
			make as make_abstract_wrapper
		end

	EWG_SHARED_STRING_EQUALITY_TESTER
		export {NONE} all end

feature {NONE} -- Initialization

	make (a_mapped_eiffel_name: STRING; a_header_file_name: STRING; a_members: like members) is
		require
			a_mapped_eiffel_name_not_void: a_mapped_eiffel_name /= Void
			a_mapped_eiffel_name_not_empty: not a_mapped_eiffel_name.is_empty
			a_header_file_name_not_void: a_header_file_name /= Void
			a_header_file_name_not_empty: not a_header_file_name.is_empty
			a_members_not_void: a_members /= Void
		do
			make_abstract_wrapper (a_mapped_eiffel_name, a_header_file_name)
			create members.make_default
			adopt_members (a_members)
			members := a_members
		ensure
			mapped_eiffel_name_set: mapped_eiffel_name = a_mapped_eiffel_name
			header_file_name_set: header_file_name = a_header_file_name
			members_set: members = a_members
		end

feature

	members: DS_ARRAYED_LIST [EWG_MEMBER_WRAPPER]
			-- The member wrapper of the composite.
			-- This does not need to be a 1:1 mapping onto
			-- the composite to wrap. For example, some members
			-- of a struct might be ignored. Or a runlength string
			-- consisting of a "char*" and a "int" might be wrapped
			-- using a single EWG_MEMBER_WRAPPER object.


feature {ANY}

	extend_members (a_members: DS_BILINEAR [EWG_MEMBER_WRAPPER]) is
			-- Extend `members' with `a_members'
		require
			a_members_not_void: a_members /= Void
		do
			adopt_members (a_members)
			members.append_last (a_members)
		ensure
			members_extended: True -- TODO:
			a_members_have_current_as_composite: True -- TODO:
		end

	add_member (a_member: EWG_MEMBER_WRAPPER) is
			-- Extend `members' with `a_member'
		require
			a_member_not_void: a_member /= Void
		do
			a_member.set_composite_wrapper (Current)
			members.force_last (a_member)
		ensure
			members_extended: True -- TODO:
			a_member_has_current_as_composite: a_member.composite_wrapper = Current
		end

	resolve_feature_name_clashes is
			-- Make sure no two features of the Eiffel class(es) this
			-- class generates will have equal names.
		local
			wrapper_cs: DS_LINEAR_CURSOR [EWG_MEMBER_WRAPPER]
			feature_name_set: DS_HASH_SET [STRING]

		do
			create feature_name_set.make (members.count * 2)
			feature_name_set.set_equality_tester (string_equality_tester)
			from
				wrapper_cs := members.new_cursor
				wrapper_cs.start
			until
				wrapper_cs.off
			loop
				from
				until
					not has_set_name_from_list (feature_name_set, wrapper_cs.item.proposed_feature_name_list)
				loop
					wrapper_cs.item.rename_mapped_eiffel_name
				end
				feature_name_set.append_last (wrapper_cs.item.proposed_feature_name_list)

				wrapper_cs.forth
			end
		end

	has_set_name_from_list (a_set: DS_SET [STRING]; a_list: DS_LINEAR [STRING]): BOOLEAN is
			-- Does `a_set' have an item name equal to an item name from `a_list' ?
		require
			a_set_not_void: a_set /= Void
			a_set_has_no_void_item: not a_set.has (Void)
			a_list_not_void: a_list /= Void
			a_list_has_no_void_item: not a_list.has (Void)
		local
			cs: DS_LINEAR_CURSOR [STRING]
		do
			from
				cs := a_list.new_cursor
				cs.start
			until
				cs.off
			loop
				if a_set.has (cs.item) then
					Result := True
					cs.go_after
				else
					cs.forth
				end
			end
		end

feature {NONE}

	adopt_members (a_members: DS_BILINEAR [EWG_MEMBER_WRAPPER]) is
		require
			a_members_not_void: a_members /= Void
		local
			cs: DS_BILINEAR_CURSOR [EWG_MEMBER_WRAPPER]
		do
			from
				cs := a_members.new_cursor
				cs.start
			until
				cs.off
			loop
				cs.item.set_composite_wrapper (Current)
				cs.forth
			end
		ensure
			members_have_current_as_composite_wrapper: members_have_current_as_composite_wrapper (a_members)
		end


feature {ANY} -- Assertions

	members_have_current_as_composite_wrapper (a_members: DS_BILINEAR [EWG_MEMBER_WRAPPER]): BOOLEAN is
			-- All items in `members' have member.composite_wrapper = Current
		local
			cs: DS_BILINEAR_CURSOR [EWG_MEMBER_WRAPPER]
		do
			Result := True
			from
				cs := a_members.new_cursor
				cs.start
			until
				cs.off
			loop
				if cs.item.composite_wrapper /= Current then
					Result := False
					cs.go_after
				end
				cs.forth
			end
		end

invariant

	members_not_void: members /= Void
	members_have_current_as_composite_wrapper: members_have_current_as_composite_wrapper (members)

end
