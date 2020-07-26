dprint(3, "alert_details.lua")
-- upvalues
local _G, GetItemIcon, GetSpellInfo = _G, GetItemIcon, GetSpellInfo
--local GameTooltip, GetSpellInfo = GameTooltip, GetSpellInfo
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:ShowAlertDetails(container, eventShort, uid)
	dprint(2, "O:DrawAlertDetails", container, eventShort, uid)
	--VDT_AddData(container, "container")
	local db = P.alerts[eventShort].alertDetails[uid]
	-- spell selection
	if A.EventsShort[eventShort].spellSelection == true then
		O:AttachHeader(container, "Spell/Aura settings")
		O:AttachSpellSelection(container, eventShort, uid, db)
		O:InitSpellTable(container, eventShort, uid, db)
		O:UpdateSpellTable(eventShort, uid, db)
	end
	--[[
	-- unit selection
	if A:GetEventSettingByShort(event, "unit_selection") == true then
		O:AttachHeader(container, "Unit selection")
		local units_list = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself"}
		local exclude_list = {[1] = "---", [2] = "Myself", [3] = "Target"}
		if A:GetEventSettingByShort(event, "source_units") == true then
			O:AttachDropdown(container, "Source units", db, "srcUnits", units_list, 160)
			O:AttachDropdown(container, "excluding", db, "srcExclude", exclude_list, 100)
		end
		if A:GetEventSettingByShort(event, "target_units") == true then
			O:AttachSpacer(container, 80)
			O:AttachDropdown(container, "Target units", db, "dstUnits", units_list, 160)
			O:AttachDropdown(container, "excluding", db, "dstExclude", exclude_list, 100)
		end
	end
	-- display settings
	if A:GetEventSettingByShort(event, "display_settings") == true then
		O:AttachHeader(container, "Display settings")
		O:AttachCheckBox(container, "Show progress bar", db, "show_bar", 150)
	end
	-- announce settings
	O:AttachHeader(container, "Chat announcements, Addon messages, AlertMe Text")
	local chat_channels = {[1] = "Don't announce", [2] = "BG > Raid > Party", [3] = "Party", [4] = "Say"}
	O:AttachDropdown(container, "Announce in chat channel", db, "chat_channels", chat_channels, 160)
	O:AttachSpacer(container, 30)
	local system_messages = {[1] = "Always", [2] = "Never", [3] = "If BG/Raid/Party/Say not available"}
	local addon_messages_dd = O:AttachDropdown(container, "Post addon messages", db, "system_messages", system_messages, 230)
	addon_messages_dd:SetCallback("OnEnter", function(widget)
		O.tooltip = O.tooltip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
		O.tooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		--O.tooltip:SetText("Addon messages will be posted in configured chat frames", 1, .82, 0, true)
		O.tooltip:AddLine("Addon messages will be posted in configured chat frames", 1, .82, 0, true)
		O.tooltip:AddLine("See General Options", 1, 1, 1, true)
		--O.tooltip:SetFontObject(GameFontHighlightSmall)
		O.tooltip:Show()
	end)
	addon_messages_dd:SetCallback("OnLeave", function(widget)
		O.tooltip:Hide()
	end)
	if A:GetEventSettingByShort(event, "whisper_destination") == true then
		O:AttachSpacer(container, 30)
		local whisper_destination = {[1] = "Don't whisper", [2] = "Whisper if spell is cast by me",  [3] = "Whisper"}
		O:AttachDropdown(container, "Whisper destination unit (if friendly)", db, "whisper_destination", whisper_destination, 200)
	end
	local scrolling_text_cb = O:AttachCheckBox(container, "Post in scrolling text frame", db ,"scrolling_text", 220)
	scrolling_text_cb:SetCallback("OnEnter", function(widget)
		O.tooltip = O.tooltip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
		O.tooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		--O.tooltip:SetText("Addon messages will be posted in configured chat frames", 1, .82, 0, true)
		O.tooltip:AddLine("See General Options for scrolling text setup", 1, .82, 0, true)
		--O.tooltip:SetFontObject(GameFontHighlightSmall)
		O.tooltip:Show()
	end)
	scrolling_text_cb:SetCallback("OnLeave", function(widget)
		O.tooltip:Hide()
	end)
	O:AttachEditBox(container, "Chat message override", db, "override", 420)
	-- sound alerts
	O:AttachHeader(container, "Sound alerts")
	local sound_selection_list = {[1] = "No sound alerts", [2] = "Play one sound alert for all spells", [3] = "Play individual sound alerts per spell"}
	local sound_selection_dd = O:AttachDropdown(container, "Sound alert", db, "sound_selection", sound_selection_list, 250)
	sound_selection_dd:SetCallback("OnEnter", function(widget)
		O.tooltip = O.tooltip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
		O.tooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		--O.tooltip:SetText("Addon messages will be posted in configured chat frames", 1, .82, 0, true)
		O.tooltip:AddLine("Set alerts per spell by clicking on the spell name in the above table", 1, .82, 0, true)
		--O.tooltip:SetFontObject(GameFontHighlightSmall)
		O.tooltip:Show()
	end)
	sound_selection_dd:SetCallback("OnLeave", function(widget)
		O.tooltip:Hide()
	end)
	O:AttachSpacer(container, 92)
	local sound_file_dd = A.Libs.AceGUI:Create("LSM30_Sound")
	sound_file_dd:SetList(A.LSM:HashTable("sound"))
	sound_file_dd:SetCallback("OnValueChanged", function(widget, _, value)
		widget:SetValue(value)
		db.sound_file = value
	end)
	if db.sound_file ~= "" then sound_file_dd:SetValue(db.sound_file) end
	container:AddChild(sound_file_dd)
	]]
