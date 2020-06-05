-- lua upvalues
local _G = _G
local print, type, tostring = print, type, tostring
-- misc upvalues
local LibStub = LibStub
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
Engine[4] = A.Defaults.global
-- set wow global
_G.AlertMe = Engine

-- set engine environment as new global environment
setfenv(1, Engine)
-- get addon metadata
ADDON_NAME = AddonName
ADDON_VERSION = GetAddOnMetadata(AddonName, "Version")
ADDON_VERSION_STRING = tostring(ADDON_VERSION)
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
DEBUG_LEVEL = 2
-- make debugger avilable
VDT_AddData = _G.ViragDevTool_AddData
-- add engine  to debugger
VDT_AddData(Engine, "Engine")

-- addon initialized
function A:OnInitialize()
	self:Debug(2,"OnInitialize")
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
	self:Debug(2,"OnEnable")
	-- open options (options.lua)
	--self:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	self:Debug(2,"OnDisable")
end

-- the profile was changed/copied/deleted
function A:OnProfileChanged(event, newProfileKey)
	self:Debug(2,"Profile changed", event, newProfileKey)
end

-- debug handling
function A:Debug(lvl,...)
	local prefix = "|cFF7B241CAlertMe **|r "
	if type(lvl) ~= "number" or not lvl then
		print(prefix.."lvl not valid",lvl,...)
		return
	end
	if lvl <= DEBUG_LEVEL then
		print(prefix,...)
	end
end
