-- get addon environment
local AlertMe = _G.AlertMe
-- misc upvalues
local LibStub = LibStub
-- wow upvalues
-- set addon environment as new global environment
setfenv(1, AlertMe)


-- initialize options window
function AlertMe:OpenOptions()
	Debug(2, "OpenOptions")
	-- init AceGui
	AceGUI = LibStub("AceGUI-3.0")
	-- create main frame for options
	local frame = AceGUI:Create("Frame")
	VDT_AddData(frame, "options frame")
	VDT_AddData(AceGUI, "AceGUI")
	frame:SetTitle("AlertMe Options")
	frame:SetStatusText("Version: "..version_string.." created by "..author)
	frame:SetCallback("OnClose", CloseOptions)
	-- frame:SetLayout("Flow")
	frame:SetLayout("Fill")
	frame:SetWidth(1000)
	frame:SetHeight(700)
	-- create tab group
	local tabgroup = AceGUI:Create("TabGroup")
	tabgroup:SetLayout("Flow")
	-- Register callback
	tabgroup:SetCallback("OnGroupSelected", SelectTab)
	-- set tabs and activate initial tab
	local tabs, initial = GetTable("tabs")
	tabgroup:SetTabs(tabs)
	tabgroup:SelectTab(initial)
	-- attach tabs to  main frame
	frame:AddChild(tabgroup)
end

function CloseOptions(widget, event)
	Debug(2, "CloseOptions", widget, event)
	-- frame recycling
	AceGUI:Release(widget)
end

function SelectTab(container, event, tab)
	Debug(2, "SelectTab", container, event, tab)
	-- frame recycling
	--container:ReleaseChildren()
	OpenTab(tab)
end

function OpenTab(tab)
	Debug(2, "OpenTab", tab)
end

function AlertMe:GetDefaultOptions()
	---- default values for profiles
	local o = {
		profile = {
			zones = {
				['*'] = true
			},
		}
	}
	return o
end

-- various tables for tabs, dropdowns plus initial values
--local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
--local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
--local events = {["gain"] = "On aura gain/refresh", ["dispel"] = "On aura dispel", ["start"] = "On cast start"}
function GetTable(tbl)
	local t =  {}
	-- tabs
	t["tabs"] = {
		{text = "General", value = "general"},
		{text = "Event specific", value = "events"},
		{text = "Alerts", value = "alerts"},
		{text = "Profiles", value = "profiles"}
	}
	t["tabs"].initial = "general"
	-- return requested table
	return t[tbl], t["tabs"].initial
end
