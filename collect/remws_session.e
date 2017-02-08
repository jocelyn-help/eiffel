note
	description: "Summary description for {REMWS_SESSION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REMWS_SESSION

inherit
	SHARED_COLLECT_CONFIGURATION

	SHARED_APP_LOGGER

	ERROR_CODES

	DAY_LIGHT_TIME_UTILITIES

create
	make

feature {NONE} -- Initialization

	make (a_username, a_password: READABLE_STRING_8)
		do
			username := a_username
			password := a_password

			create token.make
			create error_message.make_empty

			create login_request.make
			create logout_request.make
			create login_response.make
			create logout_response.make

			-- Parsing
			create xml_parser_factory
			xml_parser := xml_parser_factory.new_standard_parser
		end

feature -- Access

	username: READABLE_STRING_8
	password: READABLE_STRING_8

	is_logged_in: BOOLEAN
			-- is collect logged in remws?

feature -- Access: session

	token:        TOKEN
			-- the current `TOKEN'

	login_request: LOGIN_REQUEST
			-- The login request
	logout_request: LOGOUT_REQUEST
			-- The logout request
	login_response: LOGIN_RESPONSE
			-- The login response
	logout_response: LOGOUT_RESPONSE

	last_token_file_path: PATH
			-- last token file name full path
		do
			separate config as cfg do
				create Result.make_from_separate (cfg.location)
				Result := Result.extended ("last_token")
			end
		end

feature -- Parsing

	xml_parser_factory: XML_PARSER_FACTORY
			-- Global xml parser factory
	xml_parser:         XML_STANDARD_PARSER
			-- Global xml parser		

feature -- Status report

	is_token_expired: BOOLEAN
			-- Tells if `token' is expired
		local
			l_current_dt: DATE_TIME
			l_offset:   DATE_TIME_DURATION
		do
			create l_current_dt.make_now
			--create l_interval.make_definite (0, 0, 0, 10)

			l_offset := check_day_light_time_saving (l_current_dt)

			if is_utc_set then
				Result := l_current_dt + l_offset > token.expiry
			else
				Result := l_current_dt > token.expiry
			end
		end

feature -- Basic operations

	reset
		do
			login_response.reset
		end

	do_login
			-- Execute login
		require
			is_not_logged_in: not is_logged_in
		local
			l_xml_str: detachable STRING
			--l_res:     LOGIN_RESPONSE
			last_token_file: PLAIN_TEXT_FILE
		do
			is_logged_in := False
			if attached username as l_username and attached password as l_password then
				login_request.set_username (l_username)
				login_request.set_password (l_password)

				l_xml_str := post (login_request)
				if l_xml_str /= Void then
					log_debug_display ("do_login_response: " + l_xml_str, True, False)
					login_response.from_xml (l_xml_str, xml_parser)

					log_debug_display ("login outcome: " + login_response.outcome.out, True, True)
					log_debug_display ("login message: " + login_response.message,     True, True)
					if login_response.outcome = success then
						token.id.copy (login_response.token.id)
						token.expiry.copy (login_response.token.expiry)
						if token.id.count > 0 then
							is_logged_in := True
							-- save token to text file
							create last_token_file.make_with_path (last_token_file_path)
							last_token_file.create_read_write
							last_token_file.put_string (token.id)
							last_token_file.put_new_line
							last_token_file.put_string (token.expiry.formatted_out ({DEFAULTS}.default_date_time_format))
							last_token_file.put_new_line
							last_token_file.close
						end
					end

					l_xml_str.wipe_out
				else
					log_debug_display ("do_login_response: FAILED !", True, False)
				end
			else
				is_logged_in := False
			end
		end

	do_logout
			-- Execute logout
		local
			l_xml_str: detachable STRING
			--l_res:     LOGOUT_RESPONSE
		do
			if attached token as l_token then
				logout_request.token_id.copy (token.id)

				l_xml_str := post (logout_request)
				if l_xml_str /= Void then
					log_debug_display ("do_logout response " + l_xml_str, True, False)
					log_debug_display ("login outcome: " + logout_response.outcome.out, True, True)
					log_debug_display ("login message: " + logout_response.message,     True, True)

					logout_response.from_xml (l_xml_str, xml_parser)
					l_xml_str.wipe_out
				else
					log_debug_display ("do_logout response: FAILED !", True, False)
				end

				if logout_response.outcome = success then
					is_logged_in := False
				end
			else
					-- Check .. should not occur.
			end
		end

	check_login: BOOLEAN
			-- Check if is system logged in using the current token `expiry'
		local
			l_current_dt: DATE_TIME
			l_interval:   DATE_TIME_DURATION
			l_offset:     DATE_TIME_DURATION
		do
			create l_current_dt.make_now_utc

			l_offset := check_day_light_time_saving (l_current_dt)

			if use_testing_ws then
				create l_interval.make_definite  (0, 0, -28, 0)
			else
				create l_interval.make_definite  (0, 0, -58, 0)
			end

			if attached token then
				if l_current_dt + l_offset >= token.expiry + l_interval then
				    Result := False
			    else
			    	Result := True
				end
			else
				Result := False
			end
		end

feature {COLLECT_EXECUTION} -- Network IO

	post (a_request: REQUEST_I): detachable STRING
			-- Post `a_request' to remws
		local
			cl: NET_HTTP_CLIENT
			sess: HTTP_CLIENT_SESSION
			ctx: detachable HTTP_CLIENT_REQUEST_CONTEXT
		do
			create cl
			if use_testing_ws then
				sess := cl.new_session (a_request.ws_test_url)
			else
				sess := cl.new_session (a_request.ws_url)
			end
			create ctx.make
			a_request.apply_http_headers_to (ctx)
			ctx.set_upload_data (a_request.to_xml)
			if attached sess.post ("", ctx, Void) as resp then
				if resp.error_occurred then
					error_code    := resp.status
					if attached resp.error_message as m then
						error_message := m
					else
						error_message := "Request failed!"
					end
				elseif attached resp.body as b then
					Result := b
				else
					check should_not_occur: False end
					error_code    := {ERROR_CODES}.err_request_failure
					error_message := {ERROR_CODES}.msg_request_failure
				end
			end
			sess.close
		end

	do_post (a_request: REQUEST_I): RESPONSE_I
			-- Do a post to remws
			-- Parse the XML response
			-- Convert the response in json
		require
			a_request_attached: attached a_request
		local
			l_xml_str: detachable STRING
		do
			--create l_xml_str.make_empty
			Result := a_request.init_response
			l_xml_str := post (a_request)

			if error_code /= 0 then
				Result.set_outcome (error_code)
				Result.set_message (error_message)
			elseif l_xml_str /= Void then
				log_debug_display (" <<< " + l_xml_str, True, False)
				Result.from_xml (l_xml_str, xml_parser)
				l_xml_str.wipe_out
			end
			error_code := success
			error_message.wipe_out
		ensure
			result_attached: attached Result
		end

feature {NONE} -- cURL

	error_code:     INTEGER
			-- Post error code
	error_message:  STRING
			-- Post error message

	internal_error: ERROR_RESPONSE once create Result.make end

invariant

end
