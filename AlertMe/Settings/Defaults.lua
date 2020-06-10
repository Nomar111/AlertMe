dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	general_main = {
		zones = {
			['*'] = true,
		},
		chat_frames ={
			['*'] = true,
		},
		test = true
	},
	alerts_main = {
		['*'] = {
			--select_alert = 1,
			alerts = {},
		},
	},
}
