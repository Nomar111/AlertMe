--dprint(3, "core.lua")
-- upvalues
local _G, CombatLogGetCurrentEventInfo, UnitGUID, bit = _G, CombatLogGetCurrentEventInfo, UnitGUID, bit
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE
local GetInstanceInfo, IsInInstance, GetNumGroupMembers, SendChatMessage = GetInstanceInfo, IsInInstance, GetNumGroupMembers, SendChatMessage
local PlaySoundFile, StopSound, GetSchoolString = PlaySoundFile, StopSound, GetSchoolString
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
	-- init examples profile
	A:InitExamples()
	-- init LSM
	A:InitLSM()
	-- init scrolling text frame
	A:UpdateScrolling()
	-- init options
	A:InitSpellOptions()
	-- init Chatframes
	A:InitChatFrames()
	-- init LCD
	A:InitLCD()
	-- init LDB
	A:InitLDB()
	-- register for events
	A.ToggleAddon()
	-- for reloadui
	A:HideAllBars()
	-- init debugger
	VDT_AddData = _G.ViragDevTool_AddData or nil
end

function A:ParseCombatLog(eventName)
	dprint(3, "A:ParseCombatLog", eventName)
	local arg = {CombatLogGetCurrentEventInfo()}
	local ti = {
		ts = arg[1],
		event = arg[2],
		srcGUID = arg[4],
		srcName = arg[5],
		srcFlags = arg[6],
		dstGUID = arg[8],
		dstName = arg[9],
		dstFlags = arg[10],
		spellName = arg[13],
		spellSchool = arg[14]
	}
	-- check if trigger event exists in events table, if not abort
	if A.Events[ti.event] == nil then
		dprint(3, "Event not tracked")
		return
	end
	-- spell cast success sometimes has no destination data - take source data then
	if ti.event == "SPELL_CAST_SUCCESS" and ti.dstGUID == "" then
		ti.dstGUID, ti.dstName, ti.dstFlags = ti.srcGUID, ti.srcName, ti.srcFlags
	elseif ti.event == "SPELL_INTERRUPT" then
		ti.lockout = A.Lockouts[ti.spellName]
	end
	-- set evenInfo (either from master event or from self)
	local masterEvent = A.Events[ti.event].masterEvent
	local eventInfo = A.Events[masterEvent] or A.Events[ti.event]
	-- get optional arguments if there are any
	if eventInfo.optionalArgs then
		for i,v in pairs(eventInfo.optionalArgs) do
			ti[v] = arg[i+14]
		end
	end
	-- set relevant spell name
	ti.relSpellName = ti[eventInfo.relSpellName]
	-- call processTriggerInfo
	A:ProcessTriggerInfo(ti, eventInfo)
end

function A:ProcessTriggerInfo(ti, eventInfo)
	dprint(3, "A:ProcessTriggerInfo", ti.event, ti.relSpellName)
	if eventInfo.short == "removed" then
		-- remove auras if needed
		A:HideBars(ti, eventInfo)
		return
	elseif eventInfo.short == "success" then
		-- if spell cast success fake an applay event
		A:FakeEvent(ti, eventInfo)
	end
	-- do some checks
	local check, alerts = A:DoChecks(ti, eventInfo)
	if not check then return end
	-- if aura gain event & progress bar is to be displayed special treatment
	--if A:GetAlertSetting(alertsUnits, showBar, true) and eventInfo.short == "gain" then
	if eventInfo.short == "gain" then
		local name, _, _, _, duration, _, _, _, _, _, remaining = A:GetUnitAura(ti, eventInfo)
		if name and ((duration - remaining <= 2) or duration == 0) then
			A:DoActions(ti, eventInfo, alerts, false)
		elseif not name then
			if A:CheckSnapShot(ti, eventInfo) then
				-- call actions from snapShot
				A:DoActions(ti, eventInfo, alerts, true)
			else
				-- add a snapshot
				A:AddSnapShot(ti, eventInfo)
			end
		end
	else -- success, interrupt, dispel
		A:DoActions(ti, eventInfo, alerts, false)
	end
