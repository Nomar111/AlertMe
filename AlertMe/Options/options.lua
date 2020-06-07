dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, unpack = _G, dprint, FCF_GetNumActiveChatFrames, unpack
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)
O.options = nil

function A:InitOptions()
	dprint(2, "A:InitOptions")
	-- if table was already initialized, abort
	if O.options ~= nil then
		return
	end

	-- create standard groups with order
	O.order = 1
	local function CreateGroup(name, desc, childGroups, reset_order)
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
	-- create standard header
	local function CreateHeader(name, order)
		local header = {
			type = "header",
			name = name,
			order = (order ~= nil) and order or 1,
		}
		return header
	end

	-- first level
	O.options = CreateGroup("AlertMeOptions", _, "tree")
	O.options.handler = A
	-- second level
	O.options.args.general = CreateGroup("General", _, _, true)
	O.options.args.events = CreateGroup("Event")
	O.options.args.alerts = CreateGroup("Alerts", "Create your alerts", _)
	O.options.args.profiles = CreateGroup("Profiles")
	O.options.args.info = CreateGroup("Info")

	-- general
	local zone_types = {bg = "Battlegrounds", world = "World", raid = "Raid Instances"}
	O.options.args.general.args.header = CreateHeader("General Options")
	O.options.args.general.args.zones = {
		type = 'multiselect',
		name = "Addon is enabled in",
		order = 5,
		values = zone_types,
		get = 'GetOptions',
		set = 'SetOptions',
	}
	O.options.args.general.args.chat_frames = {
		type = 'multiselect',
		name = "Display addon messages in the following chat windows",
		order = 10,
		values = A:GetChatInfo(),
		get = 'GetOptions',
		set = 'SetOptions',
	}

	-- profiles
	A:RefreshProfiles()

	-- info
	O.options.args.info.args.header = CreateHeader("Addon Info")
	O.options.args.info.args.addonInfo = {
		type = "description",
		name = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR,
		fontSize = "medium",
		order = 2
	}

	-- alerts: eventtabs - preparation
	local opt = O.options.args.alerts.args
	opt.gain = CreateGroup("On aura gain", _, _, true)
	opt.dispel = CreateGroup("On spell dispel")
	opt.start = CreateGroup("On cast start")
	opt.success = CreateGroup("On cast success")
	opt.interrupt = CreateGroup("On interrupt")
	opt.gain.args.header = CreateHeader("On aura gain & refresh")
	opt.dispel.args.header = CreateHeader("On spell dispel")
	opt.start.args.header = CreateHeader("On spell cast start")
	opt.success.args.header = CreateHeader("On spell cast success")
	opt.interrupt.args.header = CreateHeader("On interrupt")

	-- prepare event control
	local event_control = {
		type = "group",
		name = "",
		desc = "Create, edit, delete alerts",
		inline = true,
		order = 2,
		args = {
			create_alert = {
				type = "input",
				name = "New alert",
				desc = "Name of new event",
				order = 1,
				--get = "",
				--set = ""
			},
		}
	}
	-- attach to options
	opt.gain.args.event_control = event_control
	opt.dispel.args.event_control = event_control
	opt.start.args.event_control = event_control
	opt.success.args.event_control = event_control
	opt.interrupt.args.event_control = event_control
end


--
-- local eventgroup = {
-- 	type = "group",
-- 	name = "On aura gain/refresh",
-- 	order = 1,
-- 	args = {
-- 		create_alert = {
-- 			type = "input",
-- 			name = "test",
-- 			order = 1,
-- 			width = "full",
-- 			--get = 'GetOption',
-- 			set = 'SetOption',
-- 		}
-- 	}
-- }
--
-- -- alerts
-- O.options.args.alerts_events.args.gain = eventgroup
-- O.options.args.alerts_events.args.dispel = eventgroup
function A:GetInfoPath(info)
	--VDT_AddData(info,"info")
	local i = 1
	local path = self.db.profile
	while info[i] ~= nil do
		path = path[info[i]]
		i = i + 1
	end
	--VDT_AddData(path, "path")
	return path
end

-- callback functions for multiple values
function A:GetOptions(info, key)
	local path = A:GetInfoPath(info)
	return path[key]
	--return(self.db.profile[info[#info]][key])
end

function A:SetOptions(info , key, value)
	--dprint(1, info, key, value)
	local path = A:GetInfoPath(info)
	--VDT_AddData(path, "path")
	path[key] = value
	--self.db.profile[info[#info]][key] = value
end

-- callback functions for single values
function A:GetOption(info)
	local path = A:GetInfoPath(info)
	return path
end

function A:SetOption(info, value)
	local path = A:GetInfoPath(info)
	path = value

end

-- automatically called on profile copy/delete/etc.
function A:OnProfileEvent(event)
	dprint(2, "OnProfileEvent", event)
	A:RefreshProfiles()
	-- do whatever it takes
end

-- refreshes the profiles tab
function A:RefreshProfiles()
	O.options.args.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	O.options.args.profiles.order = 4
end

function A:GetChatInfo()
	local chat_frames = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			chat_frames["ChatFrame"..i] = name
		end
	end
	return chat_frames
end
