dprint(3,"core.lua")
-- upvalues
local _G, CombatLogGetCurrentEventInfo, UnitGUID, bit, UnitAura = _G, CombatLogGetCurrentEventInfo, UnitGUID, bit, UnitAura
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER
local IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames = IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames
local GetTime, GetSpellInfo, C_Timer, GetInstanceInfo, PlaySoundFile, StopSound, CreateFrame, UIParent, IsShiftKeyDown = GetTime, GetSpellInfo, C_Timer, GetInstanceInfo, PlaySoundFile, StopSound, CreateFrame, UIParent, IsShiftKeyDown
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
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
	-- for reloadui
	A:HideAllBars()
	-- register for events
	A.ToggleAddon()
end

function A.ToggleAddon()
	dprint(2, "A.ToggleAddon", P.general.enabled)
	if P.general.enabled == true then
		A:RegisterEvent("PLAYER_ENTERING_WORLD", A.RegisterCLEU)
		A:RegisterEvent("ZONE_CHANGED", A.RegisterCLEU)
		A:RegisterEvent("ZONE_CHANGED_INDOORS", A.RegisterCLEU)
		A.RegisterCLEU("Toggle")
	else
		A:UnregisterEvent("PLAYER_ENTERING_WORLD")
		A:UnregisterEvent("ZONE_CHANGED")
		A:UnregisterEvent("ZONE_CHANGED_INDOORS")
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllBars()
	end
end

function A.RegisterCLEU(event)
	dprint(2, "A.RegisterCLEU", event)
	local name, instanceType = GetInstanceInfo()

	if instanceType ~= "pvp" and P.general.zones.world then
		dprint(3, "register", instanceType, P.general.zones.world)
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.ParseCombatLog)
	elseif instanceType == "pvp" and  P.general.zones.bg then
		dprint(3, "register", instanceType, P.general.zones.bg)
		A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", A.ParseCombatLog)
	else
		A:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		A:HideAllBars()
	end
end

function A:ParseCombatLog(eventName)
	local arg = {}
	arg = {CombatLogGetCurrentEventInfo()}
	--VDT_AddData(arg,"arg")
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

	dprint(2, ti.event, ti.spellName, ti.srcName, ti.dstName)

	-- spell cast success sometimes has no destination data - take source data then
	if ti.event == "SPELL_CAST_SUCCESS" and ti.dstGUID == "" then
		ti.dstGUID, ti.dstName, ti.dstFlags = ti.srcGUID, ti.srcName, ti.srcFlags
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
	ti.delayed = false
	-- set relevant spell name
	ti.relSpellName = ti[eventInfo.relSpellName]
	-- call processTriggerInfo
	A:ProcessTriggerInfo(ti, eventInfo)
end

function A:ProcessTriggerInfo(ti, eventInfo)
	dprint(2, "A:ProcessTriggerInfo", ti.event, ti.spellName)

	-- check for relevant alerts for spell/event
	local alerts = A:GetAlerts(ti, eventInfo)
	if alerts == false or alerts == nil then
		dprint(2, "no alert", ti.spellName, ti.event)
		return
	end
	-- check units
	local alerts, errorMessages = A:CheckUnits(ti, alerts, eventInfo)
	if alerts == false or alerts == nil then
		--dprint(1, "unit check failed", ti.alertname, ti.relSpellName)
		if errorMessages then
			for i, errorMessage in pairs(errorMessages) do
				dprint(1, errorMessage, ti.relSpellName, "srcFriendly", ti.srcIsFriendly, "dstFriendly", ti.dstIsFriendly)
			end
		end
		return
	end

	-- check aura applied for friendly
	if eventInfo.short == "gain" and ti.dstIsFriendly then
		local name, _, duration, remaining = A:GetAuraInfo(ti)
		if not name  or (duration and remaining - duration >= 3 or remaining <= 2) then
			dprint(1, "aura info missing", ti.spellName, "friend", ti.dstIsFriendly, "dur", duration, "rem", remaining)
			return
		end
	end

	--VDT_AddData(ti,"ti")
	-- do whatever is defined in actions
	if eventInfo.actions ~= nil then
		for _, action in pairs(eventInfo.actions) do
			if action == "chatAnnounce" and type(alerts) == "table" then A:ChatAnnounce(ti, alerts, eventInfo) end
			if action == "playSound" and type(alerts) == "table" then A:PlaySound(ti, alerts, eventInfo) end
			if action == "displayBars" and type(alerts) == "table" then A:DisplayBars(ti, alerts, eventInfo) end
			if action == "hideBars" then A:HideBars(ti, eventInfo) end
		end
	end
