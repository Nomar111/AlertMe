dprint(3,"core.lua")
-- upvalues
local _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs = _G, CreateFrame, date, dprint, IsShiftKeyDown, pairs
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
	-- init scrolling text frame
	A:ScrollingTextInitOrUpdate()
	-- init options
end

function A:InitSpellOptions()
    dprint(1, "A:InitSpellOptions")
    -- loop through evens
	for i,v in pairs(P.alerts) do
		dprint(1, i, v)
		for m,k in pairs(v.alert_dd_list) do
			dprint(1,m,k)
		end
		for m,k in pairs(v.alert_details) do
			dprint(1,m,k)
		end
	end
    --     for i,og in pairs(optionGroups) do
    --         -- only process active option groups
    --         if og.active then
    --             -- loop over spells (string split)
    --             for i, spellName in pairs(aura_env.parseCSL(og.spellNames)) do
    --                 -- create table for each spellName/eventName
    --                 if not spellOptions[spellName] then spellOptions[spellName] = {} end
    --                 if not spellOptions[spellName][eventName] then spellOptions[spellName][eventName] = {} end
    --                 -- create entry for each spell/event/eoptiongroup
    --                 table.insert(spellOptions[spellName][eventName], {optionGroup = og, optionGroupName = og.name})
    --             end
    --         end
    --     end
    -- end

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
