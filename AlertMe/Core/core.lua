dprint(3,"core.lua")
-- upvalues
local _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo, tinsert, UnitGUID, bit = _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo, table.insert, UnitGUID, bit
local COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_HOSTILE
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
	-- init scrolling text frame
	A:ScrollingTextInitOrUpdate()
	-- init options
	A:InitSpellOptions()
	-- register for events
	A:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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
	local spellOptions = {}
    if A.SpellOptions[ti.relSpellName][eventInfo.short] == nil then
		dprint(1, "No combination found in options for ", ti.relSpellName, eventInfo.short)
		return
	else
		spellOptions = A.SpellOptions[ti.relSpellName][eventInfo.short]
	end
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
    -- do the specified actions for this event
    for _, action in pairs(eventInfo.actions) do
         action(ti, alerts, eventInfo)
    end
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
			--dprint(1, "Level 2: ", uid, alert_lvl_2)
			-- alert details sublevel
			for i, alert_lvl_3 in pairs(alert_lvl_2) do
				--dprint(1, "Level 3: ", uid, i, alert_lvl_3)
				if i ~= "spells" then
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


-- scrolling text init
function A:ScrollingTextInitOrUpdate()
	dprint(2, "A:ScrollingTextInitOrUpdate")
	-- enabled?
	local db = P.general.scrolling_text
	if db.enabled == false then return end
	-- init frame if it doesnt exist
	if A.ScrollingText == nil then
		local f = CreateFrame("ScrollingMessageFrame", "AlertMeScrollingText", UIParent)
		f:SetFrameStrata("LOW")
		f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",tile=true,tileSize=32,edgeSize=32,insets={left=0,right=0,top=0,bottom=0}})
		-- enable mousewheel scrolling
		f:EnableMouse(true)
		f:EnableMouseWheel(true)
		f:SetScript("OnMouseWheel", function(self, delta)
			if delta == 1 then
				self:ScrollUp()
			elseif delta == -1 then
				self:ScrollDown()
			end
		end)
		-- enable drag - shift & left click
		f:SetMovable(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then f:StartMoving() end end)
		f:SetScript("OnDragStop", function(self)
			f:StopMovingOrSizing()
			db.point, _, _, db.point_x, db.point_y = f:GetPoint(1)
		end)
		-- right click hide
		f:SetScript("OnMouseUp", function (self, button)
			if button == "RightButton" then
				self:Hide()
			end
		end)
		A.ScrollingText = f
		-- hide frame after init
		A.ScrollingText:Hide()
		VDT_AddData(A.ScrollingText, "ScrollingText")
	end
	-- update settings
	local f = A.ScrollingText
	f:SetWidth(db.width)
	f:SetHeight(db.font_size * db.visible_lines)
	local align = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	f:SetJustifyH(align[db.align])
	f:SetFading(db.fading)
	f:SetFont("Interface\\AddOns\\AlertMe\\Media\\Fonts\\Roboto_Condensed\\RobotoCondensed-Regular.ttf", db.font_size)
	f:SetMaxLines(db.maxlines)
	f:SetTimeVisible(db.timevisible)
	f:SetBackdropColor(0, 0, 0, db.alpha)
	-- set position according to db
	A:ScrollingTextSetPosition(false)
end

function A:ScrollingTextShow(setup)
	-- enabled?
	local db = P.general.scrolling_text
	if db.enabled == false then return end
	-- if not yet initialized, do so
	if A.ScrollingText == nil then
		A:ScrollingTextInitOrUpdate()
	end
	A.ScrollingText:Show()
	-- add dummy messages for setup
	if setup == true then
		A.ScrollingText:AddMessage("Adding some test messages")
		A.ScrollingText:AddMessage("Player-Servername gains AuraX")
		A.ScrollingText:AddMessage("TeammateX is sapped")
		A.ScrollingText:AddMessage("AuraY is dispelled on PlayerB-ServernameZ (by PlayerC)")
		A.ScrollingText:AddMessage("Dumb warrior gains Recklessness")
		A.ScrollingText:AddMessage("HuntardX casts Aiming Shot")
	end
end

function A:ScrollingTextHide()
	-- hide if exsists
	if A.ScrollingText ~= nil then
		A.ScrollingText:Hide()
	end
end

function A:ScrollingTextSetPosition(reset)
	-- enabled?
	local db = P.general.scrolling_text
	if db.enabled == false then return end
	-- abort if not exists
	if A.ScrollingText == nil then return end
	-- reset position?
	if reset == true then
		db.point = "CENTER"
		db.point_x = 0
		db.point_y = -150
	end
	A.ScrollingText:ClearAllPoints()
	A.ScrollingText:SetPoint(db.point, db.point_x, db.point_y)
end
