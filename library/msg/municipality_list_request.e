note
	description: "Summary description for {MUNICIPALITY_LIST_REQUEST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

--| ----------------------------------------------------------------------------
--| This is the message structure for the municipalities list message, for the
--| time being only json is a supported format
--| ----------------------------------------------------------------------------
--| The message is an unnamed json object composed by a header and a data part
--| for example:
--| `token_id' can be an empty string
--|
--| {
--|   "header": {
--|     "id":                <municipality_list_request_id>
--|   },
--|   "data": {
--|     "provinces_list": [{"province": "P1"},
--|                        {"province": "P2"},
--|                        ...,
--|                        {"province": "Pn"}]
--|   }
--| }
--|
--| ----------------------------------------------------------------------------

class
	MUNICIPALITY_LIST_REQUEST

inherit
	REQUEST_I

create
	make,
	make_from_json_string,
	make_from_token

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			create token_id.make_empty

			create xml_representation.make_empty
			create json_representation.make_empty

			create provinces_list.make (0)
		end

	make_from_json_string (json: STRING; parser: JSON_PARSER)
			-- Initialization of `Current' from a json string
		require
			json_not_void: json /= Void
		do
			create token_id.make_empty

			create json_representation.make_empty
			create xml_representation.make_empty

			create provinces_list.make (0)

			from_json (json, parser)
		end

	make_from_token (a_token: STRING)
			-- Build a `MUNICIPALITY_LIST_REQUEST' with `token_id' = `a_token'
		do
			create token_id.make_from_string (a_token)

			create json_representation.make_empty
			create xml_representation.make_empty

			create provinces_list.make (0)
		end

feature -- Access

	id: INTEGER
			-- message id
		do
			Result := municipality_list_request_id
		end

	token: STRING
			-- Access to `token_id'
		do
			Result := token_id
		end

	provinces: ARRAYED_LIST[STRING]
			-- Access to `provinces_list'
		do
			Result := provinces_list
		end

