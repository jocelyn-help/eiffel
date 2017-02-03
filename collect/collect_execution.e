note
	description: "Summary description for {COLLECT_EXECUTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COLLECT_EXECUTION

inherit
	WSF_EXECUTION
		redefine
			initialize
		end

	SHARED_COLLECT_CONFIGURATION

	SHARED_APP_LOGGER

	DAY_LIGHT_TIME_UTILITIES

	MSG_CONSTANTS
	ERROR_CODES
	EXCEPTIONS
	PAGE_TEMPLATES
	DEFAULTS
	MEMORY

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	initialize
		do
			Precursor
			create json_parser.make_with_string ("{}")
		end

	remws_session (cfg: separate COLLECT_CONFIGURATION): REMWS_SESSION
		local
			l_username, l_password: STRING
		do
			-- login management
			if attached cfg.username as u and attached cfg.password as p then
				create l_username.make_from_separate (u)
				create l_password.make_from_separate (p)
				create Result.make (l_username, l_password)
			else
				io.error.put_string ("Missing username and password for remws service!")
				die (0)
			end
		end

feature -- Access

--	content_type: STRING

	msg_number:   INTEGER
			-- parsed messages number

	error_code:     INTEGER
			-- Post error code
	error_message:  detachable STRING
			-- Post error message

	internal_error: ERROR_RESPONSE
		once
			create Result.make
		end

