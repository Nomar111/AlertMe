dprint(2, "window.lua")
-- upvalues
local _G = _G
local dprint = dprint
local format = format
--local SetFrameStrata = SetFrameStrata
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- open the options window
function A:OpenOptions(tab)
	dprint(2, "OpenOptions")
	-- create main frame for options
	local Frame = A.Libs.AceGUI:Create("Frame")
	Frame:SetTitle("AlertMe Options")
	--Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
	Frame:EnableResize(true)
	Frame:SetLayout("Flow")
	Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget)	end)
	-- initialize options table
	A:RefreshProfiles()
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeOptions", O.options)
	A.Libs.AceConfigDialog:SetDefaultSize("AlertMeOptions", 900, 600)
	if not tab then tab = "general" end
	A.Libs.AceConfigDialog:SelectGroup("AlertMeOptions", tab)
	A.Libs.AceConfigDialog:Open("AlertMeOptions", Frame)
end
--
-- -- tab configuration
-- tabs = {
-- 	{text = "General", value = "general"},
-- 	{text = "Event specific", value = "events"},
-- 	{text = "Alerts", value = "alerts"},
-- 	{text = "Profiles", value = "profiles"}
-- }
-- local initialTab = "general"
