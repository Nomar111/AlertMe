dprint(3, "init.lua")
-- upvalues
local _G, dprint = _G, dprint
local tostring = tostring
local LibStub, GetAddOnMetadata = LibStub, GetAddOnMetadata

-- get engine/addon environment
local AddonName, Engine = ...
-- set engine environment as new global environment
setfenv(1, Engine)

-- register as ace addon
local A = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0","AceEvent-3.0")
-- create (default) options table
A.Defaults = {}
-- set engine environment substructure
Engine[1] = A
Engine[2] = A.Defaults
-- set wow global
_G.AlertMe = Engine

-- addon globls
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
dprint = dprint
VDT_AddData = _G.ViragDevTool_AddData

-- add engine  to debugger
VDT_AddData(Engine, "Engine")

-- addon initialized
function A:OnInitialize()
	dprint(2, "Ace Event: OnInitialize")
	-- setup database
	self.db = LibStub("AceDB-3.0"):New("AlertMeDB", A.Defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
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
	dprint(3, "Ace Event: OnEnable")
	A:Initialize()
	-- open options (options.lua)
	--self:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(3, "Ace Event: OnDisable")
end

-- automatically called when profile changes
function A:OnProfileChanged()
	dprint(3, "OnProfileChanged")
end
