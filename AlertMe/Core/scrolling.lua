-- set addon environment
setfenv(1, _G.AlertMe)

function A:UpdateScrolling()
	local db = P.scrolling
	if not db.enabled then return end
	-- init frame if it doesnt exist
	if not A.ScrollingText then
		local f = CreateFrame("ScrollingMessageFrame", "AlertMeScrollingText", UIParent)
		f:SetFrameStrata("LOW")
		f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",tile=true , tileSize=16})
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
		f:SetScript("OnDragStart", function(self) f:StartMoving() end)
		f:SetScript("OnDragStop", function(self)
			f:StopMovingOrSizing()
			db.point, _, _, db.ofs_x, db.ofs_y = f:GetPoint(1)
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
	end
	-- update settings
	local f = A.ScrollingText
	f:SetWidth(db.width)
	f:SetHeight(db.fontSize * db.visibleLines)
	local align = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	f:SetJustifyH(align[db.align])
	f:SetFading(db.fading)
	f:SetFont(A.fonts[db.font], db.fontSize)
	f:SetMaxLines(db.maxLines)
	f:SetTimeVisible(db.timeVisible)
	f:SetBackdropColor(0, 0, 0, db.alpha)
	f:RefreshLayout()
	f:RefreshDisplay()
	-- set position according to db
	A:SetScrollingPos(false)
	A:ToggleScrollingLocked()
end

function A:ToggleScrollingLocked()
	A.ScrollingText:EnableMouse(P.scrolling.interactive)
end

function A.ShowScrolling()
	if not P.scrolling.enabled then return end
	-- if not yet initialized, do so
	if not A.ScrollingText then
		A:UpdateScrolling()
	end
	A.ScrollingText:Show()
end

function A:HideScrolling()
	if A.ScrollingText then
		A.ScrollingText:Hide()
	end
end

function A:SetScrollingPos(reset)
	local db = P.scrolling
	if not db.enabled then return end
	-- abort if not exists
	if not A.ScrollingText then return end
	-- reset position?
	if reset then
		local def = D.profile.scrolling
		db.point = def.point
		db.ofs_x = def.ofs_x
		db.ofs_y = def.ofs_y
	end
	A.ScrollingText:ClearAllPoints()
	A.ScrollingText:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:PostInScrolling(msg)
	if P.scrolling.enabled then
		A:ShowScrolling()
		A.ScrollingText:AddMessage(msg)
	end
end
