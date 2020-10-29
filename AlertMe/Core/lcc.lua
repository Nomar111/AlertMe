-- upvalues
local UnitPlayerControlled, UnitIsFriend, UnitIsEnemy = UnitPlayerControlled, UnitIsFriend, UnitIsEnemy
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL
-- set addon environment
setfenv(1, _G.AlertMe)

function A:InitLCC()
	if not P.bars.spells.enabled or not P.general.enabled == true then
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
end

local function getAlerts(spellName)
	-- get spellName
	if not spellName then return end
	-- check if spell/event combo exists in spell options
	local alerts = {}
	if A.SpellOptions[spellName] and A.SpellOptions[spellName]["start"] then
		for _, tbl in pairs(A.SpellOptions[spellName]["start"]) do
			if tbl.options.showBar then
				tinsert(alerts, tbl.options)
			end
		end
	end
	-- return if table
	if type(alerts) == "table" and #alerts >= 1 then
		return alerts
	end
end

function A:OnUnitCast(event, unit, unitGUID, unitName, unitFlags, spellName, spellId, icon, startTime, endTime)
	local barType = "spells"
	-- events
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED"
	or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
		-- check spell settings for that spell
		local alerts = getAlerts(spellName)
		if not alerts then return end
		-- create arguments for unitcheck
		local ti = {
			event = event,
			srcGUID = unitGUID,
			srcName = unitName,
			srcFlags = unitFlags,
			spellName = spellName,
			relSpellName = relSpellName,
		}
		local eventInfo = A.Events["SPELL_CAST_START"]
		-- check units
		local alertsUnit, errorMessages = A:CheckUnits(ti, eventInfo, alerts)
		if not alertsUnit then
			--dprint(3, "unit check failed", ti.relSpellName, unpack(errorMessages))
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
