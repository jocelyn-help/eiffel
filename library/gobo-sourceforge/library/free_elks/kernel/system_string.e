indexing
	description: "Fake abstraction of a .NET SYSTEM_STRING in a non-.NET system"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2008, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2008-10-25 22:32:57 +0200 (Sat, 25 Oct 2008) $"
	revision: "$Revision: 6537 $"

class
	SYSTEM_STRING

feature -- Access

	length: INTEGER is do end

invariant
	is_dotnet: {PLATFORM}.is_dotnet

end