end

function A:DoActions(ti, eventInfo, alerts, snapShot)
	dprint(2, "A:DoActions", eventInfo.short, ti.relSpellName, "snapShot", snapShot)
	if eventInfo.actions then
		for _, action in pairs(eventInfo.actions) do
			if action == "chatAnnounce" and type(alerts) == "table" then A:ChatAnnounce(ti, alerts, eventInfo) end
			if action == "playSound" and type(alerts) == "table" then A:PlaySound(ti, alerts, eventInfo) end
			if action == "displayBars" and type(alerts) == "table" then A:DisplayBars(ti, alerts, eventInfo, snapShot) end
		end
	end
end


--**********************************************************************************************************************************
--Checks
--**********************************************************************************************************************************
function A:DoChecks(ti, eventInfo)
	dprint(3, "A:DoChecks", ti.relSpellName, eventInfo.short)
	local alerts, alertsUnits, errorMessage
	-- check for relevant alerts for spell/event
	alerts = A:GetAlerts(ti, eventInfo)
	if not alerts then
		dprint(3, "no relevant alert found for", eventInfo.short, ti.relSpellName)
		return false
	end
	-- check units
	alertsUnits, errorMessages = A:CheckUnits(ti, eventInfo, alerts)
	if not alertsUnits then
		dprint(3, "unit check failed", ti.relSpellName, unpack(errorMessages))
		return false
	end
	return true, alertsUnits
end

function A:GetAlerts(ti, eventInfo)
	dprint(3, "A:GetAlerts", ti.relSpellName, eventInfo.short)
	local alerts = {}
	local spellOptions
	if A.SpellOptions[ti.relSpellName] and A.SpellOptions[ti.relSpellName][eventInfo.short] then
		spellOptions = A.SpellOptions[ti.relSpellName][eventInfo.short]
	end
	-- various checks
	if eventInfo.spellSelection == false then -- spell selection disabled for this event
		dprint(3, "no spell sel for this event - ret all", eventInfo.short)
		for uid, tbl in pairs(A.AlertOptions[eventInfo.short]) do
			tinsert(alerts, tbl)
		end
	elseif not spellOptions then -- check for spell in alerts, check spell/event combo
		dprint(3, "spell/event combo not found", ti.relSpellName, eventInfo.short)
	else
		for uid, tbl in pairs(spellOptions) do
			tinsert(alerts, tbl.options)
		end
	end
	-- return if table
	if type(alerts) == "table" and #alerts >= 1 then
		return alerts
	end
end

