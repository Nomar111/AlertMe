-- set addon environment
setfenv(1, _G.AlertMe)

local function getGlowList()
	local ret = {}
	ret[-1] = "No glow"
	for i=1, 8 do
		if P.glow[i].name == "Glow Preset" then
			P.glow[i].name = "Glow Preset "..i
		end
		ret[i] = P.glow[i].name
	end
	return ret
end

local function updateSpelltable(handle, uid)
	O.Spelltable:ReleaseChildren()
	-- get saved vars
	local db = P.alerts[handle].alertDetails[uid]
	-- scroll frame
	local scrollGroup = A.Libs.AceGUI:Create("AlertMeScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	O.Spelltable:AddChild(scrollGroup)
	-- loop over all tracked spells/auras
	for spellName, tbl in pairs(db.spellNames) do
		-- rowGroup
		local rowGroup = O.attachGroup(scrollGroup, "simple", _, {fullWidth = true, layout = "Flow"})
		-- delete spell icon
		local del = {}
		del.texture, del.tooltip = A.backgrounds["AlertMe_Delete"],  { lines = {"Delete item from spell table"} }
		del.OnClick = function(widget)
			db.spellNames[widget:GetUserData("spellName")] = nil
			updateSpelltable(handle, uid)
		end
		local iconDelSpell = O.attachIcon(rowGroup, del.texture, 18, del.OnClick, del.tooltip)
		iconDelSpell:SetUserData("spellName", spellName)
		O.attachSpacer(rowGroup, 10)
		-- spell/aura icon & spellname
		O.attachIcon(rowGroup, tbl.icon, 18)
		O.attachSpacer(rowGroup, 5)
		-- spell/aura name
		O.attachLabel(rowGroup, spellName, _, _, 190)
		O.attachSpacer(rowGroup, 12)
		-- add sound
		local add = {}
		add.texture, add.tooltip = A.backgrounds["AlertMe_Add"],  { lines = {"Set an individual sound alert"} }
		add.OnClick = function(widget)
			local _spellName = widget:GetUserData("spellName")
			local _soundFile = db.spellNames[_spellName].soundFile
			if _spellName  then O.Soundselection:SetUserData("spellName", _spellName) end
			if _soundFile then O.Soundselection:SetValue(_soundFile) end
			O.Soundselection:SetDisabled(false)
		end
		local iconAddSound = O.attachIcon(rowGroup, add.texture, 16, add.OnClick, add.tooltip)
		iconAddSound:SetUserData("spellName", spellName)
		O.attachSpacer(rowGroup, 10)
		-- sound label
		O.attachLabel(rowGroup, tbl.soundFile, _, _, 200)
	end
end

local function spellSelection(container, handle, uid)
	if not A.menus[handle].spellSelection then return end
	O.attachHeader(container, "Spell/Aura settings")
	local db = P.alerts[handle].alertDetails[uid]
	local spellGroup = O.attachGroup(container, "simple", _, {fullWidth = true, layout = "Flow"})
	-- spell edit box
	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	local text = A.menus[handle].type or ""
	editBox:SetLabel("Add".." "..text)
	editBox:SetWidth(232)
	editBox:SetCallback("OnEnterPressed", function(widget, event, input)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name ~= nil and name == input then
				db.spellNames[name]["icon"] = icon
				updateSpelltable(handle, uid, db)
			end
		end
		editBox:SetText("")
	end)
	spellGroup:AddChild(editBox)
	O.attachSpacer(spellGroup,20)
	local lsm = O.attachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 207)
	lsm:SetCallback("OnValueChanged", function(widget, _, value)
		local _spellName = widget:GetUserData("spellName")
		P.alerts[handle].alertDetails[uid].spellNames[_spellName].soundFile = value
		widget:SetDisabled(true)
		widget:SetValue("")
		updateSpelltable(handle, uid)
	end)
	lsm:SetDisabled(true)
	O.Soundselection = lsm
	O.Soundselection:SetUserData("key", "None")
	-- spell table
	O.Spelltable = O.attachGroup(container, "simple", _, {fullWidth = true, layout = "none", height = 105})
	updateSpelltable(handle, uid)
end

