-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Snapshots = {}
VDT_AddData(A.Snapshots, "Snapshots")

function A:InitLCD()
	dprint(2, "A:InitLCD")
	A.Libs.LCD:Register("AlertMe")
	A.Libs.LCD.enableEnemyBuffTracking = true
	UnitAura = A.Libs.LCD.UnitAuraWithBuffs
	--A.Libs.LCD.RegisterCallback("AlertMe", "UNIT_BUFF", function(event, unit) end)
end

function A:GetUnitAura(ti, eventInfo)
	dprint(2, "A:GetUnitAura", ti.relSpellName, ti.dstName)
	local unit = (ti.dstIsTarget == true) and "target" or ti.dstName
	local filter = (ti.auraType == "BUFF") and "HELPFUL" or "HARMFUL"
	local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining =  A:MatchUnitAura(ti, eventInfo, unit, filter)
	if not name and not ti.delayed then -- only do the first timer
		ti.delayed = true
		C_Timer.After(0.2, function()
			dprint(2, "delayed call", ti.relSpellName, ti.dstName)
			A:ProcessTriggerInfo(ti, eventInfo)
		end)
	else
		return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining
	end
end

function A:MatchUnitAura(ti, eventInfo, unit, filter)
	dprint(2, "A:MatchUnitAura", ti.relSpellName, "unit", unit, "filter", filter)
	for i = 1, 100 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId  = UnitAura(unit, i, filter)
		if not name then
			break
		elseif ti.relSpellName == name then
			local remaining = (expirationTime > 0) and expirationTime - GetTime() or nil
			return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining
		end
	end
end

function A:FakeEvent(ti, eventinfo)
	dprint(2, "A:FakeEvent", ti.relSpellName, origEvent.short, "delayed", ti.delayed)
	-- create fake args
	local _ti = tcopy(ti)
	_ti.event = "SPELL_AURA_APPLIED"
	local _eventInfo = A.Events["SPELL_AURA_APPLIED"]
	-- get alerts for fake args
	local alerts, alertsUnits, errorMessages
	-- check for relevant alerts for spell/event
	alerts = A:GetAlerts(_ti, _eventInfo)
	if not alerts then
		dprint(2, "fakeevent: no relevant alert found", _eventInfo.short, _ti.relSpellName, delayed)
		return
	end
	-- check units
	alertsUnits, errorMessages = A:CheckUnits(_ti, _eventInfo, alerts)
	if not alertsUnits then
		dprint(2, "fakeevent: unit check failed", _eventInfo.short, _ti.relSpellName, unpack(errorMessages))
		return
	end
	-- check for snapshots
	local exists
	exists, _ti, _eventInfo = A:CheckSnapShot(ti, eventinfo)
	if exists then
		-- do whatever is defined in actions
		dprint(1, "fakevent: do actions", _ti.relSpellName, _eventInfo.short)
		A:DoActions(_ti, _eventInfo, alertsUnits, true)
	else
		-- if no snapshot was found, add one for the success event
		A:AddSnapShot(ti, eventinfo)
	end
end

function A:CheckSnapShot(ti, eventInfo)
	dprint(2, "A:CheckSnapShot", ti.relSpellName, eventInfo.short)
	A:CleanSnapshots()
	if eventInfo.short == "gain" then
		if A.Snapshots[ti.dstGUID] and A.Snapshots[ti.dstGUID][ti.relSpellName] and A.Snapshots[ti.dstGUID][ti.relSpellName]["success"] then
			local snapShot = A.Snapshots[ti.dstGUID][ti.relSpellName]["success"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				dprint(1, "snapshot(gain): found match (success)", timeDiff, ti.relSpellName, eventInfo.short)
				return true, snapShot.ti, snapShot.eventInfo
			end
		end
		dprint(1, "snapshot(gain): no match (success)", timeDiff, ti.relSpellName)
		return false
	elseif eventInfo.short == "success" then
		if A.Snapshots[ti.dstGUID] and A.Snapshots[ti.dstGUID][ti.relSpellName] and A.Snapshots[ti.dstGUID][ti.relSpellName]["gain"] then
			local snapShot = A.Snapshots[ti.dstGUID][ti.relSpellName]["gain"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				dprint(1, "snapshot(success): found match (gain)", timeDiff, ti.relSpellName)
				return true, snapShot.ti, snapShot.eventInfo
			end
		end
		dprint(1, "no gain ss found", ti.relSpellName, eventInfo.short)
		return false
	end
end

function A:AddSnapShot(ti, eventInfo)
	dprint(1, "A:AddSnapShot", ti.relSpellName, eventInfo.short)
	--if ti.delayed then return end
	if not A.Snapshots[ti.dstGUID] then A.Snapshots[ti.dstGUID] = {} end
	if not A.Snapshots[ti.dstGUID][ti.relSpellName] then A.Snapshots[ti.dstGUID][ti.relSpellName] = {} end
	A.Snapshots[ti.dstGUID][ti.relSpellName][eventInfo.short] = {
		ts = GetTime(),
		ti = tcopy(ti),
		eventInfo = tcopy(eventInfo)
	}
end

function A:CleanSnapshots()
	dprint(2, "A:CleanSnapshots")
	local now = GetTime()
	for d, dstGUID in pairs(A.Snapshots) do
		for s, relSpellName in pairs(dstGUID) do
			for e, short in pairs(relSpellName) do
				if now - short.ts > 10 then
					A.Snapshots[d][s][e] = nil
				end
			end
		end
	end
	for d, dstGUID in pairs(A.Snapshots) do
		for s, relSpellName in pairs(dstGUID) do
			if not next(relSpellName) then
				A.Snapshots[d][s] = nil
			end
		end
	end
	for d, dstGUID in pairs(A.Snapshots) do
		if not next(dstGUID) then
			A.Snapshots[d] = nil
		end
	end
end
