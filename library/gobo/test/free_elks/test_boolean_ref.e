indexing

	description:

		"Test features of class BOOLEAN_REF"

	library: "FreeELKS Library"
	copyright: "Copyright (c) 2005, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-02-13 12:34:45 +0100 (Wed, 13 Feb 2008) $"
	revision: "$Revision: 6301 $"

class TEST_BOOLEAN_REF

inherit

	TS_TEST_CASE

create

	make_default

feature -- Test

	test_default_create is
			-- Test feature 'default_create'.
		local
			bref: BOOLEAN_REF
		do
			create bref
			assert ("not_void", bref /= Void)
			assert ("default", bref.item = False)
		end

	test_out is
			-- Test feature 'out'.
		local
			bref: BOOLEAN_REF
			l_out: STRING
		do
			bref := True
			l_out := bref.out
			assert ("not_void1", l_out /= Void)
			assert ("string_type1", l_out.same_type (""))
			assert_equal ("true", "True", l_out)
			assert ("new_string1", l_out /= bref.out)
			bref := False
			l_out := bref.out
			assert ("not_void2", l_out /= Void)
			assert ("string_type2", l_out.same_type (""))
			assert_equal ("false", "False", l_out)
			assert ("new_string2", l_out /= bref.out)
		end

	test_item is
			-- Test feature 'item'.
		local
			bref: BOOLEAN_REF
		do
			bref := True
			assert ("item1", bref.item = True)
			bref := False
			assert ("item2", bref.item = False)
		end

	test_set_item is
			-- Test feature 'set_item'.
		local
			bref: BOOLEAN_REF
		do
			create bref
			bref.set_item (True)
			assert ("item1", bref.item = True)
			bref.set_item (False)
			assert ("item2", bref.item = False)
		end

	test_is_hashable is
			-- Test feature 'is_hashable'.
		local
			bref: BOOLEAN_REF
		do
			bref := True
			assert ("true_hashable", bref.is_hashable)
			bref := False
			assert ("false_hashable", bref.is_hashable)
		end

	test_hash_code is
			-- Test feature 'hash_code'.
		local
			bref1, bref2: BOOLEAN_REF
		do
			bref1 := True
			bref2 := True
			assert ("hash_code1", bref1.hash_code = bref2.hash_code)
			bref1 := False
			bref2 := False
			assert ("hash_code2", bref1.hash_code = bref2.hash_code)
		end

	test_to_integer is
			-- Test feature 'to_integer'.
		local
			bref: BOOLEAN_REF
		do
			bref := True
			assert_integers_equal ("to_integer1", 1, bref.to_integer)
			bref := False
			assert_integers_equal ("to_integer2", 0, bref.to_integer)
		end

	test_to_reference is
			-- Test feature 'to_reference'.
		local
			bref1, bref2: BOOLEAN_REF
		do
			bref1 := True
			bref2 := bref1.to_reference
			assert ("not_void1", bref2 /= Void)
			assert ("item1", bref2.item = True)
			bref1 := False
			bref2 := bref1.to_reference
			assert ("not_void2", bref2 /= Void)
			assert ("item2", bref2.item = False)
		end

	test_infix_and is
			-- Test feature 'infix "and"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 and b2
			assert ("and1", b3 = True)
			b1 := True
			b2 := False
			b3 := b1 and b2
			assert ("and2", b3 = False)
			b1 := False
			b2 := True
			b3 := b1 and b2
			assert ("and3", b3 = False)
			b1 := False
			b2 := False
			b3 := b1 and b2
			assert ("and4", b3 = False)
		end

	test_infix_and_then is
			-- Test feature 'infix "and then"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 and then b2
			assert ("and_then1", b3 = True)
			b1 := True
			b2 := False
			b3 := b1 and then b2
			assert ("and_then2", b3 = False)
			b1 := False
			b2 := True
			b3 := b1 and then b2
			assert ("and_then3", b3 = False)
			b1 := False
			b2 := False
			b3 := b1 and then b2
			assert ("and_then4", b3 = False)
		end

	test_infix_or is
			-- Test feature 'infix "or"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 or b2
			assert ("or1", b3 = True)
			b1 := True
			b2 := False
			b3 := b1 or b2
			assert ("or2", b3 = True)
			b1 := False
			b2 := True
			b3 := b1 or b2
			assert ("or3", b3 = True)
			b1 := False
			b2 := False
			b3 := b1 or b2
			assert ("or4", b3 = False)
		end

	test_infix_or_else is
			-- Test feature 'infix "or else"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 or else b2
			assert ("or_else1", b3 = True)
			b1 := True
			b2 := False
			b3 := b1 or else b2
			assert ("or_else2", b3 = True)
			b1 := False
			b2 := True
			b3 := b1 or else b2
			assert ("or_else3", b3 = True)
			b1 := False
			b2 := False
			b3 := b1 or else b2
			assert ("or_else4", b3 = False)
		end

	test_infix_xor is
			-- Test feature 'infix "xor"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 xor b2
			assert ("xor1", b3 = False)
			b1 := True
			b2 := False
			b3 := b1 xor b2
			assert ("xor2", b3 = True)
			b1 := False
			b2 := True
			b3 := b1 xor b2
			assert ("xor3", b3 = True)
			b1 := False
			b2 := False
			b3 := b1 xor b2
			assert ("xor4", b3 = False)
		end

	test_infix_implies is
			-- Test feature 'infix "implies"'.
		local
			b1, b2: BOOLEAN_REF
			b3: BOOLEAN
		do
			b1 := True
			b2 := True
			b3 := b1 implies b2
			assert ("implies1", b3 = True)
			b1 := True
			b2 := False
			b3 := b1 implies b2
			assert ("implies2", b3 = False)
			b1 := False
			b2 := True
			b3 := b1 implies b2
			assert ("implies3", b3 = True)
			b1 := False
			b2 := False
			b3 := b1 implies b2
			assert ("implies4", b3 = True)
		end

	test_prefix_not is
			-- Test feature 'prefix "not"'.
		local
			bref1, bref2: BOOLEAN_REF
		do
			bref1 := True
			bref2 := not bref1
			assert ("not1", bref2.item = False)
			bref1 := False
			bref2 := not bref1
			assert ("not1", bref2.item = True)
		end

end
