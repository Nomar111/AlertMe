dprint(3,"core.lua")
-- upvalues
local _G, CreateFrame = _G, CreateFrame
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- init function
function A:Initialize()
	-- init scrolling text frame

end

function A:InitScrollingText(setup)
	local db = P.general.scrolling_text
	-- check for options
	--if db.use == false and setup == false then return end
	-- create Frame
	if not A["ScrollingText"] then
		A["ScrollingText"] = CreateFrame("ScrollingMessageFrame", "AlertMe ScrollingText", UIParent)
	end
	local f = A["ScrollingText"]
	VDT_AddData(f, "ScrollingText")
	-- setup frame
	f:SetWidth(db.width)
	f:SetHeight(db.height)
	f:SetJustifyH(db.align)
	f:SetFading(db.fading)
	f:SetPoint(db.point, db.point_x, db.point_y)
	f:SetFrameStrata("LOW")
	f:SetFont("Interface\\AddOns\\AlertMe\\Media\\Fonts\\Roboto_Condensed\\RobotoCondensed-Regular.ttf", 14)
	f:SetMaxLines(db.maxlines)
	f:EnableMouse(true)
	f:EnableMouseWheel(true)
	f:SetTimeVisible(timevisible)
	if setup == true then
		f:SetMovable(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)
		f:SetScript("OnMouseUp", function (self, button)
			if button == "RightButton" then self:Hide() end
		end)
		f:AddMessage("Adding some test messages")
		f:AddMessage("Player-Servername gains AuraX")
		f:AddMessage("TeammateX is sapped")
		f:AddMessage("AuraY is dispelled on PlayerB-ServernameZ (by PlayerC)")
		f:AddMessage("Dumb warrior gains Recklessness")
		f:AddMessage("HuntardX casts Aiming Shot")
	end
	-- if frame was hidden show it
	if not f:IsVisible() then
		f:Show()
	end
	f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",tile=true,tileSize=32,edgeSize=32,insets={left=0,right=0,top=0,bottom=0}})
	f:SetBackdropColor(0, 0, 0, db.bg_aplpha)
	f:SetScript("OnMouseWheel", function(self, delta)
		if delta == 1 then
			self:ScrollUp()
		elseif delta == -1 then
			self:ScrollDown()
		end
	end)
end

-- central table with event options
A.Events = {
	["SPELL_AURA_APPLIED"] = {
		short = "gain",
		options_display = true,
		options_name = "On aura gain or refresh",
		options_order = 1,
		spell_aura = "Aura",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = true,
		whisper_destination = true,
	},
	["SPELL_AURA_REFRESH"] = {
		short = "gain",
		options_display = false,
	},
	["SPELL_AURA_REMOVED"] = {
		short = "removed",
		options_display = false,
	},
	["SPELL_DISPEL"] = {
		short = "dispel",
		options_display = true,
		options_name = "On dispel",
		options_order = 2,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = false,
	},
	["SPELL_CAST_START"] = {
		short = "start",
		options_display = true,
		options_name = "On cast start",
		options_order = 3,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		display_settings = true,
		whisper_destination = false,
	},
	["SPELL_CAST_SUCCESS"] = {
		short = "success",
		options_display = true,
		options_name = "On cast success",
		options_order = 4,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = true,
	},
	["SPELL_INTERRUPT"] = {
		short = "interrupt",
		options_display = true,
		options_name = "On interrupt",
		options_order = 5,
		spell_aura = "Spell",
		spell_selection = false,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = false,
	},
}

function A:GetEventSettingByShort(short, setting)
	for i,v in pairs(A.Events) do
		--dprint(1, v.short, "short", short)
		if v.short == short and v[setting] ~= nil then
			return v[setting]
		end
	end
end
