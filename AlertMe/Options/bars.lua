-- set addon environment
setfenv(1, _G.AlertMe)

-- prepare settings for test bars
local testBars = {
	auras = {
		{"Testbar1", "Hostile player", 134715, 40, false}, -- fap
		{"Testbar2", "Friendly player", 136048, 20, true}, -- innervate
	},
	spells = {
		{"Testbar1", "Greater Heal", 135915, 3, true}, -- greater heal
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
		local enableGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		-- enable
		O.attachCheckBox(enableGroup, "Enable".." "..barTypeText, db ,"enabled", 140, A.InitLCC)
		O.attachCheckBox(enableGroup, "Unlock bars", db ,"unlocked", 140, containerLock)
		O.attachSpacer(container, _, "medium")
		-- buttons
		local buttonGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		-- show
		local btnShow = O.attachButton(buttonGroup, "Show test bars", 120)
		btnShow:SetCallback("OnClick", function()
			A:ShowBar(barType, getTestBar(barType, 1))
			A:ShowBar(barType, getTestBar(barType, 2))
		end)
		-- hide
		O.attachSpacer(buttonGroup, 20)
		local btnHide = O.attachButton(buttonGroup, "Hide test bars", 120)
		btnHide:SetCallback("OnClick", function()
			A:HideBar(barType, "Testbar1")
			A:HideBar(barType, "Testbar2")
		end)
		-- reset
		O.attachSpacer(buttonGroup, 20)
		local btnReset = O.attachButton(buttonGroup, "Reset position", 120)
		btnReset:SetCallback("OnClick", function() A:ResetContainerPosition(barType) end)
		O.attachSpacer(tabGroup, _, "medium")
		-- texture
		local textureGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.attachLSM(textureGroup, "statusbar", "Bar texture", db, "texture", sliderWidth - 4, updateTestBar)
		O.attachSpacer(textureGroup, 23)
		O.attachSpacer(tabGroup, _, "medium")
		-- width/height
		local sizeGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.attachSlider(sizeGroup, "Set width", db, "width", 40, 400, 5, false, sliderWidth, updateTestBar)
		O.attachSpacer(sizeGroup, 20)
		O.attachSlider(sizeGroup, "Set height", db, "height", 1, 50, 1, false, sliderWidth, updateTestBar)
		O.attachSpacer(tabGroup, _, "medium")
		-- icon / fill
		local iconGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.attachCheckBox(iconGroup, "Show icon", db ,"showIcon", sliderWidth+20, updateTestBar)
		O.attachCheckBox(iconGroup, "Fill up", db ,"fill", 140, updateTestBar)
		O.attachSpacer(tabGroup, _, "small")
		local checkGroup = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
		O.attachCheckBox(checkGroup, "Time visible", db ,"timeVisible", sliderWidth+20, updateTestBar)
		O.attachCheckBox(checkGroup, "Grow upwards", db ,"growUp", 140, updateTestBar)
		O.attachSpacer(tabGroup, _, "large")
		-- colors
		O.attachColorPicker(tabGroup, "Bar color (good)", db, "goodColor", true, _, updateTestBar)
		O.attachSpacer(tabGroup, _, "small")
		O.attachColorPicker(tabGroup, "Bar color (harm)", db, "badColor", true, _, updateTestBar)
		O.attachSpacer(tabGroup, _, "small")
		O.attachColorPicker(tabGroup, "Background color", db, "backgroundColor", true, _, updateTestBar)
		O.attachSpacer(tabGroup, _, "small")
		O.attachColorPicker(tabGroup, "Text color", db, "textColor", true, _, updateTestBar)
		O.attachSpacer(tabGroup, _, "small")
		O.attachColorPicker(tabGroup, "Text shadow", db, "shadowColor", true, _, updateTestBar)
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
	local tabGroup = O.attachTabGroup(container, _, format, P.bars, "barType", tabs, onSelect)
	-- attach bar options
	attachBarOptions(tabGroup, P.bars.barType)
end
