note
	description: "Summary description for {APP_FILE_LOG}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_FILE_LOG

inherit
	PLAIN_TEXT_FILE

create
	make_with_name, make_with_path

feature -- Element change

	put_separate_string	(s: separate STRING_8)
		require
			extendible: extendible
			non_void: s /= Void
		local
			ext_s: separate ANY
		do
			if s.count /= 0 then
				ext_s := s.area
				file_ps (file_pointer, $ext_s, s.count)
			end
		end

end
