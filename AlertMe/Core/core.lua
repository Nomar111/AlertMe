dprint(3,"core.lua")
-- upvalues
local _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo = _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs, CombatLogGetCurrentEventInfo
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
	-- Assign all the data from current event
	local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
	destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool,
	arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24  = CombatLogGetCurrentEventInfo()
	if A.Events[subevent] then
		dprint(1, timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24)
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
