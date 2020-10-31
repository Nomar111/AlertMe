-- upvalues
local GetItemIcon, GetSpellInfo = GetItemIcon, GetSpellInfo
-- set addon environment
setfenv(1, _G.AlertMe)


local function updateSpellTable(eventShort, uid)
	O.SpellTable:ReleaseChildren()
	-- local variables
	local db = P.alerts[eventShort].alertDetails[uid]
	-- scroll frame
	local scrollGroup = A.Libs.AceGUI:Create("AlertMeScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	O.SpellTable:AddChild(scrollGroup)
	-- loop over all tracked spells/auras
	for spellName, tbl in pairs(db.spellNames) do
		-- rowGroup
		local rowGroup = O.attachGroup(scrollGroup, "simple", _, {fullWidth = true, layout = "Flow"})
		-- delete spell icon
		local del = {}
		del.texture, del.tooltip = A.backgrounds["AlertMe_Delete"],  { lines = {"Delete spell/aurable"} }
		del.onClick = function(widget)
			db.spellNames[widget:GetUserData("spellName")] = nil
			updateSpellTable(eventShort, uid)
		end
		local iconDelSpell = O.attachIcon(rowGroup, del.texture, 18, del.onClick, del.tooltip)
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
		add.onClick = function(widget)
			local _spellName = widget:GetUserData("spellName")
			local _soundFile = db.spellNames[_spellName].soundFile
			if _spellName  then O.SoundSelection:SetUserData("spellName", _spellName) end
			if _soundFile then O.SoundSelection:SetValue(_soundFile) end
			O.SoundSelection:SetDisabled(false)
		end
		local iconAddSound = O.attachIcon(rowGroup, add.texture, 16, add.onClick, add.tooltip)
		iconAddSound:SetUserData("spellName", spellName)
		O.attachSpacer(rowGroup, 10)
		-- sound label
		O.attachLabel(rowGroup, tbl.soundFile, _, _, 200)
	end
end

local function spellSelection(container, eventShort, uid)
	if not A.EventsShort[eventShort].spellSelection then return end
	O.attachHeader(container, "Spell/Aura settings")
	local db = P.alerts[eventShort].alertDetails[uid]
	local spellGroup = O.attachGroup(container, "simple", _, {fullWidth = true, layout = "Flow"})

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
	O.attachSpacer(spellGroup,20)
	local lsm = O.attachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 207)
	lsm:SetCallback("OnValueChanged", function(widget, _, value)
		local _spellName = widget:GetUserData("spellName")
		P.alerts[eventShort].alertDetails[uid].spellNames[_spellName].soundFile = value
		widget:SetDisabled(true)
		widget:SetValue("")
		updateSpellTable(eventShort, uid)
	end)
	lsm:SetDisabled(true)
	O.SoundSelection = lsm
	O.SoundSelection:SetUserData("key", "None")
	-- spell table
	O.SpellTable = O.attachGroup(container, "simple", _, {fullWidth = true, layout = "none", height = 105})
	updateSpellTable(eventShort, uid)
end

