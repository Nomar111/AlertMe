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
	-- alerts_db = {
	-- 	["*"] = {
	-- 		alerts = {
	-- 			["*"] = {
	-- 				name = "New alert",
	-- 				active = "false",
	-- 				src_units = 5,
	-- 				src_units_exclude = 1,
	-- 				dst_units = 5,
	-- 				dst_units_exclude = 1,
	-- 			},
	-- 		}
	-- 	},
	-- },
}
