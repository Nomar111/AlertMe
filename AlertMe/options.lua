local p = pmon_globals
-- set selection options
local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
-- option tables
local pmon_options_info = {
	name = 'PVP Monitor',
	handler = pmon,
	type = 'group',
	args = {
		version = {
			order = 0,
			type = 'description',
			fontSize = "medium",
			name = "Version" .. " " .. pmon.version .. ", Created by Nomar (Zandalar Treibe - EU)",
			width = 'double',
		}
	}
}
-- general options
local pmon_options_general = {
	name = 'General',
	handler = pmon,
	type = 'group',
	args = {
		-- Zone types --
		header = {
			order = 2,
			type = 'header',
			name = "Zone types",
		},
		zones = {
			order = 3,
			name = "Addon is enabled in",
			type = 'multiselect',
			values = zone_types,
			get = 'getOptions',
			set = 'setOptions',
		}
	}
}
-- local drop_down
local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
-- shared media
local LSM = LibStub("LibSharedMedia-3.0")
local sounds = LSM:HashTable("sound")
pmon.sounds_hash = LSM:HashTable("sound")
pmon.sounds_list = LSM:List("sound")
p.virag(sounds,"sounds")
-- test options
local pmon_options_test = {
	name = 'Testing',
	handler = pmon,
	type = 'group',
	args = {
		test_toggle = {
			order = 1,
			type = 'toggle',
			name = 'Test Toggle',
			desc = 'Descriptiooooon',
			get = 'getOption',
			set = 'setOption',
		},
		test_select_dropwdown = {
			order = 2,
			type = 'select',
			name = 'Test Select Dropdown',
			values = drop_down,
			get = 'getOption',
			set = 'setOption',
			style = "dropdown"
		},
		test_select_radio = {
			order = 3,
			type = 'select',
			name = 'Test Select Radio',
			values = drop_down,
			get = 'getOption',
			set = 'setOption',
			style = "radio"
		},
		-- sounds = {
		--   type = "select",
		--   name = "Sound",
		--   values = LSM:HashTable("sound"),
		--   dialogControl = "LSM30_Statusbar",
		-- },
		sounds = {
			type = "select",
			name = "Sound",
			values = pmon.sounds_list,
			get = 'getOption',
			set = 'setOption',
		},
	}
}
--range
--color
--input

-- initialize options window
function pmon:initOptions()
	p.debug(2,"initOptions")
	--local acreg = LibStub("AceConfigRegistry-3.0")
	local acreg = LibStub("AceConfig-3.0")
	local acdia = LibStub("AceConfigDialog-3.0")
	-- start tab
	acreg:RegisterOptionsTable("PVP Monitor", pmon_options_info)
	acdia:AddToBlizOptions("PVP Monitor", "PVP Monitor")
	-- general options
	acreg:RegisterOptionsTable("General", pmon_options_general)
	acdia:AddToBlizOptions("General", "General", "PVP Monitor")
	-- profiles (uses ACEDbs sstandard table)
	local pmon_options_profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(pmon.db)
  acreg:RegisterOptionsTable("Profiles", pmon_options_profiles)
	acdia:AddToBlizOptions("Profiles", "Profiles", "PVP Monitor")
	-- test options
	acreg:RegisterOptionsTable("Testing", pmon_options_test)
	acdia:AddToBlizOptions("Testing", "Testing", "PVP Monitor")
  -- register chat commands
	self:RegisterChatCommand("pmon", "openOptions")
	self:RegisterChatCommand("pvpmonitor", "openOptions")
end

-- callback functions
function pmon:getOptions(info,key)
		return(self.db.profile[info[#info]][key])
end

function pmon:setOptions(info,key,value)
	self.db.profile[info[#info]][key] = value
end

function pmon:getOption(info)
		return(self.db.profile[info[#info]])
end

function pmon:setOption(info,value)
	self.db.profile[info[#info]] = value
	-- disable radio buttons depending on selection in dropdown
	if info[#info] == "test_select_dropwdown" then
		if value == "bg" then
			pmon_options_test.args.test_select_radio.disabled = true
		else
			pmon_options_test.args.test_select_radio.disabled = false
		end
	end
end

-- open interface options by /pmon
function pmon:openOptions(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory("PVP Monitor")
	end
end