end

function A:GetAlerts(ti, eventInfo)
	dprint(2, "A:GetAlerts", ti, eventInfo)
	-- if no spells are checked for this event return true
	if eventInfo.spellSelection == false then
		dprint(3, "ti.event.spellSelection", eventInfo.spellSelection)
		return true
	end
	-- search for spell
	if A.SpellOptions[ti.relSpellName] == nil then
		dprint(3, "spell not found in options", ti.relSpellName)
		return false
	end
	-- search for spell/event combination
	if A.SpellOptions[ti.relSpellName][eventInfo.short] == nil then
		dprint(3, "spell/event combination not found in options", ti.relSpellName, eventInfo.short)
		return false
	end
	local spellOptions = A.SpellOptions[ti.relSpellName][eventInfo.short]
	-- create table of relevant alert settings
	local alerts = {}
	for uid, tbl in pairs(spellOptions) do
		tinsert(alerts, tbl.options)
	end
	return alerts
end

function A:DisplayBars(ti, alerts, eventInfo)
	dprint(2, "A:DisplayBars", ti, alerts, eventInfo)
	for _, alert in pairs(alerts) do
		if alert.showBar == true and eventInfo.displaySettings == true then
			local spellId, icon, duration, remaining = A:GetAuraInfo(ti, eventinfo)
			if duration ~= nil then
				local id = ti.dstGUID..ti.spellName
				A:ShowBar("auras", id, A:GetUnitName(ti.dstName), icon, remaining, true)
			else
				dprint(1, "no spell duration available, abort bar display")
			end
		end
	end
end

function A:HideBars(ti, eventInfo)
	dprint(2, "A:HideBars", ti, eventInfo)
	local id = ti.dstGUID..ti.spellName
	A:HideBar("auras", id)
end

-- getAuraInfo: try to get correct spellId and duration or guess
function A:GetAuraInfo(ti, eventinfo)
	dprint(2, "A:GetAuraInfo")
	local unit = (ti.dstIsTarget == true) and "target" or ti.dstName

	--dprint(1, "unit", unit)
	local name, icon, _, debuffType, duration, expirationTime, source, _, _, spellId = A:GetUnitAura(unit, ti.relSpellName)
	if not name and ti.delayed == false then
		ti.delayed = true
		dprint(1, "repeat", unit, ti.relSpellName, name, duration)
			C_Timer.After(1, function()
				A:ProcessTriggerInfo(ti, eventInfo)
			end)
	end
		--return
	if name then
		local remaining = expirationTime - GetTime()
		return spellId, icon, duration, remaining
	end
end


function A:GetUnitAura(unit, spell)
	dprint(2, "A:GetUnitAura", unit, spell)
	for i = 1, 255 do
		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = A.Libs.LCD.UnitAuraDirect(unit, i, "HELPFUL")
		if not name then
			name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = A.Libs.LCD.UnitAuraDirect(unit, i, "HARMFUL")
		end
		if not name then return end
		if spell == spellId or spell == name then
			return name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId
		end
	end
end

