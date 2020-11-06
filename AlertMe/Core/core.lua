-- upvalues
local _G, CombatLogGetCurrentEventInfo, GetInstanceInfo = _G, CombatLogGetCurrentEventInfo, GetInstanceInfo
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_REACTION_NEUTRAL
local IsInInstance, GetNumGroupMembers, C_Timer = IsInInstance, GetNumGroupMembers, C_Timer
local PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bitband = PlaySoundFile, StopSound, SendChatMessage, GetSchoolString, bit.band

-- set addon environment
setfenv(1, _G.AlertMe)

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
	--
	if P.bars.spells then P.bars.spells = nil end
	if P.bars.barType == "spells" then P.bars.barType = "auras" end
end

function A:COMBAT_LOG_EVENT_UNFILTERED(eventName)
	local arg = { CombatLogGetCurrentEventInfo() }
	-- check if trigger event exists in events table, if not abort
	if not A.events[arg[2]] then return end
	-- create table with relevant cleu arguments
	local cleu = {
		--ts = arg[1],
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
	local evi = A.events[cleu.event]
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
	if evi.handle == "removed" then					-- remove gui elements if needed
		A:HideGUI(cleu, evi)
		return
	elseif evi.handle == "success" then				-- if spell cast success fake an apply event
		A:FakeEvent(cleu, evi)
	end
	-- do some checks
	local check, alerts = A:DoChecks(cleu, evi)
	if not check then return end
	-- aura gains need special treatment
	if evi.handle == "gain" then
		local name, _, _, _, duration, _, _, _, _, _, remaining = A:GetUnitAura(cleu, evi)
		if name and ((duration - remaining <= 2) or duration == 0) then	-- aura has a duration or was recently applied
			A:DoActions(cleu, evi, alerts, false)
		elseif not name then
			if A:CheckSnapshot(cleu, evi) then 		-- no direct aura info, check for recent spell cast success events
				A:DoActions(cleu, evi, alerts, true)
			else
				A:AddSnapshot(cleu, evi) 			-- add a snapshot
			end
		end
	else -- success, interrupt, dispel
		A:DoActions(cleu, evi, alerts, false)
	end
end

--**********************************************************************************************************************************
--Checks
local function getAlerts(cleu, evi)
	local alerts, spellOptions =  {}
	-- get all alert options for this spell/event
	if A.spellOptions[cleu.checkedSpell] and A.spellOptions[cleu.checkedSpell][evi.handle] then
		spellOptions = A.spellOptions[cleu.checkedSpell][evi.handle]
	end
	if not evi.spellSelection then 		-- if spell selection is disabled return all alerts
		for uid, tbl in pairs(A.alertOptions[evi.handle]) do
			tinsert(alerts, tbl)
		end
	elseif spellOptions then 			-- spell/event combo existing: add alerts
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
		--dprint(3, "unit check failed", cleu.checkedSpell, unpack(errors))
		return false
	else
		return true, _alerts
	end
end

function A:CheckUnits(cleu, evi, alerts)
	-- if that event has no unit selection return alerts
	if not evi.unitSelection then return alerts end
	-- prepare local variables
	local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
	local _alerts , errors = {}, {}
	-- loop over the alerts
	for _, alert in pairs(alerts) do
		-- variable to hold the check result for this alert
		local checkFailed = false
		-- do all unit checks for source/destination units
		for _, pre in pairs (evi.unitSelection) do
			local c = {}
			local name, GUID, flags = cleu[pre.."Name"], cleu[pre.."GUID"], cleu[pre.."Flags"]
			local unit, exclude = alert[pre.."Units"], alert[pre.."Exclude"]
			c.playerControlled = (bitband(flags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)
			c.isFriendly = (bitband(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0)
			c.isHostile = (bitband(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0)
			c.isTarget, c.isPlayer = (GUID == targetGUID), (GUID == playerGUID)
			-- write some useful info into ti for later use
			cleu[pre.."IsTarget"], cleu[pre.."IsPlayer"] = c.isTarget, c.isPlayer
			cleu[pre.."IsFriendly"], cleu[pre.."IsHostile"] = c.isFriendly, c.isHostile
			-- loop over required checks as defined in A.lists.units
			if A.lists.units[unit].checks then
				for condition, ref in pairs(A.lists.units[unit].checks) do
					if c[condition] ~= ref then
						tinsert(errors, pre..", "..condition.." failed")
						checkFailed = true
						break
					end
				end
			end
			-- loop over checks as defined in A.lists.excludes
			if A.lists.excludes[exclude].checks then
				for condition, ref in pairs(A.lists.excludes[exclude].checks) do
					if c[condition] == ref then	-- since it's exclude we check for equal
						tinsert(errors, pre..", exclude, "..condition.." failed")
						checkFailed = true
						break
					end
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
function A:DoActions(cleu, evi, alerts, ...)
	if evi.actions then
		for _, action in pairs(evi.actions) do
			A[action](A, cleu, evi, alerts, ...)
		end
	end
end

local function getIcon(spellName)
	local icon
	if A.spellOptions[spellName] then
		icon = A.spellOptions[spellName].icon
	else
		local spellId = A.Libs.LCD:GetLastRankSpellIDByName(spellName)
		_, _, icon = GetSpellInfo(spellId)
	end
	return icon
end

local function createMessage(cleu, evi, alert, plain, msgType)
	local prefix, postfix = P.messages.prefix, P.messages.postfix
	local r, icon, msg = {}
	-- get current target and mouseover unit names
	r.targetName = GetShortName(UnitName("target")) or nil
	r.mouseoverName = GetShortName(UnitName("mouseover")) or nil
	-- check possible replacements for being nil
	r.srcName = (cleu.srcName) and GetShortName(cleu.srcName) or nil
	r.dstName = (cleu.dstName) and GetShortName(cleu.dstName) or nil
	r.spellName = (cleu.spellName) and cleu.spellName or nil
	r.extraSpellName = (cleu.extraSpellName) and cleu.extraSpellName or nil
	r.extraSchool = (cleu.extraSchool) and GetSchoolString(cleu.extraSchool) or nil
	r.lockout = (cleu.lockout) and cleu.lockout or nil
	r.missType = (cleu.missType) and A.missTypes[cleu.missType] or nil
	-- get standard event message or message override from alert
	if alert.msgOverride and alert.msgOverride ~= "" then
		msg = alert.msgOverride
	else
		msg = P.messages[evi.handle]
	end
	-- check if whisper message
	if msgType == "w" and alert.msgWhisper and alert.msgWhisper ~= "" then
			msg = alert.msgWhisper
	end
	-- replace patterns
	for _, pattern in pairs(A.patterns) do
		local replacement = r[string.sub(pattern, 3)]
		if replacement then
			msg = string.gsub(msg, pattern, replacement)
		end
	end
	-- get reaction color
	local color = A:GetReactionColor(cleu, evi)
	-- return
	if plain then
		return prefix..msg..postfix
	else -- not plain = colored/icon
		icon = getIcon(cleu.checkedSpell)
		if P.scrolling.showIcon and icon then
			local size = P.scrolling.fontSize - 2.5
			local iconText = " |T"..icon..":"..size..":"..size..":0:0|t "
			return WrapTextInColorCode(prefix, color)..iconText..msg..iconText..WrapTextInColorCode(postfix, color)
		end
		return WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
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
		return "PARTY"
	end
end

function A:ChatAnnounce(cleu, evi, alerts, ...)
	-- get possible channels
	local inInstance, instanceType = IsInInstance()
	local isGrouped = (GetNumGroupMembers() > 0)
	local channel = getChannel()
	-- create queue for messages
	local msgQueue = { INSTANCE_CHAT = {}, RAID = {}, PARTY = {}, SAY = {}, SYSTEM = {}, WHISPER = {}, SCROLLING = {} }
	-- loop through alerts and prepare message queue
	for _, alert in pairs(alerts) do
		local msg = createMessage(cleu, evi, alert, true)
		local colmsg = createMessage(cleu, evi, alert)
		local whispmsg = createMessage(cleu, evi, alert, true, "w")
		-- chat messages to other people (only possible in instances)
		if P.messages.chatEnabled and inInstance then				-- options setting
			if alert.chatChannels == 2 and channel then				-- bg/raid/party
				msgQueue[channel][msg] = msg
			elseif alert.chatChannels == 3 and isGrouped then		-- party
				msgQueue["PARTY"][msg] = msg
			elseif alert.chatChannels == 4 then						-- say
				msgQueue["SAY"][msg] = msg
			end
		end
		-- whisper destination unit
		if P.messages.chatEnabled and cleu.dstIsFriendly and (not cleu.dstIsPlayer or P.general.debugLevel > 1) then		-- and not cleu.dstIsPlayer
			if (alert.dstWhisper == 2 and cleu.srcIsPlayer) 		-- whisper if cast by me
			or alert.dstWhisper == 3 then							-- whisper
				msgQueue["WHISPER"][whispmsg] = whispmsg
			end
		end
		-- addon/system messages
		if P.messages.enabled then 									-- options setting
			if alert.addonMessages == 1 							-- always display system messages
			or (alert.addonMessages == 3 and not channel and alert.chatChannels ~= 1) then	-- if channel not available
				msgQueue["SYSTEM"][msg] = colmsg
			end
		end
		-- scrolling text
		if P.scrolling.enabled and alert.scrollingText then
			msgQueue["SCROLLING"][msg] = colmsg
		end
	end

	-- loop through message queue and send messages
	for _channel, messages in pairs(msgQueue) do
		for _, message in pairs(messages) do
			if _channel == "SYSTEM" then
				AddonMessage(message)
			elseif _channel == "WHISPER" then
				SendChatMessage(message, _channel, nil, cleu.dstName)
			elseif _channel == "SCROLLING" then
				A:PostInScrolling(message)
			else -- say/raid/party/bg
				SendChatMessage(message, _channel, nil, nil)
			end
		end
	end
end

local function playSoundQueue(queue, oldplaying, oldhandle)
	local delay = 1.3
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

function A:PlaySound(cleu, evi, alerts, ...)
	local soundQueue = {}
	-- loop alerts
	for _, alert in pairs(alerts) do
		if alert.soundSelection == 2 then					-- [2] = "Play one sound alert for all spells"
			sound = alert.soundFile
		elseif alert.soundSelection == 3 then				-- [3] = "Play individual sound alerts per spell"
			sound = alert.spellNames[cleu.spellName].soundFile
		end
		-- add to soundqueue
		if sound and sound ~= "None" and sound ~= "" then
			soundQueue[sound] = true
		end
	end
	playSoundQueue(soundQueue)
end

--**********************************************************************************************************************************
--Build tables with alert/spell data
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
function A:GetReactionColor(cleu, evi, option)
	local color = "white"
	-- check events
	if evi.handle == "gain" then
		if (cleu.dstIsFriendly and cleu.auraType == "BUFF") or (cleu.dstIsHostile and cleu.auraType == "DEBUFF") then
			color = "green"
		else
			color = "red"
		end
	elseif evi.handle == "dispel" then
		if (cleu.dstIsFriendly and cleu.auraType == "BUFF") or (cleu.dstIsHostile and cleu.auraType == "DEBUFF") then
			color = "red"
		else
			color = "green"
		end
	elseif evi.handle == "start" or evi.handle == "success" or evi.handle == "interrupt" then
		if cleu.srcIsFriendly then
			color =  "green"
		else
			color = "red"
		end
	elseif evi.handle == "missed" then
		if cleu.srcIsFriendly then
			color =  "red"
		else
			color = "green"
		end
	end
	-- return RGB or HEX
	if option == "rgb" then
		return unpack(A.colors[color]["rgb"])
	elseif option == "reaction" then
		return (color == "green") and true or false
	else
		return A.colors[color]["hex"]
	end
end

function A:HideGUI(cleu, evi)
	A:HideAuraBars(cleu, evi)
	A:HideGlow(cleu, evi)
end

function A:HideAllGUIs()
	A:HideAllBars()
	A:HideAllGlows()
end
