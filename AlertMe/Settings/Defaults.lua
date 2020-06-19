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
		test = false,
	},
	alerts_db = {
		["**"] = {
			selected_alert = nil,
			alerts = {
				['*'] = {
					name = "New Alert",
					active = true,
					spell_names = {
						['*'] = ""
					},
					source_units = 5,
					source_exclude = 1,
					target_units = 5,
					target_exclude = 1,
					dummy = 1,
				},
			},
		},
	},
	events = {
		dd_value = 3,
		dd_items = {[1] = "Eins", [2] = "Zwei"},
	}
}