-- checkUnits: check source, destination units of trigger event vs. relevant options
function A:CheckUnits(ti, alerts_in, eventInfo)
	dprint(2, "A:CheckUnits",ti , alerts_in, eventInfo)
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
			--local isOutsider = (bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0)
			local isPlayer = (GUID == playerGUID)
			local isTarget = (GUID == targetGUID)

			-- write some useful info into ti for later use
			ti[pre.."IsTarget"], ti[pre.."IsPlayer"], ti[pre.."IsFriendly"], ti[pre.."IsHostile"] = isTarget, isPlayer, isFriendly, isHostile
			-- player controlled check
			if not playerControlled then
				--dprint(2, pre, "unit not player controlled")
				tinsert(errorMessages, pre..", ".."unit not player controlled")
				checkFailed = true
				break
			end
			-- exclude check -- 1 = none, 2 = myself, 3 = target
			if (exclude == 3 and isTarget) or (exclude == 2 and isPlayer) then
				--dprint(1, pre, "exclude check failed for", alert.name)
				tinsert(errorMessages, pre..", ".."exclude check failed")
				checkFailed = true
				break
			end
			-- do other checks
			if units == 4 then -- target check
				if not isTarget then
					--dprint(1, pre, "target check failed for", ti.spellName, pre, "hostile", isHostile, name)
					tinsert(errorMessages, pre..", ".."target check failed")
					checkFailed = true
					break
				end
			elseif units == 5 then  -- player check
				if not isPlayer then
					--dprint(1, pre, "player check failed for", ti.spellName, "hostile", isHostile, name)
					tinsert(errorMessages, pre..", ".."player check failed")
					checkFailed = true
					break
				end
			elseif units == 2 then -- friendly player check
				if not isFriendly then
					--dprint(1, pre, "friendly player check failed for", ti.spellName, pre, "hostile", isHostile, name)
					tinsert(errorMessages, pre..", ".."friendly player check failed")
					checkFailed = true
					break
					-- elseif pre == "dst" and isOutsider and not isTarget and not isPlayer then
					-- 	dprint(2, pre, "friendly player = outsider", alert.name)
					-- 	checkFailed = true
					--     break
				end
			elseif units == 3 then -- hostile player check
				if not isHostile then
					--dprint(1, pre, "hostile player check failed for", ti.spellName, pre, "foe", isHostile, name)
					tinsert(errorMessages, pre..", ".."friendly player check failed")
					checkFailed = true
					break
				end
			end
		end
		if not checkFailed then
			tinsert(alerts_out, alert)
		end
	end
	VDT_AddData(errorMessages, "errorMessages")
	-- return
	if #alerts_out == 0 then
		return false, errorMessages
	else
		return alerts_out, errorMessages
	end
end

