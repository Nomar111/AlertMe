-- upvalues
local _G, CombatLogGetCurrentEventInfo, GetInstanceInfo, gsub = _G, CombatLogGetCurrentEventInfo, GetInstanceInfo, string.gsub
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL
local IsInInstance, GetNumGroupMembers, UnitGUID, UnitName, C_Timer = IsInInstance, GetNumGroupMembers, UnitGUID, UnitName, C_Timer
local PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bitband = PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bit.band

-- set addon environment
setfenv(1, _G.AlertMe)

-- local functions
local function HideGUI(cleu, evi)
	A:HideAuraBars(cleu, evi)
	A:HideGlow(cleu, evi)
end

-- init function
function A:Initialize()
	-- init examples profile
	A:InitExamples()
	-- init LSM
	A:InitLSM()
	-- init chat frames
	InitChatFrames()
	-- init scrolling text frame
	A:UpdateScrolling()
	-- init options
	A:InitSpellOptions()
	-- init LibClassicDuration
	A:InitLCD()
	-- init LibDataBroker aka minimap icon
	A:InitLDB()
	-- register for events
	A.ToggleAddon()
	-- for reloadui
	A:HideAllGUIs()
	-- init LibClassicCasterino (AlertMe version)
	A:InitLCC()
	-- Debug
	debug()
end

