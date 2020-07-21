dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- upvalues
local CreateFrame, IsShiftKeyDown = CreateFrame, IsShiftKeyDown
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Bars = {}

function A:ShowTestBar(barType)
	dprint(1, "A:ShowTestBar()")
	local function barstopped( callback, bar )
		dprint(1, bar.candybarLabel:GetText(), "stopped")
	end
	-- enabled?
	local db = P.bars.auras
	if db.enabled == false then return end
	-- get texture
	local texture = A.LSM.Textures[db.texture]
	local icon = 136078
	VDT_AddData(A.LSM.Textures, "A.LSM.Textures")
	-- create candy bar
	local bar = A.Libs.LCB:New(texture, width, height)
	VDT_AddData(bar, "testbar")
	bar:SetIcon(icon)
	bar:SetLabel("Playername")
	bar:SetDuration(30)
	bar:SetTextColor(0, 0, 0, 1)
	bar:SetColor(unpack(A.Colors.red.rgb), db.alpha)
	bar:SetPoint("CENTER", UIParent)
	bar:SetFill(false)
	--bar:SetShadowColor(r, g, b, a) -- Sets the shadow color of the bar label and bar duration text.
	bar:SetTimeVisibility(true)
	bar:Start()
	bar:ClearAllPoints()
	bar:SetPoint(db.point, db.ofs_x, db.ofs_y)
	-- callback
	A.Libs.LCB.RegisterCallback(A, "LibCandyBar_Stop", barstopped)
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
