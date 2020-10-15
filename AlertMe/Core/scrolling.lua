--dprint(3, "scrolling.lua")
local _G = _G
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- scrolling text init
function A:UpdateScrolling()
	dprint(2, "A:UpdateScrolling")
	-- enabled?
	local db = P.scrolling
	if db.enabled == false then return end
	-- init frame if it doesnt exist
	if A.ScrollingText == nil then
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
	f:SetFont(A.Fonts[db.font], db.fontSize)
	f:SetMaxLines(db.maxLines)
	f:SetTimeVisible(db.timeVisible)
	f:SetBackdropColor(0, 0, 0, db.alpha)
	f:RefreshLayout()
	f:RefreshDisplay()
	--f:EnableMouse(db.interactive)
	-- set position according to db
	A:SetScrollingPosition(false)
	A:ToggleScrollingInteractive()

end

function A:ToggleScrollingInteractive()
	A.ScrollingText:EnableMouse(P.scrolling.interactive)
end

function A:ShowScrolling(setup)
	-- enabled?
	local db = P.scrolling
	if db.enabled == false then return end
	-- if not yet initialized, do so
	if A.ScrollingText == nil then
		A:UpdateScrolling()
	end
	A.ScrollingText:Show()
	-- add dummy messages for setup
	if setup == true then
		A.ScrollingText:AddMessage("Adding some test messages")
		A.ScrollingText:AddMessage("PaladinX gains Blessing of Freedom")
		A.ScrollingText:AddMessage("TeammateY is sapped")
		A.ScrollingText:AddMessage("AuraX is dispelled on PlayernameZ (by PlayernameC)")
		A.ScrollingText:AddMessage("OP Warrior gains Recklessness")
		A.ScrollingText:AddMessage("MotivatedPriest casts Mana Burn")
	end
end

function A:HideScrolling()
	-- hide if exsists
	if A.ScrollingText ~= nil then
		A.ScrollingText:Hide()
	end
end

function A:SetScrollingPosition(reset)
	-- enabled?
	local db = P.scrolling
	if db.enabled == false then return end
	-- abort if not exists
	if A.ScrollingText == nil then return end
	-- reset position?
	if reset == true then
		db.point = "CENTER"
		db.ofs_x = 0
		db.ofs_y = -150
	end
	A.ScrollingText:ClearAllPoints()
	A.ScrollingText:SetPoint(db.point, db.ofs_x, db.ofs_y)
end

function A:PostInScrolling(msg, icon)
	dprint(3, "A:PostInScrolling", msg, icon)
	if P.scrolling.enabled == true then
		A:ShowScrolling()
		A.ScrollingText:AddMessage(msg)
	end
end
