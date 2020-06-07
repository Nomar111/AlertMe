dprint(3, "options.lua")
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)
--O.Profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)

function A:InitOptions()
	--local Profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- define options table
	O.Tabs = {
		type = "group",
		childGroups = "tabs",
		args = {
			General = {
				type = "group",
				name = "General",
				desc = "General Settings",
				type = "group",
				order = 1,
				args = {}
			},
			Events = {
				type = "group",
				name = "Events",
				desc = "Event Settings",
				order = 2,
				args = {}
			},
			Alerts = {
				type = "group",
				name = "Alerts",
				desc = "Alert Setup",
				order = 3,
				args = {}
			},
			Profiles = {
				type = "group",
				name = "Profiles",
				desc = "Profile Settings",
				order = 4,
				args = Profiles
			}
		}
	}
	O.Tabs.args.Profiles =  A.Libs.AceDBOptions:GetOptionsTable(A.db)
end