feature -- Execution

	execute
	    local
			req: WSF_REQUEST
			res: WSF_RESPONSE
	    	l_received_chars: INTEGER
	    	l_msg_id:         INTEGER
	    	l_current_time:   DATE_TIME
	    	l_offset:         DATE_TIME_DURATION

	    	l_request_content:        STRING
	    	l_json_response:       STRING

	    	l_req_obj: detachable REQUEST_I
	    	l_res_obj: detachable RESPONSE_I
	    	l_mem_stat:       MEM_INFO
			l_gc_stat:        GC_INFO
			l_qt_res:         QUERY_TOKEN_RESPONSE
			l_remws_session: like remws_session
		do
			l_remws_session := remws_session (config)

			req := request
			res := response

			create l_request_content.make (req.content_length_value.to_integer_32)
			--l_request_content.resize (req.content_length_value.to_integer_32)
			create l_json_response.make_empty
			create l_current_time.make_now

			create l_qt_res.make

			if is_utc_set then
				l_offset       := check_day_light_time_saving (l_current_time)
				log_debug_display ("time_offset     : " + l_offset.second.out, True, True);
				l_current_time := l_current_time + l_offset
			end

			log_debug_display ("is logged in    : " + l_remws_session.is_logged_in.out, True, True)
			log_debug_display ("token id        : " + l_remws_session.token.id, True, True)
			log_debug_display ("token expiry    : " + l_remws_session.token.expiry.formatted_out (default_date_time_format), True, True)
			log_debug_display ("current time    : " + l_current_time.formatted_out (default_date_time_format), True, True)
			log_debug_display ("is token expired: " + l_remws_session.is_token_expired.out, True, True)

			if l_remws_session.is_token_expired then
				execution_environment.sleep (1_000_000_000) -- 1 second.
				l_remws_session.reset
				l_remws_session.do_login
				if l_remws_session.is_logged_in then
					log_information_display ("logged in with new token " +
					             l_remws_session.token.id +
					             " expiring upon " +
					             l_remws_session.token.expiry.formatted_out (default_date_time_format),
					             True, True
					            )
				else
					log_error_display ("Unable to login", True, True)
					log_information_display ("Outcome   : " + l_remws_session.login_response.outcome.out, True, True)
					log_information_display ("Message   : " + l_remws_session.login_response.message, True, True)
				end
				execution_environment.sleep (1_000_000_000) -- 1 second.
			end

			-- read json input
			if req.content_length_value > 0 then
				l_received_chars := req.input.read_to_string (l_request_content, 1, req.content_length_value.to_integer_32)
			else
				l_received_chars := 0
			end
			log_debug_display ("Received " + l_received_chars.out + " chars", True, True)
			log_debug_display (" <<< " + l_request_content, True, False)
			-- parse the message header
			l_msg_id := parse_header (l_request_content)
			log_debug_display ("Received message id: " + l_msg_id.out, True, True)

			if l_msg_id = {REQUEST_I}.login_request_id then
				l_req_obj := create {LOGIN_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if l_res_obj /= Void then
					l_json_response := l_res_obj.to_json
				end
			elseif l_msg_id = {REQUEST_I}.logout_request_id then
				l_req_obj := create {LOGOUT_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if l_res_obj /= Void then
					l_json_response := l_res_obj.to_json
				end
			elseif l_msg_id = {REQUEST_I}.station_status_list_request_id then
				l_req_obj := create {STATION_STATUS_LIST_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if l_res_obj /= Void then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Station status list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.station_types_list_request_id then
				l_req_obj := create {STATION_TYPES_LIST_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Station types list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.province_list_request_id then
				l_req_obj := create {PROVINCE_LIST_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Province list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.municipality_list_request_id then
				l_req_obj := create {MUNICIPALITY_LIST_REQUEST}.make

				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Municipality list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.station_list_request_id then
				l_req_obj := create {STATION_LIST_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					--log ("**********%N" + l_json_response + "%N**********%N", log_debug)
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Station list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.sensor_type_list_request_id then
				l_req_obj := create {SENSOR_TYPE_LIST_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Sensor types list", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.realtime_data_request_id then
				l_req_obj := create {REALTIME_DATA_REQUEST}.make
				l_req_obj.from_json (l_request_content, json_parser)
				l_req_obj.set_token_id (l_remws_session.token.id)
				l_res_obj := l_remws_session.do_post (l_req_obj)
				if attached l_res_obj then
					l_json_response := l_res_obj.to_json
					log_information_display ("Sent message id: " + l_res_obj.id.out + " Realtime data", True, True)
					log_information_display ("Message outcome: " + l_res_obj.outcome.out, True, True)
					log_information_display ("Message message: " + l_res_obj.message, True, True)
				end
			elseif l_msg_id = {REQUEST_I}.query_token_request_id then
				l_qt_res.set_message ("Query token response")
				l_qt_res.set_outcome (0)
				l_qt_res.set_id (l_remws_session.token.id)
				l_qt_res.set_expiry (l_remws_session.token.expiry)
				l_json_response := l_qt_res.to_json
			else
				l_json_response := internal_error.to_json
			end

			res.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-Type", "text/json"], ["Content-Length", l_json_response.count.out]>>)
			res.put_string (l_json_response)
			log_information_display (" >>> " + l_json_response, True, False)

			if l_req_obj /= Void then
				l_req_obj.dispose
			end
			if l_res_obj /= Void then
				l_res_obj.dispose
			end

			msg_number := msg_number + 1
			log_notice_display ("%T Managed message number " + msg_number.out, True, True)
			if msg_number = {INTEGER}.max_value then
				msg_number := 1
			end

			if (msg_number \\ 1000) = 0 then
				l_mem_stat := memory_statistics (Total_memory)
				l_gc_stat  := gc_statistics (total_memory)

				full_collect
				full_coalesce
				log_alert_display ("MEMORY STATISTICS " + msg_number.out,              True, True)
				log_alert_display ("Total 64:       "   + l_mem_stat.total64.out,      True, True)
				log_alert_display ("Total memory:   "   + l_mem_stat.total_memory.out, True, True)
				log_alert_display ("Free 64:        "   + l_mem_stat.free64.out,       True, True)
				log_alert_display ("Used 64:        "   + l_mem_stat.used64.out,       True, True)


				log_alert_display ("GC STATISTICS   "   + msg_number.out,              True, True)
				log_alert_display ("Collected:      "   + l_gc_stat.collected.out,     True, True)
				log_alert_display ("Total memory:   "   + l_gc_stat.total_memory.out,  True, True)
				log_alert_display ("Eiffel memory:  "   + l_gc_stat.eiffel_memory.out, True, True)
				log_alert_display ("Memory used:    "   + l_gc_stat.memory_used.out,   True, True)

				log_alert_display ("C memory:       "   + l_gc_stat.c_memory.out,      True, True)
				log_alert_display ("Cycle count:    "   + l_gc_stat.cycle_count.out,   True, True)

				log_alert_display ("%N", True, True)
			end
			log_notice_display ("%N", True, True)

			l_request_content.wipe_out
			l_json_response.wipe_out
		end

feature -- Basic operations

	parse_header (json: STRING): INTEGER
			-- Search message header for message id
		local
			key:         JSON_STRING
			--json_parser: JSON_PARSER
		do
			json_parser.reset_reader
			json_parser.reset
			json_parser.set_representation (json)

			create key.make_from_string ("header")
			json_parser.parse_content
			if json_parser.is_valid and then attached json_parser.parsed_json_value as jv then
				if
					attached {JSON_OBJECT} jv as j_object and then
					attached {JSON_OBJECT} j_object.item (key) as j_header and then
					attached {JSON_NUMBER} j_header.item ("id") as j_id
				then
					log_debug_display ("message id: " + j_id.integer_64_item.out, True, False)
					Result := j_id.integer_64_item.to_integer
				else
					log_error_display ("The message header was not found!", True, True)
					log_error_display ("%TThis is probably not a valid message.", True, True)
					error_code    := {ERROR_CODES}.err_invalid_json
					error_message := {ERROR_CODES}.msg_invalid_json
				end
			else
				log_critical_display ("json parser is not valid!!!", True, True)
				if json_parser.has_error then
					log_critical_display ("json parser error: " + json_parser.errors_as_string, True, True)
				end
				error_code    := {ERROR_CODES}.err_no_json_parser
				error_message := {ERROR_CODES}.msg_no_json_parser
			end

			key.item.wipe_out
			json_parser.reset_reader
			json_parser.reset
		end

feature {NONE} -- Implementation

	json_parser: JSON_PARSER
			-- Global json parser

invariant

end
