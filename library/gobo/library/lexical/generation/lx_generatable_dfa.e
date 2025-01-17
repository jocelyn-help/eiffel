indexing

	description:

		"DFA equipped with lexical analyzer generator"

	library: "Gobo Eiffel Lexical Library"
	copyright: "Copyright (c) 1999-2004, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-10-06 09:53:14 +0200 (Mon, 06 Oct 2008) $"
	revision: "$Revision: 6531 $"

deferred class LX_GENERATABLE_DFA

inherit

	LX_DFA
		rename
			initialize as initialize_dfa
		end

	LX_TABLES
		export
			{LX_TABLES} all
			{ANY}
				to_tables
		end

	UT_CHARACTER_CODES
		export {NONE} all end

	KL_IMPORTED_INTEGER_ROUTINES

	KL_IMPORTED_STRING_ROUTINES

	UT_IMPORTED_FORMATTERS

feature {NONE} -- Initialization

	initialize (a_description: LX_DESCRIPTION) is
			-- Initialize DFA with information found in `a_description'.
		require
			a_description_not_void: a_description /= Void
		local
			max: INTEGER
			equiv_classes: LX_EQUIVALENCE_CLASSES
		do
			input_filename := a_description.input_filename
			if input_filename = Void then
				input_filename := Default_input_filename
			end
			characters_count := a_description.characters_count
			array_size := a_description.array_size
			inspect_used := a_description.inspect_used
			actions_separated := a_description.actions_separated
			eiffel_code := a_description.eiffel_code
			eiffel_header := a_description.eiffel_header
			bol_needed := a_description.bol_needed
			pre_action_used := a_description.pre_action_used
			post_action_used := a_description.post_action_used
			pre_eof_action_used := a_description.pre_eof_action_used
			post_eof_action_used := a_description.post_eof_action_used
			line_pragma := a_description.line_pragma
			yy_start_conditions := a_description.start_conditions.names
			build_rules (a_description.rules)
			build_eof_rules (a_description.eof_rules, 0, yy_start_conditions.count - 1)
			max := characters_count
			equiv_classes := a_description.equiv_classes
			if equiv_classes /= Void and then equiv_classes.built then
				yy_ec := equiv_classes.to_array (0, max)
				yyNull_equiv_class := yy_ec.item (max)
				max := equiv_classes.count
			else
				yyNull_equiv_class := max
			end
			yyNb_rules := yy_rules.upper
			yyEnd_of_buffer := yyNb_rules + 1
			yyLine_used := a_description.line_used
			yyPosition_used := a_description.position_used
				-- Symbols start at 1 and NULL transitions
				-- are indexed by `maximum_symbol'.
			initialize_dfa (a_description.start_conditions, 1, max)
		end

	put_eob_state is
			-- Create an end-of-buffer state and insert it to current DFA.
		require
			not_built: states.count = start_states_count
			not_full: not states.is_full
		local
			eob_state: LX_DFA_STATE
			nfa_states: DS_ARRAYED_LIST [LX_NFA_STATE]
			a_rule: LX_RULE
		do
			create nfa_states.make (0)
			create eob_state.make (nfa_states, minimum_symbol, maximum_symbol)
			create a_rule.make_default (yyEnd_of_buffer)
			eob_state.accepted_rules.force_first (a_rule)
			states.put_last (eob_state)
			eob_state.set_id (states.count)
		end

