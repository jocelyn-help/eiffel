indexing

	description:

		"Test features of class CONCAT1"

	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "MIT License"
	date: "$Date: 2008-02-13 12:34:45 +0100 (Wed, 13 Feb 2008) $"
	revision: "$Revision: 6301 $"

class TEST_CONCAT1

inherit

	TS_TEST_CASE

create

	make_default

feature -- Test

	test_concat is
			-- Test feature `concat'.
		local
			c: CONCAT1
		do
			create c.make
			assert_equal ("toto", "toto", c.concat ("to", "to"))
			assert_equal ("foobar", "foobar", c.concat ("foo", "bar"))
		end

end
