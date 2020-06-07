dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames = _G, dprint, FCF_GetNumActiveChatFrames
-- get engine environment
local A, D, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- basic tab layout
O.options = {
	type = "group",
	name = "Settings",
	handler = A,
	childGroups = "tabs",
	args = {
		general = {
			type = "group",
			name = "General",
			desc = "General settings",
			order = 1,
			args = {}
		},
		events = {
			type = "group",
			name = "Events",
			desc = "Event-specific Settings",
			order = 2,
			args = {}
		},
		alerts = {
			type = "group",
			name = "Alerts",
			desc = "Create Alerts",
			order = 3,
			args = {}
		},
		profiles = {
			type = "group",
			name = "Profiles",
			desc = "Manage Profiles",
			order = 4,
			args = {}
		},
		info = {
			type = "group",
			name = "Info",
			desc = "Addon Info",
			order = 5,
			args = {}
		}
	}
}

-- general
local chat_frames = {}
for i = 1, FCF_GetNumActiveChatFrames() do
	local name = _G["ChatFrame"..i.."Tab"]:GetText()
	if name ~= "Combat Log" then
		chat_frames["ChatFrame"..i] = name
	end
end
local zone_types = {bg = "Battlegrounds", world = "World", raid = "Raid Instances"}

O.options.args.general.args = {
	header = {
		type = 'header',
		name = "General Options",
		order = 1,
	},
	spacer = {
    name = "",
    type = 'description',
    width = 'full',
    cmdHidden = true,
    order = 2,
	},
	zones = {
		type = 'multiselect',
		name = "Addon is enabled in",
		order = 3,
		values = zone_types,
		get = 'GetOptions',
		set = 'SetOptions',
	},
	chat_frames = {
		type = 'multiselect',
		name = "Display addon messages in the following chat windows",
		order = 4,
		values = chat_frames,
		get = 'GetOptions',
		set = 'SetOptions',
	},
}

-- info
O.options.args.info.args = {
	header = {
		type = "header",
		name = "Addon Info",
		order = 1
	},
	addonInfo = {
		type = "description",
		name = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR,
		fontSize = "medium",
		order = 2
	}
}

-- callback functions for single values
function A:GetOptions(info, key)
	return(self.db.profile[info[#info]][key])
end

function A:SetOptions(info , key, value)
	self.db.profile[info[#info]][key] = value
end

-- callback functions for multiple values
function A:GetOption(info)
	return(self.db.profile[info[#info]])
end

function A:SetOption(info, value)
	self.db.profile[info[#info]] = value
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
