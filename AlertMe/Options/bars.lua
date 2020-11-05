-- set addon environment
setfenv(1, _G.AlertMe)

--***************************************************************************
-- test bars
local testBars = {
	auras = {
		{"Hostile player", 134715, 40, false}, -- fap
		{"Friendly player", 136048, 20, true}, -- innervate
	},
	spells = {
		{"Greater Heal", 135915, 3, true}, -- greater heal
		{"Resurrection", 135955, 10, false}, -- resurrection
	}
}

------------------------------------------------------------------------------
-- attach bar options (=tab=) depending on selected barType
local function attachBarOptions(tabGroup, barType)
	tabGroup:ReleaseChildren()
	local sliderWidth = 200
	local db, group = P.bars[barType]
	-- callbacks
	local function containerLock()
		A:ToggleContainerLock(barType)
	end
	local function updateTestBars()
		for i, a in ipairs(testBars[barType]) do
			local id, loop = "testbar_"..i, true
			A:ShowBar(barType, id, a[1], a[2], a[3], a[4], loop)
		end
	end
	local function resetSettings()
		for handle, setting in pairs(D.profile.bars["**"]) do
			db[handle] = setting
		end
		for handle, setting in pairs(D.profile.bars[barType]) do
			db[handle] = setting
		end
		A:ResetContainerPosition(barType)
		updateTestBars()
		attachBarOptions(tabGroup, P.bars.barType)
	end
	local barTypeText = (barType == "auras") and "aura bars" or "cast bars"
	-- enable...
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachCheckBox(group, "Enable".." "..barTypeText, db ,"enabled", 140, A.InitLCC)
	O.attachCheckBox(group, "Unlock bars", db ,"unlocked", 140, containerLock)
	O.attachSpacer(tabGroup, _, "medium")
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachLSM(group, "statusbar", "Bar texture", db, "texture", sliderWidth - 4, updateTestBars)
	O.attachSpacer(group, 23)
	O.attachSpacer(tabGroup, _, "medium")
	-- icon / fill
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachCheckBox(group, "Show icon", db ,"showIcon", 153, updateTestBars)
	O.attachCheckBox(group, "Show rem. time", db ,"timeVisible", 180, updateTestBars)
	O.attachCheckBox(group, "Fill up (ltr)", db ,"fill", 90, updateTestBars)
	O.attachSpacer(tabGroup, _, "small")
	-- width/height
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachSlider(group, "Set width", db, "width", 40, 400, 5, false, sliderWidth, updateTestBars)
	O.attachSpacer(group, 20)
	O.attachSlider(group, "Set height", db, "height", 1, 50, 1, false, sliderWidth, updateTestBars)
	O.attachSpacer(tabGroup, _, "medium")
	-- spacing
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachSlider(group, "Bar spacing", db, "spacing", 0, 20, 1, false, sliderWidth, updateTestBars)
	O.attachSpacer(group, 22)
	O.attachCheckBox(group, "Grow upwards", db ,"growUp", 160, updateTestBars)
	O.attachSpacer(tabGroup, _, "large")
	-- colors
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	local width = 155
	O.attachColorPicker(group, "Bar color (good)", db, "goodColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Bar color (harm)", db, "badColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Background color", db, "backgroundColor", true, width, updateTestBars)
	O.attachSpacer(tabGroup, _, "small")
	group = O.attachGroup(tabGroup, "simple", _, {fullWidth = true})
	O.attachColorPicker(group, "Text color", db, "textColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Text shadow", db, "shadowColor", true, width, updateTestBars)
	O.attachSpacer(tabGroup, _, "medium")
	O.attachButton(tabGroup, "Reset", 90, resetSettings)
end

function O:ShowBars(container)
	container:ReleaseChildren()
	local function showTestBars()
		for barType, tbl in pairs(testBars) do
			for i, a in ipairs(tbl) do
				local id, loop = "testbar_"..i, true
				A:ShowBar(barType, id, a[1], a[2], a[3], a[4], loop)
			end
		end
	end
	local function hideTestBars()
		for barType, tbl in pairs(testBars) do
			for i, _ in ipairs(tbl) do
				local id = "testbar_"..i
				A:HideBar(barType, id)
			end
		end
	end
	local function resetPositions()
		for barType, _ in pairs(testBars) do
			A:ResetContainerPosition(barType)
		end
	end
	local function lockTestBars()
		for barType, _ in pairs(testBars) do
			P.bars[barType].unlocked = false
			A:ToggleContainerLock(barType)
		end
		O:ShowBars(container)
	end
	local function unlockTestBars()
		for barType, _ in pairs(testBars) do
			P.bars[barType].unlocked = true
			A:ToggleContainerLock(barType)
		end
		O:ShowBars(container)
	end
	-- callback for dropdown
	local function onSelect(tabGroup, barType)
		tabGroup:ReleaseChildren() -- release all existing
		attachBarOptions(tabGroup, barType) -- attach bar options
	end
	-- test bars
	local testGroup = O.attachGroup(container, "inline", "Test bars", {fullWidth = true})
	local group = O.attachGroup(testGroup, "simple", _, {fullWidth = true})
	local spacing = 10
	O.attachButton(group, "Show", 90, showTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Hide", 90, hideTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Unlock", 90, unlockTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Lock", 90, lockTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Reset", 90, resetPositions)

	-- create tabgroup
	local tabs = { {value = "auras", text = "Aura bars"}, {value = "spells", text = "Cast bars"} }
	local format = {fullWidth = true, fullHeight = true , layout = "none"}
	local tabGroup = O.attachTabGroup(container, _, format, P.bars, "barType", tabs, onSelect)
	-- attach bar options
	attachBarOptions(tabGroup, P.bars.barType)
end
