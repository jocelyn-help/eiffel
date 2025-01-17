indexing

	description:

		"External Memory routines"

	library: "Eiffel Wrapper Generator Library"
	copyright: "Copyright (c) 1999, Andreas Leitner and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2004/04/23 17:52:01 $"
	revision: "$Revision: 1.8 $"


class EWG_EXTERNAL_MEMORY_ROUTINES

inherit

	PLATFORM

feature -- Memory allocation and deallocation

	calloc_external (an_elements, an_element_size: INTEGER): POINTER is
			-- Allocate memory for an array of `an_elements' elements of
			-- `an_element_size' bytes each and returns a pointer to the
			-- allocated memory. The memory is set to zero.
		require
			an_elements_positive: an_elements >= 0
			an_element_size_positive: an_element_size >= 0
		external

			"C macro use <stdlib.h>"




		alias
			"calloc"
		end

	malloc_external (a_size: INTEGER): POINTER is
		require
			a_size_greater_equal_zero: a_size >= 0
		external

			"C macro use <stdlib.h>"




		alias
			"malloc"
		end

	free_external (a_item: POINTER) is
		require
			a_item_not_null: a_item /= Default_pointer
		external

			"C macro use <stdlib.h>"




		alias
			"free"
		end

	memcpy_external (a_dest, a_src: POINTER; a_n: INTEGER): POINTER is
		require
			a_n_greater_equal_zero: a_n >= 0
			a_dest_not_default: a_dest /= Default_pointer
			a_src_not_default: a_src /= Default_pointer
		external

			"C macro use <string.h>"




		alias
			"memcpy"
		end


	read_integer_8_external (a_pointer: POINTER; a_pos: INTEGER): INTEGER is
			-- Get the byte at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads 8 bits.
			-- TODO: 'signed char' is not 1 byte on all architectures
			-- replace with macro that uses customizable types
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				(int)((signed char*)$a_pointer)[$a_pos]
				]"














		ensure
			result_is_byte: Result >= -128 and Result <= 127
		end

	put_integer_8_external (a_pointer: POINTER; a_int: INTEGER; a_pos: INTEGER) is
			-- Put `a_int' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes 8 bits.
			-- TODO: 'signed char' is not 1 byte on all architectures
			-- replace with macro that uses customizable types
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer
			a_int_is_byte: a_int >= -128 and a_int <= 127

		external
			"C inline"
		alias "[
				((signed char*)$a_pointer)[$a_pos] = (signed char) $a_int;
				]"














		ensure
			integer_set: read_integer_8_external (a_pointer, a_pos) = a_int
		end

	read_integer_16_external (a_pointer: POINTER; a_pos: INTEGER): INTEGER is
			-- Get the integer at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads 16 bits.
			-- TODO: looking at the code, this probably does not work correctly
			-- int is not even on most architectures 16 bit
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((short*)(((char*)$a_pointer) + $a_pos))
				]"














		ensure
			result_is_int16: Result >= -32768 and Result <= 32767
		end

	put_integer_16_external (a_pointer: POINTER; a_int: INTEGER; a_pos: INTEGER) is
			-- Put `a_int' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes 16 bits.
			-- TODO: 'short' is not 2 bytes on all architectures
			-- replace with macro that uses customizable types
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer
			a_int_is_int16: a_int >= -32768 and a_int <= 32767

		external
			"C inline"
		alias "[
				 *((short*)(((char*)$a_pointer) + $a_pos)) = (short) $a_int;
				]"














		ensure
			integer_set: read_integer_16_external (a_pointer, a_pos) = a_int
		end

	read_integer_32_external (a_pointer: POINTER; a_pos: INTEGER): INTEGER is
			-- Get the integer at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads 32 bits.
			-- TODO: 'int' is not 4 bytes on all architectures
			-- replace with macro that uses customizable types
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((int*)(((char*)$a_pointer) + $a_pos))
				]"











		end

	put_integer_32_external (a_pointer: POINTER; a_int: INTEGER; a_pos: INTEGER) is
			-- Put `a_int' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes 16 bits.
			-- TODO: 'int' is not 4 bytes on all architectures
			-- replace with macro that uses customizable types
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *(int*)(((char*)$a_pointer) + $a_pos)) = (int) $a_int;
				]"











		ensure
			integer_set: read_integer_32_external (a_pointer, a_pos) = a_int
		end

	read_integer_external (a_pointer: POINTER; a_pos: INTEGER): INTEGER is
			-- Get the integer at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads `sizeof_int' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((int*)(((char*)$a_pointer) + $a_pos))
				]"











		end

	put_integer_external (a_pointer: POINTER; a_int: INTEGER; a_pos: INTEGER) is
			-- Put `a_int' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes `sizeof_int' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((int*)(((char*)$a_pointer) + $a_pos)) = (int) $a_int;
				 ]"











		ensure
			integer_set: read_integer_external (a_pointer, a_pos) = a_int
		end


	read_real_external (a_pointer: POINTER; a_pos: INTEGER): REAL is
			-- Get the real at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads `sizeof_real' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((float*)(((char*)$a_pointer) + $a_pos))
				]"











		end

	put_real_external (a_pointer: POINTER; a_real: REAL; a_pos: INTEGER) is
			-- Put `a_real' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes `sizeof_real' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((float*)(((char*)$a_pointer) + $a_pos)) = (float) $a_real;
				 ]"











		ensure
			real_set: read_real_external (a_pointer, a_pos) = a_real
		end


	read_double_external (a_pointer: POINTER; a_pos: INTEGER): DOUBLE is
			-- Get the double at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads `sizeof_double' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((double*)(((char*)$a_pointer) + $a_pos))
				]"











		end

	put_double_external (a_pointer: POINTER; a_double: DOUBLE; a_pos: INTEGER) is
			-- Put `a_double' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes `sizeof_double' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external
			"C inline"
		alias "[
				 *((double*)(((char*)$a_pointer) + $a_pos)) = (double) $a_double;
				 ]"











		ensure
			double_set: read_double_external (a_pointer, a_pos) = a_double
		end

	read_pointer_external (a_pointer: POINTER; a_pos: INTEGER): POINTER is
			-- Get the pointer at the `a_pos'-th
			-- byte position starting at `a_pointer'.
			-- Reads `sizeof_pointer' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer

		external

			"C macro use <ewg_memory_macros.h>"




		alias
			"ewg_read_pointer"
		end


	put_pointer_external (a_pointer: POINTER; a_value: POINTER; a_pos: INTEGER) is
			-- Put `a_value' at the `a_pos'-th byte position
			-- starting at `a_pointer'.
			-- Writes `sizeof_pointer' bytes.
		require
			a_pointer_not_default_pointer: a_pointer /= Default_pointer
		external

			"C macro use <ewg_memory_macros.h>"




		alias
			"ewg_put_pointer"
		ensure
			pointer_set: read_pointer_external (a_pointer, a_pos) = a_value
		end

	add_pointer_and_integer_external (a_pointer: POINTER; a_integer: INTEGER): POINTER is
		obsolete "Use `a_pointer + a_integer' instead"
		do
			Result := a_pointer + a_integer
		end

	pointer_to_integer_external (a_pointer: POINTER): INTEGER is
		-- TODO: what if sizeof(int) != sizeof(void*) ?

		external
			"C macro use <stdlib.h>"
		alias
			"(int)"





		end

	integer_to_pointer_external (a_integer: INTEGER): POINTER is
		-- TODO: what if sizeof(int) != sizeof(void*) ?

		external
			"C macro use <stdlib.h>"
		alias
			"(void*)"





		end

	reference_of_external (a_pointer: POINTER): POINTER is

		external
			"C macro use <ewg_memory_macros.h>"
		alias
			"ewg_reference_of"







		end

	sizeof_pointer_external: INTEGER is
		do
			Result := Pointer_bits // 8
		end

	sizeof_int_external: INTEGER is
		do




			Result := Integer_bits // 8

		end

	sizeof_real_external: INTEGER is

		do
			Result := Real_bits // 8







		end

	sizeof_double_external: INTEGER is
		do
			Result := Double_bits // 8
		end

-- bitwise and & or
-- TODO: put in other class

	bitwise_integer_or_external (a_value_1: INTEGER; a_value_2: INTEGER): INTEGER is

		do
			Result := a_value_1 | a_value_2







		end

	bitwise_integer_and_external (a_value_1: INTEGER; a_value_2: INTEGER): INTEGER is

		do
			Result := a_value_1 & a_value_2







		end

	bitwise_integer_xor_external (a_value_1: INTEGER; a_value_2: INTEGER): INTEGER is

		do
			Result := a_value_1.bit_xor (a_value_2)







		end

end
