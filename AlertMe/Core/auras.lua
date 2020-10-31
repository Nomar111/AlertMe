-- set addon environment
setfenv(1, _G.AlertMe)
-- create table for snapshots
A.snapshots = {}

local function cleanSnapshots()
	local now = GetTime()
	for d, dstGUID in pairs(A.snapshots) do
		for s, checkedSpell in pairs(dstGUID) do
			for e, handle in pairs(checkedSpell) do
				if now - handle.ts > 10 then
					A.snapshots[d][s][e] = nil
				end
			end
		end
	end
	for d, dstGUID in pairs(A.snapshots) do
		for s, checkedSpell in pairs(dstGUID) do
			if not next(checkedSpell) then
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

local function matchUnitAura(cleu, evi, unit, filter)
	for i = 1, 100 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId  = UnitAura(unit, i, filter)
		if not name then
			break
		elseif cleu.checkedSpell == name then
			local remaining = (expirationTime > 0) and expirationTime - GetTime() or 0
			return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, remaining
		end
	end
end

function A:getUnitAura(cleu, evi)
	local unit = (cleu.dstIsTarget == true) and "target" or cleu.dstName
	local filter = (cleu.auraType == "BUFF") and "HELPFUL" or "HARMFUL"
	return matchUnitAura(cleu, evi, unit, filter)
	-- if not name and not cleu.delayed then -- only do the first timer
	-- 	C_Timer.After(0.2, function()
	-- 		A:processCLEU(cleu, evi)
	-- 	end)
end

function A:fakeEvent(cleu, evi)
	local _cleu = tcopy(cleu)
	_cleu.event = "SPELL_AURA_APPLIED"
	local _evi = events["SPELL_AURA_APPLIED"]
	-- get alerts for fake args
	local check, alerts = A:doChecks(_cleu, _evi)
	if not check then return end
	-- check for snapshots
	local exists
	exists, __cleu, __evi = A:checkSnapShot(_cleu, _evi)
	if exists then -- do whatever is defined in actions
		A:doActions(__cleu, __evi, alerts, true)
	else -- if no snapshot was found, add one for cast success event
		A:addSnapShot(cleu, evi)
	end
end

function A:checkSnapShot(cleu, evi)
	-- clear snasphot table of old entries first
	cleanSnapshots()
	-- if event = gain, check for success events and vice versa
	if evi.handle == "gain" then
		if A.snapshots[cleu.dstGUID] and A.snapshots[cleu.dstGUID][cleu.checkedSpell] and A.snapshots[cleu.dstGUID][cleu.checkedSpell]["success"] then
			local snapShot = A.snapshots[cleu.dstGUID][cleu.checkedSpell]["success"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				return true, snapShot.ti, snapShot.evi
			end
		end
		return false
	elseif evi.handle == "success" then
		if A.snapshots[cleu.dstGUID] and A.snapshots[cleu.dstGUID][cleu.checkedSpell] and A.snapshots[cleu.dstGUID][cleu.checkedSpell]["gain"] then
			local snapShot = A.snapshots[cleu.dstGUID][cleu.checkedSpell]["gain"]
			local timeDiff = GetTime() - snapShot.ts
			if timeDiff >= 0 and timeDiff < 2 then
				return true, snapShot.ti, snapShot.evi
			end
		end
		return false
	end
end

function A:addSnapShot(cleu, evi)
	if not A.snapshots[cleu.dstGUID] then A.snapshots[cleu.dstGUID] = {} end
	if not A.snapshots[cleu.dstGUID][cleu.checkedSpell] then A.snapshots[cleu.dstGUID][cleu.checkedSpell] = {} end
	A.snapshots[cleu.dstGUID][cleu.checkedSpell][evi.handle] = {
		ts = GetTime(),
		cleu = tcopy(cleu),
		evi = tcopy(evi)
	}
end

function A:initLCD()
	-- LibClassicDurations
	A.Libs.LCD:Register("AlertMe")
	A.Libs.LCD.enableEnemyBuffTracking = true
	UnitAura = A.Libs.LCD.UnitAuraWithBuffs
	--A.Libs.LCD.RegisterCallback("AlertMe", "UNIT_BUFF", function(event, unit) end)
end