local function unitSelection(container, handle, uid)
	local db, units, order, excludes  = P.alerts[handle].alertDetails[uid]
	if A.menus[handle].unitSelection then
		O.attachHeader(container, "Unit selection")
		units, order, excludes = A.lists.units:getList(), A.lists.units:getOrder(), A.lists.excludes:getList()
		local unitsGroup = O.attachGroup(container, "simple", _ , { fullWidth = true })
		if A.menus[handle].unitSelection[1] == "src" then
			O.attachDropdown(unitsGroup, "Source units", db, "srcUnits", units, order, 140)
			O.attachDropdown(unitsGroup, "excluding", db, "srcExclude", excludes, _, 100)
		end
		if A.menus[handle].unitSelection[2] then
			O.attachSpacer(unitsGroup, 20)
			O.attachDropdown(unitsGroup, "Target units", db, "dstUnits", units, order, 140)
			O.attachDropdown(unitsGroup, "excluding", db, "dstExclude", excludes, _, 100)
		end
	end
end

local function displaySettings(container, handle, uid)
	local disp = A.menus[handle].displayOptions
	if not disp then return end -- no display options
	local db = P.alerts[handle].alertDetails[uid]
	local tooltip, label
	local group = O.attachGroup(container, "simple", _ , { fullWidth = true })
	O.attachHeader(displayGroup, "Display settings")
	-- show progress bar
	if disp.bar then
		label = disp.barText or "progress bars"
		label = "Show "..label
		O.attachCheckBox(group, label, db, "showBar", 150)
	end
	if disp.bar and disp.glow then
		O.attachSpacer(group, 9)
	end
	-- show glow
	if disp.glow then
		tooltip = { header = "Glow on uniframes", lines = { "Glow presets can bet edited in Options-Glow" } }
		O.attachDropdown(group, _, db, "showGlow", getGlowList(), _, 150, _, tooltip)
	end
end

local function announceSettings(container, handle, uid)
	local db, list, order, tooltip = P.alerts[handle].alertDetails[uid]
	-- announce settings
	O.attachHeader(container, "Text alerts")
	local announceGroup = O.attachGroup(container, "simple", _ , { fullWidth = true } )
	-- chat channels
	list = A.lists.channels:getList()
	O.attachDropdown(announceGroup, "Announce in channel", db, "chatChannels", list, _, 140)
	O.attachSpacer(announceGroup, 20)
	-- addon/system messages
	list, order, tooltip = A.lists.addonmsg:getList(), A.lists.addonmsg:getOrder(), A.lists.addonmsg.tooltip
	O.attachDropdown(announceGroup, "Post addon messages", db, "addonMessages", list, order, 150, _, tooltip)
	-- dstwhisper
	if A.menus[handle].dstWhisper then
		O.attachSpacer(announceGroup, 20)
		list = A.lists.dstwhisper:getList()
		O.attachDropdown(announceGroup, "Whisper dest. unit", db, "dstWhisper", list, _, 160)
	end
	O.attachSpacer(container, _, "small")
	-- scrolling text
	O.attachCheckBox(container, "Post in Scrolling Text", db ,"scrollingText", 180)
	O.attachSpacer(container, _, "small")
	-- message override
	tooltip = {	header = "Message override", lines = { "Override the standard text message" } }
	O.attachEditBox(container, "Chat message override", db, "msgOverride", 1, _, tooltip)
end

local function soundSettings(container, handle, uid)
	local db, list, order, tooltip = P.alerts[handle].alertDetails[uid]
	local soundGroup = O.attachGroup(container, "simple", _ , { fullWidth = true })
	local updateState = function()
		if O.SoundselectionDefault:GetValue() ~= 2 then
			O.Soundfile:SetDisabled(true)
		else
			O.Soundfile:SetDisabled(false)
		end
	end
	-- sound alerts
	O.attachHeader(soundGroup, "Sound alerts")
	list, order, tooltip = A.lists.soundsel:getList(), A.lists.soundsel:getOrder(), A.lists.soundsel.tooltip
	O.SoundselectionDefault = O.attachDropdown(soundGroup, "Sound alert", db, "soundSelection", list, order, 225, updateState, tooltip)
	O.attachSpacer(soundGroup, 20)
	O.Soundfile = O.attachLSM(soundGroup, "sound", _, db, "soundFile", _, _)
	updateState()
end

function O:ShowAlertDetails(container, handle, uid)
	local db = P.alerts[handle].alertDetails[uid]
	-- spell selection
	spellSelection(container, handle, uid)
	-- unit selection
	unitSelection(container, handle, uid)
	-- display settings
	displaySettings(container, handle, uid)
	-- announce settings
	announceSettings(container, handle, uid)
	-- sound alerts
	soundSettings(container, handle, uid)
end
