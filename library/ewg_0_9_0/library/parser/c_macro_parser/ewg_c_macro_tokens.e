indexing

	description: "Parser token codes"
	generator: "geyacc version 3.4"

class EWG_C_MACRO_TOKENS

inherit

	YY_PARSER_TOKENS

feature -- Last values

	last_any_value: ANY
	last_string_value: STRING

feature -- Access

	token_name (a_token: INTEGER): STRING is
			-- Name of token `a_token'
		do
			inspect a_token
			when 0 then
				Result := "EOF token"
			when -1 then
				Result := "Error token"
			when TOK_ID then
				Result := "TOK_ID"
			when TOK_DEFINITION then
				Result := "TOK_DEFINITION"
			when TOK_LPAREN then
				Result := "TOK_LPAREN"
			when TOK_RPAREN then
				Result := "TOK_RPAREN"
			when TOK_COMMA then
				Result := "TOK_COMMA"
			else
				Result := yy_character_token_name (a_token)
			end
		end

feature -- Token codes

	TOK_ID: INTEGER is 258
	TOK_DEFINITION: INTEGER is 259
	TOK_LPAREN: INTEGER is 260
	TOK_RPAREN: INTEGER is 261
	TOK_COMMA: INTEGER is 262

end