-- chatAnnounce
function A:ChatAnnounce(ti, alerts, eventInfo)
	dprint(2, "A:ChatAnnounce", ti, alerts, eventInfo)

	local prefix, postfix = P.messages.prefix, P.messages.postfix
	-- check possible replacements for being nil
	local srcName = (ti.srcName) and A:GetUnitName(ti.srcName) or ""
	local dstName = (ti.dstName) and A:GetUnitName(ti.dstName) or ""
	local spellName = (ti.spellName) and ti.spellName or ""
	local extraSpellName = (ti.extraSpellName) and ti.extraSpellName or ""
	local extraSchool = (ti.extraSchool) and GetSchoolString(ti.extraSchool) or ""
	local lockout = (ti.lockout) and ti.lockout or ""

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
		-- get message from options
		local msg = ""
		if alert.msgOverride ~= nil and alert.msgOverride ~= "" then
			msg = alert.msgOverride
		else
			msg = P.messages[eventInfo.short]
		end
		-- replace
		msg = string.gsub(msg,"%%dstName", dstName)
		msg = string.gsub(msg,"%%srcName", srcName)
		msg = string.gsub(msg, "%%spellName", spellName)
		msg = string.gsub(msg, "%%extraSpellName", extraSpellName)
		msg = string.gsub(msg, "%%extraSchool", extraSchool)
		msg = string.gsub(msg, "%%lockout", lockout)
		-- get reaction color
		local color = A:GetReactionColor(ti)
		local colmsg = WrapTextInColorCode(prefix, color)..msg..WrapTextInColorCode(postfix, color)
		msg = prefix..msg..postfix
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
			msgQueue["SYSTEM"][msg] = colmsg
		end
		-- whisper destination unit
		if eventInfo.dstWhisper == true and alert.dstWhisper ~= 1 and ti.dstIsFriendly and not ti.dstIsPlayer then
			if (alert.dstWhisper == 2 and ti.srcIsPlayer) or alert.dstWhisper == 3 then
				if msgQueue["WHISPER"] == nil then msgQueue["WHISPER"] = {} end
				msgQueue["WHISPER"][msg] = msg
			end
		end
		-- scrolling messages
		if alert.scrollingText == true and P.scrolling.enabled then
			if msgQueue["SCROLLING"] == nil then msgQueue["SCROLLING"] = {} end
			msgQueue["SCROLLING"][msg] = colmsg
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
				A:PostInScrolling(msg)
			else
				SendChatMessage(msg, chan, nil, nil)
			end
		end
	end
end

