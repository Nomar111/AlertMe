-- get engine environment
local A, O = unpack(select(2, ...))
-- upvalues
local UnitPlayerControlled, UnitIsFriend, UnitIsEnemy, print = UnitPlayerControlled, UnitIsFriend, UnitIsEnemy, print
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function A:InitLCC()
	dprint(3, "A:InitLCC")
	if not P.bars.spells.enabled then
		A.Libs.LCC.UnregisterAllCallbacks(A)
		return
	end
	-- register callbacks from lib classic casterino
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_START", "OnUnitCast")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_DELAYED", "OnUnitCast") -- only for player
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_STOP", "OnUnitCast")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_FAILED", "OnUnitCast")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_INTERRUPTED", "OnUnitCast")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_START", "OnUnitCast")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_UPDATE", "OnUnitCast") -- only for player
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_STOP", "OnUnitCast")
	-- provide casting/channel info
	UnitCastingInfo = function(unit)
		return A.Libs.LCC:UnitCastingInfo(unit) -- name,text,texture,startTimeMS,endTimeMS,isTradeSkill,castID,notInterruptible,spellId
	end
	UnitChannelInfo = function(unit)
		return A.Libs.LCC:UnitChannelInfo(unit)	-- name,text,texture,startTimeMS,endTimeMS,isTradeSkill,castID,notInterruptible,spellId
	end
	-- debug
	--A:DebugLCC()
end

local function getAlerts(spellName)
	-- get spellName
	if not spellName then return end
	-- check if spell/event combo exists in spell options
	local alerts = {}
	if A.SpellOptions[spellName] and A.SpellOptions[spellName]["start"] then
		for _, tbl in pairs(A.SpellOptions[spellName]["start"]) do
			if tbl.options.showBar then
				tinsert(alerts, tbl)
			end
		end
	end
	-- return if table
	if type(alerts) == "table" and #alerts >= 1 then
		return alerts
	end
end

local function checkUnits(unit, unitGUID, alerts)
	dprint(3, "checkSpellSettings", spellId)
	-- set some local variables
	local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
	-- create return table
	local errorMessages = {}
	-- loop over the option groups
	for _, alert in pairs(alerts) do
		-- variable to hold the check result for this og
		local checkFailed = false
		-- set local variables
		local units, exclude = alert.options["srcUnits"], alert.options["srcExclude"]
		local playerControlled, isFriendly, isHostile
		if unit ~= "noUnit" then
			playerControlled, isFriendly, isHostile = UnitPlayerControlled(unit), UnitIsFriend(unit, "player"), UnitIsEnemy(unit, "player")
		elseif A.GUIDS[unitGUID] then
			playerControlled = true
			isFriendly = A.GUIDS[unitGUID].friendly
			isHostile = not A.GUIDS[unitGUID].friendly
		else
			dprint(1, "cannot get unit reaction, assuming...", unit, unitGUID)
			playerControlled = true
			isFriendly = false
			isHostile = true
		end
			-- make some assupmtions
		local isPlayer, isTarget = (unitGUID == playerGUID), (unitGUID == targetGUID)
		-- player controlled check
		if not playerControlled and units ~= 6 then
			tinsert(errorMessages, "unit not player controlled")
			checkFailed = true
		end
		-- exclude check -- 1 = none, 2 = myself, 3 = target
		if (exclude == 3 and isTarget) or (exclude == 2 and isPlayer) then
			tinsert(errorMessages, "exclude check failed")
			checkFailed = true
		end
		-- do other checks
		if units == 4 then -- target check
			if not isTarget then
				tinsert(errorMessages, "target check failed")
				checkFailed = true
			end
		elseif units == 5 then  -- player check
			if not isPlayer then
				tinsert(errorMessages, "player check failed")
				checkFailed = true
				break
			end
		elseif units == 2 then -- friendly player check
			if not isFriendly then
				tinsert(errorMessages, "friendly player check failed")
				checkFailed = true
			end
		elseif units == 3 then -- hostile player check
			if not isHostile then
				tinsert(errorMessages, "hostile player check failed")
				checkFailed = true
			end
		end
		-- if all checks passed for at least one alert, we can show the cast bar
		if not checkFailed then
			return true, errorMessages
		end
	end
	return false, errorMessages
end

function A:OnUnitCast(event, unit, unitGUID, unitName, spellName, spellId, icon, castType, startTime, endTime)
	dprint(2, event, unit, unitGUID, unitName, spellName, spellId, icon, castType, startTime, endTime)
	local barType = "spells"
	-- events
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"
	or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		-- check display settings for that spell
		local alerts = getAlerts(spellName)
		if not alerts then return end
		-- unit check
		local unitCheck, errorMessages = checkUnits(unit, unitGUID, alerts)
		if not unitCheck then
			dprint(2, "unitCheck failed", unpack(errorMessages))
			return
		end
		-- calculate remaining duration & show cast bar
		remaining = (endTime - (GetTime() * 1000))/1000
		A:ShowBar(barType, unitGUID, unitName, icon, remaining, true)
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_STOP"
	or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		A:HideBar(barType, unitGUID)
	end
end

function A:DebugLCC()
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetScript("OnEvent", function(self, event, ...)
		return self[event](self, event, ...)
	end)

	local CastbarEventHandler = function(event, unit, ...)
		print("A:DebugLCC", event, unit, ...)
	end
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_START", CastbarEventHandler)
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_DELAYED", CastbarEventHandler) -- only for player
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_STOP", CastbarEventHandler)
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_FAILED", CastbarEventHandler)
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_INTERRUPTED", CastbarEventHandler)
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_CHANNEL_START", CastbarEventHandler)
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_CHANNEL_UPDATE", CastbarEventHandler) -- only for player
	A.Libs.LCC.RegisterCallback(f,"UNIT_SPELLCAST_CHANNEL_STOP",CastbarEventHandler)
end
