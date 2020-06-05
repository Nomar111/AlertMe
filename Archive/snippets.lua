-- table copy by elv
function table.copy(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == 'table' then
			nt[k] = table.copy(v, deep, seen)
		else
			nt[k] = v
		end
	end

	setmetatable(nt, table.copy(getmetatable(t), deep, seen))
	seen[t] = nt
	return nt
end


RAID_CLASS_COLORS["SHAMAN"].colorStr = "ff0270dd"
RAID_CLASS_COLORS["SHAMAN"].r = 0.01
RAID_CLASS_COLORS["SHAMAN"].g = 0.44
RAID_CLASS_COLORS["SHAMAN"].b = 0.87

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
	end
	return ChatTabInfo
end


	<Include file="AceLocale-3.0\AceLocale-3.0.xml"/>
		<Include file="AceHook-3.0\AceHook-3.0.xml"/>
		
	<Include file="LibClassicDurations\LibClassicDurations.xml"/>
	<Script file="LibClassicCasterino-1.0\LibClassicCasterino.lua"/>
	<Script file="LibHealComm-4.0\LibHealComm-4.0.lua"/>
	<Script file="LibClassicSpellActionCount-1.0\LibClassicSpellActionCount-1.0.lua"/>
	<Script file="LibTotemInfo\GetTotemInfo.lua"/>

	<Include file="LibSharedMedia-3.0\lib.xml"/>
	<Script file="LibSimpleSticky\LibSimpleSticky.lua"/>
	<Include file='oUF\oUF.xml'/>
	<Include file='oUF_Plugins\oUF_Plugins.xml'/>
	<Include file="LibActionButton-1.0\LibActionButton-1.0.xml"/>
	<Script file="LibDataBroker\LibDataBroker-1.1.lua"/>
	<Script file="LibElvUIPlugin-1.0\LibElvUIPlugin-1.0.lua"/>
	<Include file="UTF8\UTF8.xml"/>
	<Include file="LibItemSearch-1.2\LibItemSearch-1.2.xml"/>
	<Include file="LibChatAnims\LibChatAnims.xml"/>
	<Include file="LibCompress\lib.xml"/>
	<Include file="LibBase64-1.0\lib.xml"/>
	<Script file="LibAnim\LibAnim.lua"/>
	<Script file="LibTranslit-1.0\LibTranslit-1.0.lua"/>
	<Script file="LibRangeCheck-2.0\LibRangeCheck-2.0.lua"/>
