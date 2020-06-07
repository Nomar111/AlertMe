dprint(3, "window.lua")
-- upvalues
local _G = _G
local dprint = dprint
local format = format
--local SetFrameStrata = SetFrameStrata
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

--[[
	O.Profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	--A.Libs.AceConfigDialog:SetDefaultSize("ElvUI", 900, 680)
]]

-- main options function
function A:OpenOptions()
	dprint(2, "OpenOptions")
	-- create main frame for options
	local Frame = A.Libs.AceGUI:Create("Frame")
	Frame:SetTitle("AlertMe Options")
	Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
	Frame:EnableResize(true)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame:SetLayout("Flow")
	Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget)	end)
	-- initialize options table
	A:InitOptions()
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeOptions", O.Tabs)
	A.Libs.AceConfigDialog:Open("AlertMeOptions", Frame)
	-- create tab group
	-- local TabGroup = A.Libs.AceGUI::Create("TabGroup")
	-- tabGroup:SetLayout("Flow")
	-- tabGroup:SetCallback("OnGroupSelected", OpenTab)
	-- tabGroup:SetTabs(tabs)
	-- tabGroup:SelectTab(initialTab)
	-- -- attach tabs to  main frame
	-- f:AddChild(tabGroup)
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
