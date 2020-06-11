dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, type, unpack = _G, dprint, FCF_GetNumActiveChatFrames, type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.options = nil
O.order = 1
O.elvl = 2 -- That's the level functions assume the events to be

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
	if tab == nil then tab = "general" end
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
	-- set handler and standard get/set functions
	O.options.handler = O
	O.options.get = "GetOption"
	O.options.set = "SetOption"
	VDT_AddData(O.options, "options")
	-- second level
	O.options.args.general = O:CreateGroup("General", "", 1)
	O.options.args.events = O:CreateGroup("Event")
	O.options.args.alerts = O:CreateGroup("Alerts", "Create your alerts")
	O.options.args.profiles = O:CreateGroup("Profiles")
	O.options.args.info = O:CreateGroup("Info")
	-- general_main
	O:CreateGeneralOptions(O.options.args.general.args)
	-- profiles
	O:CreateProfileOptions()
	-- info
	O:CreateInfoOptions(O.options.args.info.args)
	-- alerts
	O:CreateAlertOptions(O.options.args.alerts.args)

end

-- creates the general options tab
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

-- creates the info tab
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
	-- check if options table is initialized - this function may get called by other functions too
	if not O.options then return end
	-- get options table and override order
	O.options.args.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	O.options.args.profiles.order = 4
end

-- return a table reference and key from info
function O:GetInfoPath(info, relative, num)
	--dprint(1, unpack(info))
	--dprint(1, "rel", relative, "num", num)
	local count = num
	if relative == true then count = (#info + num) end
	local path = P
	-- loop until lvl
	for i = 1, count do
		path = path[info[i]]
	end
	--dprint(1, "ofs", num, "returned path", path)
	return path
end

-- standard get
function O:GetOption(info, key)
	--dprint(1, "GetOption", "key", key, unpack(info))
	local offset = 0
	-- get parent object
	if key == nil then
		key = info[#info]
		offset = -1
	end
	local parent = O:GetInfoPath(info, true, offset)
	return parent[key]
end

-- standard set
function O:SetOption(info, arg2, value)
	--dprint(1, "SetOption", unpack(info))
	local offset = 0
	-- get parent object
	if value == nil then
		key = info[#info]
		offset = -1
		value = arg2
	else
		key = arg2
	end
	local parent = O:GetInfoPath(info, true, offset)
	parent[key] = value
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
	-- increase order numbers automatically if not provided
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
