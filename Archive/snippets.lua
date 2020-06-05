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
