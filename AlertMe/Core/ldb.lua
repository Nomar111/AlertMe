-- upvalues
local UIParent = UIParent
-- set addon environment
setfenv(1, _G.AlertMe)

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hHalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vHalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vHalf..hHalf, frame, (vHalf == "TOP" and "BOTTOM" or "TOP")..hHalf
end

function A:InitLDB()
	A.AlertMeBroker = A.Libs.LDB:NewDataObject("AlertMe", {
		type = "launcher",
		text = "AlertMe",
		iconR = (P.general.enabled) and 1 or 0.5,
		icon = A.backgrounds["AlertMe_Minimap"],
		tocname = "AlertMe",
		OnClick = function(self, button)
			if button == "LeftButton" then
				if(IsShiftKeyDown()) then
					P.general.enabled = not P.general.enabled
					A.UpdateLDBtooltip()
					A.ToggleAddon()
					O:ReOpenOptions()
				else
					O:OpenOptions()
				end
			elseif button == "MiddleButton" then
				A.ToggleMinimap(true)
				O:ReOpenOptions()
			end
		end,
		OnEnter = function(self)
			O.Tooltip = O.Tooltip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
			O.Tooltip:SetOwner(self, "ANCHOR_NONE")
			A.UpdateLDBtooltip()
			O.Tooltip:Show()
			O.Tooltip:SetPoint(getAnchors(self))
		end,
		OnLeave = function()
			if O.Tooltip then O.Tooltip:Hide() end
		end,
	})
	A.Libs.LDBI:Register("AlertMe", A.AlertMeBroker, P.general.minimap, P.general.minimapPos)
end

function A.UpdateLDBtooltip()
	-- prepare tooltip text
	local tooltip = {
		header = "AlertMe "..ADDON_VERSION,
		lines = {"Left-Click: Show/Hide options", "Shift-Left-Click: Enable/Disable addon", "Middle-Click: Show/Hide minimap"},
		wrap = false
	}
	if not P.general.enabled then tooltip.lines[4] = "|cffFF0000ADDON IS DISABLED" end
	-- set text
	if tooltip.header then
		O.Tooltip:SetText(tooltip.header, 1, 1, 1, wrap)
	end
	if tooltip.lines then
		for _, line in pairs(tooltip.lines) do
			O.Tooltip:AddLine(line, 1, .82, 0, wrap)
		end
	end
	O.Tooltip:Show()
end

function A.ToggleMinimap(toggle)
	if toggle then P.general.minimap.hide = not P.general.minimap.hide end
	if P.general.minimap.hide then
		A.Libs.LDBI:Hide("AlertMe")
	else
		A.Libs.LDBI:Show("AlertMe")
	end
end
