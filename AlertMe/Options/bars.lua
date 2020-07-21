dprint(3, "bars.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowBars(container)
	dprint(2, "O:ShowBars")
	local sliderWidth = 200
	local db = P.bars.auras
	-- local functions
	local function containerLock()
		A:ToggleContainerLock("auras")
	end
	local function updateTestBar()
		A:ShowBar("auras", "Testbar1", "Playername", 136078, 40, true, true)
		A:ShowBar("auras", "Testbar2", "Playername", 136078, 60, false, true)
	end
	-- header
	O:AttachHeader(container, "Aura bars")
	local enableGroup = O:AttachGroup(container, _, _, 1)
	-- enable
	O:AttachCheckBox(enableGroup, "Enable aura bars", db ,"enabled", 140)
	O:AttachCheckBox(enableGroup, "Unlock bars", db ,"unlocked", 140, containerLock)
	O:AttachSpacer(container, _, "medium")

	-- buttons
	local buttonGroup = O:AttachGroup(container, _, _, 1)
	-- show
	local btnShow = O:AttachButton(buttonGroup, "Show test bar", 120)
	btnShow:SetCallback("OnClick", function()
		A:ShowBar("auras", "Testbar1", "Playername", 136078, 40, true, nil)
		A:ShowBar("auras", "Testbar2", "Playername", 136078, 60, false, nil)
	end)
	-- hide
	O:AttachSpacer(buttonGroup, 20)
	local btnHide = O:AttachButton(buttonGroup, "Hide test bar", 120)
	btnHide:SetCallback("OnClick", function()
		A:HideBar("auras", "Testbar1")
		A:HideBar("auras", "Testbar2")
	end)
	-- reset
	O:AttachSpacer(buttonGroup, 20)
	local btnReset = O:AttachButton(buttonGroup, "Reset position", 120)
	btnReset:SetCallback("OnClick", function() A:ResetContainerPosition("auras") end)
	O:AttachSpacer(container, _, "medium")

	-- texture
	local textureGroup = O:AttachGroup(container, _, _, 1)
	O:AttachLSM(textureGroup, "statusbar", "Bar texture", db, "texture", sliderWidth - 4, updateTestBar)
	O:AttachSpacer(textureGroup, 23)
	--O:AttachSlider(textureGroup, "Bar alpha", db, "alpha", 0, 1, 0.01, true, sliderWidth, updateTestBar)
	O:AttachSpacer(container, _, "medium")

	-- width/height
	local sizeGroup = O:AttachGroup(container, _, _, 1)
	O:AttachSlider(sizeGroup, "Set width", db, "width", 40, 400, 5, false, sliderWidth, updateTestBar)
	O:AttachSpacer(sizeGroup, 20)
	O:AttachSlider(sizeGroup, "Set height", db, "height", 1, 50, 1, false, sliderWidth, updateTestBar)
	O:AttachSpacer(container, _, "medium")

	-- icon / fill
	local iconGroup = O:AttachGroup(container, _, _, 1)
	O:AttachCheckBox(iconGroup, "Show icon", db ,"showIcon", 120, updateTestBar)
	O:AttachCheckBox(iconGroup, "Fill up", db ,"fill", 100, updateTestBar)
	O:AttachCheckBox(iconGroup, "Time visible", db ,"timeVisible", 120, updateTestBar)
	O:AttachSpacer(container, _, "large")

	-- colors
	O:AttachColorPicker(container, "Bar color (good)", db, "goodColor", true, _, updateTestBar)
	O:AttachSpacer(container, _, "small")
	O:AttachColorPicker(container, "Bar color (harm)", db, "badColor", true, _, updateTestBar)
	O:AttachSpacer(container, _, "small")
	O:AttachColorPicker(container, "Background color", db, "backgroundColor", true, _, updateTestBar)
	O:AttachSpacer(container, _, "small")
	O:AttachColorPicker(container, "Text color", db, "textColor", true, _, updateTestBar)
	O:AttachSpacer(container, _, "small")
	O:AttachColorPicker(container, "Text shadow", db, "shadowColor", true, _, updateTestBar)
end
