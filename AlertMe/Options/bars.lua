-- set addon environment
setfenv(1, _G.AlertMe)

-- prepare settings for test bars
local testBars = {
	auras = {
		{"Testbar1", "Hostile player", 134715, 40, false}, -- fap
		{"Testbar2", "Friendly player", 136048, 20, true}, -- innervate
	},
	spells = {
		{"Testbar1", "Greater Heal", 135915, 3, false}, -- greater heal
		{"Testbar2", "Resurrection", 135955, 10, false}, -- resurrection
	}
}
local function getTestBar(barType, i)
	return unpack(testBars[barType][i])
end

function O:ShowBars(container)
	-------------------------------------------------------------------------------
	-- attach bar options depending on selected barType
	local function attachBarOptions(tabGroup, barType)
		local sliderWidth = 200
		local db = P.bars[barType]
		-- onclick functions
		local function containerLock()
			A:ToggleContainerLock(barType)
		end
		local function updateTestBar()
			local id, label, icon, duration, reaction = getTestBar(barType, 1)
			A:ShowBar(barType, id, label, icon, duration, reaction, true)
			id, label, icon, duration, reaction = getTestBar(barType, 2)
			A:ShowBar(barType, id, label, icon, duration, reaction, true)
		end
		-- header
		local barTypeText = (barType == "auras") and "aura bars" or "cast bars"
		local enableGroup = O.AttachGroup(tabGroup, "simple", _, {fullWidth = true})
		-- enable
		O.AttachCheckBox(enableGroup, "Enable "..barTypeText, db ,"enabled", 140, A.InitLCC)
		O.AttachCheckBox(enableGroup, "Unlock bars", db ,"unlocked", 140, containerLock)
		O.AttachSpacer(container, _, "medium")
		-- buttons
		local buttonGroup = O.AttachGroup(tabGroup, "simple", _, {fullWidth = true})
		-- show
		local btnShow = O.AttachButton(buttonGroup, "Show test bars", 120)
		btnShow:SetCallback("OnClick", function()
			A:ShowBar(barType, getTestBar(barType, 1))
			A:ShowBar(barType, getTestBar(barType, 2))
		end)
		-- hide
		O.AttachSpacer(buttonGroup, 20)
		local btnHide = O.AttachButton(buttonGroup, "Hide test bars", 120)
		btnHide:SetCallback("OnClick", function()
			A:HideBar(barType, "Testbar1")
			A:HideBar(barType, "Testbar2")
		end)
		-- reset
		O.AttachSpacer(buttonGroup, 20)
		local btnReset = O.AttachButton(buttonGroup, "Reset position", 120)
		btnReset:SetCallback("OnClick", function() A:ResetContainerPosition(barType) end)
		O.AttachSpacer(tabGroup, _, "medium")
		-- texture
		local textureGroup = O.AttachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.AttachLSM(textureGroup, "statusbar", "Bar texture", db, "texture", sliderWidth - 4, updateTestBar)
		O.AttachSpacer(textureGroup, 23)
		O.AttachSpacer(tabGroup, _, "medium")
		-- width/height
		local sizeGroup = O.AttachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.AttachSlider(sizeGroup, "Set width", db, "width", 40, 400, 5, false, sliderWidth, updateTestBar)
		O.AttachSpacer(sizeGroup, 20)
		O.AttachSlider(sizeGroup, "Set height", db, "height", 1, 50, 1, false, sliderWidth, updateTestBar)
		O.AttachSpacer(container, _, "medium")
		-- icon / fill
		local iconGroup = O.AttachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.AttachCheckBox(iconGroup, "Show icon", db ,"showIcon", 120, updateTestBar)
		O.AttachCheckBox(iconGroup, "Fill up", db ,"fill", 100, updateTestBar)
		O.AttachCheckBox(iconGroup, "Time visible", db ,"timeVisible", 120, updateTestBar)
		O.AttachSpacer(tabGroup, _, "large")
		-- colors
		O.AttachColorPicker(tabGroup, "Bar color (good)", db, "goodColor", true, _, updateTestBar)
		O.AttachSpacer(tabGroup, _, "small")
		O.AttachColorPicker(tabGroup, "Bar color (harm)", db, "badColor", true, _, updateTestBar)
		O.AttachSpacer(tabGroup, _, "small")
		O.AttachColorPicker(tabGroup, "Background color", db, "backgroundColor", true, _, updateTestBar)
		O.AttachSpacer(tabGroup, _, "small")
		O.AttachColorPicker(tabGroup, "Text color", db, "textColor", true, _, updateTestBar)
		O.AttachSpacer(tabGroup, _, "small")
		O.AttachColorPicker(tabGroup, "Text shadow", db, "shadowColor", true, _, updateTestBar)
	end
	-- function
	local function onSelect(tabGroup, barType)
		-- release all existing
		tabGroup:ReleaseChildren()
		-- attach bar options
		attachBarOptions(tabGroup, barType)
	end
	-- create Tabgroup
	local tabs = {}
	tabs[1] = {value = "auras", text = "Aura bars"}
	tabs[2] = {value = "spells", text = "Cast bars"}
	local format = {fullWidth = true, fullHeight = true , layout = "none"}
	local tabGroup = O.AttachTabGroup(container, _, format, P.bars, "barType", tabs, onSelect)
	-- attach bar options
	attachBarOptions(tabGroup, P.bars.barType)
end
