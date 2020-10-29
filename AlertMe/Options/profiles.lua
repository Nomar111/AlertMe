-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates / refreshes the profiles tab
function O:ShowProfiles(container)
	-- get options table and override order
	O.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeProfile", O.config.profiles)
	local profilesGroup = O.AttachGroup(container, "simple", _, {fullWidth = true, fullHeight = true, layout = "Flow"})
	A.Libs.AceConfigDialog:Open("AlertMeProfile", profilesGroup)
end