end

function O:AttachSpellSelection(container, eventShort, uid)
	dprint(2, "O:AttachSpellSelection", container, eventShort, uid)

	-- local variables & functions
	local db = P.alerts[eventShort].alertDetails[uid]

	local spellGroup = O:AttachGroup(container, _, _, 1, _, "Flow")

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
		--O:UpdateScrollTableData()
		editBox:SetText("")
	end)
	spellGroup:AddChild(editBox)
	O:AttachSpacer(spellGroup,20)

	-- sound selection per spell
	local soundSelection = O:AttachLSM(spellGroup, "sound", "Set sound alert per spell", db, "dummy", 207)
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
	dprint(2, "O:InitSpellTable", container)
	local spellTable = A.Libs.AceGUI:Create("SimpleGroup")
	spellTable = A.Libs.AceGUI:Create("SimpleGroup")
	spellTable:SetFullWidth(true)
	spellTable:SetHeight(300)
	container:AddChild(spellTable)
	O.SpellTable = spellTable
end

function O:UpdateSpellTable(eventShort, uid)
	dprint(2, "O:UpdateSpellTable", eventShort, uid)
	--VDT_AddData(db, "db")
	O.SpellTable:ReleaseChildren()

	-- local variables and functions
	local db = P.alerts[eventShort].alertDetails[uid]
	local iconAdd = A.LSM:HashTable("background")["Add"]
	local iconDel = A.LSM:HashTable("background")["Delete"]
	local btnDelSpellToolTip = {lines={"Delete spell/aura"}}
	local btnAddSoundToolTip = {lines={"Set an individual sound alert"}}

	local function btnDelSpellOnClick(self)
		dprint(2, "btnDelSpellOnClick", self)
		local spellName = self:GetUserData("spellName")
		db.spellNames[spellName] = nil
		O:UpdateSpellTable(eventShort, uid)
	end

	local function btnAddSoundOnClick(self)
		dprint(2, "btnAddSoundOnClick", self)
		local spellName = self:GetUserData("spellName")
		O.SoundSelection:SetUserData("spellName", spellName)
		local soundFile = db.spellNames[spellName].soundFile
		if soundFile ~= "" then O.SoundSelection:SetValue(soundFile) end
		O.SoundSelection:SetDisabled(false)
	end

	local scrollGroup = A.Libs.AceGUI:Create("ScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	scrollGroup.frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile=true , tileSize=16})
	O.SpellTable:AddChild(scrollGroup)

	-- loop over all tracked spells/auras
	for spellName, tbl in pairs(db.spellNames) do
		-- rowGroup
		local rowGroup = O:AttachGroup(scrollGroup, _, _, 1, _, "Flow")

		-- delete spell icon
		local btnDelSpell = O.AttachIcon(rowGroup, iconDel, 18, btnDelSpellOnClick, btnDelSpellToolTip, btnDelSpellUserData)
		btnDelSpell:SetUserData("spellName", spellName)
		O:AttachSpacer(rowGroup, 10)

		-- spell/aura icon & spellname
		O.AttachIcon(rowGroup, tbl.icon, 18)
		O:AttachSpacer(rowGroup, 5)

		-- spell/aura name
		O:AttachInteractiveLabel(rowGroup, spellName, _, _, 190)
		O:AttachSpacer(rowGroup, 12)

		-- add sound
		local btnAddSound = O.AttachIcon(rowGroup, iconAdd, 16, btnAddSoundOnClick, btnAddSoundToolTip)
		btnAddSound:SetUserData("spellName", spellName)
		O:AttachSpacer(rowGroup, 10)

		-- sound label
		O:AttachInteractiveLabel(rowGroup, tbl.soundFile, _, _, 200)

	end
end
