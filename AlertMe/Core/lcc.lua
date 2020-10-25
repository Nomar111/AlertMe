-- get engine environment
local A, O = unpack(select(2, ...))
-- upvalues
local UnitPlayerControlled, UnitIsFriend, UnitIsEnemy = UnitPlayerControlled, UnitIsFriend, UnitIsEnemy
-- set engine as new global environment
setfenv(1, _G.AlertMe)
local barType = "spells"

function A:InitLCC()
	dprint(3, "A:InitLCC")
	-- register callbacks from lib classic casterino
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_START", "UNIT_SPELLCAST")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST") -- only for player
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST")
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST") -- only for player
	A.Libs.LCC.RegisterCallback(A,"UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST")
	-- provide casting/channel info
	UnitCastingInfo = function(unit)
		return A.Libs.LCC:UnitCastingInfo(unit) -- name,text,texture,startTimeMS,endTimeMS,isTradeSkill,castID,notInterruptible,spellId
	end
	UnitChannelInfo = function(unit)
		return A.Libs.LCC:UnitChannelInfo(unit)
	end
end

local function getAlerts(spellId)
	dprint(3, "checkSpellSettings", spellId)
	-- get spellName
	local spellName = GetSpellInfo(spellId)
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

local function checkUnits(unit, alerts)
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
		local GUID = UnitGUID(unit)
		local units, exclude = alert.options["srcUnits"], alert.options["srcExclude"]
		local playerControlled = UnitPlayerControlled(unit)
		local isFriendly = UnitIsFriend(unit, "player")
		local isHostile = UnitIsEnemy(unit, "player")
		local isPlayer = (GUID == playerGUID)
		local isTarget = (GUID == targetGUID)
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


function A:UNIT_SPELLCAST(event, unit, castGUID, spellId)
	dprint(2, "A:UNIT_SPELLCAST", event, unit, spellId)
	-- we need a vlaid GUID and spellId
	local unitGUID, id = UnitGUID(unit), nil
	if unitGUID and spellId then
		id = UnitGUID(unit)..spellId
	else
		return
	end
	-- events
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
		-- check display settings for that spell
		local alerts = getAlerts(spellId)
		if not alerts then return end
		-- unit check
		local unitCheck, errorMessages = checkUnits(unit, alerts)
		if not unitCheck then
			dprint(2, "unitCheck failed", unpack(errorMessages))
			return
		end
		-- show cast bar
		local name, _, icon, _, endMS = UnitCastingInfo(unit)
		local remaining = (endMS - (GetTime() * 1000))/1000
		A:ShowBar(barType, id, name, icon, remaining, true)
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		A:HideBar(barType, id)
	end
end
