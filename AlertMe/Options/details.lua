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
	O.Widgets.Spelltable:ReleaseChildren()
	-- get saved vars
	local db = P.alerts[handle].alertDetails[uid]
	local widget, group
	-- scroll frame
	local scrollGroup = A.Libs.AceGUI:Create("AlertMeScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	O.Widgets.Spelltable:AddChild(scrollGroup)
	-- loop over all tracked spells/auras
	for spellName, spell in pairs(db.spellNames) do
		-- rowGroup
		group = O.attachGroup(scrollGroup, "simple", _, {fullWidth = true, layout = "Flow"})
		-- delete icon
		local del = {}
		del.texture, del.tooltip = A.backgrounds["AlertMe_Delete"],  { lines = {"Delete item from spell table"} }
		del.OnClick = function(_widget)
			db.spellNames[_widget:GetUserData("spellName")] = nil
			updateSpelltable(handle, uid)
		end
		widget = O.attachIcon(group, del.texture, 18, del.OnClick, del.tooltip)
		widget:SetUserData("spellName", spellName)
		O.attachSpacer(group, 10)
		-- spell icon
		O.attachIcon(group, spell.icon, 18)
		O.attachSpacer(group, 5)
		-- spell name
		O.attachLabel(group, spellName, _, _, 162)
		if db.soundSelection == 3 then
			O.attachSpacer(group, 12)
			-- add sound
			local add = {}
			add.texture, add.tooltip = A.backgrounds["AlertMe_Add"],  { lines = {"Set an individual sound alert"} }
			add.OnClick = function(_widget)
				local _spellName = _widget:GetUserData("spellName")
				local _soundFile = db.spellNames[_spellName].soundFile
				if _spellName then O.Widgets.Soundselection:SetUserData("spellName", _spellName) end
				if _soundFile then O.Widgets.Soundselection:SetValue(_soundFile) end
				O.Widgets.Soundselection:SetDisabled(false)
			end
			widget = O.attachIcon(group, add.texture, 16, add.OnClick, add.tooltip)
			widget:SetUserData("spellName", spellName)
			O.attachSpacer(group, 10)
			-- sound label
			O.attachLabel(group, spell.soundFile, _, _, 200)
		end
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
	editBox:SetWidth(200+2)
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
	local lsm = O.attachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 178)
	lsm:SetCallback("OnValueChanged", function(widget, _, value)
		local _spellName = widget:GetUserData("spellName")
		P.alerts[handle].alertDetails[uid].spellNames[_spellName].soundFile = value
		widget:SetDisabled(true)
		widget:SetValue("")
		updateSpelltable(handle, uid)
	end)
	lsm:SetDisabled(true)
	O.Widgets.Soundselection = lsm
	O.Widgets.Soundselection:SetUserData("key", "None")
	-- spell table
	O.Widgets.Spelltable = O.attachGroup(container, "simple", _, {fullWidth = true, layout = "none", height = 105})
	updateSpelltable(handle, uid)
end

local function unitSelection(container, handle, uid)
	local db, units, order, excludes  = P.alerts[handle].alertDetails[uid]
	if A.menus[handle].unitSelection then
		O.attachHeader(container, "Unit selection")
		units, order, excludes = A.lists.units:getList(), A.lists.units:getOrder(), A.lists.excludes:getList()
		local group = O.attachGroup(container, "simple", _ , { fullWidth = true })
		if A.menus[handle].unitSelection[1] == "src" then
			O.attachDropdown(group, "Source units", db, "srcUnits", units, order, 140)
			O.attachDropdown(group, "excluding", db, "srcExclude", excludes, _, 90)
			O.attachSpacer(group, 20)
		end
		if A.menus[handle].unitSelection[2] then
			O.attachDropdown(group, "Target units", db, "dstUnits", units, order, 140)
			O.attachDropdown(group, "excluding", db, "dstExclude", excludes, _, 90)
		end
	end
end

