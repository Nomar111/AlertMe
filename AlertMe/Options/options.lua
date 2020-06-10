dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, type, unpack = _G, dprint, FCF_GetNumActiveChatFrames, type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- set some variables
O.options = nil
O.order = 1

-- *************************************************************************************
-- open the options window
function O:OpenOptions(tab)
	dprint(2, "O:OpenOptions")
	-- create main frame for options
	if O.Frame == nil then
		O.Frame = A.Libs.AceGUI:Create("Frame")
		O.Frame:SetTitle("AlertMe Options")
		--Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
		O.Frame:EnableResize(true)
		O.Frame:SetLayout("Flow")
		O.Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget)	end)
	else
		O.Frame:Show()
	end
	-- create options table
	O:CreateOptions()
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeOptions", O.options)
	A.Libs.AceConfigDialog:SetDefaultSize("AlertMeOptions", 950, 680)
	-- open the options window at a certainn group/tab
	if tab == nil then tab = "general_main" end
	A.Libs.AceConfigDialog:SelectGroup("AlertMeOptions", tab)
	A.Libs.AceConfigDialog:Open("AlertMeOptions", O.Frame)
end

-- *************************************************************************************
-- creates the options table
function O:CreateOptions()
	dprint(2, "O:CreateOptions")
	-- if table was already initialized, abort
	if O.options ~= nil then
		dprint(1, "options table not nil!")
		return
	end
	-- create first and second level (main tabs) here
	O.options = O:CreateGroup("AlertMeOptions", "", 1, "tree")
	O.options.handler = O
	O.options.get = "GetOption"
	O.options.set = "SetOption"
	-- second level
	O.options.args.general_main = O:CreateGroup("General", "", 1)
	O.options.args.events_main = O:CreateGroup("Event")
	O.options.args.alerts_main = O:CreateGroup("Alerts", "Create your alerts")
	O.options.args.profiles_main = O:CreateGroup("Profiles")
	O.options.args.info_main = O:CreateGroup("Info")
	-- general_main
	O:CreateGeneralOptions(O.options.args.general_main.args)
	-- profiles
	O:CreateProfileOptions()
	-- info
	O:CreateInfoOptions(O.options.args.info_main.args)
	-- alerts
	O:CreateAlertOptions(O.options.args.alerts_main.args)

end

-- creates the general_main options tab
function O:CreateGeneralOptions(o)
	-- some local tables for populating dropdowns etc.
	local zone_types = {bg = "Battlegrounds", world = "World", raid = "Raid Instances"}
	-- header
	o.header = O:CreateHeader("General Options")
	-- zones multi
	o.zones = {
		type = 'multiselect',
		name = "Addon is enabled in",
		order = 1,
		values = zone_types,
	}
	-- chat frames multi
	o.chat_frames = {
		type = 'multiselect',
		name = "Display addon messages in the following chat windows",
		order = 10,
		values = O:GetChatFrameInfo(),
	}
	o.test = {
		type = "toggle",
		name = "test",
		order = 99,
	}
end

-- creates the info_main tab
function O:CreateInfoOptions(o)
	o.header = O:CreateHeader("Addon Info")
	o.addonInfo = {
		type = "description",
		name = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR,
		fontSize = "medium",
		order = 2
	}
end

-- creates / refreshes the profiles tab
function O:CreateProfileOptions()
	-- check if options table is initialized
	if not O.options then return end
	-- get options table and override order
	O.options.args.profiles_main = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	O.options.args.profiles_main.order = 4
end

-- return a table reference and key from info
function O:GetInfoPath(info)
	local i = 1
	local path = A.db.profile
	local key = ""
	while info[i] ~= nil do
		-- check if item is table
		local object = path[info[i]]
		if type(object) == "table" then
			path = path[info[i]]
		else
			key = info[i]
		end
		i = i + 1
	end
	return path, key
end

-- standard get
function O:GetOption(info, key)
	dprint(1, "GetOption", unpack(info))
	local path, key_ = O:GetInfoPath(info)
	if not key then key = key_ end
	return path[key]
end

-- standard set
function O:SetOption(info, arg2, arg3)
	dprint(1, "SetOption", unpack(info))
	local path, key_ = O:GetInfoPath(info)
	local value, key
	if arg3 == nil then
		key = key_
		value = arg2
	else
		key = arg2
		value = arg3
	end
	path[key] = value
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
function O:CreateGroup(name, desc, order, childGroups)
	-- count orders up automatically if not provided
	if order == nil then
		order = O.order
	end
	local group = {
		type = "group",
		name = name,
		desc = desc,
		childGroups = childGroups,
		order = order,
		args = {}
	}
	O.order = order + 1
	return group
end

function O:CreateSpacer(order, width)
	local spacer = {
		name = '',
		type = 'description',
		order = order,
		cmdHidden = true,
		width = width/10,
	}
	return spacer
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