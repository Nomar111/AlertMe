dprint(3,"init.lua")
-- lua upvalues
local _G = _G
local dprint, print, type, tostring = dprint, print, type, tostring
-- misc upvalues
local LibStub, VDT_AddData = LibStub, ViragDevTool_AddData
-- wow upvalues
local GetAddOnMetadata = GetAddOnMetadata

-- get engine/addon environment
local AddonName, Engine = ...
-- register as ace addon
local A = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0","AceEvent-3.0")
-- create (default) options table
A.Defaults = {profile = {}, global = {}}
A.Options = {type = 'group', args = {}}
-- set engine environment
Engine[1] = A
Engine[2] = {}
Engine[3] = A.Defaults.profile

-- set wow global
_G.AlertMe = Engine

-- set engine environment as new global environment
setfenv(1, Engine)
-- get/set addon metadata
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")

-- add engine  to debugger
VDT_AddData(Engine, "Engine")

-- addon initialized
function A:OnInitialize()
	dprint(3,"Ace Event: OnInitialize")
	-- set up ACE db
	--self.db = LibStub("AceDB-3.0"):New("AlertMeDB", self:ReturnDefaultOptions(), true)
	--self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	-- register slash command
	--self:RegisterChatCommand("alertme", "OpenOptions")
end

-- addon enabled
function A:OnEnable()
	dprint(3,"Ace Event: OnEnable")
	--A:Initialize()
	-- open options (options.lua)
	--self:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(3,"Ace Event: OnDisable")
end