feature -- Status setting

	set_logger (a_logger: LOG_LOGGING_FACILITY)
			-- Set the logger
		require
			logger_not_void: a_logger /= Void
		do
			logger := a_logger
		ensure
			logger_not_void: logger /= Void
		end

	set_token_id (a_token: STRING)
			-- Set `token_id'
		do
			token_id.copy (a_token)
		end

feature -- Conversion

	to_xml: STRING
			-- XML representation
		local
			l_token_id: STRING
			l_p_list:   STRING
			i:          INTEGER
		do
			create l_token_id.make_from_string (token_id)
			create l_p_list.make_empty
			create Result.make_from_string (xml_request_template)
			if token_id.is_empty then
				Result.replace_substring_all ("<Token>",   "")
				Result.replace_substring_all ("</Token>",  "")
				Result.replace_substring_all ("<Id>",      "")
				Result.replace_substring_all ("</Id>",     "")
				Result.replace_substring_all ("$tokenid",  "")
			else
				Result.replace_substring_all ("$tokenid", l_token_id)
			end
			from
				i := 1
			until
				i = provinces_list.count + 1
			loop
				l_p_list.append ("<Provincia>")
				l_p_list.append (provinces_list.i_th (i))
				l_p_list.append ("</Provincia>%N")
				i := i + 1
			end

			Result.replace_substring_all ("$provinces_list", l_p_list)
			xml_representation := Result

			l_token_id.wipe_out
			l_p_list.wipe_out
		end

	from_json(json: STRING; parser: JSON_PARSER)
			-- Parse json message
		require else
			json_valid: attached json and then not json.is_empty
			json_parser_valid: attached parser and then parser.is_valid
		local
			key:         JSON_STRING
			key1:        JSON_STRING
			--json_parser: JSON_PARSER
			i:           INTEGER
			l_p:         STRING
			l_count:     INTEGER
		do
			json_representation.copy (json)
		 	--create json_parser.make_with_string (json)
		 	parser.reset_reader
		 	parser.reset
		 	parser.set_representation (json)

			create key1.make_from_string ("province")
			create key.make_from_string ("header")
			parser.parse_content
			if parser.is_valid and then attached parser.parsed_json_value as jv then
				if attached {JSON_OBJECT} jv as j_object and then attached {JSON_OBJECT} j_object.item (key) as j_header
					and then attached {JSON_NUMBER} j_header.item ("id") as j_id
					--and then attached {JSON_NUMBER} j_header.item ("parameters_number") as j_parnum
				then
					print ("Message: " + j_id.integer_64_item.out + "%N") --", " + j_parnum.integer_64_item.out + "%N")
					--set_parameters_number (j_parnum.integer_64_item.to_integer)
				else
					print ("The header was not found!%N")
				end

				key := "data"
				if attached {JSON_OBJECT} jv as j_object and then attached {JSON_OBJECT} j_object.item (key) as j_data
					--and then attached {JSON_STRING} j_data.item ("tokenid") as j_tokenid
					and then attached {JSON_ARRAY} j_data.item ("provinces_list") as j_provinces
				then
					--token_id := j_tokenid.item

					provinces_list.wipe_out

					l_count := j_provinces.count
					from i := 1
					until i = l_count + 1
					loop
						if attached {JSON_OBJECT} j_provinces.i_th (i) as j_prov
							and then attached {JSON_STRING} j_prov.item (key1) as j_p
						then
							create l_p.make_from_string (j_p.item)
							provinces_list.extend (l_p)
						end

						i := i + 1
					end

				end
			end
			parser.reset_reader
			parser.reset
			key.item.wipe_out
			key1.item.wipe_out
		end

	to_json: STRING
			-- json representation
		local
			i: INTEGER
		do
			create Result.make_empty
			-- TODO
			json_representation.wipe_out

			json_representation.append ("{")
			json_representation.append ("%"header%": {")
			json_representation.append ("%"id%": " + municipality_list_request_id.out + "}")
			--json_representation.append (",%"parameters_number%": " + station_status_list_request_parnum_token.out + "}")
			json_representation.append (",%"data%": {")
			--json_representation.append ("%"tokenid%": %"" + token_id + "%"},")

			json_representation.append ("%"provinces_list%": [")

			from i := 1
			until i = provinces_list.count + 1
			loop
				if i > 1 then
					json_representation.append (",")
				end

				json_representation.append ("{%"province%": %"" + provinces_list.i_th (i) + "%"}")

			end
			json_representation.append ("]}}")
		end

	from_xml (xml: STRING; parser: XML_STANDARD_PARSER)
			-- Parse xml message
		do
			-- should never be called from request messages
		end

feature -- Basic operations

	init_response: RESPONSE_I
			--
		do
			Result := create {MUNICIPALITY_LIST_RESPONSE}.make
		end

feature {DISPOSANLE}

	dispose
			--
		do
			json_representation.wipe_out
			xml_representation.wipe_out
			provinces_list.wipe_out
		end

feature {NONE} -- Utilities implementation

	json_representation: STRING
	xml_representation:  STRING

	ws_url: STRING
			-- Web service URL
		do
			Result := anaws_url
		end

	ws_test_url: STRING
			-- Testing web service URL
		do
			Result := anaws_test_url
		end

	soap_action_header:  STRING
			-- SOAP action header
		do
			Result := "SOAPAction: " + remws_uri + "/" + anaws_interface + "/" + name
		end

	name: STRING
			-- Request `name' to be passed to remws
		do
			Result := "ElencoComuni"
		end

	xml_request_template: STRING = "[
		<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
          <s:Body>
            <ElencoComuni xmlns="http://tempuri.org/">
              <xInput>
                <ElencoComuni xmlns="">
                  <Token>
                    <Id>$tokenid</Id>
                  </Token>
                  <Province>
                    $provinces_list
                  </Province>
                </ElencoComuni>
              </xInput>
            </ElencoComuni>
          </s:Body>
        </s:Envelope>
	]"

feature {NONE} -- Implementation

	token_id: STRING
	provinces_list:ARRAYED_LIST[STRING]
	--parnum:   INTEGER

invariant
	invariant_clause: True -- Your invariant here

end
