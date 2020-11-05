-- set addon environment
setfenv(1, _G.AlertMe)
-- create tables
A.bars = {auras={}, casts={}}
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
		header:SetText("drag "..barType)
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
	local ofs_y, m
	if db.growUp then
		m = 1
		ofs_y = db.height				-- initial offset = bar height
	else
		m = -1
		ofs_y = container:GetHeight()	-- initial offset = container height
	end
	-- sort bars by duration --
	for id, bar in pairs(bars) do
		bar:ClearAllPoints()
		bar:SetPoint("TOP", container, "TOP", 0, ofs_y * m)
		ofs_y = ofs_y + db.height + db.spacing
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
	local db = P.bars[barType]
	local def = D.profile.bars[barType]
	db.point, db.ofs_x, db.ofs_y = def.point, def.ofs_x, def.ofs_y
	local f = getContainer(barType)
	f:ClearAllPoints()
	f:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

-- callback for when bar is stopped
local function barStopped(_, delBar)
	local id, barType, a = delBar:Get("id"), delBar:Get("barType"), delBar:Get("args")
	-- get pointer or abort
	if not (A.bars and A.bars[barType] and A.bars[barType][id]) then return end
	local ending = (delBar.remaining and delBar.remaining < 0.3) and true or false -- find out if bar was stopped on purpose
	-- release table
	delBar:SetParent(nil)
	A.bars[barType][id] = nil
	if a.loop and ending then	-- if set to loop and bar ran out naturally, then loop/repeat with original args
		A:ShowBar(a.barType, a.id, a.label, a.icon, a.duration, a.reaction, a.loop)
	else
		reArrangeBars(barType)	-- if not rearrange
	end
end


function A:ShowBar(barType, id, label, icon, duration, reaction, loop)
	local db = P.bars[barType]
	if not db.enabled or not id or not duration then return end
	-- check if already exists
	local bar = A.bars[barType][id]
	if not bar then			-- create new bar if it doesn't exist
		local args = { barType=barType, id=id, label=label, icon=icon, duration=duration, reaction=reaction, loop=loop }
		bar = A.Libs.LCB:New(A.statusbars[db.texture], db.width, db.height)
		bar:Set("id", id)
		bar:Set("barType", barType)
		bar:Set("args", args)
		A.bars[barType][id] = bar
	else
		bar:SetWidth(db.width)
		bar:SetHeight(db.height)
		bar:SetTexture(A.statusbars[db.texture])
		bar:SetIcon(nil)
	end
	-- update/set bar settings
	if db.showIcon == true and icon then bar:SetIcon(icon) end
	if label then
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
	end
	bar:SetDuration(duration)
	bar:SetFill(db.fill)
	bar:SetTimeVisibility(db.timeVisible)
	-- set color depending on reaction (true = green/good)
	if reaction then
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
	for barType, ids in pairs(A.bars) do
			P.bars[barType].unlocked = false
			A:ToggleContainerLock(barType)
		for id, _ in pairs(ids) do
			A.bars[barType][id]:Stop()
		end
	end
end

function A:DisplayAuraBars(cleu, evi, alerts, snapShot)
	local barType = evi.barType
	-- abort conditions: wrong setting in event, auras disabled
	if barType ~= "auras" or not P.bars.auras.enabled then return end
	local id = cleu.dstGUID..cleu.spellName
	-- get color scheme for bar
	local reaction = A:GetReactionColor(cleu, evi, "reaction")
	for _, alert in pairs(alerts) do
		if alert.showBar and evi.displayOptions and evi.displayOptions.bar then
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:GetUnitAura(cleu, evi)
			if remaining then
				A:ShowBar(barType, id, GetShortName(cleu.dstName), icon, remaining, reaction)
			elseif not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(cleu.checkedSpell)
				remaining = A.Libs.LCD:GetDurationForRank(cleu.checkedSpell, spellID, cleu.srcGUID)
				_, _, icon = GetSpellInfo(spellId)
				A:ShowBar(barType, id, GetShortName(cleu.dstName), icon, remaining, reaction)
			else
				dprint(1, "A:DisplayAuraBars", "no aura duration, no snapshot, why am i here?", cleu.checkedSpell,  evi.handle)
			end
		end
	end
end

function A:HideAuraBars(cleu, evi)
	local id = cleu.dstGUID..cleu.spellName
	A:HideBar(evi.barType, id)
end
