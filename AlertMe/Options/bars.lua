-- set addon environment
setfenv(1, _G.AlertMe)

--***************************************************************************
-- test bars
local testBars = {
	auras = {
		{"Hostile player", 134715, 40, false}, -- fap
		{"Friendly player", 136048, 20, true}, -- innervate
	},
	casts = {
		{"Greater Heal", 135915, 3, true}, -- greater heal
		{"Resurrection", 135955, 10, false}, -- resurrection
	}
}

------------------------------------------------------------------------------
-- attach bar options (=tab=) depending on selected barType
local function attachBarOptions(tabgroup, barType)
	tabgroup:ReleaseChildren()
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
		attachBarOptions(tabgroup, P.bars.barType)
	end
	-- enable...
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachCheckBox(group, "Enable".." "..firstLower(db.label), db ,"enabled", 160, A.InitLCC)
	O.attachCheckBox(group, "Unlock bars", db ,"unlocked", 120, containerLock)
	O.attachSpacer(tabgroup, _, "small")
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachLSM(group, "statusbar", "Bar texture", db, "texture", sliderWidth - 4, updateTestBars)
	O.attachSpacer(tabgroup, _, "medium")
	-- icon / fill
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachCheckBox(group, "Show icon", db ,"showIcon", 100, updateTestBars)
	O.attachCheckBox(group, "Show remaining", db ,"timeVisible", 135, updateTestBars)
	O.attachCheckBox(group, "Fill up (left-to-right)", db ,"fill", 140, updateTestBars)

	O.attachSpacer(tabgroup, _, "small")
	-- width/height
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachSlider(group, "Set width", db, "width", 40, 400, 5, false, sliderWidth, updateTestBars)
	O.attachSpacer(group, 20)
	O.attachSlider(group, "Set height", db, "height", 1, 50, 1, false, sliderWidth, updateTestBars)
	O.attachSpacer(tabgroup, _, "medium")
	-- spacing
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachSlider(group, "Bar spacing", db, "spacing", 0, 20, 1, false, sliderWidth, updateTestBars)
	O.attachSpacer(group, 22)
	O.attachCheckBox(group, "Grow upwards", db ,"growUp", 160, updateTestBars)
	O.attachSpacer(tabgroup, _, "large")
	-- colors
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	local width = 145
	O.attachColorPicker(group, "Bar color (good)", db, "goodColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Bar color (harm)", db, "badColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Background color", db, "backgroundColor", true, width, updateTestBars)
	O.attachSpacer(tabgroup, _, "small")
	group = O.attachGroup(tabgroup, "simple", _, {fullWidth = true})
	O.attachColorPicker(group, "Text color", db, "textColor", true, width, updateTestBars)
	O.attachColorPicker(group, "Text shadow", db, "shadowColor", true, width, updateTestBars)
	O.attachSpacer(tabgroup, _, "medium")
	--local text = (barType == "auras") and "aura"
	local tooltip = { lines = { "Reset settings for "..firstLower(db.label) } }
	O.attachButton(tabgroup, "Reset", 90, resetSettings, tooltip)
end

function O:ShowBars(container)
	container:ReleaseChildren()
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
	local function showTestBars()
		for barType, tbl in pairs(testBars) do
			for i, a in ipairs(tbl) do
				local id, loop = "testbar_"..i, true
				A:ShowBar(barType, id, a[1], a[2], a[3], a[4], loop)
			end
		end
		unlockTestBars()
	end
	local function hideTestBars()
		for barType, tbl in pairs(testBars) do
			for i, _ in ipairs(tbl) do
				local id = "testbar_"..i
				A:HideBar(barType, id)
			end
		end
		lockTestBars()
	end
	local function resetPositions()
		for barType, _ in pairs(testBars) do
			A:ResetContainerPosition(barType)
		end
	end

	-- callback for dropdown
	local function onSelect(tabgroup, barType)
		tabgroup:ReleaseChildren() -- release all existing
		attachBarOptions(tabgroup, barType) -- attach bar options
	end
	-- test bars
	local testGroup, group, tooltip
	local spacing = 10
	testGroup = O.attachGroup(container, "inline", "Test bars", {fullWidth = true})
	group = O.attachGroup(testGroup, "simple", _, {fullWidth = true})
	O.attachButton(group, "Show", 90, showTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Hide", 90, hideTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Lock", 90, lockTestBars)
	O.attachSpacer(group, spacing)
	O.attachButton(group, "Unlock", 90, unlockTestBars)
	O.attachSpacer(group, spacing)
	tooltip = { lines = { "Reset positions of all bars" } }
	O.attachButton(group, "Reset", 90, resetPositions, tooltip)
	-- create tabgroup
	local tabs = {}
	for _barType, tbl in pairs(D.profile.bars) do
		if _barType ~= "**" and type(tbl) == "table" then
			tinsert(tabs, { value = _barType, text = tbl.label } )
		end
	end
	--local tabs = { {value = "auras", text = "Aura bars"}, {value = "casts", text = "Casting bars"} }
	local format = {fullWidth = true, fullHeight = true , layout = "none"}
	local tabgroup = O.attachTabGroup(container, _, format, P.bars, "barType", tabs, onSelect)
	-- attach bar options
	attachBarOptions(tabgroup, P.bars.barType)
end
