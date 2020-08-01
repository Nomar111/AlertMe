dprint(3,"core.lua")
-- upvalues
local _G, CombatLogGetCurrentEventInfo, UnitGUID, bit, UnitAura = _G, CombatLogGetCurrentEventInfo, UnitGUID, bit, UnitAura
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE
local IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames = IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames
local GetTime, GetSpellInfo = GetTime, GetSpellInfo
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
	-- init scrolling text frame
	A:UpdateScrolling()
	-- init options
	A:InitSpellOptions()
	-- init Chatframes
	A:InitChatFrames()
	-- register for events
	A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	A:RegisterEvent("PLAYER_ENTERING_WORLD")
	A:RegisterEvent("PLAYER_DEAD")
	-- for reloadui
	A.EnterWorld = GetTime()
	A:HideAllBars()
end

function A:PLAYER_ENTERING_WORLD(eventName)
	dprint(2, eventName)
	A.EnterWorld = GetTime()
	A:HideAllBars()
end

function A:PLAYER_DEAD(eventName)
	dprint(2, eventName)
	A.EnterWorld = GetTime()
	A:HideAllBars()
end

function A:COMBAT_LOG_EVENT_UNFILTERED(eventName)
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

	-- to prevent logon events don't do anything in the first 2 seconds
	if GetTime() - A.EnterWorld < 2 then
		--return
		dprint(1, "not blocked")
	end

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
	alerts = A:CheckUnits(ti, alerts, eventInfo)
	if alerts == false or alerts == nil then
		dprint(2, "unit check failed", ti.spellName, ti.event)
		return
	end

	--dprint(2, "checks ok for", ti.event, ti.spellName, ti.srcName, ti.dstName)
	--VDT_AddData(ti,"ti")
	-- do whatever is defined in actions
	if eventInfo.actions ~= nil then
		for _, action in pairs(eventInfo.actions) do
			if action == "displayBars" and type(alerts) == "table" then A:DisplayBars(ti, alerts, eventInfo) end
			if action == "hideBars" then A:HideBars(ti, eventInfo) end
			if action == "chatAnnounce" and type(alerts) == "table" then A:ChatAnnounce(ti, alerts, eventInfo) end
		end
	end
end

function A:GetAlerts(ti, eventInfo)
	dprint(2, "A:GetAlerts", ti, eventInfo)
	-- if no spells are checked for this event return true
	if eventInfo.spellSelection == false then
		--dprint(1, "ti.event.spellSelection", eventInfo.spellSelection)
		return true
	end
	-- search for spell
	if A.SpellOptions[ti.relSpellName] == nil then
		dprint(2, "Spell not found in options", ti.relSpellName)
		return false
	end
	-- search for spell/event combination
	if A.SpellOptions[ti.relSpellName][eventInfo.short] == nil then
		dprint(2, "Spell/event combination not found in options ", ti.relSpellName, eventInfo.short)
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
			local spellId, icon, duration, remaining = A:GetAuraInfo(ti)
			if duration ~= nil then
				local id = ti.dstGUID..ti.spellName
				A:ShowBar("auras", id, A:GetUnitName(ti.dstName), icon, remaining, true)
			end
			--A:ShowBar("auras", ti.srcGUID..ti.spellName, ti.spellName, spellOptions.icon, 60, true)
		end
	end
end

function A:HideBars(ti, eventInfo)
	dprint(2, "A:HideBars", ti, eventInfo)
	local id = ti.dstGUID..ti.spellName
	A:HideBar("auras", id)
end

-- getAuraInfo: try to get correct spellId and duration or guess
function A:GetAuraInfo(ti)
	dprint(2, "A:GetAuraInfo")
    local name, icon, _, debuffType, duration, expirationTime, source, _, _, spellId = A:GetUnitAura(ti.dstName, ti.relSpellName)

	-- if WA_GetUnitAura returns nothing (enemy player...) use LibClassicDuration
    if expirationTime == nil then
        dprint(1, "No spell info available, using LibClassicDuration")
        spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
        duration = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID)
        _,_,icon = GetSpellInfo(spellId)
		expirationTime = GetTime() + duration
    end
    -- check for relevant values
    if spellId == nil or duration == nil then
        dprint(2, "No spell info available, abort")
        return false
    end
    --return
	local remaining = expirationTime - GetTime()
    return spellId, icon, duration, remaining
end

function A:GetUnitAura(unit, spell)
	dprint(2, "A:GetUnitAura", unit, spell)
	for i = 1, 255 do
		local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i)
		if not name then return end
		if spell == spellId or spell == name then
			return UnitAura(unit, i)
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
            if not playerControlled then
                dprint(2, pre, "unit not player controlled")
                checkFailed = true
                break
            end
            -- exclude check -- 1 = none, 2 = tmyself, 3 = target
            if (exclude == 3 and isTarget) or (exclude == 2 and isPlayer) then
                dprint(2, pre, "exclude check failed for", alert.name)
                checkFailed = true
                break
            end
            -- do other checks
            if units == 4 then -- target check
                if not isTarget then
                    dprint(2, pre, "target check failed for", alert.name)
                    checkFailed = true
                    break
                end
            elseif units == 5 then  -- player check
                if not isPlayer then
                    dprint(2, pre, "player check failed for", alert.name)
                    checkFailed = true
                    break
                end
            elseif units == 2 then -- friendly player check
                if not isFriendly then
                    dprint(2, pre, "friendly player check failed for", alert.name)
                    checkFailed = true
                    break
                end
            elseif units == 3 then -- hostile player check
                if not isHostile then
                    dprint(2, pre, "hostile player check failed for", alert.name)
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
    if #alerts_out == 0 then return else return alerts_out end
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
		if alert.scrollingText == true then
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
		--dprint(1, "Loop1: ", event, alert)
		A.AlertOptions[event] = {}
		-- alert details
		for uid, alertDetails in pairs(alert.alertDetails) do
			-- check if alert is active and not default value
			if alertDetails.active == true and alertDetails.created == true then
				--dprint(1, "Loop2: ", uid, alertDetails)
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

function A:InitChatFrames()
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