function A:CheckUnits(ti, eventInfo, alerts_in)
	dprint(2, "A:CheckUnits",ti , ti.relSpellName, eventInfo.short)
	-- if no unit selection for this event return
	if eventInfo.unitSelection == false or alerts_in == true then
		return alerts_in
	end
	-- set some local variables
	local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
	-- create return table
	local alerts_out = {}
	local errorMessages = {}
	-- loop over the option groups
	for _, alert in pairs(alerts_in) do
		-- variable to hold the check result for this og
		local checkFailed = false
		-- do the relevant checks (src, dst)
		for _, pre in pairs (eventInfo.units) do
			-- set local variables
			local name, GUID, flags = ti[pre.."Name"], ti[pre.."GUID"], ti[pre.."Flags"]
			local units, exclude = alert[pre.."Units"], alert[pre.."Exclude"]
			local playerControlled = (bit.band(flags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)
			local isFriendly = (bit.band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0)
			local isHostile = (bit.band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0)
			local isPlayer = (GUID == playerGUID)
			local isTarget = (GUID == targetGUID)
			-- write some useful info into ti for later use
			ti[pre.."IsTarget"], ti[pre.."IsPlayer"], ti[pre.."IsFriendly"], ti[pre.."IsHostile"] = isTarget, isPlayer, isFriendly, isHostile
			-- player controlled check
			if not playerControlled and units ~= 6 then
				tinsert(errorMessages, pre..", ".."unit not player controlled")
				checkFailed = true
				break
			end
			-- exclude check -- 1 = none, 2 = myself, 3 = target
			if (exclude == 3 and isTarget) or (exclude == 2 and isPlayer) then
				tinsert(errorMessages, pre..", ".."exclude check failed")
				checkFailed = true
				break
			end
			-- do other checks
			if units == 4 then -- target check
				if not isTarget then
					tinsert(errorMessages, pre..", ".."target check failed")
					checkFailed = true
					break
				end
			elseif units == 5 then  -- player check
				if not isPlayer then
					tinsert(errorMessages, pre..", ".."player check failed")
					checkFailed = true
					break
				end
			elseif units == 2 then -- friendly player check
				if not isFriendly then
					tinsert(errorMessages, pre..", ".."friendly player check failed")
					checkFailed = true
					break
				end
			elseif units == 3 then -- hostile player check
				if not isHostile then
					tinsert(errorMessages, pre..", ".."hostile player check failed")
					checkFailed = true
					break
				end
			end
		end
		if not checkFailed then
			tinsert(alerts_out, alert)
		end
	end
	-- return
	if type(alerts_out) == "table" and #alerts_out >= 1 then
		return alerts_out, errorMessages
	else
		return false, errorMessages
	end
end

--**********************************************************************************************************************************
--Actions
--**********************************************************************************************************************************
function A:ChatAnnounce(ti, alerts, eventInfo)
	dprint(2, "A:ChatAnnounce", ti.spellName, eventInfo.short, "snapShot")
	-- get possible channels
	local inInstance, instanceType = IsInInstance()
	local channel = nil
	if GetNumGroupMembers() > 5 then
		if inInstance then
			channel = "INSTANCE_CHAT"
		else
			channel = "RAID"
		end
	elseif GetNumGroupMembers() > 0 then
		channel = "Party"
	end
	-- create queue for messages
	local msgQueue = {}
	-- loop through option groups
	for _, alert in pairs(alerts) do
		local msg = A:CreateMessage(ti, eventInfo, alert, false, false)
		local msgSystem = A:CreateMessage(ti, eventInfo, alert, true, false)
		local msgScrolling = (P.scrolling.showIcon) and A:CreateMessage(ti, eventInfo, alert, true, true) or  msgSystem
		-- bg/raid/party
		if alert.chatChannels == 2 and channel then
			if msgQueue[channel] == nil then msgQueue[channel] = {} end
			msgQueue[channel][msg] = msg
		end
		-- party
		if alert.chatChannels == 3 and inInstance then
			if msgQueue["PARTY"] == nil then msgQueue["PARTY"] = {} end
			msgQueue["PARTY"][msg] = msg
		end
		-- say
		if alert.chatChannels == 4 and inInstance then
			if msgQueue["SAY"] == nil then msgQueue["SAY"] = {} end
			msgQueue["SAY"][msg] = msg
		end
		-- addon messages
		if alert.addonMessages == 1 or (alert.addonMessages == 3 and not inInstance) then
			if msgQueue["SYSTEM"] == nil then msgQueue["SYSTEM"] = {} end
			msgQueue["SYSTEM"][msg] = msgSystem
		end
		-- whisper destination unit
		if eventInfo.dstWhisper == true and ti.dstIsFriendly and not ti.dstIsPlayer then
			if (alert.dstWhisper == 2 and ti.srcIsPlayer) or alert.dstWhisper == 3 then
				if msgQueue["WHISPER"] == nil then msgQueue["WHISPER"] = {} end
				msgQueue["WHISPER"][msg] = mmsgsg
			end
		end
		-- scrolling messages
		if alert.scrollingText == true and P.scrolling.enabled then
			if msgQueue["SCROLLING"] == nil then msgQueue["SCROLLING"] = {} end
			msgQueue["SCROLLING"][msg] = msgScrolling
		end
	end
	-- loop through message queue and send messages
	for chan, messages in pairs(msgQueue) do
		for _, msg in pairs(messages) do
			if chan == "SYSTEM" then
				A:SystemMessage(msg)
			elseif chan == "WHISPER" then
				SendChatMessage(string.gsub(msg, dstName, "You"), chan, nil, ti.dstName)
			elseif chan == "SCROLLING" then
				A:PostInScrolling(msg, ti.icon)
			else
				SendChatMessage(msg, chan, nil, nil)
			end
		end
	end
end

function A:PlaySound(ti, alerts, eventInfo)
	dprint(2, "A:PlaySound", ti.relSpellName, eventInfo.short)
	local soundQueue = {}
	local delay = 1.3
	-- play the sound queue
	local function PlaySoundQueue(queue, oldIsPlaying, oldHandle)
		dprint(2, "PlaySoundQueue", queue, oldIsPlaying, oldHandle)
		-- stop ols sound if its still plying
		if oldIsPlaying and oldHandle then
			StopSound(oldHandle)
		end
		-- loop & iterate
		for sound, _ in pairs(queue) do
			local isPlaying, handle = PlaySoundFile(A.Sounds[sound])
			queue[sound] = nil
			if next(queue) then
				C_Timer.After(delay, function() PlaySoundQueue(queue, isPlaying, handle) end)
			else
				break
			end
		end
	end
	-- loop alerts
	for _, alert in pairs(alerts) do
		--{[1] = "No sound alerts", [2] = "Play one sound alert for all spells", [3] = "Play individual sound alerts per spell"
		if alert.soundSelection == 1 then
			break
		elseif alert.soundSelection == 2 then
			sound = alert.soundFile
		elseif alert.soundSelection == 3 then
			sound = alert.spellNames[ti.spellName].soundFile
		end
		-- add to soundqueue
		if sound == nil or sound == "None" or sound == "" then
			break
		else
			soundQueue[sound] = true
		end
	end
	PlaySoundQueue(soundQueue)
end

--**********************************************************************************************************************************
--Inits
--**********************************************************************************************************************************
function A:InitSpellOptions()
	dprint(3, "A:InitSpellOptions")
	A.AlertOptions = {}
	A.SpellOptions = {}
	--VDT_AddData(A.AlertOptions, "A.AlertOptions")
	--VDT_AddData(A.SpellOptions, "A.SpellOptions")
	-- loop through events/alerts
	for event, alert in pairs(P.alerts) do
		--dprint(3, "Loop1: ", event, alert)
		A.AlertOptions[event] = {}
		-- alert details
		for uid, alertDetails in pairs(alert.alertDetails) do
			-- check if alert is active and not default value
			if alertDetails.active == true and alertDetails.created == true then
				--dprint(3, "Loop2: ", uid, alertDetails)
				A.AlertOptions[event][uid] = alertDetails
				-- spells
				for spellName, spellDetails in pairs(alertDetails.spellNames) do
					if not A.SpellOptions[spellName] then A.SpellOptions[spellName] = {} end
					if not A.SpellOptions[spellName][event] then A.SpellOptions[spellName][event] = {} end
					if not A.SpellOptions[spellName][event][uid] then
						A.SpellOptions[spellName][event][uid] = {
							uid = uid,
							event = event,
							options = A.AlertOptions[event][uid],
							icon = spellDetails.icon,
							soundFile = spellDetails.soundFile,
						}
					end
				end
			end
		end
	end
end

--**********************************************************************************************************************************
-- Register events
--**********************************************************************************************************************************
function A.RegisterCLEU(event)
	dprint(3, "A.RegisterCLEU", event)
	local name, instanceType = GetInstanceInfo()
	-- check against instance type and settings
	if (instanceType == "party" or instanceType == "raid") and P.general.zones.instance then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.ParseCombatLog)
	elseif (instanceType == "pvp" or instanceType == "arena") and P.general.zones.bg then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.ParseCombatLog)
	elseif instanceType == "none" and P.general.zones.world then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.ParseCombatLog)
	else
		--dprint(2, "unregister", "type", instanceType, "bg", P.general.zones.bg, "world", P.general.zones.world, "instance", P.general.zones.instance)
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllBars()
	end
