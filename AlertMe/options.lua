-- get addon environment
local AlertMe = _G.AlertMe
-- misc upvalues
local LibStub = LibStub
-- wow upvalues
-- set addon environment as new global environment
setfenv(1, AlertMe)
-- various tables for options
local tabs = {{text = "General"}, {text = "Event specific"}, {text = "Alerts"}, {text = "Profiles"}}
local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
local events = {["gain"] = "On aura gain/refresh", ["dispel"] = "On aura dispel", ["start"] = "On cast start"}

-- initialize options window
function AlertMe:OpenOptions()
	Debug(2,"OpenOptions")
	-- init AceGui
	local AceGUI = LibStub("AceGUI-3.0")
	-- create main frame for options
	local frame = AceGUI:Create("Frame")
	frame.SetWidth(1200)
	frame.SetHeight(800)
	frame:SetTitle("AlertMe Options (v"..self.version..") by Nomar - Zandalar Tribe (EU)")
	--frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	-- frame:SetLayout("Flow")
	frame:SetLayout("Fill")
	-- create tab group
	local tabgroup =  AceGUI:Create("TabGroup")
	tabgroup:SetLayout("Flow")
	-- Setup which tabs to show
	tabgroup:SetTabs(tabs)
	-- Register callback
	tabgroup:SetCallback("OnGroupSelected", SelectTab)
	-- Set initial Tab (this will fire the OnGroupSelected callback)
	tabgroup:SelectTab("General")
	-- attach tabs to options frame
	frame:AddChild(tab)
end

function SelectTab(widget, event, tab)
		Debug(2,"SelectTab", widget, event, tab)
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
