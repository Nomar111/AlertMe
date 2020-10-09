-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Snapshots = {}

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

function A:AddSnapShot
end