function A:COMBAT_LOG_EVENT_UNFILTERED(eventName)
	local arg = { CombatLogGetCurrentEventInfo() }
	-- check if trigger event exists in events table, if not abort
	if not events[arg[2]] then return end
	-- create table with relevant cleu arguments
	local cleu = {
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
	-- spell cast success sometimes has no destination data - take source data then
	if cleu.event == "SPELL_CAST_SUCCESS" and cleu.dstGUID == "" then
		cleu.dstGUID, cleu.dstName, cleu.dstFlags = cleu.srcGUID, cleu.srcName, cleu.srcFlags
	elseif cleu.event == "SPELL_INTERRUPT" then
		cleu.lockout = A.lockouts[cleu.spellName] or ""	-- set lockout timers for interrupts
	end
	-- get relevant event/menu infos and merge them into evi (evi)
	local evi = events[cleu.event]
	-- get optional arguments if there are any
	if evi.extraArgs then
		for i, extra in pairs(evi.extraArgs) do
			cleu[extra] = arg[i+14]
		end
	end
	-- set relevant spell name
	cleu.checkedSpell = cleu[evi.checkedSpell]
	-- call ProcessCLEU
	A:ProcessCLEU(cleu, evi)
end

function A:ProcessCLEU(cleu, evi)
	if evi.handle == "removed" then
		-- remove gui elements if needed
		HideGUI(cleu, evi)
		return
	elseif evi.handle == "success" then
		-- if spell cast success fake an applay event
		A:FakeEvent(cleu, evi)
	end
	-- do some checks
	local check, alerts = A:DoChecks(cleu, evi)
	if not check then return end
	-- auras need a special treatment
	if evi.handle == "gain" then
		local name, _, _, _, duration, _, _, _, _, _, remaining = A:GetUnitAura(cleu, evi)
		if name and ((duration - remaining <= 2) or duration == 0) then	-- aura has a duration or was recently applied
			-- rermaining nil?
			A:DoActions(cleu, evi, alerts, false)
		elseif not name then
			if A:CheckSnapshot(cleu, evi) then -- no direct aura info, check for recent spell cast success events
				A:DoActions(cleu, evi, alerts, true)
			else
				A:AddSnapshot(cleu, evi) -- add a snapshot
			end
		end
	else -- success, interrupt, dispel
		A:DoActions(cleu, evi, alerts, false)
	end
end

function A:DoActions(cleu, evi, alerts, ...)
	if evi.actions then
		for _, action in pairs(evi.actions) do
			A[action](A, cleu, evi, alerts, ...)
		end
	end
end

--**********************************************************************************************************************************
--Checks
local function getAlerts(cleu, evi)
	local alerts, spellOptions =  {}
	if A.spellOptions[cleu.checkedSpell] and A.spellOptions[cleu.checkedSpell][evi.handle] then
		spellOptions = A.spellOptions[cleu.checkedSpell][evi.handle]
	end
	-- various checks
	if not evi.spellSelection then -- spell selection disabled for this event (interrupt for example), return all alerts from this event
		for uid, tbl in pairs(A.alertOptions[evi.handle]) do
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

function A:DoChecks(cleu, evi)
	local alerts, _alerts, errors
	-- check for relevant alerts for spell/event
	alerts = getAlerts(cleu, evi)
	if not alerts then return false end
	-- check units
	_alerts, errors = A:CheckUnits(cleu, evi, alerts)
	if not _alerts then
		return false --dprint(3, "unit check failed", cleu.checkedSpell, unpack(errors))
	else
		return true, _alerts
	end
end

function A:CheckUnits(cleu, evi, alerts)
	-- if no unit selection for this event return
	if not evi.unitSelection then return alerts end
	-- set some local variables
	local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
	-- create return table
	local _alerts , errors = {}, {}
	-- loop over the option groups
	for _, alert in pairs(alerts) do
		-- variable to hold the check result for this og
		local checkFailed = false
		-- do the relevant checks (src, dst)
		for _, pre in pairs (evi.unitSelection) do
			--vdt:data(cleu, "cleu")
			-- set local variables
			local name, GUID, flags = cleu[pre.."Name"], cleu[pre.."GUID"], cleu[pre.."Flags"]
			local units, exclude = alert[pre.."Units"], alert[pre.."Exclude"]
			local playerControlled = (bitband(flags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)
			local isFriendly = (bitband(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0)
			local isHostile = (bitband(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0)
			local isPlayer = (GUID == playerGUID)
			local isTarget = (GUID == targetGUID)
			-- write some useful info into ti for later use
			cleu[pre.."IsTarget"], cleu[pre.."IsPlayer"], cleu[pre.."IsFriendly"], cleu[pre.."IsHostile"] = isTarget, isPlayer, isFriendly, isHostile
			local targetName = UnitName("target")
			if targetName then cleu.targetName = GetShortName(targetName) end
			local mouseoverName = UnitName("mouseover")
			if mouseoverName then cleu.mouseoverName = GetShortName(mouseoverName) end
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
local function createMessage(cleu, evi, alert, colored, showIcon)
	local prefix, postfix = P.messages.prefix, P.messages.postfix
	-- check possible replacements for being nil
	local srcName = (cleu.srcName) and GetShortName(cleu.srcName) or ""
	local dstName = (cleu.dstName) and GetShortName(cleu.dstName) or ""
	local spellName = (cleu.spellName) and cleu.spellName or ""
	local extraSpellName = (cleu.extraSpellName) and cleu.extraSpellName or ""
	local extraSchool = (cleu.extraSchool) and GetSchoolString(cleu.extraSchool) or ""
	local lockout = (cleu.lockout) and cleu.lockout or ""
	local targetName = (cleu.targetName) and cleu.targetName or ""
	local mouseoverName = (cleu.mouseoverName) and cleu.mouseoverName or ""
	local icon
	local msg = P.messages[evi.handle]
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
	local color = A:GetReactionColor(cleu)
	-- return
	if not colored then
		return prefix..msg..postfix
	elseif colored and not showIcon then
		return WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
	elseif colored and showIcon then
		-- get icon
		if A.spellOptions[cleu.checkedSpell] then
			icon = A.spellOptions[cleu.checkedSpell].icon
		else
			local spellId = A.Libs.LCD:GetLastRankSpellIDByName(cleu.checkedSpell)
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

function A:ChatAnnounce(cleu, evi, alerts, ...)
	-- get possible channels
	local inInstance, instanceType = IsInInstance()
	local channel = getChannel()
	-- create queue for messages
	local msgQueue = {}
	-- loop through option groups
	for _, alert in pairs(alerts) do
		local msg = createMessage(cleu, evi, alert, false, false)
		local msgSystem = createMessage(cleu, evi, alert, true, false)
		local msgScrolling = (P.scrolling.showIcon) and createMessage(cleu, evi, alert, true, true) or  msgSystem -- show spell icon in scrolling text frame?
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
		if evi.dstWhisper == true and cleu.dstIsFriendly and not cleu.dstIsPlayer then
			if (alert.dstWhisper == 2 and cleu.srcIsPlayer) or alert.dstWhisper == 3 then
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
				AddonMessage(msg)
			elseif chan == "WHISPER" then
				SendChatMessage(msg, chan, nil, cleu.dstName)
			elseif chan == "SCROLLING" then
				A:PostInScrolling(msg, cleu.icon)
			else
				SendChatMessage(msg, chan, nil, nil) 		-- say/raid/party/bg
			end
		end
	end
end

function A:PlaySound(cleu, evi, alerts, ...)
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
			sound = alert.spellNames[cleu.spellName].soundFile
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
function A.InitSpellOptions()
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
function A.RegisterCLEU(event)
	local name, instanceType = GetInstanceInfo()
	-- check against instance type and settings
	if (instanceType == "party" or instanceType == "raid") and P.general.zones.instance then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	elseif (instanceType == "pvp" or instanceType == "arena") and P.general.zones.bg then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	elseif instanceType == "none" and P.general.zones.world then
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllGUIs()
	end
end

function A.ToggleAddon()
	-- (un)register callbacks from casterino
	A:InitLCC()
	-- (un)register events
	if P.general.enabled == true then
		A:RegisterEvent("PLAYER_ENTERING_WORLD", A.RegisterCLEU)
		A.RegisterCLEU("Toggle")
	else
		A:UnregisterEvent("PLAYER_ENTERING_WORLD")
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllGUIs()
	end
	A.AlertMeBroker.iconR = (P.general.enabled) and 1 or 0.5
end

--**********************************************************************************************************************************
-- Various
--**********************************************************************************************************************************
function A:GetReactionColor(cleu, rgb)
	local color = "white"
	-- check events
	if cleu.event == "SPELL_AURA_APPLIED" or cleu.event == "SPELL_AURA_REFRESH" then
		if (cleu.dstIsFriendly and cleu.auraType == "BUFF") or (cleu.dstIsHostile and cleu.auraType == "DEBUFF") then
			color = "green"
		else
			color = "red"
		end
	elseif cleu.event == "SPELL_DISPEL" then
		if (cleu.dstIsFriendly and cleu.auraType == "BUFF") or (cleu.dstIsHostile and cleu.auraType == "DEBUFF") then
			color = "red"
		else
			color = "green"
		end
	elseif cleu.event == "SPELL_CAST_START" or cleu.event == "SPELL_CAST_SUCCESS" or cleu.event == "SPELL_INTERRUPT" then
		if cleu.srcIsFriendly then
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

function A:HideAllGUIs()
	A:HideAllBars()
	A:HideAllGlows()
end
