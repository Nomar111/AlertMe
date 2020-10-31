-- upvalues
local sub = string.sub
-- set addon environment
setfenv(1, _G.AlertMe)
-- create tables
A.bars = {auras={}, spells={}}
A.container = {}

local function getContainer(barType)
	local db = P.bars[barType]
	if A.container[barType] == nil then
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
		A.container[barType] = f
	end
	return A.container[barType]
end

local function reArrangeBars(barType)
	local bars = A.bars[barType]
	if not bars then return end
	local db = P.bars[barType]
	local container = getContainer(barType)
	-- sort bars by duration
	local ofs_y =  db.height + 5
	for id, bar in pairs(bars) do
		bar:ClearAllPoints()
		bar:SetPoint("TOP", container, "TOP", 0, ofs_y*-1)
		ofs_y = ofs_y + db.height + 5
	end
end

function A:ToggleContainerLock(barType)
	local f = getContainer(barType)
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
	local def = D.profile.bars[barType]
	db.point, db.ofs_x, db.ofs_y = def.point, def.ofs_x, def.ofs_y
	local f = getContainer(barType)
	f:ClearAllPoints()
	f:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:ShowBar(barType, id, label, icon, duration, reaction, noCreate)
	--dprint(3, "A:ShowBar", barType, id, label, icon, duration, color, noCreate)
	local db = P.bars[barType]
	-- enabled?
	if not db.enabled then return end
	-- if bar doesnt exists and coCreate, abort
	if not A.bars[barType][id] and noCreate then return end
	-- callback for when bar is stopped
	local function barStopped(_, delBar)
		local _id = delBar:Get("id")
		local _barType = delBar:Get("barType")
		delBar:SetParent(nil)
		if A.bars and A.bars[_barType] and A.bars[_barType][_id] then
			A.bars[_barType][_id] = nil
			reArrangeBars(_barType)
		end
	end
	-- check if already exists
	if not A.bars[barType][id] then
		local newBar = A.Libs.LCB:New(A.Statusbars[db.texture], db.width, db.height)
		newBar:Set("id", id)
		newBar:Set("barType", barType)
		A.bars[barType][id] = newBar
	else
		A.bars[barType][id]:Stop()
		A:ShowBar(barType, id, label, icon, duration, color)
	end
	local bar = A.bars[barType][id]
	-- update/set bar settings
	if db.showIcon == true and icon then bar:SetIcon(icon) end
	label = label or ""
	if db.width <= 140 then
		label = sub(label, 1, 10)
	elseif db.width <= 160 then
		label = sub(label, 1, 14)
	elseif db.width <= 180 then
		label = sub(label, 1, 18)
	elseif db.width <= 200 then
		label = sub(label, 1, 22)
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
	local container = getContainer(barType)
	bar:SetParent(container)
	reArrangeBars(barType)
	-- start
	bar:Start()
	-- caLLback for stopping
	A.Libs.LCB.RegisterCallback(A, "LibCandyBar_Stop", barStopped)
end

function A:HideBar(barType, id)
	if A.bars[barType][id] then
		A.bars[barType][id]:Stop()
	end
end

function A:HideAllBars()
	if not A.bars then return end
	for barType,ids in pairs(A.bars) do
		for id, _ in pairs(ids) do
			A.bars[barType][id]:Stop()
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
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:getUnitAura(ti, eventInfo)
			if remaining then
				A:ShowBar(barType, id, getShortName(ti.dstName), icon, remaining, true)
			elseif not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
				remaining = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID)
				_, _, icon = GetSpellInfo(spellId)
				A:ShowBar(barType, id, getShortName(ti.dstName), icon, remaining, true)
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
