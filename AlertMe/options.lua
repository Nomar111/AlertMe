-- get addon environment
local AlertMe = _G.AlertMe
-- lua upvalues
local _G = _G
local pairs, print = pairs, print
local tinsert = tinsert
-- misc upvalues
local LibStub = LibStub
-- wow upvalues
-- set addon environment as new global environment
setfenv(1, AlertMe)

function ReturnDefaultOptions()
	---- default values for profiles
	return {
		profile = {
			options= {
				zones = {
					['*'] = true
				},
				chatFrames = {
					['ChatFrame1'] = true,
					['*'] = false
				},
			},
		},
	}
end

defaults = ReturnDefaultOptions()
VDT_AddData(defaults, "defaults")

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
		text = "Zone configuration",
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
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "world",
				text = "World",
				relativeWidth = 0.1,
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
	},
	{
		widgetType = "Heading",
		text = "System messages",
		fullWidth = true
	},
	{
		widgetType = "InlineGroup",
		key = "chatFrames",
		text = "Display addon/system messages in the following chat windows",
		layout = "Flow",
		fullWidth = true,
		children = {
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "ChatFrame1",
				text = "Chat Window 1",
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "ChatFrame2",
				text = "Chat Window 2",
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "ChatFrame3",
				text = "Chat Window 3",
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "ChatFrame4",
				text = "Chat Window 4",
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
			{
				widgetType = "CheckBox",
				type = "radio",
				key = "ChatFrame5",
				text = "Chat Window 5",
				relativeWidth = 0.15,
				get = true,
				set = true,
			},
		}
	},
}

local function GetDefaultValue(parentKey, key)
	Debug(2,"GetDefaultvalue", parentKey, key)
	-- try to find specific value in defaults table
	local defaults = ReturnDefaultOptions()
	local value = defaults.profile.options[parentKey][key]
	if value ~= nil then return value	end
	-- try to find wildcards for that option
	value = defaults.profile.options[parentKey]['*']
	if value ~= nil then
		return value
	else
		Debug(1, "No Defaultvalue for parentKey", parentKey, "key", key)
		return false
	end
end

local function GetDBValue(parentKey, key)
	Debug(2,"GetDBValue", parentKey, key)
	-- try to find the value in options db --> muss eigentlich rekursiv gesucht werden!!!
	local value = AlertMe.db.profile.options[parentKey][key]
	if value ~= nil then return value	end
	-- get default value if no entry in db can be found
	value = GetDefaultValue(parentKey, key)
	if value then
		return value
	else
		return false
	end
end

local function SetDBValue(widget, event, value)
	Debug(2,"SetValue", widget, event, value)
	local key = widget.key
	local parentKey = widget.parent.key
	-- get default value
	local defaultValue = GetDefaultValue(parentKey, key)
	-- write value only to db, if it not equals default
	if defaultValue ~= value then
		AlertMe.db.profile.options[parentKey][key] = value
	elseif defaultValue == value then
		-- if value equals default value -> delete db entry
		AlertMe.db.profile.options[parentKey][key] = nil
	end
end

local function CreateWidget(container, parentKey, options)
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

local function OpenTab(container, event, tab)
	Debug(2, "SelectTab", container, event, tab)
	-- frame recycling
	container:ReleaseChildren()
	-- general options
	if tab == "general" then
			CreateWidget(container, "options", options_general)
	end
end

-- onClose callback function for widgets
local function OnClose(widget, event)
	Debug(2, "OnClose", widget, event)
	-- frame recycling
	AceGUI:Release(widget)
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
