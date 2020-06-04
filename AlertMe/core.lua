-- lua upvalues
local _G = _G
local print, type = print, type
-- misc upvalues
local LibStub = LibStub
local VDT_AddData = _G.ViragDevTool_AddData
-- wow upvalues
local GetAddOnMetadata = GetAddOnMetadata

-- register as ace addon
local AlertMe = LibStub("AceAddon-3.0"):NewAddon("AlertMe", "AceConsole-3.0","AceEvent-3.0")
-- create wow-global
_G["AlertMe"] = AlertMe
-- set addon environment as new global environment
setfenv(1, AlertMe)
-- set addon version
version = GetAddOnMetadata("AlertMe", "Version")
debug_level = 2
-- make debugger avilable
AlertMe.VDT_AddData = VDT_AddData
-- add global object to debugger
VDT_AddData(AlertMe)

-- addon initialized
function AlertMe:OnInitialize()
	Debug(2,"OnInitialize")
	-- set up ACE db
	self.db = LibStub("AceDB-3.0"):New("AlertMeDB", self:GetDefaultOptions(), true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	-- register slash command
	self:RegisterChatCommand("alertme", "OpenOptions")
end

-- addon enabled
function AlertMe:OnEnable()
	Debug(2,"OnEnable")
	-- open options (options.lua)
	self:OpenOptions()
end

-- addon disabled
function AlertMe:OnDisable()
	Debug(2,"OnDisable")
end

-- the profile was changed/copied/deleted
function AlertMe:OnProfileChanged(event, newProfileKey)
	Debug(2,"Profile changed", event, newProfileKey)
end

-- debug handling
Debug = function(lvl,...)
	local prefix = "|cFF7B241CAlertMe **|r "
	if type(lvl) ~= "number" or not lvl then
		print(prefix.."lvl not valid",lvl,...)
		return
	end
	if lvl <= debug_level then
		print(prefix,...)
	end
end
