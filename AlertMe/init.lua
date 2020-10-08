--print("init.lua")
-- upvalues
local _G = _G
local LibStub, GetAddOnMetadata, tostring = LibStub, GetAddOnMetadata, tostring
local UnitName, GetRealmName, date, FCF_GetNumActiveChatFrames, WrapTextInColorCode = UnitName, GetRealmName, date, FCF_GetNumActiveChatFrames, WrapTextInColorCode

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
A.Spells = {}
-- set engine environment substructure
Engine[1] = A
Engine[2] = A.Defaults  	-- D
Engine[3] = A.Options   	-- O
Engine[4] = A.Spells		-- S

-- set wow global
_G.AlertMe = Engine

-- init debugger and add engine
VDT_AddData = _G.ViragDevTool_AddData
VDT_AddData(Engine, "Engine")
VDT_AddData(A, "A")
VDT_AddData(A.Defaults, "D")
VDT_AddData(A.Options, "O")
VDT_AddData(A.Spells, "S")

-- addon globals
ADDON_NAME = AddonName
ADDON_VERSION = tostring(GetAddOnMetadata(AddonName, "Version"))
ADDON_AUTHOR = GetAddOnMetadata(AddonName, "Author")
PLAYER_NAME = UnitName("player")
REALM_NAME = GetRealmName()
PLAYER_REALM = PLAYER_NAME.." - "..REALM_NAME

-- addon upvalues
print, pairs, unpack, strsplit, type, tcopy, tinsert, unpack = _G.print, _G.pairs, _G.unpack, _G.strsplit, _G.type, _G.table.copy, _G.table.insert, _G.unpack
GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = _G.GameFontHighlight, _G.GameFontHighlightLarge, _G.GameFontHighlightSmall

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
--A.Libs.Callbacks = LibStub("CallbackHandler-1.0"):New(A.Libs.Callbacks)



function A:InitChatFrames()
	A.ChatFrames = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			A.ChatFrames[name] = "ChatFrame"..i
		end
	end
end

-- addon initialized
function A:OnInitialize()
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
	-- init chatframes/debugging
	A:InitChatFrames()
	-- debug print
	function dprint(lvl,...)
		--print(lvl,debug_lvl,...)
		local msg = ""
		local debug_level = 1--tonumber(GetAddOnMetadata(AddonName, "X-DebugLevel"))
		local color = "FFcfac67"
		local prefix = "["..date("%H:%M:%S").."]"..WrapTextInColorCode(" AlertMe ** ", color)
		local separator = WrapTextInColorCode(" ** ", color)
		local args = {...}
		-- check lvl argument
		if not lvl or type(lvl) ~= "number" then
			msg = "Provided lvl arg is invalid: "..tostring(lvl)
			lvl_check = false
		end
		-- check level vs debug_level
		if  lvl_check ~= false and lvl > debug_level then
			return
		end
		-- check args
		if #args == 0 then
			msg = "No debug messages provided or nil"
		else
			for i=1, #args do
				local sep = (i == 1) and "" or separator
				msg = msg..sep..tostring(args[i])
			end
		end
		A:SystemMessage(prefix..msg)
	end
end

function A:OpenOptions()
	dprint(2, "A:OpenOptions")
	A.Options:OpenOptions()
end

-- addon enabled
function A:OnEnable()
	dprint(2, "A:OnEnable")
	A:Initialize()
	--A.Options:OpenOptions()
end

-- addon disabled
function A:OnDisable()
	dprint(2, "A:OnDisable")
end

-- automatically called on profile copy/delete/etc.
function A:OnProfileEvent(event)
	dprint(2, "A:OnProfileEvent", event)
	-- set global P again
	P = A.db.profile
	-- update options table
	A.Options.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- do whatever else
end
