dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	general = {
		zones = {
			["*"] = true,
		},
		chat_frames ={
			["*"] = true,
		},
		test = true
	},
	alerts = {
		["*"] = {							-- events
			--select_alert = 1,
			alert_settings = {
				["*"] = { 					-- alerts (key = creationtime)
					name = "New Alert",
					active = false,
					testbox = false,
				},
			},
		},
	},
	alerts_db = {
		["*"] = { 		-- events
			["*"] = {	-- uid
				name = "NEUE",
				active = true,
				testbox = false,
			}
		}
	}

}
