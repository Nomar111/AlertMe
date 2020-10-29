-- upvalues
local GetItemIcon, GetSpellInfo = GetItemIcon, GetSpellInfo
-- set addon environment
setfenv(1, _G.AlertMe)

local function updateSpellTable(eventShort, uid)
	O.SpellTable:ReleaseChildren()
	-- local variables and functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local iconAdd = A.Backgrounds["AlertMe_Add"]
	local iconDel =  A.Backgrounds["AlertMe_Delete"]
	local btnDelSpellToolTip = {lines={"Delete spell/aura"}}
	local btnAddSoundToolTip = {lines={"Set an individual sound alert"}}
	-- delete
	local function btnDelSpellOnClick(self)
		local spellName = self:GetUserData("spellName")
		db.spellNames[spellName] = nil
		updateSpellTable(eventShort, uid)
	end
	-- add
	local function btnAddSoundOnClick(self)
		local spellName = self:GetUserData("spellName")
		O.SoundSelection:SetUserData("spellName", spellName)
		local soundFile = db.spellNames[spellName].soundFile
		if soundFile ~= "" then O.SoundSelection:SetValue(soundFile) end
		O.SoundSelection:SetDisabled(false)
	end
	-- scroll frame
	local scrollGroup = A.Libs.AceGUI:Create("AlertMeScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	O.SpellTable:AddChild(scrollGroup)
	-- loop over all tracked spells/auras
	for spellName, tbl in pairs(db.spellNames) do
		-- rowGroup
		local rowGroup = O.AttachGroup(scrollGroup, "simple", _, {fullWidth = true, layout = "Flow"})
		-- delete spell icon
		local btnDelSpell = O.AttachIcon(rowGroup, iconDel, 18, btnDelSpellOnClick, btnDelSpellToolTip, btnDelSpellUserData)
		btnDelSpell:SetUserData("spellName", spellName)
		O.AttachSpacer(rowGroup, 10)
		-- spell/aura icon & spellname
		O.AttachIcon(rowGroup, tbl.icon, 18)
		O.AttachSpacer(rowGroup, 5)
		-- spell/aura name
		O.AttachLabel(rowGroup, spellName, _, _, 190)
		O.AttachSpacer(rowGroup, 12)
		-- add sound
		local btnAddSound = O.AttachIcon(rowGroup, iconAdd, 16, btnAddSoundOnClick, btnAddSoundToolTip)
		btnAddSound:SetUserData("spellName", spellName)
		O.AttachSpacer(rowGroup, 10)
		-- sound label
		O.AttachLabel(rowGroup, tbl.soundFile, _, _, 200)
	end
end

local function spellSelection(container, eventShort, uid)
	if not A.EventsShort[eventShort].spellSelection then return end
	O.AttachHeader(container, "Spell/Aura settings")
	local db = P.alerts[eventShort].alertDetails[uid]
	local spellGroup = O.AttachGroup(container, "simple", _, {fullWidth = true, layout = "Flow"})
	--*********************************************************************************************************************
	-- spell edit box
	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	editBox:SetLabel("Add "..A.EventsShort[eventShort].type.." to be tracked")
	editBox:SetWidth(232)
	editBox:SetCallback("OnEnterPressed", function(widget, event, text)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name ~= nil and name == text then
				db.spellNames[text]["icon"] = icon
				updateSpellTable(eventShort, uid, db)
			end
		end
		editBox:SetText("")
	end)
	spellGroup:AddChild(editBox)
	O.AttachSpacer(spellGroup,20)
	-- sound selection drowdown (per spell)
	local soundSelection = O.AttachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 207)
	soundSelection:SetCallback("OnValueChanged", function(widget, _, value)
		local spellName = widget:GetUserData("spellName")
		local _db = db.spellNames[spellName]
		local _key = widget:GetUserData("key")
		_db[_key] = value
		widget:SetDisabled(true)
		widget:SetValue("")
		updateSpellTable(eventShort, uid)
	end)
	soundSelection:SetDisabled(true)
	O.SoundSelection = soundSelection
	O.SoundSelection:SetUserData("key", "soundFile")
	--*********************************************************************************************************************
	-- spell table
	O.SpellTable = O.AttachGroup(container, "simple", _, {fullWidth = true, layout = "none", height = 105})
	updateSpellTable(eventShort, uid)
end