function A:PlaySound(ti, alerts, eventInfo)
	dprint(2, "A:PlaySound")
	local soundQueue = {}
	local delay = 1.3

	local function TableEmpty(table)
		for i,v in pairs(table) do
			if i then
				return false
			end
		end
		return true
	end

	local function PlaySoundQueue(queue, oldIsIsplaying, oldHandle)
		dprint(2, "PlaySoundQueue", queue, oldIsIsplaying, oldHandle)

		if oldIsIsplaying and oldHandle then
			StopSound(oldHandle)
		end

		for sound, _ in pairs(queue) do
			local isPlaying, handle = PlaySoundFile(A.sounds[sound])
			queue[sound] = nil
			if TableEmpty(queue) == false then
				C_Timer.After(delay, function()
					PlaySoundQueue(queue, isPlaying, handle)
				end)
			end
			break
		end
	end

	for _, alert in pairs(alerts) do
		--{[1] = "No sound alerts", [2] = "Play one sound alert for all spells", [3] = "Play individual sound alerts per spell"
		if alert.soundSelection == 1 then
			break
		elseif alert.soundSelection == 2 then
			sound = alert.soundFile
		elseif alert.soundSelection == 3 then
			sound = alert.spellNames[ti.spellName].soundFile
		end

		if sound == nil or sound == "None" or sound == "" then
			break
		else
			soundQueue[sound] = true
		end
	end
	PlaySoundQueue(soundQueue)
end

function A:GetReactionColor(ti, rgb)
	dprint(2, "A:GetReactionColor")
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
	-- spell cast start / success
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
	else return A.Colors[color]["hex"]
	end
end

-- systemMessage: posts messages in various chat windows
function A:SystemMessage(msg)
	dprint(2, "A:SystemMessage", msg)
	-- loop through chat frames and post messages
	for i, name in pairs(A.ChatFrames) do
		if P.messages.chatFrames[name] == true then
			local f = _G[name]
			f:AddMessage(msg)
		end
	end
end

function A:PostInScrolling(msg)
	dprint(2, "A:PostInScrolling", msg)
	if P.scrolling.enabled == true then
		A:ShowScrolling()
		A.ScrollingText:AddMessage(msg)
	end
end

function A:InitSpellOptions()
	dprint(2, "A:InitSpellOptions")
	A.AlertOptions = {}
	A.SpellOptions = {}
	VDT_AddData(A.AlertOptions, "A.AlertOptions")
	VDT_AddData(A.SpellOptions, "A.SpellOptions")
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
					if A.SpellOptions[spellName] == nil then A.SpellOptions[spellName] = {}	end
					if A.SpellOptions[spellName][event] == nil then A.SpellOptions[spellName][event] = {} end
					if A.SpellOptions[spellName][event][uid] == nil then
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

function A:GetUnitName(name)
	-- getUnitName: Returns Unitname without Realm
	local short = gsub(name, "%-[^|]+", "")
	return short
end

function A:InitLCD()
	dprint(2, "A:InitLCD")
	A.Libs.LCD:Register("AlertMe")
	A.Libs.LCD.enableEnemyBuffTracking = true
	--A.Libs.LCD.RegisterCallback("AlertMe", "UNIT_BUFF", function(event, unit) end) --A:OnUnitBuff(event, unit, "HELPFUL")
end

function A:InitChatFrames()
	dprint(2, "A:InitChatFrames")
	A.ChatFrames = {}
	-- loop through chat frames
	for i = 1, FCF_GetNumActiveChatFrames() do
		-- get name
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			A.ChatFrames[name] = "ChatFrame"..i
		end
	end
end

function A:InitLSM()
	dprint(2, "A:InitLSM")
	A.Sounds = A.Libs.LSM:HashTable("sound")
	A.Statusbars = A.Libs.LSM:HashTable("statusbar")
	A.Backgrounds = A.Libs.LSM:HashTable("background")
	A.Fonts = A.Libs.LSM:HashTable("font")
	A.Borders = {}
end

-- function copied from LibDBIcon-1.0.lua
local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hHalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vHalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vHalf..hHalf, frame, (vHalf == "TOP" and "BOTTOM" or "TOP")..hHalf
end

function A:InitLDB()
	dprint(2, "A:InitLDB")


	local AlertMeBroker
	AlertMeBroker = A.Libs.LDB:NewDataObject("AlertMe", {
		type = "launcher",
		text = "AlertMe",
		icon = A.Backgrounds["AlertMe"],
		tocname = "AlertMe",
		OnClick = function(self, button)
			if button == "LeftButton" then
				if(IsShiftKeyDown()) then
					P.general.enabled = not P.general.enabled
					A.UpdateLDBTooltip()
					A.ToggleAddon()
				else
					O:OpenOptions()
				end
			elseif button == "MiddleButton" then
				A.ToggleMinimap(true)
			end
		end,
		OnEnter = function(self)
			O.ToolTip = O.ToolTip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
			O.ToolTip:SetOwner(self, "ANCHOR_NONE")
			A.UpdateLDBTooltip()
			O.ToolTip:Show()
			O.ToolTip:SetPoint(getAnchors(self))
		end,
		OnLeave = function()
			if O.ToolTip then O.ToolTip:Hide() end
		end,
	})
	A.Libs.LDBI:Register("AlertMe", AlertMeBroker, P.general.minimap);
end

function A.UpdateLDBTooltip()
	local toolTip = {
		header = "AlertMe "..ADDON_VERSION,
		lines = {},
		wrap = false
	}
	toolTip.lines[1] = "Left-Click: Show/Hide options"
	toolTip.lines[2] = "Shift-Left-Click: Enable/Disable addon"
	toolTip.lines[3] = "Middle-Click: Show/Hide minimap"

	if P.general.enabled == false then
		toolTip.lines[4] = "|cffFF0000ADDON IS DISABLED"
	end

	if toolTip.header then
		O.ToolTip:SetText(toolTip.header, 1, 1, 1, wrap)
	end
	if toolTip.lines then
		for _, line in pairs(toolTip.lines) do
			O.ToolTip:AddLine(line, 1, .82, 0, wrap)
		end
	end
	O.ToolTip:Show()
end

function A.ToggleMinimap(toggle)
	if toggle then P.general.showMinimap = not P.general.showMinimap end
	if P.general.showMinimap then
		A.Libs.LDBI:Show("AlertMe")
	else
		A.Libs.LDBI:Hide("AlertMe")
	end
end
