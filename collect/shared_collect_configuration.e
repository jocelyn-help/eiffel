note
	description: "Summary description for {SHARED_COLLECT_CONFIGURATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_COLLECT_CONFIGURATION

feature -- Access

	config: separate COLLECT_CONFIGURATION
		do
			separate config_cell as cell do
				Result := cell.item
			end
		end

	is_utc_set: BOOLEAN
		do
			separate config as cfg do
				Result := cfg.is_utc_set
			end
		end

	use_testing_ws: BOOLEAN
		do
			separate config as cfg do
				Result := cfg.use_testing_ws
			end
		end

feature {NONE} -- Implementation

	config_cell: separate CELL [separate COLLECT_CONFIGURATION]
		once ("process")
			create Result.put (create {COLLECT_CONFIGURATION}.make (create {PATH}.make_current))
		end

	set_config (cfg: COLLECT_CONFIGURATION)
		do
			separate config_cell as cell do
				cell.replace (cfg)
			end
		end


end
