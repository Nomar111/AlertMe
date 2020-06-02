local ADDON_NAME,AlertMe = ...
_G.ViragDevTool_AddData(AlertMe,ADDON_NAME)
--[[
-- local declarations
local _G = _G
local LibStub = LibStub
-- create a global container fpr functions and vars
pmon_globals = {}
local p = pmon_globals
-- init debugger
p.virag = _G["ViragDevTool_AddData"]
-- debug level
p.debug_level = 2
p.virag(addonTable,addonName)

-- debug messages
p.debug = function(lvl,...)
	if type(lvl) ~= "number" or not lvl then pmon:Print("lvl not valid",lvl,...) end
	if lvl <= p.debug_level then pmon:Print(...) end
end

-- default values for profiles
local defaults = {
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

-- init addon in ACE
pmon = LibStub("AceAddon-3.0"):NewAddon("PVP Monitor","AceConsole-3.0","AceEvent-3.0")
pmon.version = "0.1"
p.virag(pmon,"pmon")
-- ACE events
function pmon:OnInitialize()
	p.debug(2,"OnInitialize")
	-- set up ACE db
	self.db = LibStub("AceDB-3.0"):New("pmon_db", defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "onProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "onProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "onProfileChanged")
end

-- ACE event
function pmon:OnEnable()
	p.debug(2,"OnEnable")
	-- init options (options.lua)
	self:initOptions()
end

-- ACE event
function pmon:OnDisable()
	p.debug(2,"OnDisable")
end

-- the profile was changed/copied/deleted
function pmon:onProfileChanged(event,newProfileKey)
	p.debug(self,2,"Profile changed",event,newProfileKey)
end
]]