local function unitSelection(container, eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	-- unit selection
	if A.EventsShort[eventShort].unitSelection then
		O.attachHeader(container, "Unit selection")
		local unitsList = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself", [6] = "All entities"}
		local excludeList = {[1] = "---", [2] = "Myself", [3] = "Target"}
		local unitsGroup = O.attachGroup(container, "simple", _ , { fullWidth = true })
		if A.EventsShort[eventShort].units[1] == "src" then
			O.attachDropdown(unitsGroup, "Source units", db, "srcUnits", unitsList, 140)
			O.attachDropdown(unitsGroup, "excluding", db, "srcExclude", excludeList, 100)
		end
		if A.EventsShort[eventShort].units[2] and A.EventsShort[eventShort].units[2] == "dst" then
			O.attachSpacer(unitsGroup, 20)
			O.attachDropdown(unitsGroup, "Target units", db, "dstUnits", unitsList, 140)
			O.attachDropdown(unitsGroup, "excluding", db, "dstExclude", excludeList, 100)
		end
	end
end

local function displaySettings(container, eventShort, uid)
	if not A.EventsShort[eventShort].displaySettings.enabled then return end
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	-- display settings
	local displayGroup = O.attachGroup(container, "simple", _ , { fullWidth = true })
	O.attachHeader(displayGroup, "Display settings")
	if A.EventsShort[eventShort].displaySettings.bar then
		local label = "Show "..A.EventsShort[eventShort].displaySettings.barTypeText
		O.attachCheckBox(displayGroup, label, db, "showBar", 150)
	end
	if A.EventsShort[eventShort].displaySettings.glow then
		O.attachSpacer(displayGroup, 9)
		local glowList = {[-1]="No glow",[1]="Glow Preset 1",[2]="Glow Preset 2",[3]="Glow Preset 3",[4]="Glow Preset 4",[5]="Glow Preset 5",[6]="Glow Preset 6",[7]="Glow Preset 7",[8]="Glow Preset 8"}
		tooltip = {
			header = "Enable glow on unitframes",
			lines = { "Works for friendly unitframes by default", "Also works for enemy uniframes if using BGTC*", "*BattlegrounndTargets Classic" },
		}
		O.attachDropdown(displayGroup, _, db, "showGlow", glowList, 150, _, tooltip)
	end

end

local function announceSettings(container, eventShort, uid)
	local db = P.alerts[eventShort].alertDetails[uid]
	-- announce settings
	O.attachHeader(container, "Text alerts")
	local announceGroup = O.attachGroup(container, "simple", _ , { fullWidth = true } )
	-- chat channels
	local list = { [1] = "Don't announce", [2] = "BG > Raid > Party", [3] = "Party", [4] = "Say" }
	O.attachDropdown(announceGroup, "Announce in channel", db, "chatChannels", list, 140)
	O.attachSpacer(announceGroup, 20)
	-- addon messages
	list = { [1] = "Always", [2] = "Never", [3] = "If chan not available" }
	local tooltip = {header = "Addon messages", lines = {"Addon messages are only visible to yourself", "Chat windows are setup in 'Messages'"} }
	O.attachDropdown(announceGroup, "Post addon messages", db, "addonMessages", list, 150, _, tooltip)
	-- destination whisper
	if A.EventsShort[eventShort].dstWhisper then
		O.attachSpacer(announceGroup, 20)
		list = { [1] = "Don't whisper", [2] = "Whisper if cast by me",  [3] = "Whisper" }
		O.attachDropdown(announceGroup, "Whisper dest. unit", db, "dstWhisper", list, 160)
	end
	O.attachSpacer(container, _, "small")
	-- scrolling text
	tooltip = {	header = "Scrolling Text",lines = { "Post messages to Scrolling Text" } }
	O.attachCheckBox(container, "Post in Scrolling Text", db ,"scrollingText", 180, _, tooltip)
	O.attachSpacer(container, _, "small")
	-- message override
	tooltip = {	header = "Message override", lines = { "Set an alternative chat message","If empty, (event) standard will be used" } }
	O.attachEditBox(container, "Chat message override", db, "msgOverride", 1, _, tooltip)
end

local function soundSettings(container, eventShort, uid)
	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local soundGroup = O.attachGroup(container, "simple", _ , { fullWidth = true })
	local updateState = function()
		if O.SoundSelectionDefault:GetValue() ~= 2 then
			O.SoundFile:SetDisabled(true)
		else
			O.SoundFile:SetDisabled(false)
		end
	end
	-- sound alerts
	O.attachHeader(soundGroup, "Sound alerts")
	local list = { [1] = "No sound alerts", [2] = "Play one sound", [3] = "Play individual sounds" }
	local tooltip = { lines = { "Set alerts in the spell table" } }
	O.SoundSelectionDefault = O.attachDropdown(soundGroup, "Sound alert", db, "soundSelection", list, 245, updateState, tooltip)
	O.attachSpacer(soundGroup, 20)
	O.SoundFile = O.attachLSM(soundGroup, "sound", _, db, "soundFile", _, _)
	updateState()
end

function O:showAlertDetails(container, eventShort, uid)
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
