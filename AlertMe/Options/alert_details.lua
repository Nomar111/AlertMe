-- get engine environment
local A, O = unpack(select(2, ...))
-- upvalues
local _G, GetItemIcon = _G, GetItemIcon
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowAlertDetails(container, eventShort, uid)
	dprint(3, "O:ShowAlertDetails", eventShort, uid)
	local db = P.alerts[eventShort].alertDetails[uid]
	-- spell selection
	if A.EventsShort[eventShort].spellSelection == true then
		O.AttachHeader(container, "Spell/Aura settings")
		O:ShowSpellSelection(container, eventShort, uid, db)
		O:InitSpellTable(container, eventShort, uid, db)
		O:UpdateSpellTable(eventShort, uid, db)
	end
	-- unit selection
	O:ShowUnitSelection(container, eventShort, uid)
	-- display settings
	O:ShowDisplaySettings(container, eventShort, uid)
	-- announce settings
	O:ShowAnnounceSettings(container, eventShort, uid)
	-- sound alerts
	O:ShowSoundSettings(container, eventShort, uid)
end

function O:ShowUnitSelection(container, eventShort, uid)
	dprint(3, "O:ShowUnitSelection", eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	-- unit selection
	if A.EventsShort[eventShort].unitSelection == true then
		O.AttachHeader(container, "Unit selection")
		local unitsList = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself", [6] = "All entities"}
		local excludeList = {[1] = "---", [2] = "Myself", [3] = "Target"}
		local unitsGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
		if A.EventsShort[eventShort].units[1] == "src" then
			O.AttachDropdown(unitsGroup, "Source units", db, "srcUnits", unitsList, 140)
			O.AttachDropdown(unitsGroup, "excluding", db, "srcExclude", excludeList, 100)
		end
		if A.EventsShort[eventShort].units[2] ~= nil and A.EventsShort[eventShort].units[2] == "dst" then
			O.AttachSpacer(unitsGroup, 20)
			O.AttachDropdown(unitsGroup, "Target units", db, "dstUnits", unitsList, 140)
			O.AttachDropdown(unitsGroup, "excluding", db, "dstExclude", excludeList, 100)
		end
	end
end

function O:ShowDisplaySettings(container, eventShort, uid)
	dprint(3, "O:ShowDisplaySettings", eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local glowList = {[1]="Glow Preset 1",[2]="Glow Preset 2",[3]="Glow Preset 3",[4]="Glow Preset 4",[5]="Glow Preset 5",[6]="Glow Preset 6",[7]="Glow Preset 7",[8]="Glow Preset 8"}
	-- display settings
	if A.EventsShort[eventShort].displaySettings == true then
		local displayGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
		O.AttachHeader(displayGroup, "Display settings")
		O.AttachCheckBox(displayGroup, "Show progress bar", db, "showBar", 150)
		O.AttachSpacer(displayGroup, 20)
		O.AttachDropdown(displayGroup, "Glow unitframe", db, "showGlow", glowList, 220)
	end
end

function O:ShowAnnounceSettings(container, eventShort, uid)
	dprint(3, "O:ShowAnnounceSettings", eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	-- announce settings
	O.AttachHeader(container, "Text alerts")
	local announceGroup = O.AttachGroup(container, "simple", _ , { fullWidth = true })
	local channelList = {[1] = "Don't announce", [2] = "BG > Raid > Party", [3] = "Party", [4] = "Say"}
	-- chat channels
	O.AttachDropdown(announceGroup, "Announce in channel", db, "chatChannels", channelList, 140)
	O.AttachSpacer(announceGroup, 20)
	-- addon messages
	local systemList = {[1] = "Always", [2] = "Never", [3] = "If channel not available"}
	local toolTip = {
		header = "Addon messages",
		lines = {"Addon messages are only visible to yourself", "Chat windows are setup in 'Messages'"},
		wrap = false
	}
	O.AttachDropdown(announceGroup, "Post addon messages", db, "addonMessages", systemList, 170, _, toolTip)
	-- dstwhisper
	if A.EventsShort[eventShort].dstWhisper == true then
		local whisperList = {[1] = "Don't whisper", [2] = "Whisper if cast by me",  [3] = "Whisper"}
		O.AttachSpacer(announceGroup, 20)
		O.AttachDropdown(announceGroup, "Whisper destination unit", db, "dstWhisper", whisperList, 160)
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

function O:ShowSoundSettings(container, eventShort, uid)
	dprint(3, "O:ShowSoundSettings", eventShort, uid)
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

function O:ShowSpellSelection(container, eventShort, uid)
	dprint(3, "O:ShowSpellSelection", eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	--local spellGroup = O:AttachGroup(container, _, _, 1, _, "Flow")
	local spellGroup = O.AttachGroup(container, "simple", _, {fullWidth = true, layout = "Flow"})
	-- spell edit box
	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	editBox:SetLabel("Add "..A.EventsShort[eventShort].type.." to be tracked")
	editBox:SetWidth(232)
	editBox:SetCallback("OnEnterPressed", function(widget, event, text)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name ~= nil and name == text then
				db.spellNames[text]["icon"] = icon
				O:UpdateSpellTable(eventShort, uid, db)
			end
		end
		editBox:SetText("")
	end)
	spellGroup:AddChild(editBox)
	O.AttachSpacer(spellGroup,20)
	-- sound selection per spell
	local soundSelection = O.AttachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 207)
	soundSelection:SetCallback("OnValueChanged", function(widget, _, value)
		local spellName = widget:GetUserData("spellName")
		local _db = db.spellNames[spellName]
		local _key = widget:GetUserData("key")
		_db[_key] = value
		widget:SetDisabled(true)
		widget:SetValue("")
		O:UpdateSpellTable(eventShort, uid)
	end)
	soundSelection:SetDisabled(true)
	O.SoundSelection = soundSelection
	O.SoundSelection:SetUserData("key", "soundFile")
end

function O:InitSpellTable(container, eventShort, uid, db)
	dprint(3, "O:InitSpellTable")
	O.SpellTable = O.AttachGroup(container, "simple", _, {fullWidth = true, layout = "none", height = 105})
end

function O:UpdateSpellTable(eventShort, uid)
	dprint(3, "O:UpdateSpellTable", eventShort, uid)
	O.SpellTable:ReleaseChildren()
	-- local variables and functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local iconAdd = A.Backgrounds["AlertMe_Add"]
	local iconDel =  A.Backgrounds["AlertMe_Delete"]
	local btnDelSpellToolTip = {lines={"Delete spell/aura"}}
	local btnAddSoundToolTip = {lines={"Set an individual sound alert"}}
	-- delete
	local function btnDelSpellOnClick(self)
		dprint(3, "btnDelSpellOnClick", self)
		local spellName = self:GetUserData("spellName")
		db.spellNames[spellName] = nil
		O:UpdateSpellTable(eventShort, uid)
	end
	-- add
	local function btnAddSoundOnClick(self)
		dprint(3, "btnAddSoundOnClick", self)
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
