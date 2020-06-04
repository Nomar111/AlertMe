-- get addon environment
local AlertMe = _G.AlertMe
-- lua upvalues
local pairs, print = pairs, print
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
	local frame = AceGUI:Create("Frame") --VDT_AddData(frame, "options frame");VDT_AddData(AceGUI, "AceGUI")
	-- set options title and status text
	frame:SetTitle("AlertMe Options")
	frame:SetStatusText("Version: "..version_string.." created by "..author)
	-- set callback for close
	frame:SetCallback("OnClose", CloseOptions)
	-- layout fill = tabs take all available space
	frame:SetLayout("Fill")
	-- set width, height
	frame:SetWidth(1000)
	frame:SetHeight(700)
	-- create tab group
	local tabgroup = AceGUI:Create("TabGroup")
	tabgroup:SetLayout("Flow")
	-- register callback for tab selection
	tabgroup:SetCallback("OnGroupSelected", SelectTab)
	-- set tabs and activate initial tab
	local tabs, initial = GetTable("tabs")
	tabgroup:SetTabs(tabs)
	tabgroup:SelectTab(initial)
	-- attach tabs to  main frame
	frame:AddChild(tabgroup)
	VDT_AddData(frame, "options frame")
end

function CloseOptions(widget, event)
	Debug(2, "CloseOptions", widget, event)
	-- frame recycling
	AceGUI:Release(widget)
end

function ToggleCheckbox(checkbox, event, value)
	print(checkbox, event, value)
end

function SetValue(widget, event, value)
	Debug(2,"SetValue", widget, event, value)
	local key = widget.key
	local db = widget.db
	local defaultvalue = nil
	print (db, "db", key, "key")
	if key ~= nil then
		-- try to get specific value from database
		if AlertMe.db.profile[db][key] ~= nil then
			defaultvalue = AlertMe.db.profile[db][key]
			Debug(2,"db value", key, defaultvalue)
		else
			-- get specific value from default options
			local defaults = AlertMe:GetDefaultOptions()
			defaultvalue = defaults.profile[db][key]
			Debug(2,"defaultvalue", key, defaultvalue)
			-- if no specific value found, look for wildcards
			if not defaultvalue then
				defaultvalue = defaults.profile[db]['*']
			end
		end
		if defaultvalue == nil then
			Debug(1, "No Defaultvalue found! Terminating.")
			return
		else
			if defaultvalue ~= value then
				Debug(2,"SetValue", "AlertMe.db.profile."..db.."."..key, value)
				AlertMe.db.profile[db][key] = value
			end
		end
		-- single values
	else
		-- try to get specific value from database
		if AlertMe.db.profile[db] ~= nil then
			if AlertMe.db.profile[db] ~= nil then
				defaultvalue = AlertMe.db.profile[db]
			else
				-- get specific value from default options
				local defaults = AlertMe:GetDefaultOptions()
				defaultvalue = defaults.profile[db]
				-- if no specific value found, look for wildcards
				if not defaultvalue then
					defaultvalue = defaults.profile['*']
					if defaultvalue == nil then
						Debug(1, "No Defaultvalue found! Terminating.")
						return
					else
						if defaultvalue ~= value then
							Debug(2,"SetValue", AlertMe.db.profile.."."..db, value)
							AlertMe.db.profile[db] = value
						end
					end
				end
			end
		end
	end
end



function GetValue(db,key)
	Debug(2,"GetValue", db, key)
	local value = nil
	-- multiselects/tablevalues
	if key ~= nil then
		-- try to get specific value from database
		if AlertMe.db.profile[db][key] ~= nil then
			value = AlertMe.db.profile[db][key]
		else
			-- get specific value from default options
			local defaults = AlertMe:GetDefaultOptions()
			value = defaults.profile[db][key]
			-- if no specific value found, look for wildcards
			if not value then
				value = defaults.profile[db]['*']
			end
		end
		-- single values
	else
		-- try to get specific value from database
		if AlertMe.db.profile[db] ~= nil then
			if AlertMe.db.profile[db] ~= nil then
				value = AlertMe.db.profile[db]
			else
				-- get specific value from default options
				local defaults = AlertMe:GetDefaultOptions()
				value = defaults.profile[db]
				-- if no specific value found, look for wildcards
				if not value then
					value = defaults.profile['*']
				end
			end
		end
	end
	return value