local function unitSelection(container, eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	-- unit selection
	if A.EventsShort[eventShort].unitSelection then
		O.AttachHeader(container, "Unit selection")
		local unitsList = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself", [6] = "All entities"}
		local excludeList = {[1] = "---", [2] = "Myself", [3] = "Target"}
		local unitsGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
		if A.EventsShort[eventShort].units[1] == "src" then
			O.AttachDropdown(unitsGroup, "Source units", db, "srcUnits", unitsList, 140)
			O.AttachDropdown(unitsGroup, "excluding", db, "srcExclude", excludeList, 100)
		end
		if A.EventsShort[eventShort].units[2] and A.EventsShort[eventShort].units[2] == "dst" then
			O.AttachSpacer(unitsGroup, 20)
			O.AttachDropdown(unitsGroup, "Target units", db, "dstUnits", unitsList, 140)
			O.AttachDropdown(unitsGroup, "excluding", db, "dstExclude", excludeList, 100)
		end
	end
end

local function displaySettings(container, eventShort, uid)
	if not A.EventsShort[eventShort].displaySettings.enabled then return end
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local glowList = {[-1]="No Glow",[1]="Glow Preset 1",[2]="Glow Preset 2",[3]="Glow Preset 3",[4]="Glow Preset 4",[5]="Glow Preset 5",[6]="Glow Preset 6",[7]="Glow Preset 7",[8]="Glow Preset 8"}
	local ttGlow = {
		header = "Enable glow on unitframes",
		lines = {"Works for friendly unitframes by default", "Also works for enemy uniframes if using BattleGroundTargets Classic"},
		wrap = false
	}
	-- display settings
	local displayGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
	O.AttachHeader(displayGroup, "Display settings")
	if A.EventsShort[eventShort].displaySettings.bar then
		local label = "Show "..A.EventsShort[eventShort].displaySettings.barTypeText
		O.AttachCheckBox(displayGroup, label, db, "showBar", 150)
	end
	if A.EventsShort[eventShort].displaySettings.glow then
		O.AttachSpacer(displayGroup, 9)
		O.AttachDropdown(displayGroup, _, db, "showGlow", glowList, 150, _, ttGlow)
	end
end

local function announceSettings(container, eventShort, uid)
	local db = P.alerts[eventShort].alertDetails[uid]
	-- announce settings
	O.AttachHeader(container, "Text alerts")
	local announceGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
	local channelList = {[1] = "Don't announce", [2] = "BG > Raid > Party", [3] = "Party", [4] = "Say"}
	-- chat channels
	O.AttachDropdown(announceGroup, "Announce in channel", db, "chatChannels", channelList, 140)
	O.AttachSpacer(announceGroup, 20)
	-- addon messages
	local systemList = {[1] = "Always", [2] = "Never", [3] = "If chan not available"}
	local toolTip = {
		header = "Addon messages",
		lines = {"Addon messages are only visible to yourself", "Chat windows are setup in 'Messages'"},
		wrap = false
	}
	O.AttachDropdown(announceGroup, "Post addon messages", db, "addonMessages", systemList, 150, _, toolTip)
	-- dstwhisper
	if A.EventsShort[eventShort].dstWhisper == true then
		local whisperList = {[1] = "Don't whisper", [2] = "Whisper if cast by me",  [3] = "Whisper"}
		O.AttachSpacer(announceGroup, 20)
		O.AttachDropdown(announceGroup, "Whisper dest. unit", db, "dstWhisper", whisperList, 160)
	end
	-- scrolling text
	toolTip = {
		header = "Scrolling Text",
		lines = {"Post messages to Scrolling Text"},
		wrap = false
	}
	O.AttachSpacer(container, _, "small")
	O.AttachCheckBox(container, "Post in Scrolling Text", db ,"scrollingText", 180, _, toolTip)
	O.AttachSpacer(container, _, "small")
	-- message override
	toolTip = {
		header = "Message override",
		lines = {"Set an alternative chat message","If empty, (event) standard will be used"},
		wrap = false
	}
	O.AttachEditBox(container, "Chat message override", db, "msgOverride", 1, _, toolTip)
end

local function soundSettings(container, eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local soundGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
	-- update states
	local function updateState()
		if O.SoundSelectionDefault:GetValue() ~= 2 then
			O.SoundFile:SetDisabled(true)
		else
			O.SoundFile:SetDisabled(false)
		end
	end
	-- sound alerts
	O.AttachHeader(soundGroup, "Sound alerts")
	local list = {[1] = "No sound alerts", [2] = "Play one sound alert for all spells", [3] = "Play individual sound alerts per spell"}
	local toolTip = {lines = {"Set alerts per spell in the spell table"}, wrap = false}
	O.SoundSelectionDefault = O.AttachDropdown(soundGroup, "Sound alert", db, "soundSelection", list, 245, updateState, toolTip)
	O.AttachSpacer(soundGroup, 20)
	O.SoundFile = O.AttachLSM(soundGroup, "sound", _, db, "soundFile", _, _)
	updateState()
end

function O:ShowAlertDetails(container, eventShort, uid)
	local db = P.alerts[eventShort].alertDetails[uid]
	-- spell selection
	spellSelection(container, eventShort, uid)
	-- unit selection
	unitSelection(container, eventShort, uid)
	-- display settings
	displaySettings(container, eventShort, uid)
	-- announce settings
	announceSettings(container, eventShort, uid)
	-- sound alerts
	soundSettings(container, eventShort, uid)
end
