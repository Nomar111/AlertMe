-- get addon environment
local AlertMe = _G.AlertMe
-- lua upvalues
local pairs, print = pairs, print
-- misc upvalues
local LibStub = LibStub
-- wow upvalues
-- set addon environment as new global environment
setfenv(1, AlertMe)

function AlertMe:ReturnDefaultOptions()
	---- default values for profiles
	return {
		profile = {
			options= {
				zones = {
					['*'] = true,
					['raid'] = false,
				},
			},
		},
	}
end

local function ReturnOptionsTable(tbl, byValue)
	Debug(2, "ReturnOptionsTable", tbl, byValue)
	local t =  {}
	-- tabs
	t["tabs"] = {
		{text = "General", value = "general"},
		{text = "Event specific", value = "events"},
		{text = "Alerts", value = "alerts"},
		{text = "Profiles", value = "profiles"}
	}
	t["tabs_initial"] = "general"
	-- zone types
	t["zones"] = {
		name = "zones",
		title = "Addon is active in:",
		widgetType = "InlineGroup",
		layout = "Flow",
		children = {
			{
				key = "bg",
				widgetType = "CheckBox",
				type = "radio",
				label = "Battlegrounds",
				relativewidth = 0.2,
				callback = SetDBValue
			},
			{
				key = "world",
				widgetType = "CheckBox",
				type = "radio",
				label = "World",
				relativewidth = 0.2,
				callback = SetDBValue
			},
			{
				key = "raid",
				widgetType = "CheckBox",
				type = "radio",
				label = "Raid Instances",
				relativewidth = 0.2,
				callback = SetDBValue
			},
		}
	}
	-- return requested table
	if not byValue then
		local initial = ""
		if t[tbl.."_initial"] ~= nil then
			initial = t[tbl.."_initial"]
		end
		return t[tbl], initial

	else
		local val = {}
		for _, tab in pairs(t[tbl]) do
			val[tab.value] = tab.text
		end
		return val
	end
end

-- onClose callback function for widgets
local function OnClose(widget, event)
	Debug(2, "OnClose", widget, event)
	-- frame recycling
	AceGUI:Release(widget)
end

local function OpenTab(container, event, tab)
	Debug(2, "SelectTab", container, event, tab)
	-- frame recycling
	container:ReleaseChildren()
	-- general options
	if tab == "general" then
		-- heading
		local heading = AceGUI:Create("Heading")
		heading:SetText("General Options")
		heading:SetFullWidth(true)
		container:AddChild(heading)
		CreateGroup(container, "zones")
	end
end

function CreateGroup(container, optionsTableName)
	Debug(2, "CreateGroup", container, optionsTableName)
	-- get corresponding table
	local options = ReturnOptionsTable(optionsTableName)
	VDT_AddData(options, "OptionsTableZones")
	-- create group
	local group = AceGUI:Create(options.widgetType)
	group:SetTitle(options.title)
	group:SetLayout(options.layout)
	group:SetFullWidth(true)
	group.name = options.name
	container:AddChild(group)
	Debug(1, options, "options table bei Group Creation")
	-- create checkboxes
	for _, child in pairs(options.children) do
		local widget = AceGUI:Create(child.widgetType)
		local value = GetDBValue(options.name, child.key)
		widget:SetValue(value)
		widget:SetLabel(child.label)
		widget:SetRelativeWidth(child.relativewidth)
		widget:SetType(widget.type)
		widget:SetCallback("OnValueChanged", child.callback, value)
		widget.optionsTable = options
		widget.parentName = options.name
		widget.key = child.key
		group:AddChild(widget)
	end
	VDT_AddData(group, "ZonesGroupinFrame")
end

-- initialize options window
function AlertMe:OpenOptions()
	Debug(2, "OpenOptions")
	-- init AceGui
	AceGUI = LibStub("AceGUI-3.0")
-- create main frame for options
	local optionsFrame = AceGUI:Create("Frame") --VDT_AddData(frame, "options frame");VDT_AddData(AceGUI, "AceGUI")
	local f = optionsFrame
	-- set options title and status text
	f:SetTitle("AlertMe Options")
	f:SetStatusText("Version: "..version_string.." created by "..author)
	-- set callback for close
	f:SetCallback("OnClose", OnClose)
	-- layout fill = tabs take all available space
	f:SetLayout("Fill")
	-- set width, height
	f:SetWidth(1000)
	f:SetHeight(700)
	-- create tab group
	local tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetLayout("Flow")
	-- register callback for tab selection
	tabGroup:SetCallback("OnGroupSelected", OpenTab)
	-- set tabs and activate initial tab
	local tabs, initial = ReturnOptionsTable("tabs")
	tabGroup:SetTabs(tabs)
	tabGroup:SelectTab(initial)
	-- attach tabs to  main frame
	f:AddChild(tabGroup)
	--VDT_AddData(OptionsFrame, "optionsFrame")
	--VDT_AddData(AceGUI, "AceGUI")
end

function GetDBValue(parentName, key)
	Debug(2,"GetDBValue", parentName, key)
	-- try to find the value in options db --> muss eigentlich rekursiv gesucht werden!!!
	local value = AlertMe.db.profile.options[parentName][key]
	if value ~= nil then return value end
	-- try to find specific value in defaults table
	local defaults = ReturnDefaultOptions()
	value = defaults.profile.options[parentName][key]
	if value ~= nil then return value end
	-- try to find wildcards for that option
	value = defaults.profile[parentName]['*']
	if value ~= nil then return value end
	Debug(1, "Option key", key, "not found under parent", parentName)
	return false
end

function SetDBValue(widget, event, value)
	Debug(2,"SetValue", widget, event, value)
	VDT_AddData(widget, "setdbvalue - widget")
	local key = widget.key
	local parentName = widget.parent.name
	-- get current db value
	local valueDB = GetDBValue(parentName, key)
	Debug(1,valueDB, "valueDB on Set")
	if valueDB ~= nil and valueDB ~= value then
		AlertMe.db.profile.options[parentName][key] = value
	end
end

function ToggleCheckbox(checkbox, event, value)
	print(checkbox, event, value)
end
-- various tables for tabs, dropdowns plus initial values
--local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
--local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
--local events = {["gain"] = "On aura gain/refresh", ["dispel"] = "On aura dispel", ["start"] = "On cast start"}
