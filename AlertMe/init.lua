-- get eaddon environment
local name, Engine = ...
-- create addon global and set it to engine environment
_G.AlertMe = Engine
-- upvalues
local _G, LibStub, GetAddOnMetadata = _G, LibStub, GetAddOnMetadata
-- set engine environment as new global environment
setfenv(1, _G.AlertMe)
-- create some later needed tables
O = { config = {} } -- options
L = {} -- locales
D = {} -- defaults
-- register as ace addon
A = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0")

-- addon upvalues
CreateFrame, GameTooltip, WrapTextInColorCode = _G.CreateFrame, _G.GameTooltip, _G.WrapTextInColorCode
print, unpack, tinsert, pairs, ipairs, type, next = _G.print, _G.unpack, _G.tinsert, _G.pairs, _G.ipairs, _G.type, _G.next
gsub, sub, tostring = _G.string.gsub, _G.string.sub, _G.tostring
IsShiftKeyDown, UnitGUID, UnitName = _G.IsShiftKeyDown, _G.UnitGUID, _G.UnitName
GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = _G.GameFontHighlight, _G.GameFontHighlightLarge, _G.GameFontHighlightSmall
GetTime, date, time = _G.GetTime, _G.date, _G.time

-- addon globals
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(name, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(name, "Author")
PLAYER_NAME = UnitName("player")
DEBUG_LEVEL = 1

-- libraries
A.Libs = {}
A.Libs.AceGUI = LibStub("AceGUI-3.0")
A.Libs.AceConfig = LibStub("AceConfig-3.0")
A.Libs.AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
A.Libs.AceConfigDialog = LibStub("AceConfigDialog-3.0")
A.Libs.AceDB = LibStub("AceDB-3.0")
A.Libs.AceDBOptions = LibStub("AceDBOptions-3.0")
--A.Libs.AceLocale = LibStub("AceLocale-3.0")
A.Libs.LSM = LibStub("LibSharedMedia-3.0")
A.Libs.LCD = LibStub("LibClassicDurations")
A.Libs.LCB = LibStub("LibCandyBar-3.0")
A.Libs.LCG = LibStub("LibCustomGlow-1.0")
A.Libs.LGF = LibStub("LibGetFrame-1.0")
A.Libs.LDB = LibStub("LibDataBroker-1.1")
A.Libs.LDBI = A.Libs.LDB and LibStub("LibDBIcon-1.0", true)
A.Libs.LCC = LibStub("LibCCAlertMe", true)

-- addon initialized
function A:OnInitialize()
	-- setup saved variables database
	self.db = A.Libs.AceDB:New("AlertMeDB", D, false)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileEvent")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileEvent")
	-- define addon global P for profile data
	P = A.db.profile
	-- register slash command
	local open = O.OpenOptions
	self:RegisterChatCommand("alertme", "open")
end

-- addon enabled
function A:OnEnable()
	A:Initialize()
end

-- automatically called on profile copy/delete/etc.
function A:OnProfileEvent(event)
	-- set global P again
	P = A.db.profile
	-- update options table
	O.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
end
