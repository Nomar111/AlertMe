-- set addon environment
setfenv(1, _G.AlertMe)

function A:updateScrolling()
	local db = P.scrolling
	if not db.enabled then return end
	-- init frame if it doesnt exist
	if not scrollingText then
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
		scrollingText = f
		-- hide frame after init
		scrollingText:Hide()
	end
	-- update settings
	local f = scrollingText
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
	A:setScrollingPos(false)
	A:toggleScrollingLocked()
end

function A:toggleScrollingLocked()
	scrollingText:EnableMouse(P.scrolling.interactive)
end

function A.showScrolling()
	if not P.scrolling.enabled then return end
	-- if not yet initialized, do so
	if not scrollingText then
		A:updateScrolling()
	end
	scrollingText:Show()
end

function A:hideScrolling()
	if scrollingText then
		scrollingText:Hide()
	end
end

function A:setScrollingPos(reset)
	local db = P.scrolling
	if not db.enabled then return end
	-- abort if not exists
	if not scrollingText then return end
	-- reset position?
	if reset then
		local def = D.profile.scrolling
		db.point = def.point
		db.ofs_x = def.ofs_x
		db.ofs_y = def.ofs_y
	end
	scrollingText:ClearAllPoints()
	scrollingText:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:postInScrolling(msg)
	if P.scrolling.enabled then
		A:showScrolling()
		scrollingText:AddMessage(msg)
	end
end
