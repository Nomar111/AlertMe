-- get engine environment
local A, O = unpack(select(2, ...))
--upvalues
local _G, table, getmetatable, setmetatable, hooksecurefunc = _G, table, getmetatable, setmetatable, hooksecurefunc
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function tcopy(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == 'table' then
			nt[k] = tcopy(v, deep, seen)
		else
			nt[k] = v
		end
	end
	setmetatable(nt, tcopy(getmetatable(t), deep, seen))
	seen[t] = nt
	return nt
end

function A:GetUnitNameShort(name)
	-- getUnitName: Returns Unitname without Realm
	local short = gsub(name, "%-[^|]+", "")
	return short
end

function A:InitChatFrames()
	A.ChatFrames = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			A.ChatFrames[name] = "ChatFrame"..i
		end
	end
end
A:InitChatFrames()

function A:SystemMessage(msg)
	-- loop through chat frames and post messages
	for i, name in pairs(A.ChatFrames) do
		if P.messages.chatFrames[name] == true then
			local f = _G[name]
			f:AddMessage(msg)
		end
	end
end

function dprint(lvl,...)
	--print(lvl,debug_lvl,...)
	local msg = ""
	local logmsg = ""
	local debugLevel = DEBUG_LEVEL
	local debugLevelLog = DEBUG_LEVEL
	if A.db then
		debugLevel =  A.db.profile.general.debugLevel
		debugLevelLog =  A.db.profile.general.debugLevelLog
	end
	local lvlCheck
	local color = "FFcfac67"
	local prefix = "["..date("%H:%M:%S").."]"..WrapTextInColorCode(" AlertMe ** ", color)
	local separator = WrapTextInColorCode(" ** ", color)
	local args = {...}
	-- check lvl argument
	if not lvl or type(lvl) ~= "number" then
		msg = "Provided lvl arg is invalid: "..tostring(lvl)
		lvlCheck = false
	end
	-- check level vs debug_level
	if  lvlCheck ~= false and lvl <= debugLevel then
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
	if lvlCheck ~= false and lvl <= debugLevelLog then
		if #args == 0 then
			logmsg = "No debug messages provided or nil"
		else
			for i=1, #args do
				local sep = (i == 1) and "" or separator
				logmsg = logmsg..sep..tostring(args[i])
			end
		end
		if A.db then
			tinsert(A.db.profile.log, logmsg)
		end
	end
end

-- ViragDevTool
function VDT_AddData(obj, desc)
	local vdt = _G.ViragDevTool_AddData or nil
	if vdt then
		vdt(obj, desc)
	end
end

-- debug hook
function dhook(object, method, dbg, dlevel)
	dlevel = dlevel or 1
	local function hooked(self, ...)
		if debugs then
			local args = {...}
			local msg, sep = method..", ", ", "
			local i = 1
			while args[i] and dbg[i] ~= nil do
				local v = dbg[i]
				if type(args[i]) == "table" and args[i][v] then
					msg = msg..tostring(args[i][v])..sep
				elseif dbg[i] then
					msg = msg..tostring(args[i])..sep
				end
				i = i + 1
			end
			dprint(1, msg)
		else
			dprint(1, method, ...)
		end
		--VDT_AddData(ti,"ti")
	end
	hooksecurefunc(A, method, hooked)
	--[[
	dbg = table which entries can be:
		"string" = key of an argument table
		true = argument itself
		false = no display
		_,nil = return all arguments
		dhook(A, "CheckUnits", {"event", false, true})
		dhook(A, "OnUnitCast")
	]]--
end

function debug()
	VDT_AddData(_G.AlertMe, "AlertMe")
	VDT_AddData(A, "A")
	VDT_AddData(P, "P")
	--dhook(A, "OnUnitCast")
end
