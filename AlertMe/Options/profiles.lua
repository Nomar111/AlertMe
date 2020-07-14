dprint(3, "profiles.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates / refreshes the profiles tab
function O:ShowProfiles(container)
	dprint(2, "O:ShowProfiles", container)
	-- get options table and override order
	O.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeProfile", O.config.profiles)
	A.Libs.AceConfigDialog:Open("AlertMeProfile", container)
end
