dprint(2, "init.lua")
-- upvalues
local _G, dprint = _G, dprint
local tostring  = tostring
local LibStub, GetAddOnMetadata = LibStub, GetAddOnMetadata
local UnitName, GetRealmName = UnitName, GetRealmName

-- get engine/addon environment
local AddonName, Engine = ...
-- set engine environment as new global environment
setfenv(1, Engine)

-- register as ace addon
local A = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0")
-- create (default) options table
A.Defaults = {}
A.Options = {Profiles={}}
-- set engine environment substructure
Engine[1] = A
Engine[2] = A.Defaults
Engine[3] = A.Options
-- set wow global
_G.AlertMe = Engine

-- addon globls
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
PLAYER_NAME = UnitName("player")
REALM_NAME = GetRealmName()
PLAYER_REALM = PLAYER_NAME.." - "..REALM_NAME
VDT_AddData = _G.ViragDevTool_AddData
LibStub = LibStub
dprint = dprint

-- add engine  to debugger
VDT_AddData(Engine, "Engine")
VDT_AddData(A, "A")
VDT_AddData(A.Defaults, "D")
VDT_AddData(A.Options, "O")

-- libraries
A.Libs = {AceGUI={}, AceConfig={}, AceConfigDialog={}, AceConfigRegistry={}, AceDBOptions={}}
A.Libs.AceGUI = LibStub("AceGUI-3.0")
A.Libs.AceConfig = LibStub("AceConfig-3.0")
A.Libs.AceConfigDialog = LibStub("AceConfigDialog-3.0")
A.Libs.AceDBOptions = LibStub("AceDBOptions-3.0")

-- addon initialized
function A:OnInitialize()
	dprint(2, "Ace Event: OnInitialize")
	-- setup database
	self.db = LibStub("AceDB-3.0"):New("AlertMeDB", A.Defaults, false)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileEvent")
	VDT_AddData(self.db, "db")
	-- register slash command
	self:RegisterChatCommand("alertme", "OpenOptions")
end

-- addon enabled
function A:OnEnable()
	dprint(2, "Ace Event: OnEnable")
	self:Initialize()
	self:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(2, "Ace Event: OnDisable")
end
