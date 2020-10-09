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
	dprint(2, "A:GetAuraInfo", ti.dstName, ti.relSpellName)
	local unit = (ti.dstIsTarget == true) and "target" or ti.dstName
	for i = 1, 100 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId  = UnitAura(unit, i)
		if not name then
			break
		else
			if ti.relSpellName == name then
				local remaining = (expirationTime > 0) and expirationTime - GetTime() or nil
				return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining
			end
		end
	end
end

function A:Snapshot(ti, eventInfo)
	dprint(3, "A:Snapshot", ti.relSpellName, eventInfo.short)
	-- if success was cast check if there is a gain alert that fits the event
	if eventInfo.short == "success" then
		local _eventInfo = tcopy(eventInfo)
		local _ti = tcopy(ti)
		_ti.event = "SPELL_AURA_APPLIED"
		_eventInfo.short = "gain"
		local alerts = A:GetAlerts(_ti, _eventInfo)
		if not alerts then return end
		if not A:CheckUnits(_ti, _eventInfo, alerts) then return end
		A:CheckSnapShot(ti, eventInfo)
	elseif eventInfo.short == "gain" then
		A:CheckSnapShot(ti, eventInfo)
	end
end

function A:CheckSnapShot(ti, eventInfo)
	dprint(2, "A:Snapshot", ti.relSpellName, eventInfo.short)
	A:CleanSnapshots()
	if eventInfo.short == "gain" then
		if A.Snapshots[ti.dstGUID] and A.Snapshots[ti.dstGUID][ti.relSpellName] and A.Snapshots[ti.dstGUID][ti.relSpellName]["success"] then
			local snap = A.Snapshots[ti.dstGUID][ti.relSpellName]["success"]
			local timeDiff = GetTime() - snap.ts
			if timeDiff > 0 and timeDiff < 3 then
				--dprint(1, ti.relSpellName, "on", ti.dstName, "before", GetTime() - snap.ts, "trig", eventInfo.short)
				return true
			end
		end
	elseif eventInfo.short == "success" then
		if A.Snapshots[ti.dstGUID] and A.Snapshots[ti.dstGUID][ti.relSpellName] and A.Snapshots[ti.dstGUID][ti.relSpellName]["gain"] then
			local snap = A.Snapshots[ti.dstGUID][ti.relSpellName]["gain"]
			local timeDiff = GetTime() - snap.ts
			if timeDiff > 0 and timeDiff < 3 then
				dprint(1, ti.relSpellName, "on", ti.dstName, "before", GetTime() - snap.ts, "trig", eventInfo.short)
			end
		end
	end
	if not A.Snapshots[ti.dstGUID] then A.Snapshots[ti.dstGUID] = {} end
	if not A.Snapshots[ti.dstGUID][ti.relSpellName] then A.Snapshots[ti.dstGUID][ti.relSpellName] = {} end
	A.Snapshots[ti.dstGUID][ti.relSpellName][eventInfo.short] = {
		ts = GetTime(),
		ti = tcopy(ti),
		eventInfo = tcopy(eventInfo)
	}
end

function A:CleanSnapshots()
	dprint(1, "A:CleanSnapshots")
	local now = GetTime()
	for d, dstGUID in pairs(A.Snapshots) do
		for s, relSpellName in pairs(dstGUID) do
			for e, short in pairs(relSpellName) do
				if now - short.ts > 10 then
					dprint(1, "das war zu lange", now - short.ts, short)
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
