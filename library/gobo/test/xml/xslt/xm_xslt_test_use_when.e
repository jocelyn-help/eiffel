indexing

	description:

	"[
		Test use of use-when attribute.
		This class tests conditional compilation ([xsl:]use-when)
	]"

	library: "Gobo Eiffel XSLT test suite"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "MIT License"
	date: "$Date: 2008-02-13 12:34:45 +0100 (Wed, 13 Feb 2008) $"
	revision: "$Revision: 6301 $"

class XM_XSLT_TEST_USE_WHEN

inherit

	TS_TEST_CASE

	KL_IMPORTED_STRING_ROUTINES

	XM_XPATH_SHARED_CONFORMANCE

	XM_XPATH_SHARED_NAME_POOL

	XM_XPATH_STANDARD_NAMESPACES

	XM_RESOLVER_FACTORY

	XM_XSLT_SHARED_EMITTER_FACTORY

create

	make_default

feature -- Test

	test_use_when is
			-- Test use-when
		local
			l_transformer_factory: XM_XSLT_TRANSFORMER_FACTORY
			l_configuration: XM_XSLT_CONFIGURATION
			l_error_listener: XM_XSLT_TESTING_ERROR_LISTENER
			l_transformer: XM_XSLT_TRANSFORMER
			l_uri_source: XM_XSLT_URI_SOURCE
			l_output: XM_OUTPUT
			l_result: XM_XSLT_TRANSFORMATION_RESULT
		do
			conformance.set_basic_xslt_processor
			create l_configuration.make_with_defaults
			create l_error_listener.make (l_configuration.recovery_policy)
			l_configuration.set_error_listener (l_error_listener)
			create l_transformer_factory.make (l_configuration)
			create l_uri_source.make (use_when_xsl_uri.full_reference)
			l_transformer_factory.create_new_transformer (l_uri_source, dummy_uri)
			assert ("Stylesheet compiled without errors", not l_transformer_factory.was_error)
			l_transformer := l_transformer_factory.created_transformer
			assert ("transformer", l_transformer /= Void)
			l_transformer.set_initial_template ("first")
			assert ("Initial template set", l_transformer.initial_template /= Void)
			create l_output
			l_output.set_output_to_string 
			create l_result.make (l_output, "string:")
			l_transformer.transform (Void, l_result)
			assert ("Transform successfull", not l_transformer.is_error)
			assert ("Correct result", STRING_.same_string (l_output.last_output, "OK"))
		end

feature {NONE} -- Implementation

	data_dirname: STRING is
			-- Name of directory containing data files
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
		
	use_when_xsl_uri: UT_URI is
			-- URI of file 'use_when.xsl'
		local
			l_path: STRING
		once
			l_path := file_system.pathname (data_dirname, "use_when.xsl")
			Result := File_uri.filename_to_uri (l_path)
		ensure
			use_when_xsl_uri_not_void: Result /= Void
		end
		
end