end

function A.ToggleAddon()
	dprint(3, "A.ToggleAddon", P.general.enabled)
	if P.general.enabled == true then
		A:RegisterEvent("PLAYER_ENTERING_WORLD", A.RegisterCLEU)
		A.RegisterCLEU("Toggle")
	else
		A:UnregisterEvent("PLAYER_ENTERING_WORLD")
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllBars()
	end
	A.AlertMeBroker.iconR = (P.general.enabled) and 1 or 0.5
end

--**********************************************************************************************************************************
-- Various
--**********************************************************************************************************************************
function A:CreateMessage(ti, eventInfo, alert, colored, showIcon)
	dprint(3, "A:CreateMessage")
	local prefix, postfix = P.messages.prefix, P.messages.postfix
	-- check possible replacements for being nil
	local srcName = (ti.srcName) and A:GetUnitNameShort(ti.srcName) or ""
	local dstName = (ti.dstName) and A:GetUnitNameShort(ti.dstName) or ""
	local spellName = (ti.spellName) and ti.spellName or ""
	local extraSpellName = (ti.extraSpellName) and ti.extraSpellName or ""
	local extraSchool = (ti.extraSchool) and GetSchoolString(ti.extraSchool) or ""
	local lockout = (ti.lockout) and ti.lockout or ""
	-- get message from options
	local msg = P.messages[eventInfo.short]
	-- override?
	if alert.msgOverride and alert.msgOverride ~= "" then
		msg = alert.msgOverride
	end
	-- replace
	msg = string.gsub(msg, "%%dstName", dstName)
	msg = string.gsub(msg, "%%srcName", srcName)
	msg = string.gsub(msg, "%%spellName", spellName)
	msg = string.gsub(msg, "%%extraSpellName", extraSpellName)
	msg = string.gsub(msg, "%%extraSchool", extraSchool)
	msg = string.gsub(msg, "%%lockout", lockout)
	-- get reaction color
	local color = A:GetReactionColor(ti)
	-- return
	if not colored then
		return prefix..msg..postfix
	elseif colored and not showIcon then
		return WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
	elseif colored and showIcon then
		local iconSize = P.scrolling.fontSize
		local icon = " |T"..ti.icon..":"..iconSize..":"..iconSize..":0:0|t "

		return WrapTextInColorCode(prefix, color)..icon..msg..icon..WrapTextInColorCode(postfix, color)
	end
end

function A:GetReactionColor(ti, rgb)
	dprint(3, "A:GetReactionColor")
	-- prepare return value
	local color = "white"
	-- aura applied/refresh
	if ti.event == "SPELL_AURA_APPLIED" or ti.event == "SPELL_AURA_REFRESH" then
		if (ti.dstIsFriendly and ti.auraType == "BUFF") or (ti.dstIsHostile and ti.auraType == "DEBUFF") then
			color = "green"
		else
			color = "red"
		end
	end
	-- spell dispel
	if ti.event == "SPELL_DISPEL" then
		if (ti.dstIsFriendly and ti.auraType == "BUFF") or (ti.dstIsHostile and ti.auraType == "DEBUFF") then
			color = "red"
		else
			color = "green"
		end
	end
	-- spell cast start / success / interrupt
	if ti.event == "SPELL_CAST_START" or ti.event == "SPELL_CAST_SUCCESS" or ti.event == "SPELL_INTERRUPT" then
		if ti.srcIsFriendly then
			color =  "green"
		else
			color = "red"
		end
	end
	-- return RGB or HEX
	if rgb == "rgb" then
		return unpack(A.Colors[color]["rgb"])
	else
		return A.Colors[color]["hex"]
	end
end
