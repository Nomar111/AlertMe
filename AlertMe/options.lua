-- get addon environment
local AlertMe = _G.AlertMe
-- misc upvalues
local LibStub = LibStub
-- wow upvalues
local	InterfaceOptionsFrame_Show = InterfaceOptionsFrame_Show
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
-- set addon environment as new global environment
setfenv(1, AlertMe)

-- initialize options window
function AlertMe:InitOptions()
	Debug(2,"initOptions")
	--local acreg = LibStub("AceConfigRegistry-3.0")
	local acreg = LibStub("AceConfig-3.0")
	local acdia = LibStub("AceConfigDialog-3.0")
	-- start tab
	options_info = self:GetOptionsTable("info")
	acreg:RegisterOptionsTable(self.name, options_info)
	acdia:AddToBlizOptions(self.name, self.name)
	-- general options
	options_general = self:GetOptionsTable("general")
	acreg:RegisterOptionsTable("General", options_general)
	acdia:AddToBlizOptions("General", "General", self.name)
	-- profiles (uses ACEDbs sstandard table)
	options_profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  acreg:RegisterOptionsTable("Profiles", options_profiles)
	acdia:AddToBlizOptions("Profiles", "Profiles", self.name)
	-- test options
	options_test = self:GetOptionsTable("test")
	acreg:RegisterOptionsTable("Test", options_test)
	acdia:AddToBlizOptions("Test", "Test", self.name)
  -- register chat commands
	self:RegisterChatCommand("alertme", "OpenOptions")
end

-- callback functions
function AlertMe:GetOptions(info,key)
		return(self.db.profile[info[#info]][key])
end

function AlertMe:SetOptions(info,key,value)
	self.db.profile[info[#info]][key] = value
end

function AlertMe:GetOption(info)
		return(self.db.profile[info[#info]])
end

function AlertMe:SetOption(info,value)
	self.db.profile[info[#info]] = value
	-- disable radio buttons depending on selection in dropdown
	if info[#info] == "test_select_dropwdown" then
		if value == "bg" then
			options_test.args.test_select_radio.disabled = true
		else
			options_test.args.test_select_radio.disabled = false
		end
	end
end

-- open interface options by /pmon
function AlertMe:OpenOptions(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(self.name)
	end
end

function AlertMe:GetDefaults()
		---- default values for profiles
		local ret = {
			profile = {
				zones = {
					['*'] = true
				},
				test_toggle = false,
				test_select_dropwdown = "say",
				test_select_radio = "bg",
				sound = "IM",
			}
		}
		return ret
end

function AlertMe:GetOptionsTable(name)
	-- selections
	local drop_down = {["bg"] = "Instance Chat", ["say"] = "/Say", ["system"] = "System"}
	local zone_types = {["bg"] = "Battlegrounds", ["raid"] = "Raid Instances", ["world"] = "World"}
	local options = {}
	-- info page
	options["info"] = {
		name = AlertMe.name,
		handler = AlertMe,
		type = 'group',
		args = {
			version = {
				order = 0,
				type = 'description',
				fontSize = "medium",
				name = "Version" .. " " .. AlertMe.version .. ", Created by Nomar (Zandalar Treibe - EU)",
				width = 'double',
			}
		}
	}
	-- general options
	options["general"] =	{
		name = 'General',
		handler = AlertMe,
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
				get = 'GetOptions',
				set = 'SetOptions',
			}
		}
	}
	-- test options
	options["test"] = {
		name = 'Testing',
		handler = AlertMe,
		type = 'group',
		args = {
			test_toggle = {
				order = 1,
				type = 'toggle',
				name = 'Test Toggle',
				desc = 'Descriptiooooon',
				get = 'GetOption',
				set = 'SetOption',
			},
			test_select_dropwdown = {
				order = 2,
				type = 'select',
				name = 'Test Select Dropdown',
				values = drop_down,
				get = 'GetOption',
				set = 'SetOption',
				style = "dropdown"
			},
			test_select_radio = {
				order = 3,
				type = 'select',
				name = 'Test Select Radio',
				values = drop_down,
				get = 'GetOption',
				set = 'SetOption',
				style = "radio"
			},
		}
	}
	return options[name]
end
