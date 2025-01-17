indexing

	description:

		"AST Element of Phase 1, represents storage class specifiers"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2003/10/29 00:46:03 $"
	revision: "$Revision: 1.2 $"

class EWG_C_PHASE_1_STORAGE_CLASS_SPECIFIERS

inherit

	ANY
		redefine
			out
		end
	
creation

	make

feature

	make is
		do
		end

feature

	set_typedef is
		do
			is_typedef := True
		ensure
			set_is_typedef: is_typedef 
		end
	
	set_extern is
		do
			is_extern := True
		ensure
			set_is_extern: is_extern 
		end
	
	set_static is
		do
			is_static := True
		ensure
			set_is_static: is_static 
		end
	
	set_auto is
		do
			is_auto := True
		ensure
			set_is_auto: is_auto
		end
	
	set_register is
		do
			is_register := True
		ensure
			set_is_register: is_register 
		end
	
	set_inline is
		do
			is_inline := True
		ensure
			set_is_inline: is_inline 
		end

feature

	none_set: BOOLEAN is
		do
			Result := not is_typedef and not is_extern and not is_static and not is_auto and not is_inline
		end

	merge (other: EWG_C_PHASE_1_STORAGE_CLASS_SPECIFIERS) is
		do
			if other.is_typedef then
				set_typedef
			end
			if other.is_extern then
				set_extern
			end
			if other.is_static then
				set_static
			end
			if other.is_auto then
				set_auto
			end
			if other.is_register then
				set_register
			end
			if other.is_inline then
				set_inline
			end
		end

feature

	is_typedef: BOOLEAN

	is_extern: BOOLEAN

	is_static: BOOLEAN

	is_auto: BOOLEAN

	is_register: BOOLEAN

	is_inline: BOOLEAN

feature

	out: STRING is
		do
			Result := ""
			if is_typedef then
				Result := Result + "typedef "
			end
			if is_extern then
				Result := Result + "extern "
			end
			if is_static then
				Result := Result + "static "
			end
			if is_auto then
				Result := Result + "auto "
			end
			if is_register then
				Result := Result + "register "
			end
			if is_inline then
				Result := Result + "inline "
			end
		end
end
