note
	description	: "Strings for the Graphical User Interface"
	author		: "Generated by the New Vision2 Application Wizard."
	date		: "$Date: 2013/8/7 12:14:28 $"
	revision	: "1.0.0"

class
	INTERFACE_NAMES

feature -- Access

	Button_ok_item: STRING = "OK"
			-- String for "OK" buttons.

	Menu_file_item: STRING = "&File"
			-- String for menu "File"

	Menu_file_new_item: STRING = "&New%TCtrl+N"
			-- String for menu "File/New"

	Menu_file_open_item: STRING = "&Open...%TCtrl+O"
			-- String for menu "File/Open"

	Menu_file_save_item: STRING = "&Save%TCtrl+S"
			-- String for menu "File/Save"

	Menu_file_saveas_item: STRING = "Save &As..."
			-- String for menu "File/Save As"

	Menu_file_close_item: STRING = "&Close"
			-- String for menu "File/Close"

	Menu_file_exit_item: STRING = "E&xit"
			-- String for menu "File/Exit"

	Menu_communication_item: STRING = "&Communication"
			-- String for menu "Communication

	Menu_communication_connect_item: STRING = "C&onnect"
			-- String for menu "Communication/Connect"

	Menu_communication_send_message_item: STRING = "Send &message"
			-- String for menu "Communication/Send message"

	Menu_communication_disconnect_item: STRING = "&Disconnect"
			-- String for menu "Communication/Disconnect"

	Menu_configuration_item: STRING = "C&onfiguration"
			-- String for menu "Configuration"

	Menu_configuration_create_database_item: STRING = "&Create database"
			-- String for menu "Configuration/Create database"

	Menu_configuration_run_script_item: STRING = "&Run script"
			-- String for menu "Configuration/Run script"

	Menu_help_item: STRING = "&Help"
			-- String for menu "Help"

	Menu_help_contents_item: STRING = "&Contents and Index"
			-- String for menu "Help/Contents and Index"

	Menu_help_about_item: STRING = "&About..."
			-- String for menu "Help/About"

	Label_confirm_close_window: STRING = "You are about to close this window.%NClick OK to proceed."
			-- String for the confirmation dialog box that appears
			-- when the user try to close the first window.

end -- class INTERFACE_NAMES
