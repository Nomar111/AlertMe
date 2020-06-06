--Lua functions
local pairs, type, table = pairs, type, table
local setmetatable, getmetatable = setmetatable, getmetatable
local GetAddOnMetadata = GetAddOnMetadata
local print = print

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

-- debug handling
local AddonName,_ = ...
local debug_level = tonumber(GetAddOnMetadata(AddonName, "X-DebugLevel"))
function dprint(lvl,...)
	local prefix = "|cFF7B241CAlertMe **|r "
	if type(lvl) ~= "number" or not lvl then
		print(prefix.."Provided debug arguments invalid: ",lvl,...)
		return
	end
	if lvl <= debug_level then
		print(prefix,...)
	end
end
