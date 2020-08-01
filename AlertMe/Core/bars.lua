dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- upvalues
local CreateFrame, IsShiftKeyDown, unpack = CreateFrame, IsShiftKeyDown, unpack
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Bars = {auras={}, casts={}}
A.Container = {}

function A:GetContainer(barType)
	dprint(2, "A:GetContainer", barType)
	local db = P.bars[barType]
	if A.Container[barType] == nil then
		local f = CreateFrame("Frame", nil, UIParent)
		f:SetPoint(db.point, db.ofs_x, db.ofs_y)
		f:SetWidth(100)
		f:SetHeight(14)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", function(self) f:StartMoving() end)
		f:SetScript("OnDragStop", function(self)
			f:StopMovingOrSizing()
			db.point, _, _, db.ofs_x, db.ofs_y = f:GetPoint(1)
		end)
		local bg = f:CreateTexture(nil, "PARENT")
		bg:SetAllPoints(f)
		bg:SetColorTexture(0, 0, 0, 0.6)
		f.bg = bg
		--local header = f:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
		local header = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		header:SetAllPoints(f)
		header:SetText("Drag here")
		f.header = header
		-- container moveable? can't use toggle function
		f:EnableMouse(db.unlocked)
		f:SetMovable(db.unlocked)
		if db.unlocked == true then
			f.bg:Show()
			f.header:Show()
		else
			f.bg:Hide()
			f.header:Hide()
		end
		A.Container[barType] = f
	end
	return A.Container[barType]
end

function A:ToggleContainerLock(barType)
	dprint(2, "A:ToggleContainerLock", barType)
	local f = A:GetContainer(barType)
	local db = P.bars[barType]
	f:EnableMouse(db.unlocked)
	f:SetMovable(db.unlocked)
	if db.unlocked == true then
		f.bg:Show()
		f.header:Show()
	else
		f.bg:Hide()
		f.header:Hide()
	end
end

function A:ResetContainerPosition(barType)
	dprint(2, "A:ResetContainerPosition", barType)
	-- reset position
	local db = P.bars[barType]
	local def = D.profile.bars[barType]
	db.point, db.ofs_x, db.ofs_y = def.point, def.ofs_x, def.ofs_y
	local f = A:GetContainer(barType)
	f:ClearAllPoints()
	f:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:ShowBar(barType, id, label, icon, duration, reaction, noCreate)
	dprint(2, "A:ShowBar", barType, id, label, icon, duration, color, noCreate)
	local db = P.bars[barType]
	-- enabled?
	if db.enabled == false then return end
	-- if bar doesnt exists and updateOnly, abort
	if A.Bars[barType][id] == nil and noCreate == true then return end
	-- callback for when bar is stopped
	local function barStopped(_, delBar)
		dprint(2, delBar, delBar:Get("id"), "stopped")
		local _id = delBar:Get("id")
		local _barType = delBar:Get("barType")
		delBar:SetParent(nil)
		A.Bars[_barType][_id] = nil
	end
	-- check if already exists
	if A.Bars[barType][id] == nil then
		local newBar = A.Libs.LCB:New(A.LSM:HashTable("statusbar")[db.texture], db.width, db.height)
		newBar:Set("id", id)
		newBar:Set("barType", barType)
		A.Bars[barType][id] = newBar
		--VDT_AddData(newBar, id)
	else
		A.Bars[barType][id]:Stop()
		A:ShowBar(barType, id, label, icon, duration, color)
	end
	local bar = A.Bars[barType][id]
	-- update/set bar settings
	if db.showIcon == true then bar:SetIcon(icon) end
	bar:SetLabel(label)
	bar:SetDuration(duration)
	bar:SetFill(db.fill)
	bar:SetTimeVisibility(db.timeVisible)
	-- colors
	if reaction == true then
		bar:SetColor(unpack(db.goodColor))
	else
		bar:SetColor(unpack(db.badColor))
	end
	bar:SetTextColor(unpack(db.textColor))
	bar:SetShadowColor(unpack(db.shadowColor))
	bar.candyBarBackground:SetVertexColor(unpack(db.backgroundColor))
	-- position
	local container = A:GetContainer(barType)
	bar:SetParent(container)
	--bar:SetPoint("CENTER", container, "CENTER", 0, 0)
	A:ReArrangeBars(barType)
	-- start
	bar:Start()
	-- caLLback for stopping
	A.Libs.LCB.RegisterCallback(A, "LibCandyBar_Stop", barStopped)
end

function A:ReArrangeBars(barType)
	local container = A:GetContainer(barType)
	local bars = A.Bars[barType]
	local db = P.bars[barType]
	if bars == nil then return end
	-- sort bars by duration
	--bar.reamining
	local ofs_y =  db.height + 5
	for id, bar in pairs(bars) do
		bar:ClearAllPoints()
		bar:SetPoint("TOP", container, "TOP", 0, ofs_y*-1)
		ofs_y = ofs_y + db.height + 5
	end
end

function A:HideBar(barType, id)
	dprint(2, "A:HideBar", barType, id)
	if A.Bars[barType][id] ~= nil then
		A.Bars[barType][id]:Stop()
	end
end
