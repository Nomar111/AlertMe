dprint(2, "init.lua")
-- upvalues
local _G, dprint = _G, dprint
local tostring, unpack  = tostring, unpack
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
A.Options = {}
A.Profile = {profile = {}}
-- set engine environment substructure
Engine[1] = A
Engine[2] = A.Defaults  	-- D
Engine[3] = A.Options   	-- O

-- set wow global
_G.AlertMe = Engine

-- init debugger and add engine
VDT_AddData = _G.ViragDevTool_AddData
VDT_AddData(Engine, "Engine")
VDT_AddData(A, "A")
VDT_AddData(A.Defaults, "D")
VDT_AddData(A.Options, "O")

-- addon globls
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
PLAYER_NAME = UnitName("player")
REALM_NAME = GetRealmName()
PLAYER_REALM = PLAYER_NAME.." - "..REALM_NAME
LibStub = LibStub
dprint = dprint

-- libraries
A.Libs = {AceGUI={}, AceConfig={}, AceConfigDialog={}, AceConfigRegistry={}, AceDBOptions={}}
A.Libs.AceGUI = LibStub("AceGUI-3.0")
A.Libs.AceConfig = LibStub("AceConfig-3.0")
A.Libs.AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
A.Libs.AceConfigDialog = LibStub("AceConfigDialog-3.0")
A.Libs.AceDB = LibStub("AceDB-3.0")
A.Libs.AceDBOptions = LibStub("AceDBOptions-3.0")
A.Libs.LibSharedMedia = LibStub("LibSharedMedia-3.0")

-- addon initialized
function A:OnInitialize()
	dprint(2, "Ace Event: OnInitialize")
	-- setup database
	self.db = A.Libs.AceDB:New("AlertMeDB", A.Defaults, false)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileEvent")
	-- define addon global P for profile data
	P = A.db.profile
	VDT_AddData(self.db, "db")
	VDT_AddData(P, "P")
	-- register slash command
	self:RegisterChatCommand("alertme", "OpenOptions")
end

function A:OpenOptions()
	A.Options:OpenOptions()
end

-- addon enabled
function A:OnEnable()
	dprint(2, "Ace Event: OnEnable")
	A:Initialize()
	A.Options:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(2, "Ace Event: OnDisable")
end

-- automatically called on profile copy/delete/etc.
function A:OnProfileEvent(event)
	dprint(2, "OnProfileEvent", event)
	-- set global P again
	P = A.db.profile
	-- update options table
	A.Options.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- do whatever else
end
