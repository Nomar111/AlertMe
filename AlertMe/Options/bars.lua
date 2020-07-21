dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowBars(container)
	dprint(2, "O:ShowBars")
	local sliderWidth = 190
	local barsGroup = O:AttachGroup(container, _, _, 1, 1, "List")
	local db = P.bars.auras
	-- header
	O:AttachHeader(barsGroup, "Aura bars")
	-- enable
	O:AttachCheckBox(barsGroup, "Enable aura bars", db ,"enabled", 300)
	O:AttachSpacer(barsGroup, _, "small")

	-- buttons
	local buttonGroup = O:AttachGroup(barsGroup, _, _, 1)
	-- show
	local btnShow = O:AttachButton(buttonGroup, "Show test bar", 120)
	btnShow:SetCallback("OnClick", function() A:ShowTestBar() end)
	-- hide
	O:AttachSpacer(buttonGroup, 20)
	local btnHide = O:AttachButton(buttonGroup, "Hide test bar", 120)
	btnHide:SetCallback("OnClick", function() A:StopTestBar() end)
	-- reset
	O:AttachSpacer(buttonGroup, 20)
	local btnReset = O:AttachButton(buttonGroup, "Reset position", 120)
	btnReset:SetCallback("OnClick", function() A:ResetTestBar(true) end)
	O:AttachSpacer(barsGroup, _, "small")

end
