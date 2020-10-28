-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- create tables
A.Bars = {auras={}, spells={}}
A.Container = {}

local function reArrangeBars(barType)
	local bars = A.Bars[barType]
	if not bars then return end
	local db = P.bars[barType]
	local container = A:GetContainer(barType)
	-- sort bars by duration
	local ofs_y =  db.height + 5
	for id, bar in pairs(bars) do
		bar:ClearAllPoints()
		bar:SetPoint("TOP", container, "TOP", 0, ofs_y*-1)
		ofs_y = ofs_y + db.height + 5
	end
end

function A:GetContainer(barType)
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
		local header = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		header:SetAllPoints(f)
		header:SetText("Drag here")
		f.header = header
		-- container moveable? can't use toggle function
		f:EnableMouse(db.unlocked)
		f:SetMovable(db.unlocked)
		if db.unlocked then
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
	local f = A:GetContainer(barType)
	local db = P.bars[barType]
	f:EnableMouse(db.unlocked)
	f:SetMovable(db.unlocked)
	if db.unlocked then
		f.bg:Show()
		f.header:Show()
	else
		f.bg:Hide()
		f.header:Hide()
	end
end

function A:ResetContainerPosition(barType)
	-- reset position
	local db = P.bars[barType]
	local def = A.Defaults.profile.bars[barType]
	db.point, db.ofs_x, db.ofs_y = def.point, def.ofs_x, def.ofs_y
	local f = A:GetContainer(barType)
	f:ClearAllPoints()
	f:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:ShowBar(barType, id, label, icon, duration, reaction, noCreate)
	--dprint(3, "A:ShowBar", barType, id, label, icon, duration, color, noCreate)
	local db = P.bars[barType]
	-- enabled?
	if not db.enabled then return end
	-- if bar doesnt exists and coCreate, abort
	if not A.Bars[barType][id] and noCreate then return end
	-- callback for when bar is stopped
	local function barStopped(_, delBar)
		local _id = delBar:Get("id")
		local _barType = delBar:Get("barType")
		delBar:SetParent(nil)
		if A.Bars and A.Bars[_barType] and A.Bars[_barType][_id] then
			A.Bars[_barType][_id] = nil
			reArrangeBars(_barType)
		end
	end
	-- check if already exists
	if not A.Bars[barType][id] then
		local newBar = A.Libs.LCB:New(A.Statusbars[db.texture], db.width, db.height)
		newBar:Set("id", id)
		newBar:Set("barType", barType)
		A.Bars[barType][id] = newBar
	else
		A.Bars[barType][id]:Stop()
		A:ShowBar(barType, id, label, icon, duration, color)
	end
	local bar = A.Bars[barType][id]
	-- update/set bar settings
	if db.showIcon == true and icon then bar:SetIcon(icon) end
	label = label or ""
	if db.width <= 140 then
		label = string.sub(label, 1, 10)
	elseif db.width <= 160 then
		label = string.sub(label, 1, 14)
	elseif db.width <= 180 then
		label = string.sub(label, 1, 18)
	elseif db.width <= 200 then
		label = string.sub(label, 1, 22)
	end
	bar:SetLabel(label, 1, 12)
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
	reArrangeBars(barType)
	-- start
	bar:Start()
	-- caLLback for stopping
	A.Libs.LCB.RegisterCallback(A, "LibCandyBar_Stop", barStopped)
end

function A:HideBar(barType, id)
	if A.Bars[barType][id] then
		A.Bars[barType][id]:Stop()
	end
end

function A:HideAllBars()
	if not A.Bars then return end
	for barType,ids in pairs(A.Bars) do
		for id, _ in pairs(ids) do
			A.Bars[barType][id]:Stop()
		end
	end
end

function A:DisplayAuraBars(ti, alerts, eventInfo, snapShot)
	local barType = eventInfo.displaySettings.barType
	-- abort conditions: wrong setting in event, auras disabled
	if barType ~= "auras" or not P.bars.auras.enabled then return end
	local id = ti.dstGUID..ti.spellName
	for _, alert in pairs(alerts) do
		if alert.showBar and eventInfo.displaySettings.enabled and eventInfo.displaySettings.bar then
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:GetUnitAura(ti, eventInfo)
			if remaining then
				A:ShowBar(barType, id, A:GetUnitNameShort(ti.dstName), icon, remaining, true)
			elseif not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
				remaining = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID)
				_, _, icon = GetSpellInfo(spellId)
				A:ShowBar(barType, id, A:GetUnitNameShort(ti.dstName), icon, remaining, true)
			else
				dprint(1, "A:DisplayAuraBars", "no aura duration, no snapshot, why am i here?", ti.relSpellName,  eventInfo.short)
			end
		end
	end
end

function A:HideAuraBars(ti, eventInfo)
	local id = ti.dstGUID..ti.spellName
	A:HideBar(eventInfo.displaySettings.barType, id)
end
