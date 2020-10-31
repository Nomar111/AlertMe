-- set addon environment
setfenv(1, _G.AlertMe)
-- create table for snapshots
A.snapshots = {}

local function cleanSnapshots()
	local now = GetTime()
	for d, dstGUID in pairs(A.snapshots) do
		for s, relSpellName in pairs(dstGUID) do
			for e, short in pairs(relSpellName) do
				if now - short.ts > 10 then
					A.snapshots[d][s][e] = nil
				end
			end
		end
	end
	for d, dstGUID in pairs(A.snapshots) do
		for s, relSpellName in pairs(dstGUID) do
			if not next(relSpellName) then
				A.snapshots[d][s] = nil
			end
		end
	end
	for d, dstGUID in pairs(A.snapshots) do
		if not next(dstGUID) then
			A.snapshots[d] = nil
		end
	end
end

local function matchUnitAura(ti, eventInfo, unit, filter)
	for i = 1, 100 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId  = UnitAura(unit, i, filter)
		if not name then
			break
		elseif ti.relSpellName == name then
			local remaining = (expirationTime > 0) and expirationTime - GetTime() or 0
			return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining
		end
	end
end

function A:getUnitAura(ti, eventInfo)
	local unit = (ti.dstIsTarget == true) and "target" or ti.dstName
	local filter = (ti.auraType == "BUFF") and "HELPFUL" or "HARMFUL"
	return matchUnitAura(ti, eventInfo, unit, filter)
	-- if not name and not ti.delayed then -- only do the first timer
	-- 	C_Timer.After(0.2, function()
	-- 		A:ProcessTriggerInfo(ti, eventInfo)
	-- 	end)
end

function A:fakeEvent(ti, eventInfo)
	local _ti = tcopy(ti)
	_ti.event = "SPELL_AURA_APPLIED"
	local _eventInfo = A.Events["SPELL_AURA_APPLIED"]
	-- get alerts for fake args
	local check, alerts = A:DoChecks(_ti, _eventInfo)
	if not check then return end
	-- check for snapshots
	local exists
	exists, __ti, __eventInfo = A:checkSnapShot(_ti, _eventInfo)
	if exists then -- do whatever is defined in actions
		A:DoActions(__ti, __eventInfo, alerts, true)
	else -- if no snapshot was found, add one for cast success event
		A:addSnapShot(ti, eventInfo)
	end
end

function A:checkSnapShot(ti, eventInfo)
	-- clear snasphot table of old entries first
	cleanSnapshots()
	-- if event = gain, check for success events and vice versa
	if eventInfo.short == "gain" then
		if A.snapshots[ti.dstGUID] and A.snapshots[ti.dstGUID][ti.relSpellName] and A.snapshots[ti.dstGUID][ti.relSpellName]["success"] then
			local snapShot = A.snapshots[ti.dstGUID][ti.relSpellName]["success"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				return true, snapShot.ti, snapShot.eventInfo
			end
		end
		return false
	elseif eventInfo.short == "success" then
		if A.snapshots[ti.dstGUID] and A.snapshots[ti.dstGUID][ti.relSpellName] and A.snapshots[ti.dstGUID][ti.relSpellName]["gain"] then
			local snapShot = A.snapshots[ti.dstGUID][ti.relSpellName]["gain"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				return true, snapShot.ti, snapShot.eventInfo
			end
		end
		return false
	end
end

function A:addSnapShot(ti, eventInfo)
	if not A.snapshots[ti.dstGUID] then A.snapshots[ti.dstGUID] = {} end
	if not A.snapshots[ti.dstGUID][ti.relSpellName] then A.snapshots[ti.dstGUID][ti.relSpellName] = {} end
	A.snapshots[ti.dstGUID][ti.relSpellName][eventInfo.short] = {
		ts = GetTime(),
		ti = tcopy(ti),
		eventInfo = tcopy(eventInfo)
	}
end

function A:initLCD()
	-- LibClassicDurations
	A.Libs.LCD:Register("AlertMe")
	A.Libs.LCD.enableEnemyBuffTracking = true
	UnitAura = A.Libs.LCD.UnitAuraWithBuffs
	--A.Libs.LCD.RegisterCallback("AlertMe", "UNIT_BUFF", function(event, unit) end)
end