feature -- Generation

	new_scanner: YY_SCANNER is
			-- New scanner corresponding to current DFA
		deferred
		ensure
			scanner_not_void: Result /= Void
		end

	print_scanner (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for corresponding scanner to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		do
			print_eiffel_header (a_file)
			a_file.put_string ("%Nfeature -- Status report%N%N")
			print_status_report_routines (a_file)
			a_file.put_string ("%Nfeature {NONE} -- Implementation%N%N")
			print_build_tables (a_file)
			a_file.put_character ('%N')
			print_actions (a_file)
			a_file.put_character ('%N')
			print_eof_actions (a_file)
			a_file.put_string ("%Nfeature {NONE} -- Table templates%N%N")
			print_eiffel_tables (a_file)
			a_file.put_string ("%Nfeature {NONE} -- Constants%N%N")
			print_constants (a_file)
			a_file.put_string ("%Nfeature -- User-defined features%N%N")
			print_eiffel_code (a_file)
		end

	print_backing_up_report (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print a backing-up report to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			a_state: LX_DFA_STATE
		do
			from
				i := start_states_count + 1
				nb := states.count
			until
				i > nb
			loop
				a_state := states.item (i)
				if not a_state.is_accepting then
					a_file.put_string ("State #")
					a_file.put_integer (a_state.id)
					a_file.put_string (" is non-accepting -%N")
						-- Identify the state
					print_rule_line_numbers (a_state, a_file)
						-- Identify it further using the
						-- out- and jam-transitions.
					print_transitions (a_state, a_file)
					a_file.put_character ('%N')
				end
				i := i + 1
			end
		end

feature {NONE} -- Generation

	print_eiffel_header (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print user-defined eiffel header to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
		do
			if eiffel_header /= Void then
				nb := eiffel_header.count
				from
					i := 1
				until
					i > nb
				loop
					a_file.put_string (eiffel_header.item (i))
					i := i + 1
				end
			end
		end

	print_status_report_routines (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for `valid_start_condition' to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		do
			a_file.put_string ("%Tvalid_start_condition (sc: INTEGER): BOOLEAN is%N%
				%%T%T%T-- Is `sc' a valid start condition?%N%
				%%T%Tdo%N%
				%%T%T%TResult := ")
			inspect yy_start_conditions.count
			when 0 then
				a_file.put_string ("False")
			when 1 then
				a_file.put_string ("(sc = ")
				a_file.put_string (yy_start_conditions.item (yy_start_conditions.lower))
				a_file.put_character (')')
			else
				a_file.put_character ('(')
				a_file.put_string (yy_start_conditions.item (yy_start_conditions.lower))
				a_file.put_string (" <= sc and sc <= ")
				a_file.put_string (yy_start_conditions.item (yy_start_conditions.upper))
				a_file.put_character (')')
			end
			a_file.put_string ("%N%T%Tend%N")
		end

	print_build_tables (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for `yy_build_tables' to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		deferred
		end

	print_actions (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for actions to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
		do
			a_file.put_string ("%Tyy_execute_action (yy_act: INTEGER) is%N%
				%%T%T%T-- Execute semantic action.%N%
				%%T%Tdo%N")
			if inspect_used then
				print_inspect_actions (a_file)
			else
				print_binary_search_actions (a_file, yy_rules.lower, yy_rules.upper)
			end
			if post_action_used then
				a_file.put_string ("%T%T%Tpost_action%N")
			end
			if bol_needed then
				a_file.put_string ("%T%T%Tyy_set_beginning_of_line%N")
			end
			a_file.put_string ("%T%Tend%N")
			if actions_separated then
				nb := yy_rules.upper
				from
					i := yy_rules.lower
				until
					i > nb
				loop
					a_file.put_character ('%N')
					print_action_routine (a_file, yy_rules.item (i))
					i := i + 1
				end
			end
		end

	print_inspect_actions (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for actions to `a_file'.
			-- The generated code uses an inspect instruction
			-- to find out which action to execute.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			rule, next_rule: LX_RULE
			not_shared: BOOLEAN
		do
			a_file.put_string ("%T%T%Tinspect yy_act%N")
			nb := yy_rules.upper
			from
				i := yy_rules.lower
			until
				i > nb
			loop
				rule := yy_rules.item (i)
				a_file.put_string ("when ")
				a_file.put_integer (rule.id)
				if not rule.has_trail_context then
					from
						i := i + 1
						not_shared := False
					until
						not_shared or i > nb
					loop
						next_rule := yy_rules.item (i)
						if rule.action = next_rule.action and not (next_rule.has_trail_context or yyLine_used or yyPosition_used) then
							a_file.put_string (", ")
							a_file.put_integer (next_rule.id)
							i := i + 1
						elseif next_rule.has_trail_context or yyLine_used or yyPosition_used then
								-- Warning: ("action duplicated due to trailing context or options line or position")
							not_shared := True
						else
							not_shared := True
						end
					end
				else
						-- `rule' has trailing context.
					i := i + 1
					if i <= nb then
						next_rule := yy_rules.item (i)
						if next_rule.action = rule.action then
								-- Warning: ("action duplicated due to trailing context")
						end
					end
				end
				a_file.put_string (" then%N")
				print_action_call (a_file, rule)
			end
			a_file.put_string ("%T%T%Telse%N")
			if pre_action_used then
				a_file.put_string ("%T%T%T%Tpre_action%N")
			end
			a_file.put_string ("%T%T%T%Tlast_token := yyError_token%N%
				%%T%T%T%Tfatal_error (%"fatal scanner internal error: no action found%")%N%
				%%T%T%Tend%N")
		end

	print_binary_search_actions (a_file: KI_TEXT_OUTPUT_STREAM; l, u: INTEGER) is
			-- Print code for actions indexed from `l' to `u'
			-- to `a_file'. The generated code uses binary search
			-- to find out which action to execute.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
			l_large_enough: l >= yy_rules.lower
			l_small_enough: l <= u
			u_small_enough: u <= yy_rules.upper
		local
			t: INTEGER
		do
			if l = u then
				print_action_call (a_file, yy_rules.item (l))
			elseif l + 1 = u then
				a_file.put_string ("if yy_act = ")
				a_file.put_integer (l)
				a_file.put_string (" then%N")
				print_action_call (a_file, yy_rules.item (l))
				a_file.put_string ("else%N")
				print_action_call (a_file, yy_rules.item (u))
				a_file.put_string ("end%N")
			else
				t := l + (u - l) // 2
				a_file.put_string ("if yy_act <= ")
				a_file.put_integer (t)
				a_file.put_string (" then%N")
				print_binary_search_actions (a_file, l, t)
				a_file.put_string ("else%N")
				print_binary_search_actions (a_file, t + 1, u)
				a_file.put_string ("end%N")
			end
		end

	print_action_call (a_file: KI_TEXT_OUTPUT_STREAM; a_rule: LX_RULE) is
			-- Print code for `a_rule's action call to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
			a_rule_not_void: a_rule /= Void
		do
			if actions_separated then
				a_file.put_string ("%T%T--|#line ")
				if line_pragma then
					a_file.put_integer (a_rule.line_nb)
				else
					a_file.put_string ("<not available>")
				end
				a_file.put_string (" %"")
				a_file.put_string (input_filename)
				a_file.put_string ("%"%N%Tyy_execute_action_")
				a_file.put_integer (a_rule.id)
				a_file.put_character ('%N')
			else
				print_action_body (a_file, a_rule)
			end
		end

	print_action_routine (a_file: KI_TEXT_OUTPUT_STREAM; a_rule: LX_RULE) is
			-- Print code for `a_rule's action routine to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
			a_rule_not_void: a_rule /= Void
		do
			a_file.put_string ("%Tyy_execute_action_")
			a_file.put_integer (a_rule.id)
			a_file.put_string (" is%N%T%T%T--|#line ")
			if line_pragma then
				a_file.put_integer (a_rule.line_nb)
			else
				a_file.put_string ("<not available>")
			end
			a_file.put_string (" %"")
			a_file.put_string (input_filename)
			a_file.put_string ("%"%N%T%Tdo%N")
			print_action_body (a_file, a_rule)
			a_file.put_string ("%N%T%Tend%N")
		end

	print_action_body (a_file: KI_TEXT_OUTPUT_STREAM; a_rule: LX_RULE) is
			-- Print code for `a_rule's action body to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
			a_rule_not_void: a_rule /= Void
		local
			line_count, column_count, head_count: INTEGER
		do
			if a_rule.has_trail_context then
					-- `rule' has trailing context.
				if a_rule.trail_count >= 0 then
						-- The trail has a fixed size.
					a_file.put_string ("%Tyy_end := yy_end - ")
					a_file.put_integer (a_rule.trail_count)
					a_file.put_character ('%N')
				elseif a_rule.head_count >= 0 then
						-- The head has a fixed size.
					a_file.put_string ("%Tyy_end := yy_start + yy_more_len + ")
					a_file.put_integer (a_rule.head_count)
					a_file.put_character ('%N')
				else
						-- The rule has trailing context and both
						-- the head and trail have variable size.
						-- The work is done using another mechanism
						-- (variable_trail_context).
						-- TODO: Report performance degradation.
				end
			end
			if yyLine_used then
				line_count := a_rule.line_count
				column_count := a_rule.column_count
				if line_count = 0 then
					if column_count > 0 then
						a_file.put_string ("%Tyy_column := yy_column + ")
						a_file.put_integer (column_count)
						a_file.put_character ('%N')
					elseif column_count /= 0 then
							-- yy_column := yy_column + text_count
						a_file.put_string ("%Tyy_column := yy_column + yy_end - yy_start - yy_more_len%N")
					end
				elseif line_count > 0 then
					if column_count = 0 then
						a_file.put_string ("%Tyy_line := yy_line + ")
						a_file.put_integer (line_count)
						a_file.put_character ('%N')
						a_file.put_string ("%Tyy_column := 1%N")
					elseif column_count > 0 then
						a_file.put_string ("%Tyy_line := yy_line + ")
						a_file.put_integer (line_count)
						a_file.put_character ('%N')
						a_file.put_string ("%Tyy_column := ")
						a_file.put_integer (column_count)
						a_file.put_string (" + 1%N")
					else
						a_file.put_string ("yy_set_column (")
						a_file.put_integer (line_count)
						a_file.put_string (")%N")
					end
				else
					if column_count >= 0 then
						a_file.put_string ("yy_set_line (")
						a_file.put_integer (column_count)
						a_file.put_string (")%N")
					else
						a_file.put_string ("yy_set_line_column%N")
					end
				end
			end
			if yyPosition_used then
				head_count := a_rule.head_count
				if head_count > 0 then
					a_file.put_string ("%Tyy_position := yy_position + ")
					a_file.put_integer (head_count)
					a_file.put_character ('%N')
				elseif head_count /= 0 then
						-- The next line means: "yy_position := yy_position + text_count"
					a_file.put_string ("%Tyy_position := yy_position + yy_end - yy_start - yy_more_len%N")
				end
			end
			if pre_action_used then
				a_file.put_string ("pre_action%N")
			end
			a_file.put_string ("--|#line ")
			if line_pragma then
				a_file.put_integer (a_rule.line_nb)
			else
				a_file.put_string ("<not available>")
			end
			a_file.put_string (" %"")
			a_file.put_string (input_filename)
			a_file.put_character ('%"')
			a_file.put_new_line
			a_file.put_line ("debug (%"GELEX%")")
			a_file.put_string ("%Tstd.error.put_line (%"Executing scanner user-code from file '")
			a_file.put_string (input_filename)
			a_file.put_string ("' at line ")
			if line_pragma then
				a_file.put_integer (a_rule.line_nb)
			else
				a_file.put_string ("<not available>")
			end
			a_file.put_line ("%")")
			a_file.put_line ("end")
			a_file.put_string (a_rule.action.out)
			a_file.put_new_line
		end

	print_eof_actions (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for end-of-file actions to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			rule: LX_RULE
			actions: DS_ARRAYED_LIST [DS_PAIR [DP_COMMAND, DS_LINKED_LIST [LX_RULE]]]
			action: DP_COMMAND
			j, nb_actions: INTEGER
			a_pair: DS_PAIR [DP_COMMAND, DS_LINKED_LIST [LX_RULE]]
			rule_list: DS_LINKED_LIST [LX_RULE]
			rule_cursor: DS_LINKED_LIST_CURSOR [LX_RULE]
		do
			a_file.put_string ("%Tyy_execute_eof_action (yy_sc: INTEGER) is%N%
				%%T%T%T-- Execute EOF semantic action.%N%T%Tdo%N")
			if pre_eof_action_used then
				a_file.put_string ("%T%T%Tpre_eof_action%N")
			end
			from
				i := yy_eof_rules.lower
				nb := yy_eof_rules.upper
				create actions.make (yy_eof_rules.count)
			until
				i > nb
			loop
				rule := yy_eof_rules.item (i)
				if rule /= Void then
					action := rule.action
					from
						j := 1
						nb_actions := actions.count
					until
						j > nb_actions or else actions.item (j).first = action
					loop
						j := j + 1
					end
					if j <= nb_actions then
						rule_list := actions.item (j).second
					else
						create rule_list.make
						create a_pair.make (action, rule_list)
						actions.put_last (a_pair)
					end
					rule_list.put_last (rule)
				end
				i := i + 1
			end
			nb_actions := actions.count
			if nb_actions > 0 then
				a_file.put_string ("%T%T%Tinspect yy_sc%N")
				from
					j := 1
				until
					j > nb_actions
				loop
					rule_list := actions.item (j).second
					from
						rule_cursor := rule_list.new_cursor
						rule_cursor.start
						rule := rule_cursor.item
						a_file.put_string ("when ")
						a_file.put_integer (rule.id)
						rule_cursor.forth
					until
						rule_cursor.after
					loop
						a_file.put_string (", ")
						a_file.put_integer (rule_cursor.item.id)
						rule_cursor.forth
					end
					a_file.put_string (" then%N")
					a_file.put_string ("--|#line ")
					if line_pragma then
						a_file.put_integer (rule.line_nb)
					else
						a_file.put_string ("<not available>")
					end
					a_file.put_string (" %"")
					a_file.put_string (input_filename)
					a_file.put_character ('%"')
					a_file.put_new_line
					a_file.put_line ("debug (%"GELEX%")")
					a_file.put_string ("%Tstd.error.put_line (%"Executing scanner user-code from file '")
					a_file.put_string (input_filename)
					a_file.put_string ("' at line ")
					if line_pragma then
						a_file.put_integer (rule.line_nb)
					else
						a_file.put_string ("<not available>")
					end
					a_file.put_line ("%")")
					a_file.put_line ("end")
					a_file.put_string (rule.action.out)
					a_file.put_new_line
					j := j + 1
				end
				a_file.put_string ("%T%T%Telse%N%
					%%T%T%T%Tterminate%N%
					%%T%T%Tend%N")
			else
				a_file.put_string ("%T%T%Tterminate%N")
			end
			if post_eof_action_used then
				a_file.put_string ("%T%T%Tpost_eof_action%N")
			end
			a_file.put_string ("%T%Tend%N")
		end

	print_eiffel_tables (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print Eiffel code for DFA tables to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		deferred
		end

	print_constants (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print code for constants to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
		do
			a_file.put_string ("%TyyNb_rules: INTEGER is ")
			a_file.put_integer (yyNb_rules)
			a_file.put_string ("%N%T%T%T-- Number of rules%N%N%
					%%TyyEnd_of_buffer: INTEGER is ")
			a_file.put_integer (yyEnd_of_buffer)
			a_file.put_string ("%N%T%T%T-- End of buffer rule code%N%N%
					%%TyyLine_used: BOOLEAN is ")
			BOOLEAN_FORMATTER_.put_eiffel_boolean (a_file, yyLine_used)
			a_file.put_string ("%N%T%T%T-- Are line and column numbers used?%N%N%
					%%TyyPosition_used: BOOLEAN is ")
			BOOLEAN_FORMATTER_.put_eiffel_boolean (a_file, yyPosition_used)
			a_file.put_string ("%N%T%T%T-- Is `position' used?%N%N")
			nb := yy_start_conditions.upper
			from
				i := yy_start_conditions.lower
			until
				i > nb
			loop
				a_file.put_character ('%T')
				a_file.put_string (yy_start_conditions.item (i))
				a_file.put_string (": INTEGER is ")
				a_file.put_integer (i)
				a_file.put_character ('%N')
				i := i + 1
			end
			a_file.put_string ("%T%T%T-- Start condition codes%N")
		end

	print_eiffel_code (a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print user-defined eiffel code to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		do
			if eiffel_code /= Void then
				a_file.put_string (eiffel_code)
			end
		end

	print_eiffel_array (a_name: STRING; a_table: ARRAY [INTEGER]; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print Eiffel code for `a_table' named `a_name' to `a_file'.
		require
			a_name_not_void: a_name /= Void
			a_table_not_void: a_table /= Void
			zero_based_table: a_table.lower = 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, j, k, nb: INTEGER
			a_table_upper: INTEGER
		do
			a_file.put_character ('%T')
			a_file.put_string (a_name)
			a_file.put_string (": SPECIAL [INTEGER] is%N")
			if array_size = 0 then
				nb := 1
			else
				nb := a_table.count // array_size + 1
			end
			if nb = 1 then
				a_file.put_string ("%T%Tonce%N%T%T%TResult := yy_fixed_array (<<%N")
				ARRAY_FORMATTER_.put_integer_array (a_file, a_table, a_table.lower, a_table.upper)
				a_file.put_string (", yy_Dummy>>)%N%T%Tend%N")
			else
				a_file.put_string ("%T%Tlocal%N%T%T%Tan_array: ARRAY [INTEGER]%N%
					%%T%Tonce%N%T%T%Tcreate an_array.make (")
				a_file.put_integer (a_table.lower)
				a_file.put_string (", ")
				a_file.put_integer (a_table.upper)
				a_file.put_string (")%N")
				from
					j := 1
				until
					j > nb
				loop
					a_file.put_string (Indentation)
					a_file.put_string (a_name)
					a_file.put_character ('_')
					a_file.put_integer (j)
					a_file.put_string (" (an_array)%N")
					j := j + 1
				end
				a_file.put_string ("%T%T%TResult := yy_fixed_array (an_array)%N%T%Tend%N")
				from
					j := 1
					i := a_table.lower
					a_table_upper := a_table.upper
				until
					j > nb
				loop
					a_file.put_string ("%N%T")
					a_file.put_string (a_name)
					a_file.put_character ('_')
					a_file.put_integer (j)
					a_file.put_string (" (an_array: ARRAY [INTEGER]) is%N%
						%%T%Tdo%N%T%T%Tyy_array_subcopy (an_array, <<%N")
					k := a_table_upper.min (i + array_size - 1)
					ARRAY_FORMATTER_.put_integer_array (a_file, a_table, i, k)
					a_file.put_string (", yy_Dummy>>,%N%T%T%T")
					a_file.put_integer (1)
					a_file.put_string (", ")
					a_file.put_integer (k - i + 1)
					a_file.put_string (", ")
					a_file.put_integer (i)
					a_file.put_string (")%N%T%Tend%N")
					i := k + 1
					j := j + 1
				end
			end
		end

	print_rule_line_numbers (a_state: LX_DFA_STATE; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print the (sorted) list of the line numbers of 
			-- the rules associated to the NFA states making up
			-- `a_state' to `a_file'.
		require
			a_state_not_void: a_state /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			j, yy_rules_upper: INTEGER
			a_nfa_state: LX_NFA_STATE
			nfa_states: DS_ARRAYED_LIST [LX_NFA_STATE]
			line_numbers: DS_ARRAYED_LIST [INTEGER]
			line_nb: INTEGER
		do
			nfa_states := a_state.states
			nb := nfa_states.count
			create line_numbers.make (nb)
			from
				i := 1
			until
				i > nb
			loop
				a_nfa_state := nfa_states.item (i)
				from
					j := yy_rules.lower
					yy_rules_upper := yy_rules.upper
				until
					j > yy_rules_upper or else yy_rules.item (j).pattern.has (a_nfa_state)
				loop
					j := j + 1
				end
				if j <= yy_rules_upper then
					line_nb := yy_rules.item (j).line_nb
				end
				if not line_numbers.has (line_nb) then
					line_numbers.put_last (line_nb)
				end
				i := i + 1
			end
			line_numbers.sort (Integer_sorter)
			a_file.put_string (" associated rule line numbers:")
			nb := line_numbers.count
			from
				i := 1
			until
				i > nb
			loop
				if i \\ 8 = 1 then
					a_file.put_character ('%N')
				end
				a_file.put_character ('%T')
				a_file.put_integer (line_numbers.item (i))
				i := i + 1
			end
			a_file.put_character ('%N')
		end

	print_transitions (a_state: LX_DFA_STATE; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print out- and jam-transitions from `a_state'
			-- in a human-readable form (i.e. not using
			-- equivalence classes) to `a_file'.
		require
			a_state_not_void: a_state /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, j, nb: INTEGER
			transitions: LX_TRANSITION_TABLE [LX_DFA_STATE]
			has_transition: ARRAY [BOOLEAN]
		do
			nb := characters_count
			transitions := a_state.transitions
			create has_transition.make (0, nb - 1)
			if yy_ec /= Void then
					-- Equivalence classes are used.
				from
					i := 1
				until
					i >= nb
				loop
					j := yy_ec.item (i)
					if transitions.valid_label (j) then
						has_transition.put (transitions.target (j) /= Void, i)
					end
					i := i + 1
				end
					-- Null transition.
				j := yy_ec.item (nb)
				if transitions.valid_label (j) then
					has_transition.put (transitions.target (j) /= Void, 0)
				end
			else
				from
					i := 1
				until
					i >= nb
				loop
					if transitions.valid_label (i) then
						has_transition.put (transitions.target (i) /= Void, i)
					end
					i := i + 1
				end
					-- Null transition.
				if transitions.valid_label (i) then
					has_transition.put (transitions.target (nb) /= Void, 0)
				end
			end
			a_file.put_string (" out-transitions: [")
			from
				i := 0
			until
				i >= nb
			loop
				if has_transition.item (i) then
					a_file.put_character (' ')
					print_readable_character (i, a_file)
					from
						j := i
						i := i + 1
					until
						i >= nb or not has_transition.item (i)
					loop
						i := i + 1
					end
					if i - 1 > j then
							-- This was a character set.
						a_file.put_character ('-')
						print_readable_character (i - 1, a_file)
					end
					a_file.put_character (' ')
				end
				i := i + 1
			end
			a_file.put_string ("]%N jam-transitions: EOF [")
			from
				i := 0
			until
				i >= nb
			loop
				if not has_transition.item (i) then
					a_file.put_character (' ')
					print_readable_character (i, a_file)
					from
						j := i
						i := i + 1
					until
						i >= nb or has_transition.item (i)
					loop
						i := i + 1
					end
					if i - 1 > j then
							-- This was a character set.
						a_file.put_character ('-')
						print_readable_character (i - 1, a_file)
					end
					a_file.put_character (' ')
				end
				i := i + 1
			end
			a_file.put_string ("]%N")
		end

	print_readable_character (i: INTEGER; a_file: KI_TEXT_OUTPUT_STREAM) is
			-- Print a human-readable form of the character
			-- of ASCII code `i' to `a_file'. Print octal value
			-- if the corresponding character is not printable.
		require
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			octal, tmp: STRING
			j: INTEGER
		do
			if i < 32 or i >= 127 then
				inspect i
				when Back_space_code then
					a_file.put_string ("\b")
				when Form_feed_code then
					a_file.put_string ("\f")
				when New_line_code then
					a_file.put_string ("\n")
				when Carriage_return_code then
					a_file.put_string ("\r")
				when Tabulation_code then
					a_file.put_string ("\t")
				else
					a_file.put_character ('\')
						-- Convert ASCII code into octal value.
					from
						j := i
						if j < 0 then
							a_file.put_character ('-')
							j := -j
						end
						octal := ""
					until
						j = 0
					loop
						tmp := STRING_.cloned_string ((j \\ 8).out)
						tmp.append_string (octal)
						octal := tmp
						j := j // 8
					end
					inspect octal.count
					when 0 then
						a_file.put_string ("000")
					when 1 then
						a_file.put_string ("00")
					when 2 then
						a_file.put_character ('0')
					else
					end
					a_file.put_string (octal)
				end
			elseif i = Space_code then
				a_file.put_string ("' '")
			else
				a_file.put_character (INTEGER_.to_character (i))
			end
		end

feature {NONE} -- Building

	build_rules (rules: DS_ARRAYED_LIST [LX_RULE]) is
			-- Build `yy_rules'.
		require
			rules_not_void: rules /= Void
			no_void_rule: not rules.has (Void)
		local
			i, nb: INTEGER
		do
			nb := rules.count
			create yy_rules.make (1, nb)
			from
				i := 1
			until
				i > nb
			loop
				yy_rules.put (rules.item (i), i)
				i := i + 1
			end
		ensure
			yy_rules_not_void: yy_rules /= Void
		end

	build_eof_rules (rules: DS_ARRAYED_LIST [LX_RULE]; l, u: INTEGER) is
			-- Build `yy_eof_rules'.
			-- Rules are indexed by rule ids.
		require
			rules_not_void: rules /= Void
			no_void_rule: not rules.has (Void)
--			valid_rules: forall rule in rules, rule.id >= l and rule.id <= u
		local
			i, nb: INTEGER
			rule: LX_RULE
		do
			create yy_eof_rules.make (l, u)
			nb := rules.count
			from
				i := 1
			until
				i > nb
			loop
				rule := rules.item (i)
				yy_eof_rules.put (rule, rule.id)
				i := i + 1
			end
		ensure
			yy_eof_rules_not_void: yy_eof_rules /= Void
		end

feature {NONE} -- Access

	input_filename: STRING
			-- Input filename

	eiffel_code: STRING
			-- User-defined Eiffel code

	eiffel_header: DS_ARRAYED_LIST [STRING]
			-- User-defined Eiffel header

	bol_needed: BOOLEAN
			-- Does the generated scanners need
			-- "beginning of line" recognition?

	pre_action_used: BOOLEAN
			-- Should routine `pre_action' be called before
			-- each semantic action?

	post_action_used: BOOLEAN
			-- Should routine `post_action' be called after
			-- each semantic action?

	pre_eof_action_used: BOOLEAN
			-- Should routine `pre_eof_action' be called before
			-- each end-of-file semantic action?

	post_eof_action_used: BOOLEAN
			-- Should routine `post_eof_action' be called after
			-- each end-of-file semantic action?

	line_pragma: BOOLEAN
			-- Should line pragma be generated?

	characters_count: INTEGER
			-- Number of characters in character set
			-- handled by the generated scanners
			-- (The character set is always assumed to start from 0.)

	array_size: INTEGER
			-- Maximum size supported for manifest arrays

	actions_separated: BOOLEAN
			-- Should semantic actions be generated in separate routines?

	inspect_used: BOOLEAN
			-- Should the generated code uses an inspect instruction
			-- to find out which action to execute? The alternative is
			-- to use binary-search implemented with "if" instructions.

feature {NONE} -- Constants

	Indentation: STRING is "%T%T%T"

	Integer_sorter: DS_BUBBLE_SORTER [INTEGER] is
			-- Integer sorter
		local
			a_comparator: KL_COMPARABLE_COMPARATOR [INTEGER]
		once
			create a_comparator.make
			create Result.make (a_comparator)
		ensure
			sorter_not_void: Result /= Void
		end

	Default_input_filename: STRING is "standard input"
			-- Default input filename

invariant

	minimum_symbol: minimum_symbol = 1
	no_void_eiffel_header: eiffel_header /= Void implies not eiffel_header.has (Void)
	characters_count_positive: characters_count > 0
	array_size_positive: array_size >= 0
	input_filename_not_void: input_filename /= Void

end
