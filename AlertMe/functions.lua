-- upvalues
local _G, FCF_GetNumActiveChatFrames = _G, _G.FCF_GetNumActiveChatFrames
local getmetatable, setmetatable, hooksecurefunc, gsub, date, tostring = getmetatable, setmetatable, hooksecurefunc, string.gsub, date, tostring
-- set addon environment
setfenv(1, _G.AlertMe)
-- create chtFrames container
chatFrames = {}

function debug()
	-- VDT_AddData(_G.AlertMe, "AlertMe")
	-- VDT_AddData(A, "A")
	-- VDT_AddData(O, "O")
	-- VDT_AddData(P, "P")
	-- VDT_AddData(A.AlertOptions, "A.AlertOptions")
	-- VDT_AddData(A.SpellOptions, "A.SpellOptions")
	-- dhook(A, "FakeEvent")
end

function tcopy(t, deep, seen)
	seen = seen or {}
	local nt = {}
	for k, v in pairs(t) do
		dprint(k,v)
		if deep and type(v) == 'table' then
			nt[k] = tcopy(v, deep, seen)
		else
			nt[k] = v
		end
	end
	if getmetatable(t) then
		setmetatable(nt, tcopy(getmetatable(t), deep, seen))
	end
	seen[t] = nt
	return nt
end

function getShortName(name)
	-- getUnitName: Returns Unitname without Realm
	local short = gsub(name, "%-[^|]+", "")
	return short
end

function initChatFrames()
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			chatFrames[name] = "ChatFrame"..i
		end
	end
end
initChatFrames()

function addonMessage(msg)
	-- loop through chat frames and post messages
	for i, name in pairs(chatFrames) do
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
	local debugLevel, debugLevelLog = DEBUG_LEVEL
	if P then
		debugLevel =  P.general.debugLevel
		debugLevelLog = P.general.debugLevelLog
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
		addonMessage(prefix..msg)
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
		if P then
			tinsert(P.log, logmsg)
		end
	end
end
--
-- ViragDevTool
function VDT_AddData(obj, desc)
	local vdt = _G.ViragDevTool_AddData
	if not vdt then
		print("_G.ViragDevTool_AddData nicht verfürgbar")

	else
		vdt(obj, desc)
	end
end


-- debug hook
function dhook(object, method, dbg, dlevel)
	--[[
	dbg = table which entries can be:
	"string" = key of an argument table
	true = argument itself
	false = no display
	_,nil = return all arguments
	dhook(A, "CheckUnits", {"event", false, true})
	dhook(A, "OnUnitCast")
	]]--
	dlevel = dlevel or 1
	local function hooked(...)
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
		end
		--VDT_AddData(self[method],method)
	end
	hooksecurefunc(A, method, hooked)
end
