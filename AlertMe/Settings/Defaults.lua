dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...)); --Import: Engine, Defaults
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
			--alert_name = "New Alert",
			--select_alert = "",
			alerts = {[1] = "TestAlert1", [2] = "TestAlert2", [3] = "TestAlert3"},
			-- alert_settings = {
			-- 	['*'] = {
			-- 		test = true,
			-- 	},
			-- },
		},
	},
}
