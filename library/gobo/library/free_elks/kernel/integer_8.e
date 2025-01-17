indexing
	description: "Integer values coded on 8 bits"
	external_name: "System.SByte"
	assembly: "mscorlib"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2005, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2008-04-03 23:51:43 +0200 (Thu, 03 Apr 2008) $"
	revision: "$Revision: 6333 $"

frozen expanded class INTEGER_8 inherit

	INTEGER_8_REF
		redefine
			infix "<",
			infix "+",
			infix "-",
			infix "*",
			infix "/",
			prefix "+",
			prefix "-",
			infix "//",
			infix "\\",
			infix "^",
			as_natural_8,
			as_natural_16,
			as_natural_32,
			as_natural_64,
			as_integer_8,
			as_integer_16,
			as_integer_32,
			as_integer_64,
			to_real,
			to_double,
			to_character_8,
			to_character_32,
			bit_and,
			bit_or,
			bit_xor,
			bit_not,
			bit_shift_left,
			bit_shift_right
		end

create
	default_create,
	make_from_reference

convert
	make_from_reference ({INTEGER_8_REF}),
	to_real: {REAL_32},
	to_double: {REAL_64},
	to_integer_16: {INTEGER_16},
	to_integer_32: {INTEGER_32},
	to_integer_64: {INTEGER_64}

feature -- Comparison

	infix "<" (other: INTEGER_8): BOOLEAN is
			-- Is current integer less than `other'?
		external
			"built_in"
		end

feature -- Basic operations

	infix "+" (other: INTEGER_8): INTEGER_8 is
			-- Sum with `other'
		external
			"built_in"
		end

	infix "-" (other: INTEGER_8): INTEGER_8 is
			-- Result of subtracting `other'
		external
			"built_in"
		end

	infix "*" (other: INTEGER_8): INTEGER_8 is
			-- Product by `other'
		external
			"built_in"
		end

	infix "/" (other: INTEGER_8): REAL_64 is
			-- Division by `other'
		external
			"built_in"
		end

	prefix "+": INTEGER_8 is
			-- Unary plus
		external
			"built_in"
		end

	prefix "-": INTEGER_8 is
			-- Unary minus
		external
			"built_in"
		end

	infix "//" (other: INTEGER_8): INTEGER_8 is
			-- Integer division of Current by `other'
		external
			"built_in"
		end

	infix "\\" (other: INTEGER_8): INTEGER_8 is
			-- Remainder of the integer division of Current by `other'
		external
			"built_in"
		end

	infix "^" (other: REAL_64): REAL_64 is
			-- Integer power of Current by `other'
		external
			"built_in"
		end

feature -- Conversion

	as_natural_8: NATURAL_8 is
			-- Convert `item' into an NATURAL_8 value.
		external
			"built_in"
		end

	as_natural_16: NATURAL_16 is
			-- Convert `item' into an NATURAL_16 value.
		external
			"built_in"
		end

	as_natural_32: NATURAL_32 is
			-- Convert `item' into an NATURAL_32 value.
		external
			"built_in"
		end

	as_natural_64: NATURAL_64 is
			-- Convert `item' into an NATURAL_64 value.
		external
			"built_in"
		end

	as_integer_8: INTEGER_8 is
			-- Convert `item' into an INTEGER_8 value.
		external
			"built_in"
		end

	as_integer_16: INTEGER_16 is
			-- Convert `item' into an INTEGER_16 value.
		external
			"built_in"
		end

	as_integer_32: INTEGER_32 is
			-- Convert `item' into an INTEGER_32 value.
		external
			"built_in"
		end

	as_integer_64: INTEGER_64 is
			-- Convert `item' into an INTEGER_64 value.
		external
			"built_in"
		end

	to_real: REAL_32 is
			-- Convert `item' into a REAL_32
		external
			"built_in"
		end

	to_double: REAL_64 is
			-- Convert `item' into a REAL_64
		external
			"built_in"
		end

	to_character_8: CHARACTER_8 is
			-- Associated character in 8 bit version.
		external
			"built_in"
		end

	to_character_32: CHARACTER_32 is
			-- Associated character in 32 bit version.
		external
			"built_in"
		end

feature -- Bit operations

	bit_and (i: INTEGER_8): INTEGER_8 is
			-- Bitwise and between Current' and `i'.
		external
			"built_in"
		end

	bit_or (i: INTEGER_8): INTEGER_8 is
			-- Bitwise or between Current' and `i'.
		external
			"built_in"
		end

	bit_xor (i: INTEGER_8): INTEGER_8 is
			-- Bitwise xor between Current' and `i'.
		external
			"built_in"
		end

	bit_not: INTEGER_8 is
			-- One's complement of Current.
		external
			"built_in"
		end

	bit_shift_left (n: INTEGER): INTEGER_8 is
			-- Shift Current from `n' position to left.
		external
			"built_in"
		end

	bit_shift_right (n: INTEGER): INTEGER_8 is
			-- Shift Current from `n' position to right.
		external
			"built_in"
		end

end
