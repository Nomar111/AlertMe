dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, type, tinsert = _G, dprint, FCF_GetNumActiveChatFrames, type, table.insert
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- set some variables
O.options = nil
O.order = 1

-- *************************************************************************************
-- open the options window
function O:OpenOptions()
	dprint(2, "OpenOptions")
	-- create main frame for options
	local Frame = A.Libs.AceGUI:Create("Frame")
	Frame:SetTitle("AlertMe Options")
	--Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
	Frame:EnableResize(true)
	Frame:SetLayout("Flow")
	Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget)	end)
	-- initialize options table
	O:InitOptions()
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeOptions", O.options)
	A.Libs.AceConfigDialog:SetDefaultSize("AlertMeOptions", 950, 680)
	--if not tab then tab = "general" end
	--A.Libs.AceConfigDialog:SelectGroup("AlertMeOptions", tab)
	A.Libs.AceConfigDialog:Open("AlertMeOptions", Frame)
end

-- *************************************************************************************
-- initializes the options table
function O:InitOptions()
	dprint(2, "O:InitOptions")
	-- if table was already initialized, abort
	if O.options ~= nil then return	end

	-- create first and second level (main tabs) here
	O.options = O:CreateGroup("AlertMeOptions", _, _, "tree")
	O.options.handler = O
	-- second level
	O.options.args.general = O:CreateGroup("General", _, true)
	O.options.args.events = O:CreateGroup("Event")
	O.options.args.alerts = O:CreateGroup("Alerts", "Create your alerts")
	O.options.args.profiles = O:CreateGroup("Profiles")
	O.options.args.info = O:CreateGroup("Info")
	-- general
	O:CreateGeneral(O.options.args.general.args)
	-- profiles
	O:CreateProfiles()
	-- info
	O:CreateInfo(O.options.args.info.args)
	-- alerts
	O:CreateAlerts(O.options.args.alerts.args)

end

-- creates the general options tab
function O:CreateGeneral(o)
	-- some local tables for populating dropdowns etc.
	local zone_types = {bg = "Battlegrounds", world = "World", raid = "Raid Instances"}
	-- header
	o.header = O:CreateHeader("General Options")
	-- zones multi
	o.zones = {
		type = 'multiselect',
		name = "Addon is enabled in",
		order = 5,
		values = zone_types,
		get = 'GetOptions',
		set = 'SetOptions',
	}
	-- chat frames multi
	o.chat_frames = {
		type = 'multiselect',
		name = "Display addon messages in the following chat windows",
		order = 10,
		values = O:GetChatFrameInfo(),
		get = 'GetOptions',
		set = 'SetOptions',
	}
	o.test = {
		type = "toggle",
		name = "test",
		set = "SetOption",
		get = "GetOption",
	}
end

-- creates the info tab
function O:CreateInfo(o)
	o.header = O:CreateHeader("Addon Info")
	o.addonInfo = {
		type = "description",
		name = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR,
		fontSize = "medium",
		order = 2
	}
end

-- creates / refreshes the profiles tab
function O:CreateProfiles()
	-- check if options table is initialized
	if not O.options then return end
	-- get options table and override order
	O.options.args.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	O.options.args.profiles.order = 4
end

-- return a table reference from info
function O:GetInfoPath(info)
	--VDT_AddData(info,"info")
	local i = 1
	local path = A.db.profile
	while info[i] ~= nil do
		path = path[info[i]]
		i = i + 1
	end
	--VDT_AddData(path, "path")
	return path
end

-- callback functions for multiple values
function O:GetOptions(info, key)
	local path = O:GetInfoPath(info)
	return path[key]
end

function O:SetOptions(info , key, value)
	local path = O:GetInfoPath(info)
	path[key] = value
end

-- callback functions for single values
function O:GetOption(info)
	local path = O:GetInfoPath(info)
	return path
end

function O:SetOption(info, value)
	local path = O:GetInfoPath(info)
	path = value
end

-- create standard header
function O:CreateHeader(name, order)
	local header = {
		type = "header",
		name = name,
		order = (order ~= nil) and order or 1,
	}
	return header
end

-- create standard groups with order
function O:CreateGroup(name, desc, reset_order, childGroups)
	if reset_order then O.order = 1 end
	local group = {
		type = "group",
		name = name,
		desc = desc,
		childGroups = childGroups,
		order = O.order,
		args = {}
	}
	O.order = O.order + 1
	return group
end

function O:GetChatFrameInfo()
	local chat_frames = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			chat_frames["ChatFrame"..i] = name
		end
	end
	return chat_frames
end
