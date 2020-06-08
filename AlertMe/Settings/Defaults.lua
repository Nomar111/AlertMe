dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	general = {
		zones = {
			['*'] = true,
		},
		chat_frames ={
			['*'] = true,
		},
		test = true
	},
	alerts = {
		['*'] = {
			event_control = {
				--create_alert = "X",
				select_alert = 1,
				alerts = {}
			}
		}
	}
}
