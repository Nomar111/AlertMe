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

local tabs = {
	{text = "General", value = "general"},
	{text = "Event specific", value = "events"},
	{text = "Alerts", value = "alerts"},
	{text = "Profiles", value = "profiles"}
}
local initialTab = "general"

local options_general = {
	{
		widgetType = "Heading",
		text = "General Options",
		fullWidth = true
	},
	{
		widgetType = "InlineGroup",
		key = "zones",
		text = "Addon is activated in:",
		layout = "Flow",
		fullWidth = true,
		children = {
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "bg",
				text = "Battlegrounds",
				relativeWidth = 0.2,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "world",
				text = "World",
				relativeWidth = 0.2,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "raid",
				text = "Raid Instances",
				relativeWidth = 0.2,
				get = true,
				set = true,
			}
		}
	}
}

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
			CreateWidget(container, "options", options_general)
	end
end

function CreateWidget(container, parentKey, options)
	Debug(2, "CreateWidget", container, options)
	-- loop over elements on this level
	for _, element in pairs(options) do
		-- create widget
		local widget = AceGUI:Create(element.widgetType)
		-- set label/text/title
		if element.widgetType == "InlineGroup" then
			widget:SetTitle(element.text)
		elseif element.widgetType == "CheckBox" then
			widget:SetLabel(element.text)
		elseif element.widgetType == "Heading" then
			widget:SetText(element.text)
		end
		-- set key
		if element.key then
			widget.key = element.key
		end
		-- layout
		if element.layout then
			widget:SetLayout(element.layout)
		end
		-- width
		if element.fullWidth then
			widget:SetFullWidth(true)
		elseif element.relativeWidth then
			widget:SetRelativeWidth(element.relativeWidth)
		end
		-- type
		if element.type then
			widget:SetType(element.type)
		end
		-- get callback
		if element.get then
			local value = GetDBValue(parentKey, element.key)
			widget:SetValue(value)
		end
		-- set callback
		if element.set then
			widget:SetCallback("OnValueChanged", SetDBValue, value)
		end
		-- add to container
		container:AddChild(widget)
		-- check for children, if yes recursive function call
		if element.children then
			CreateWidget(widget, element.key, element.children)
		end
	end
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
	tabGroup:SetTabs(tabs)
	tabGroup:SelectTab(initialTab)
	-- attach tabs to  main frame
	f:AddChild(tabGroup)
	--VDT_AddData(OptionsFrame, "optionsFrame")
	--VDT_AddData(AceGUI, "AceGUI")
end

function GetDBValue(parentKey, key)
	Debug(2,"GetDBValue", parentKey, key)
	-- try to find the value in options db --> muss eigentlich rekursiv gesucht werden!!!
	local value = AlertMe.db.profile.options[parentKey][key]
	if value ~= nil then return value end
	-- try to find specific value in defaults table
	local defaults = ReturnDefaultOptions()
	value = defaults.profile.options[parentKey][key]
	if value ~= nil then return value end
	-- try to find wildcards for that option
	value = defaults.profile[parentKey]['*']
	if value ~= nil then return value end
	return false
end

function SetDBValue(widget, event, value)
	Debug(2,"SetValue", widget, event, value)
	VDT_AddData(widget, "setdbvalue - widget")
	local key = widget.key
	local parentKey = widget.parent.key
	-- get current db value
	local valueDB = GetDBValue(parentKey, key)
	if valueDB ~= nil and valueDB ~= value then
		AlertMe.db.profile.options[parentKey][key] = value
	end
end

function ToggleCheckbox(checkbox, event, value)
	print(checkbox, event, value)
end
