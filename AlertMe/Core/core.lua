-- upvalues
local _G, CombatLogGetCurrentEventInfo, GetInstanceInfo, gsub = _G, CombatLogGetCurrentEventInfo, GetInstanceInfo, string.gsub
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL
local IsInInstance, GetNumGroupMembers, UnitGUID, UnitName, C_Timer = IsInInstance, GetNumGroupMembers, UnitGUID, UnitName, C_Timer
local PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bitband = PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bit.band

-- set addon environment
setfenv(1, _G.AlertMe)

-- local functions
local function hideGUI(ti, eventInfo)
	A:hideAuraBars(ti, eventInfo)
	A:hideGlow(ti, eventInfo)
end

-- init function
function A:initialize()
	-- init examples profile
	A:initExamples()
	-- init LSM
	A:initLSM()
	-- init chat frames
	initChatFrames()
	-- init scrolling text frame
	A:updateScrolling()
	-- init options
	A:initSpellOptions()
	-- init LibClassicDuration
	A:initLCD()
	-- init LibDataBroker aka minimap icon
	A:initLDB()
	-- register for events
	A.toggleAddon()
	-- for reloadui
	A:hideAllGUIs()
	-- init LibClassicCasterino (AlertMe version)
	A:initLCC()
	-- Debug
	debug()
end

function A:parseCombatLog(eventName)
	local arg = { CombatLogGetCurrentEventInfo() }
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
	if not A.Events[ti.event] then return end
	-- spell cast success sometimes has no destination data - take source data then
	if ti.event == "SPELL_CAST_SUCCESS" and ti.dstGUID == "" then
		ti.dstGUID, ti.dstName, ti.dstFlags = ti.srcGUID, ti.srcName, ti.srcFlags
	elseif ti.event == "SPELL_INTERRUPT" then
		ti.lockout = A.lockouts[ti.spellName] or ""
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
	A:processTriggerInfo(ti, eventInfo)
end

function A:processTriggerInfo(ti, eventInfo)
	if eventInfo.short == "removed" then
		-- remove gui elements if needed
		hideGUI(ti, eventInfo)
		return
	elseif eventInfo.short == "success" then
		-- if spell cast success fake an applay event
		A:fakeEvent(ti, eventInfo)
	end
	-- do some checks
	local check, alerts = A:doChecks(ti, eventInfo)
	if not check then return end
	-- auras need a special treatment
	if eventInfo.short == "gain" then
		local name, _, _, _, duration, _, _, _, _, _, remaining = A:getUnitAura(ti, eventInfo)
		if name and ((duration - remaining <= 2) or duration == 0) then	-- aura has a duration or was recently applied
			-- rermaining nil?
			A:doActions(ti, eventInfo, alerts, false)
		elseif not name then
			if A:checkSnapShot(ti, eventInfo) then -- no direct aura info, check for recent spell cast success events
				A:doActions(ti, eventInfo, alerts, true)
			else
				A:addSnapShot(ti, eventInfo) -- add a snapshot
			end
		end
	else -- success, interrupt, dispel
		A:doActions(ti, eventInfo, alerts, false)
	end
end

function A:doActions(ti, eventInfo, alerts, ...)
	if eventInfo.actions then
		for _, action in pairs(eventInfo.actions) do
			A[action](A, ti, alerts, eventInfo, ...)
		end
	end
end

--**********************************************************************************************************************************
--Checks
function A:doChecks(ti, eventInfo)
	-- local function to get all the valid alerts for that event
	local function getAlerts(ti, eventInfo)
		local alerts, spellOptions =  {}
		if A.spellOptions[ti.relSpellName] and A.spellOptions[ti.relSpellName][eventInfo.short] then
			spellOptions = A.spellOptions[ti.relSpellName][eventInfo.short]
		end
		-- various checks
		if eventInfo.spellSelection == false then -- spell selection disabled for this event (interrupt for example), return all alerts from this event
			for uid, tbl in pairs(A.alertOptions[eventInfo.short]) do
				tinsert(alerts, tbl)
			end
		elseif spellOptions then -- check for spell in alerts, check spell/event combo
			for uid, tbl in pairs(spellOptions) do
				tinsert(alerts, tbl.options)
			end
		end
		-- return table with alerts or false
		if type(alerts) == "table" and #alerts > 0 then
			return alerts
		else
			return false
		end
	end

	local alerts, _alerts, errors
	-- check for relevant alerts for spell/event
	alerts = getAlerts(ti, eventInfo)
	if not alerts then return false end
	-- check units
	_alerts, errors = A:checkUnits(ti, eventInfo, alerts)
	if not _alerts then
		return false --dprint(3, "unit check failed", ti.relSpellName, unpack(errors))
	else
		return true, _alerts
	end
