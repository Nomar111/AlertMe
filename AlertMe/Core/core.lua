dprint(3,"core.lua")
-- upvalues
local _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo, tinsert, UnitGUID, bit = _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo, table.insert, UnitGUID, bit
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE
local IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames = IsInInstance, GetNumGroupMembers, WrapTextInColorCode, SendChatMessage, gsub, string, FCF_GetNumActiveChatFrames
local WA_GetUnitAura, GetTime, GetSpellInfo = WA_GetUnitAura, GetTime, GetSpellInfo
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
	--A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end


function A:GetEventSettingByShort(short, setting)
	for i,v in pairs(A.Events) do
		--dprint(1, v.short, "short", short)
		if v.short == short and v[setting] ~= nil then
			return v[setting]
		end
	end
end

function A:COMBAT_LOG_EVENT_UNFILTERED(eventName)
	local arg = {}
	arg = {CombatLogGetCurrentEventInfo()}
	VDT_AddData(arg,"arg")
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
	--dprint(1,ti.event)
	-- check if trigger event exists in events table, if not abort
    local eventInfo = A.Events[ti.event]
    if eventInfo == nil then return end
    -- get optional arguments if there are any
    if eventInfo.optionalArgs then
        for i,v in pairs(eventInfo.optionalArgs) do
            ti[v] = arg[i+14]
        end
    end
	VDT_AddData(ti,"ti")
    -- set relevant spell name
    ti.relSpellName = ti[A.Events[ti.event].relSpellName]
    -- call processTriggerInfo
    A:ProcessTriggerInfo(ti, eventInfo)
end

function A:ProcessTriggerInfo(ti, eventInfo)
	 -- get spell options for the processed spell
	if A.SpellOptions[ti.relSpellName] == nil then
		dprint(2, "Spell not found in options", ti.relSpellName)
		return
	end
	 if A.SpellOptions[ti.relSpellName][eventInfo.short] == nil then
		dprint(2, "Spell/event combination not found in options ", ti.relSpellName, eventInfo.short)
		return
	end
	local spellOptions = A.SpellOptions[ti.relSpellName][eventInfo.short]
	--VDT_AddData(spellOptions,"spellOptions")
    -- create table of relevant alert settings
    local alerts = {}
    for uid, tbl in pairs(spellOptions) do
        tinsert(alerts, tbl.options)
    end
	--VDT_AddData(relevantAlerts,"relevantAlerts")
    -- check units
    alerts = A:CheckUnits(ti, alerts, eventInfo)
	VDT_AddData(alerts,"alerts")
    if alerts == nil then
		dprint(2, "Unit checks failed for", ti.spellName, ti.event, ti.srcName, ti.dstName)
		return
	end
    -- -- do the specified actions for this event
    -- for _, action in pairs(eventInfo.actions) do
    --      action(ti, alerts, eventInfo)
    -- end
	A:ChatAnnounce(ti, alerts, eventInfo)
	A:ShowBar(ti, alerts, eventInfo)
end

function A:ShowBar(ti, alerts, eventInfo)
	 dprint(2, "A:ShowBar")
    -- loop through alerts
    for _, alert in pairs(alerts) do
        -- check bar option
        if alert.show_bar ~= true then return end
        -- get spell info
        --local spellId, icon, duration, expirationTime = A:GetAuraInfo(ti)
        --if not duration then return false end

		local textures = A.LSM:HashTable("background")
		local texture = textures["Solid"]
		dprint(1, texture)
		VDT_AddData(textures, "textures")
		--local texture = "Interface\\AddOns\\MyAddOn\\statusbar"
		local mybar = A.Libs.LCB:New(texture, 100, 16)
		mybar:SetLabel("Yay!")
		mybar:SetDuration(60)
		mybar:Start()
		mybar:SetPoint("CENTER", UIParent)
		VDT_AddData(mybar, "mybar")
        -- -- set id for display
        -- local id = ti.dstGUID.."_"..ti.relSpellName
        -- -- show bar
        -- allstates[id] = {
        --     show = true,
        --     changed = true,
        --     name = aura_env.getUnitName(ti.dstName),
        --     icon = icon,
        --     progressType = "timed",
        --     duration = duration,
        --     expirationTime = expirationTime,
        --     spellId = spellId,
        --     autoHide = true
        -- }
        -- -- color bar
        -- local f = WeakAuras.GetRegion(aura_env.id, id)
        -- f:Color(aura_env.getReactionColor(ti, "rgb"))
        -- return true
    end
end

-- getAuraInfo: try to get correct spellId and duration or guess
function A:GetAuraInfo(ti)

