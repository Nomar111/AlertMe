--Lua functions
local pairs, type, table = pairs, type, table
local setmetatable, getmetatable = setmetatable, getmetatable
local GetAddOnMetadata = GetAddOnMetadata

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
local ChatFrames = {ChatFrame1, ChatFrame3}
local debug_level = 1--tonumber(GetAddOnMetadata(AddonName, "X-DebugLevel"))
local color = "FFcfac67"
local prefix = "["..date("%H:%M:%S").."]"..WrapTextInColorCode(" AlertMe ** ", color)
local separator = WrapTextInColorCode(" ** ", color)

function dprint(lvl,...)
	local msg = ""
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
	-- send message to chat framns
	for _,f in pairs(ChatFrames) do
		f:AddMessage(prefix..msg)
	end
end

function uuid()
	local random = math.random
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end
