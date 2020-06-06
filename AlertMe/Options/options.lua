dprint(3, "options.lua")
-- upvalues
local _G = _G
local dprint = dprint
local format = format
--local SetFrameStrata = SetFrameStrata
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)


-- main options function
function A:OpenOptions()
	dprint(2, "OpenOptions")
	-- create main frame for options
	local Frame = A.Libs.AceGUI:Create("Frame")
	Frame:SetTitle("AlertMe Options")
	Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
	Frame:EnableResize(true)
	Frame:SetWidth(1000)
	Frame:SetHeight(800)
	Frame:SetLayout("FLOW")
	Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget)	end)
	O.Profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	--A.Libs.AceConfigDialog:SetDefaultSize("ElvUI", 900, 680)
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeProfiles", O.Profiles)
	A.Libs.AceConfigDialog:Open("AlertMeProfiles", Frame)
end
