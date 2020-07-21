dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- upvalues
local CreateFrame, IsShiftKeyDown, unpack = CreateFrame, IsShiftKeyDown, unpack
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Bars = {}

function A:InitBarContainer(barType)
	dprint(2, "A:InitBarContainer", barType)
	if A.AuraContainer == nil then
		dprint(1, "A.AuraContainer = nil")
		local db = P.bars.auras
		local f = CreateFrame("Frame", "AuraContainer", UIParent)
		f:ClearAllPoints()
		f:SetPoint(db.point, db.ofs_x, db.ofs_y)
		f:SetWidth(db.width)
		f:SetHeight(db.height)
		f:EnableMouse(db.unlocked)
		f:SetMovable(db.unlocked)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", function(self) f:StartMoving() end)
		f:SetScript("OnDragStop", function(self)
			f:StopMovingOrSizing()
			db.point, _, _, db.ofs_x, db.ofs_y = f:GetPoint(1)
		end)
		A.AuraContainer = f
		VDT_AddData(A.AuraContainer, "AuraContainer")
	end
end

function A:ToggleLockBarContainer(barType)
	dprint(2, "A:ToggleLockBarContainer", barType)
	local f = A.AuraContainer
	local db = P.bars.auras
	f:EnableMouse(db.unlocked)
	f:SetMovable(db.unlocked)
end

function A:ResetBarContainer()
	-- enabled?
	local db = P.bars.auras
	if db.enabled == false then return end
	-- abort if not exists
	if A.AuraContainer == nil then return end
	-- reset position?
	db.point = "CENTER"
	db.ofs_x = 0
	db.ofs_y = 150
	A.AuraContainer:ClearAllPoints()
	A.AuraContainer:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:ShowTestBar(barType)
	dprint(2, "A:ShowTestBar", barType)
	-- enabled?
	local db = P.bars.auras
	if db.enabled == false then return end
	-- init container frame if it doesn't exist
	if A.AuraContainer == nil then
		A:InitBarContainer()
	end
	-- callback for when bar is stopped
	local function barStopped(_, bar)
		dprint(2, bar:GetLabel(), "stopped")
		A.Bars.Testbar = nil
		bar:SetParent(nil)
	end
	-- get texture
	local texture = A.LSM.Textures[db.texture]
	local icon = 136078
	VDT_AddData(A.LSM.Textures, "A.LSM.Textures")
	-- create candy bar
	local bar = A.Libs.LCB:New(texture, db.width, db.height)
	VDT_AddData(bar, "testbar")
	bar:SetIcon(icon)
	bar:SetLabel("Playername")
	bar:SetDuration(60)
	bar:SetTextColor(1, 1, 1, 1)
	local r,g,b = unpack(A.Colors.red.rgb)
	bar:SetColor(r, g, b, db.alpha)
	bar:SetFill(false)
	--bar:SetShadowColor(r, g, b, a) -- Sets the shadow color of the bar label and bar duration text.
	bar:SetTimeVisibility(true)
	bar:Start()
	bar:SetParent(A.AuraContainer)
	bar:SetPoint("CENTER", A.AuraContainer, "CENTER", 0, 0)
	A.Bars.Testbar = bar
	A.Libs.LCB.RegisterCallback(A, "LibCandyBar_Stop", barStopped)
end

function A:StopTestBar()
	A.Bars.Testbar:Stop()
end

--bar:Stop(...) This will stop the bar, fire the LibCandyBar_Stop c
--[[
candy.RegisterCallback(API, "LibCandyBar_Stop", function(_, bar)
if activeBars[bar] then
activeBars[bar] = nil
RearrangeBars()
end
end)
endallback, and recycle the bar into the candybar pool. Note: make sure you remove all references to the bar in your addon upon receiving the LibCandyBar_Stop callback.

local function barstopped( callback, bar )
print( bar.candybarLabel:GetText(), "stopped")
end
LibStub("LibCandyBar-3.0"):RegisterCallback(myaddonobject, "LibCandyBar_Stop", barstopped)
]]