end



function CreateCheckboxGroup(container, groupname)
	Debug(2, "CreateCheckboxGroup", groupname)
	-- get corresponding table
	local conf = GetTable("zones")
	-- create group
	local group = AceGUI:Create(conf.type)
	group:SetLayout(conf.layout)
	group:SetTitle(conf.title)
	group:SetFullWidth(true)
	container:AddChild(group)
	local db = conf.db
	-- create checkboxes
	for _, cb in pairs(conf.checkboxes) do
		local checkbox = AceGUI:Create("CheckBox")
		checkbox:SetValue(GetValue(db, cb.key))
		checkbox:SetLabel(cb.label)
		checkbox:SetRelativeWidth(cb.relativewidth)
		checkbox:SetType(cb.type)
		checkbox:SetCallback("OnValueChanged", cb.callback, value)
		checkbox.db = conf.db
		checkbox.key = cb.key
		group:AddChild(checkbox)
	end
end

function SelectTab(container, event, tab)
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
		CreateCheckboxGroup(container, "zones")
		-- zones group
		--[[
		local inlinegroup = AceGUI:Create("InlineGroup")
		inlinegroup:SetLayout("Flow")
		inlinegroup:SetTitle("Addon is enabled in:")
		inlinegroup:SetFullWidth(true)
		container:AddChild(inlinegroup)
		-- zones checkboxes
		local cb_bg = AceGUI:Create("CheckBox")
		local cb_world = AceGUI:Create("CheckBox")
		local cb_raid = AceGUI:Create("CheckBox")
		cb_bg:SetValue(true)
		cb_bg:SetRelativeWidth(0.2)
		cb_bg:SetCallback("OnValueChanged", ToggleCheckbox)
		cb_world:SetValue(true)
		cb_world:SetRelativeWidth(0.2)
		cb_raid:SetValue(true)
		cb_raid:SetRelativeWidth(0.2)
		cb_bg:SetLabel("Battlegrounds")
		cb_world:SetLabel("World")
		cb_raid:SetLabel("Raid Instances")
		cb_bg:SetType("radio")
		cb_world:SetType("radio")
		cb_raid:SetType("radio")
		--ToggleChecked() - Toggle the value
		--cb_bg:OnValueChanged(ToggleCheckbox)
		inlinegroup:AddChild(cb_bg)
		inlinegroup:AddChild(cb_world)
		inlinegroup:AddChild(cb_raid)
		]]
	end






	-- get tab info
	--local tabs = GetTable("tabs", true)
	-- set header
	--local heading = AceGUI:Create("Heading")
	--heading:SetText(tabs[tab].." Options")
	--heading:SetFullWidth(true)
	--container:AddChild(heading)
end

function AlertMe:GetDefaultOptions()
	---- default values for profiles
	local o = {
		profile = {
			zones = {
				['*'] = true,
				['raid'] = false,
			},
		}
	}
	return o
end

-- various tables for tabs, dropdowns plus initial values
--local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
--local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
--local events = {["gain"] = "On aura gain/refresh", ["dispel"] = "On aura dispel", ["start"] = "On cast start"}
function GetTable(tbl, byValue)
	Debug(2, "GetTable", tbl, byValue)
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
		db = "zones",
		title = "Addon is active in:",
		type = "InlineGroup",
		layout = "Flow",
		checkboxes = {
		{
			key = "bg",
			label = "Battlegrounds",
			type = "radio",
			relativewidth = 0.2,
			callback = SetValue
		},
			{
				key = "world",
				label = "World",
				type = "radio",
				relativewidth = 0.2,
				callback = SetValue
			},
			{
				key = "raid",
				label = "Raid Instances",
				type = "radio",
				relativewidth = 0.2,
				callback = SetValue
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

--[[
function GetTabs(tab)
	local tabs = {
		"general" = {
			text = "General",
			contents = {
				{type = "Heading", text = "Zone settings"}
				{type = "InlineGroup"}
			}
		}
	}
end
]]
