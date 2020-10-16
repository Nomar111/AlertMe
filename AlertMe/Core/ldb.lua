-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hHalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vHalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vHalf..hHalf, frame, (vHalf == "TOP" and "BOTTOM" or "TOP")..hHalf
end

function A:InitLDB()
	dprint(3, "A:InitLDB")
	A.AlertMeBroker = A.Libs.LDB:NewDataObject("AlertMe", {
		type = "launcher",
		text = "AlertMe",
		iconR = (P.general.enabled) and 1 or 0.5,
		icon = A.Backgrounds["AlertMe"],
		tocname = "AlertMe",
		OnClick = function(self, button)
			if button == "LeftButton" then
				if(IsShiftKeyDown()) then
					P.general.enabled = not P.general.enabled
					A.UpdateLDBTooltip()
					A.ToggleAddon()
				else
					O:OpenOptions()
				end
			elseif button == "MiddleButton" then
				A.ToggleMinimap(true)
			end
		end,
		OnEnter = function(self)
			O.ToolTip = O.ToolTip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
			O.ToolTip:SetOwner(self, "ANCHOR_NONE")
			A.UpdateLDBTooltip()
			O.ToolTip:Show()
			O.ToolTip:SetPoint(getAnchors(self))
		end,
		OnLeave = function()
			if O.ToolTip then O.ToolTip:Hide() end
		end,
	})
	A.Libs.LDBI:Register("AlertMe", A.AlertMeBroker, P.general.minimap, P.general.minimapPos);
end

function A.UpdateLDBTooltip()
	dprint(3, "A.UpdateLDBTooltip")
	-- prepare tooltip text
	local toolTip = {
		header = "AlertMe "..ADDON_VERSION,
		lines = {},
		wrap = false
	}
	toolTip.lines[1] = "Left-Click: Show/Hide options"
	toolTip.lines[2] = "Shift-Left-Click: Enable/Disable addon"
	toolTip.lines[3] = "Middle-Click: Show/Hide minimap"
	if P.general.enabled == false then
		toolTip.lines[4] = "|cffFF0000ADDON IS DISABLED"
	end
	-- set text
	if toolTip.header then
		O.ToolTip:SetText(toolTip.header, 1, 1, 1, wrap)
	end
	if toolTip.lines then
		for _, line in pairs(toolTip.lines) do
			O.ToolTip:AddLine(line, 1, .82, 0, wrap)
		end
	end
	O.ToolTip:Show()
end

function A.ToggleMinimap(toggle)
	dprint(3,"A.ToggleMinimap", toggle)
	if toggle then P.general.minimap.hide = not P.general.minimap.hide end
	if P.general.minimap.hide then
		A.Libs.LDBI:Hide("AlertMe")
	else
		A.Libs.LDBI:Show("AlertMe")
	end
end