local function displaySettings(container, handle, uid)
	local disp = A.menus[handle].displayOptions
	if not disp then return end -- no display options
	local db = P.alerts[handle].alertDetails[uid]
	local tooltip, label
	local group = O.attachGroup(container, "simple", _ , { fullWidth = true })
	O.attachHeader(group, "Display settings")
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
		O.attachSpacer(container, _, "small")
	end

end

local function openMessages(handle, uid)
	local db, tooltip = P.alerts[handle].alertDetails[uid]
	local pop = O.Popup:new("messages", "Messages for this alert", 500, 260, true, _)
	if pop then
		O.attachSpacer(pop, _, "medium")
		-- standard message
		tooltip = {	header = "Standard message"}
		tooltip.lines = { "This message will be displayed if you define nothing else", "You can edit the standard messages in Options-Messages" }
		local edit = O.attachEditBox(pop, "Standard (event) message", P.messages, handle, 1, _, tooltip)
		edit:DisableButton(true)
		edit:SetCallback("OnEnterPressed", function()end)
		O.attachSpacer(pop, _, "small")
		-- message override
		tooltip = {	header = "Message override", lines = { "Override the standard text message" } }
		O.attachEditBox(pop, "Chat message override", db, "msgOverride", 1, _, tooltip)
		-- whisper messages
		if A.menus[handle].dstWhisper then
			O.attachSpacer(pop, _, "small")
			tooltip = {	header = "Whisper message", lines = { "The message you will whisper other players" } }
			O.attachEditBox(pop, "Whisper message", db, "msgWhisper", 1, _, tooltip)
		end
	end
end

local function announceSettings(container, handle, uid)
	local db, list, order, tooltip = P.alerts[handle].alertDetails[uid]
	O.attachHeader(container, "Text & Chat")
	-- ROW 1
	local group = O.attachGroup(container, "simple", _ , { fullWidth = true } )
	-- chat channels
	list = A.lists.channels:getList()
	O.attachDropdown(group, "Announce in channel", db, "chatChannels", list, _, 140)
	O.attachSpacer(group, 20)
	-- addon/system messages
	list, order, tooltip = A.lists.addonmsg:getList(), A.lists.addonmsg:getOrder(), A.lists.addonmsg.tooltip
	O.attachDropdown(group, "Post addon messages", db, "addonMessages", list, order, 150, _, tooltip)
	-- dstwhisper
	if A.menus[handle].dstWhisper then
		O.attachSpacer(group, 20)
		list, tooltip = A.lists.dstwhisper:getList(), A.lists.dstwhisper.tooltip
		local m = O.attachDropdown(group, "Whisper dest. unit", db, "dstWhisper", list, _, 140, _, tooltip)
	end
	-- ROW 2
	group = O.attachGroup(container, "simple", _ , { fullWidth = true } )
	-- scrolling text
	O.attachCheckBox(group, "Post @Scrolling Text", db ,"scrollingText", 150)
	O.attachSpacer(group, 30)
	O.attachButton(group, "Messages...", 120, function() openMessages(handle, uid) end)
end

local function soundSettings(container, handle, uid)
	local db, list, order, tooltip = P.alerts[handle].alertDetails[uid]
	local group = O.attachGroup(container, "simple", _ , { fullWidth = true })
	local updateState = function()
		if db.soundSelection == 1 then 		-- no sound
			O.Widgets.Soundfile:SetDisabled(true)
			updateSpelltable(handle, uid)
		elseif db.soundSelection == 2 then	-- one sound
			O.Widgets.Soundfile:SetDisabled(false)
			updateSpelltable(handle, uid)
		elseif db.soundSelection == 3 then	-- individual sounds
			updateSpelltable(handle, uid)
			O.Widgets.Soundfile:SetDisabled(true)
		end
	end
	-- sound alerts
	O.attachHeader(group, "Sound alerts")
	list, order, tooltip = A.lists.soundsel:getList(), A.lists.soundsel:getOrder(), A.lists.soundsel.tooltip
	O.attachDropdown(group, "Sound alert", db, "soundSelection", list, order, 200, updateState, tooltip)
	O.attachSpacer(group, 20)
	O.Widgets.Soundfile = O.attachLSM(group, "sound", _, db, "soundFile", 178, _)
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
