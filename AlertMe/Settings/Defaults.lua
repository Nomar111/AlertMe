dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	zones = {
		['*'] = true,
	},
	chat_frames ={
		['*'] = true,
<<<<<<< HEAD
	},
	-- alerts_events  = {
	-- 	['*'] = {
	-- 		create_alert = "X",
	-- 	}
	-- },
=======
	}
>>>>>>> parent of d98925e... optionen - alerts
}