end

function A:checkUnits(ti, eventInfo, alerts)
	-- if no unit selection for this event return
	if eventInfo.unitSelection == false then return alerts end
	-- set some local variables
	local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
	-- create return table
	local _alerts , errors = {}, {}
	-- loop over the option groups
	for _, alert in pairs(alerts) do
		-- variable to hold the check result for this og
		local checkFailed = false
		-- do the relevant checks (src, dst)
		for _, pre in pairs (eventInfo.units) do
			-- set local variables
			local name, GUID, flags = ti[pre.."Name"], ti[pre.."GUID"], ti[pre.."Flags"]
			local units, exclude = alert[pre.."Units"], alert[pre.."Exclude"]
			local playerControlled = (bitband(flags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)
			local isFriendly = (bitband(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0)
			local isHostile = (bitband(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0)
			local isPlayer = (GUID == playerGUID)
			local isTarget = (GUID == targetGUID)
			-- write some useful info into ti for later use
			ti[pre.."IsTarget"], ti[pre.."IsPlayer"], ti[pre.."IsFriendly"], ti[pre.."IsHostile"] = isTarget, isPlayer, isFriendly, isHostile
			local targetName = UnitName("target")
			if targetName then ti.targetName = getShortName(targetName) end
			local mouseoverName = UnitName("mouseover")
			if mouseoverName then ti.mouseoverName = getShortName(mouseoverName) end
			-- player controlled check
			if not playerControlled and units ~= 6 then
				tinsert(errors, pre..", ".."unit not player controlled")
				checkFailed = true
				break
			end
			-- exclude check -- 1 = none, 2 = myself, 3 = target
			if (exclude == 3 and isTarget) or (exclude == 2 and isPlayer) then
				tinsert(errors, pre..", ".."exclude check failed")
				checkFailed = true
				break
			end
			-- do other checks
			if units == 4 then -- target check
				if not isTarget then
					tinsert(errors, pre..", ".."target check failed")
					checkFailed = true
					break
				end
			elseif units == 5 then  -- player check
				if not isPlayer then
					tinsert(errors, pre..", ".."player check failed")
					checkFailed = true
					break
				end
			elseif units == 2 then -- friendly player check
				if not isFriendly then
					tinsert(errors, pre..", ".."friendly player check failed")
					checkFailed = true
					break
				end
			elseif units == 3 then -- hostile player check
				if not isHostile then
					tinsert(errors, pre..", ".."hostile player check failed")
					checkFailed = true
					break
				end
			end
		end
		if checkFailed ~= true then
			tinsert(_alerts, alert)
		end
	end
	-- return
	if type(_alerts) == "table" and #_alerts > 0 then
		return _alerts, errors
	else
		return false, errors
	end
end

--**********************************************************************************************************************************
-- actions
local function createMessage(ti, eventInfo, alert, colored, showIcon)
	local prefix, postfix = P.messages.prefix, P.messages.postfix
	-- check possible replacements for being nil
	local srcName = (ti.srcName) and getShortName(ti.srcName) or ""
	local dstName = (ti.dstName) and getShortName(ti.dstName) or ""
	local spellName = (ti.spellName) and ti.spellName or ""
	local extraSpellName = (ti.extraSpellName) and ti.extraSpellName or ""
	local extraSchool = (ti.extraSchool) and GetSchoolString(ti.extraSchool) or ""
	local lockout = (ti.lockout) and ti.lockout or ""
	local targetName = (ti.targetName) and ti.targetName or ""
	local mouseoverName = (ti.mouseoverName) and ti.mouseoverName or ""
	local icon
	-- get message from options
	if type(eventInfo) ~= "table" then
		dprint(1, "no eventInfo!", ti, eventInfo, alert, colored, showIcon)
		vdt.data(ti,"ti")
		vdt.data(eventInfo,"eventInfo")
		vdt.data(alert,"alert")
	end
	local msg = P.messages[eventInfo.short]
	-- override?
	if alert.msgOverride and alert.msgOverride ~= "" then
		msg = alert.msgOverride
	end
	-- replace
	msg = gsub(msg, "%%dstName", dstName)
	msg = gsub(msg, "%%srcName", srcName)
	msg = gsub(msg, "%%spellName", spellName)
	msg = gsub(msg, "%%extraSpellName", extraSpellName)
	msg = gsub(msg, "%%extraSchool", extraSchool)
	msg = gsub(msg, "%%lockout", lockout)
	msg = gsub(msg, "%%targetName", targetName)
	msg = gsub(msg, "%%mouseoverName", mouseoverName)
	-- get reaction color
	local color = A:getReactionColor(ti)
	-- return
	if not colored then
		return prefix..msg..postfix
	elseif colored and not showIcon then
		return WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
	elseif colored and showIcon then
		-- get icon
		if A.spellOptions[ti.relSpellName] then
			icon = A.spellOptions[ti.relSpellName].icon
		else
			local spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
			_, _, icon = GetSpellInfo(spellId)
		end
		if icon then
			local iconSize = P.scrolling.fontSize-2.5
			local iconText = " |T"..icon..":"..iconSize..":"..iconSize..":0:0|t "
			return WrapTextInColorCode(prefix, color)..iconText..msg..iconText..WrapTextInColorCode(postfix, color)
		else
			return WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
		end
	end
end

local function getChannel()
	if GetNumGroupMembers() > 5 then
		if inInstance then
			return "INSTANCE_CHAT"
		else
			return "RAID"
		end
	elseif GetNumGroupMembers() > 0 then
		return "Party"
	end
end

function A:chatAnnounce(ti, alerts, eventInfo)
	-- get possible channels
	local inInstance, instanceType = IsInInstance()
	local channel = getChannel()
	-- create queue for messages
	local msgQueue = {}
	-- loop through option groups
	for _, alert in pairs(alerts) do
		local msg = createMessage(ti, eventInfo, alert, false, false)
		local msgSystem = createMessage(ti, eventInfo, alert, true, false)
		local msgScrolling = (P.scrolling.showIcon) and createMessage(ti, eventInfo, alert, true, true) or  msgSystem -- show spell icon in scrolling text frame?
		-- bg/raid/party
		if alert.chatChannels == 2 and channel and P.messages.chatEnabled then
			if msgQueue[channel] == nil then msgQueue[channel] = {} end
			msgQueue[channel][msg] = msg
		end
		-- party
		if alert.chatChannels == 3 and inInstance and P.messages.chatEnabled then
			if msgQueue["PARTY"] == nil then msgQueue["PARTY"] = {} end
			msgQueue["PARTY"][msg] = msg
		end
		-- say
		if alert.chatChannels == 4 and inInstance and P.messages.chatEnabled then
			if msgQueue["SAY"] == nil then msgQueue["SAY"] = {} end
			msgQueue["SAY"][msg] = msg
		end
		-- addon messages
		if (alert.addonMessages == 1 or (alert.addonMessages == 3 and not inInstance and alert.chatChannels ~= 1)) and P.messages.enabled then
			if msgQueue["SYSTEM"] == nil then msgQueue["SYSTEM"] = {} end
			msgQueue["SYSTEM"][msg] = msgSystem
		end
		-- whisper destination unit
		if eventInfo.dstWhisper == true and ti.dstIsFriendly and not ti.dstIsPlayer then
			if (alert.dstWhisper == 2 and ti.srcIsPlayer) or alert.dstWhisper == 3 then
				if P.messages.chatEnabled then
					if msgQueue["WHISPER"] == nil then msgQueue["WHISPER"] = {} end
					msgQueue["WHISPER"][msg] = msg
				end
			end
		end
		-- scrolling messages
		if alert.scrollingText and P.scrolling.enabled then
			if not msgQueue["SCROLLING"] then msgQueue["SCROLLING"] = {} end
			msgQueue["SCROLLING"][msg] = msgScrolling
		end
	end
	-- loop through message queue and send messages
	for chan, messages in pairs(msgQueue) do
		for _, msg in pairs(messages) do
			if chan == "SYSTEM" then
				addonMessage(msg)
			elseif chan == "WHISPER" then
				SendChatMessage(msg, chan, nil, ti.dstName)
			elseif chan == "SCROLLING" then
				A:postInScrolling(msg, ti.icon)
			else
				SendChatMessage(msg, chan, nil, nil) 		-- say/raid/party/bg
			end
		end
	end
end

function A:playSound(ti, alerts, eventInfo)
	local soundQueue = {}
	local delay = 1.3
	-- play the sound queue
	local function playQueue(queue, oldplaying, oldhandle)
		-- stop old sound if its still plying
		if oldplaying and oldhandle then
			StopSound(oldhandle)
		end
		-- loop & iterate
		for sound, _ in pairs(queue) do
			local isPlaying, handle = PlaySoundFile(A.sounds[sound])
			queue[sound] = nil
			if next(queue) then
				C_Timer.After(delay, function() playQueue(queue, isPlaying, handle) end)
			else
				break
			end
		end
	end
	-- loop alerts
	for _, alert in pairs(alerts) do
		--{[1] = "No sound alerts", , [3] = "Play individual sound alerts per spell"
		if alert.soundSelection == 1 then 						-- [1] = "No sound alerts"
			break
		elseif alert.soundSelection == 2 then					-- [2] = "Play one sound alert for all spells"
			sound = alert.soundFile
		elseif alert.soundSelection == 3 then					-- [3] = "Play individual sound alerts per spell"
			sound = alert.spellNames[ti.spellName].soundFile
		end
		-- add to soundqueue
		if not sound or sound == "None" or sound == "" then
			break
		else
			soundQueue[sound] = true
		end
	end
	playQueue(soundQueue)
end

--**********************************************************************************************************************************
--Inits
--**********************************************************************************************************************************
function A.initSpellOptions()
	A.alertOptions = {}
	A.spellOptions = {}
	-- loop through events/alerts
	for event, alert in pairs(P.alerts) do
		A.alertOptions[event] = {}
		-- alert details
		for uid, alertDetails in pairs(alert.alertDetails) do
			-- check if alert is active and not default value
			if alertDetails.active == true and alertDetails.created == true then
				A.alertOptions[event][uid] = alertDetails
				-- spells
				for spellName, spellDetails in pairs(alertDetails.spellNames) do
					if not A.spellOptions[spellName] then A.spellOptions[spellName] = {icon = spellDetails.icon} end
					if not A.spellOptions[spellName][event] then A.spellOptions[spellName][event] = {} end
					if not A.spellOptions[spellName][event][uid] then
						A.spellOptions[spellName][event][uid] = {
							uid = uid,
							event = event,
							options = A.alertOptions[event][uid],
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
function A.registerCLEU(event)
	local name, instanceType = GetInstanceInfo()
	-- check against instance type and settings
	if (instanceType == "party" or instanceType == "raid") and P.general.zones.instance then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "parseCombatLog")
	elseif (instanceType == "pvp" or instanceType == "arena") and P.general.zones.bg then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "parseCombatLog")
	elseif instanceType == "none" and P.general.zones.world then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "parseCombatLog")
	else
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:hideAllGUIs()
	end
end

function A.toggleAddon()
	-- (un)register callbacks from casterino
	A:initLCC()
	-- (un)register events
	if P.general.enabled == true then
		A:RegisterEvent("PLAYER_ENTERING_WORLD", A.registerCLEU)
		A.registerCLEU("Toggle")
	else
		A:UnregisterEvent("PLAYER_ENTERING_WORLD")
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:hideAllGUIs()
	end
	A.AlertMeBroker.iconR = (P.general.enabled) and 1 or 0.5
end

--**********************************************************************************************************************************
-- Various
--**********************************************************************************************************************************
function A:getReactionColor(ti, rgb)
	local color = "white"
	-- check events
	if ti.event == "SPELL_AURA_APPLIED" or ti.event == "SPELL_AURA_REFRESH" then
		if (ti.dstIsFriendly and ti.auraType == "BUFF") or (ti.dstIsHostile and ti.auraType == "DEBUFF") then
			color = "green"
		else
			color = "red"
		end
	elseif ti.event == "SPELL_DISPEL" then
		if (ti.dstIsFriendly and ti.auraType == "BUFF") or (ti.dstIsHostile and ti.auraType == "DEBUFF") then
			color = "red"
		else
			color = "green"
		end
	elseif ti.event == "SPELL_CAST_START" or ti.event == "SPELL_CAST_SUCCESS" or ti.event == "SPELL_INTERRUPT" then
		if ti.srcIsFriendly then
			color =  "green"
		else
			color = "red"
		end
	end
	-- return RGB or HEX
	if rgb then
		return unpack(A.colors[color]["rgb"])
	else
		return A.colors[color]["hex"]
	end
end

function A:hideAllGUIs()
	A:hideAllBars()
	A:hideAllGlows()
end
