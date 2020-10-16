-- upvalues
local _G, LibStub = _G, LibStub
local GetAddOnMetadata, UnitName, GetRealmName  = GetAddOnMetadata, UnitName, GetRealmName
-- get engine/addon environment
local AddonName, Engine = ...
-- set engine environment as new global environment
setfenv(1, Engine)

-- register as ace addon
local A = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0")
-- create some tables table so we can use them right away
A.Defaults = {}
A.Options = {}
A.Profile = {profile = {}}
A.Spells = {}

-- set engine environment substructure
Engine[1] = A				-- A
Engine[2] = A.Options   	-- O

-- set wow global
_G.AlertMe = Engine

-- addon upvalues
print, pairs, type, tcopy, tinsert, unpack = _G.print, _G.pairs,  _G.type, _G.table.copy, _G.table.insert, _G.unpack
strsplit, tostring, gsub, string, date, next = _G.strsplit, _G.tostring, _G.gsub, _G.string,  _G.date, _G.next
GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = _G.GameFontHighlight, _G.GameFontHighlightLarge, _G.GameFontHighlightSmall
WrapTextInColorCode, GetTime, CreateFrame, C_Timer, UIParent = _G.WrapTextInColorCode, _G.GetTime, _G.CreateFrame, _G.C_Timer, _G.UIParent
GetSpellInfo, IsShiftKeyDown, GameTooltip, FCF_GetNumActiveChatFrames = _G.GetSpellInfo, _G.IsShiftKeyDown, _G.GameTooltip, _G.FCF_GetNumActiveChatFrames

-- addon globals
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
PLAYER_NAME = UnitName("player")
REALM_NAME = GetRealmName()
PLAYER_REALM = PLAYER_NAME.." - "..REALM_NAME
DEBUG_LEVEL = 1

-- libraries
A.Libs = {}
A.Libs.AceGUI = LibStub("AceGUI-3.0")
A.Libs.AceConfig = LibStub("AceConfig-3.0")
A.Libs.AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
A.Libs.AceConfigDialog = LibStub("AceConfigDialog-3.0")
A.Libs.AceDB = LibStub("AceDB-3.0")
A.Libs.AceDBOptions = LibStub("AceDBOptions-3.0")
A.Libs.LSM = LibStub("LibSharedMedia-3.0")
A.Libs.LCD = LibStub("LibClassicDurations")
A.Libs.LCB = LibStub("LibCandyBar-3.0")
A.Libs.LDB = LibStub("LibDataBroker-1.1")
A.Libs.LDBI = A.Libs.LDB and LibStub("LibDBIcon-1.0", true)

-- addon initialized
function A:OnInitialize()
	dprint(3, "A:OnInitialize")
	-- setup database
	self.db = A.Libs.AceDB:New("AlertMeDB", A.Defaults, false)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileEvent")
	-- define addon global P for profile data
	P = A.db.profile
	-- register slash command
	self:RegisterChatCommand("alertme", "OpenOptions")
	-- init chatframes/debugging
	A:InitChatFrames()
end

function A:OpenOptions()
	dprint(3, "A:OpenOptions")
	A.Options:OpenOptions()
end

-- addon enabled
function A:OnEnable()
	dprint(3, "A:OnEnable")
	A:Initialize()
	--A.Options:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(3, "A:OnDisable")
end

-- automatically called on profile copy/delete/etc.
function A:OnProfileEvent(event)
	dprint(3, "A:OnProfileEvent", event)
	-- set global P again
	P = A.db.profile
	-- update options table
	A.Options.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
end