-- local WA_GetUnitAura = function(unit, spell, filter)
--   if filter and not filter:upper():find("FUL") then
--       filter = filter.."|HELPFUL"
--   end
--   for i = 1, 255 do
--     local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, filter)
--     if not name then return end
--     if spell == spellId or spell == name then
--       return UnitAura(unit, i, filter)
--     end
--   end
-- end

    dprint(2, "A:GetAuraInfo")
    -- try to call the "standard" WA function
    local name, icon, _, debuffType, duration, expirationTime, source, _, _, spellId = WA_GetUnitAura(ti.dstName, ti.relSpellName)
    -- if WA_GetUnitAura returns nothing (enemy player...) use LibClassicDuration
    if duration == nil then
        dprint(2, "No spell info available, using LibClassicDuration")
        spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
        duration = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID)
        expirationTime = GetTime() + duration
        _,_,icon = GetSpellInfo(spellId)
    end
    -- check for relevant values
    if spellId == nil or duration == nil then
        dprint(2, "No spell info available, abort")
        return false
    end
    --return
    return spellId, icon, duration, expirationTime
end


-- checkUnits: check source, destination units of trigger event vs. relevant options
function A:CheckUnits(ti, alerts_in, eventInfo)
    -- set some local variables
    local playerGUID, targetGUID = UnitGUID("player"), UnitGUID("target")
    -- create return table
    local alerts_out = {}
    -- loop over the option groups
    for _, alert in pairs(alerts_in) do
        -- variable to hold the check result for this og
        local checkFailed = false
        -- do the relevant checks (src, dst)
        for _, pre in pairs (eventInfo.checkedUnits) do
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
            --dprint(2, "unit checks positive for", alert.name)
            tinsert(alerts_out, alert)
        end
    end
    -- return
    if #alerts_out == 0 then return else return alerts_out end
end


-- chatAnnounce
function A:ChatAnnounce(ti, alerts, eventInfo)
    dprint(2, "A:ChatAnnounce")
    local prefix, postfix = P.events.chatPrefix, P.events.chatPostfix
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
        if alert.override ~= nil and alert.override ~= "" then
			msg = alert.override
		else
			msg = P.events["msg_"..eventInfo.short]
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
        if alert.chat_channels == 2 and channel then msgQueue[channel] = msg end
        -- party
        if alert.chat_channels == 3 and inInstance then msgQueue["PARTY"] = msg end
        -- say
        if alert.chat_channels == 4 and inInstance then msgQueue["SAY"] = msg end
        -- system messages
        if alert.system_messages == 1 or (alert.system_messages == 3 and not inInstance) then msgQueue["SYSTEM"] = colmsg end
        -- whisper destination unit if source = player and destination is friendly and destination not player
        if alert.whisper_destination and ti.srcIsPlayer and not ti.dstIsPlayer and ti.dstIsFriendly then msgQueue["WHISPER"] = msg end
    end
    -- loop through message queue and send messages
    for chan, msg in pairs(msgQueue) do
        if chan == "SYSTEM" then
            A:SystemMessage(msg)
        elseif chan == "WHISPER" then
            SendChatMessage(string.gsub(msg, dstName, "You"), chan, nil, ti.dstName)
        else
            SendChatMessage(msg, chan, nil, nil)
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
    -- loop through chat frames and post messages
    for i, name in pairs(A.ChatFrames) do
		if P.general.chat_frames[name] == true then
			local f = _G[name]
			f:AddMessage(msg)
		end
	end
	if P.general.scrolling_text.enabled == true then
		A.ScrollingText:Show()
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
	for event, alert_lvl_1 in pairs(P.alerts) do
		--dprint(1, "Level 1: ", event, alert_lvl_1)
		A.AlertOptions[event] = {}
		-- alert uids and names
		for uid, alert_name in pairs(alert_lvl_1.alert_dd_list) do
			--dprint(1, "Level 2: ", uid, alert_name)
			A.AlertOptions[event][uid] = {["name"] = alert_name}
		end
		-- alert details
		for uid, alert_lvl_2 in pairs(alert_lvl_1.alert_details) do
			if uid ~= nil and uid ~= "" then
				--dprint(1, "Level 2: ", uid, alert_lvl_2)
				-- alert details sublevel
				for i, alert_lvl_3 in pairs(alert_lvl_2) do
					--dprint(1, "Level 3: ", uid, i, alert_lvl_3)
					if i ~= "spells" then
						dprint(2,event,uid,i)
						A.AlertOptions[event][uid][i] = alert_lvl_3
					else -- spells
						for spellName, spellOptionsTable in pairs(alert_lvl_3) do
							if A.SpellOptions[spellName] == nil then A.SpellOptions[spellName] = {}	end
							if A.SpellOptions[spellName][event] == nil then A.SpellOptions[spellName][event] = {}end
							if A.SpellOptions[spellName][event][uid] == nil then
								A.SpellOptions[spellName][event][uid] = {
									uid = uid,
									event = event,
									options = A.AlertOptions[event][uid]
								}
							end
							for spellOption, value in pairs(spellOptionsTable) do
								--dprint(1, "Level 4/spells: ", uid, spellName, spellOption, value)
								A.SpellOptions[spellName][event][uid][spellOption] = value
							end
						end
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
