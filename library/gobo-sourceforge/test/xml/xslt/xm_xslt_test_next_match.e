indexing

	description:

		"Test xsl:next-match"

	library: "Gobo Eiffel XSLT test suite"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "MIT License"
	date: "$Date: 2008-02-13 12:34:45 +0100 (Wed, 13 Feb 2008) $"
	revision: "$Revision: 6301 $"

class XM_XSLT_TEST_NEXT_MATCH

inherit

	TS_TEST_CASE

	KL_IMPORTED_STRING_ROUTINES

	XM_XPATH_SHARED_CONFORMANCE

	XM_XPATH_SHARED_NAME_POOL

	XM_RESOLVER_FACTORY

create

	make_default

feature -- Access

	expected_result: STRING is "<?xml version=%"1.0%" encoding=%"UTF-8%"?><out><m1><a mode=%"m1%"/><b mode=%"#all%"/><b mode=%"m1%"/></m1><m2><a mode=%"m2%"/><b mode=%"#all%"/><b mode=%"m2%"/></m2></out>"
			-- Expected result.

feature -- Test

	test_next_match is
			-- Test xsl:next-match
		local
			l_transformer_factory: XM_XSLT_TRANSFORMER_FACTORY
			l_configuration: XM_XSLT_CONFIGURATION
			l_error_listener: XM_XSLT_TESTING_ERROR_LISTENER
			l_transformer: XM_XSLT_TRANSFORMER
			l_uri_source, l_second_uri_source: XM_XSLT_URI_SOURCE
			l_output: XM_OUTPUT
			l_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create l_configuration.make_with_defaults
			create l_error_listener.make (l_configuration.recovery_policy)
			l_configuration.set_error_listener (l_error_listener)
			l_configuration.set_string_mode_ascii   -- make_with_defaults sets to mixed
			l_configuration.use_tiny_tree_model (False)
			create l_transformer_factory.make (l_configuration)
			create l_uri_source.make (next_match_xsl_uri.full_reference)
			l_transformer_factory.create_new_transformer (l_uri_source, dummy_uri)
			assert ("Stylesheet compiled without errors", not l_transformer_factory.was_error)
			l_transformer := l_transformer_factory.created_transformer
			assert ("transformer", l_transformer /= Void)
			create l_second_uri_source.make (next_match_xml_uri.full_reference)
			create l_output
			l_output.set_output_to_string
			create l_result.make (l_output, "string:")
			l_transformer.transform (l_second_uri_source, l_result)
			assert ("Transform successfull", not l_transformer.is_error)
			assert ("Correct result", STRING_.same_string (l_output.last_output, expected_result))
		end

feature {NONE} -- Implementation

	data_dirname: STRING is
			-- Name of directory containing schematron data files
		once
			Result := file_system.nested_pathname ("${GOBO}",
																<<"test", "xml", "xslt", "data">>)
			Result := Execution_environment.interpreted_string (Result)
		ensure
			data_dirname_not_void: Result /= Void
			data_dirname_not_empty: not Result.is_empty
		end

	dummy_uri: UT_URI is
			-- Dummy URI
		once
			create Result.make ("dummy:")
		ensure
			dummy_uri_is_absolute: Result /= Void and then Result.is_absolute
		end
		
	next_match_xsl_uri: UT_URI is
			-- URI of file 'next_match.xsl'
		local
			l_path: STRING
		once
			l_path := file_system.pathname (data_dirname, "next_match.xsl")
			Result := File_uri.filename_to_uri (l_path)
		ensure
			next_match_xsl_uri_not_void: Result /= Void
		end
		
	next_match_xml_uri: UT_URI is
			-- URI of file 'next_match.xml'
		local
			l_path: STRING
		once
			l_path := file_system.pathname (data_dirname, "next_match.xml")
			Result := File_uri.filename_to_uri (l_path)
		ensure
			next_match_xml_uri_not_void: Result /= Void
		end
	
end
