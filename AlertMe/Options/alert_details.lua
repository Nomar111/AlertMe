dprint(3, "alert_details.lua")
-- upvalues
local _G, GetItemIcon, GetSpellInfo = _G, GetItemIcon, GetSpellInfo
--local GameTooltip, GetSpellInfo, LibStub = GameTooltip, GetSpellInfo, LibStub
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
		--O:UpdateSpellTable(container,m eventShort, uid, db)
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

function O:AttachSpellSelection(container, eventShort, uid, db)
	dprint(2, "O:AttachSpellSelection", container, eventShort, uid, db)

	-- spell edit box
	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	editBox:SetLabel("Add "..A.EventsShort[eventShort].type.." to be tracked")
	editBox:SetWidth(230)
	editBox:SetCallback("OnEnterPressed", function(widget, event, text)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name ~= nil and name == text then
				db.spells[text]["icon"] = icon
				O:UpdateSpellTable(eventShort, uid, db)
				--db.spells[text]["id"] = v.spellID
			end
		end
		--O:UpdateScrollTableData()
		editBox:SetText("")
	end)
	container:AddChild(editBox)

	-- sound selection per spell
	local soundSelection = O:AttachLSM(container, "sound", _, db, "dummy", 200)
	soundSelection:SetCallback("OnValueChanged", function(widget, _, value)
		local _db = widget:GetUserData("db")
		local _key = widget:GetUserData("key")
		_db[_key] = value
		O:UpdateSpellTable(eventShort, uid, db)
	end)
	soundSelection:SetDisabled(true)
	O.SoundSelection = soundSelection
end

function O:InitSpellTable(container, eventShort, uid, db)
	dprint(2, "O:InitSpellTable", container)
	local spellTable = A.Libs.AceGUI:Create("SimpleGroup")
	spellTable = A.Libs.AceGUI:Create("SimpleGroup")
	spellTable:SetFullWidth(true)
	spellTable:SetHeight(300)
	container:AddChild(spellTable)
	O.SpellTable = spellTable
	O:UpdateSpellTable(eventShort, uid, db)
end

function O:UpdateSpellTable(eventShort, uid, db)
	dprint(2, "O:UpdateSpellTable", eventShort, uid, db)
	VDT_AddData(db, "db")
	O.SpellTable:ReleaseChildren()
	--spellTableGroup:SetTitle("Spell/Aura table")

	local scrollGroup = A.Libs.AceGUI:Create("ScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	--scrollGroup:SetRelativeWidth(0.5)
	--VDT_AddData(scrollGroup,"scrollGroup")
	scrollGroup.frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile=true , tileSize=16})
	O.SpellTable:AddChild(scrollGroup)

	local iconAdd = A.LSM:HashTable("background")["Add"]
	local iconDelete = A.LSM:HashTable("background")["Delete"]

	for spellName, tbl in pairs(db.spells) do
		-- rowGroup
		local rowGroup = O:AttachGroup(scrollGroup, _, _, 1, _, "Flow")

		-- delete
		local btnDeleteSpell = O:AttachIcon(rowGroup, iconDelete, 18)
		btnDeleteSpell:SetUserData("spell", spellName)
		btnDeleteSpell:SetUserData("db", db)
		btnDeleteSpell:SetCallback("OnClick", function(widget, event, value)
			local spell = widget:GetUserData("spell")
			local _db = widget:GetUserData("db")
			_db.spells[spell] = nil
			O:UpdateSpellTable(eventShort, uid, _db)
		end)
		O:AttachSpacer(rowGroup, 10)

		-- icon & spellname
		O:AttachIcon(rowGroup, tbl.icon, 18)
		O:AttachSpacer(rowGroup, 5)
		O:AttachInteractiveLabel(rowGroup, spellName, _, _, 150)
		O:AttachSpacer(rowGroup, 10)

		-- add sound
		local btnAddSound = O:AttachIcon(rowGroup, iconAdd, 16)
		btnAddSound:SetUserData("spell", spellName)
		btnAddSound:SetUserData("db", db)
		btnAddSound:SetCallback("OnClick", function(widget, event, value)
			local spell = widget:GetUserData("spell")
			local _db = widget:GetUserData("db")
			O.SoundSelection:SetUserData("db", _db.spells[spell])
			O.SoundSelection:SetUserData("key", "soundFile")
			O.SoundSelection:SetDisabled(false)
		end)

		-- local btnDeleteSpell = O:AttachIcon(rowGroup, iconDelete, 18)
		--O:AttachLSM(rowGroup, "sound", _, db.spells, "soundFile", 100)
		--O:AttachIcon(rowGroup, iconAdd, 18)
	end
end

function O:AttachSpellSelection_OLD(container, db, uid)
	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	editBox:SetLabel("Add spell/aura to be tracked")
	editBox:SetWidth(320)
	editBox:SetCallback("OnEnterPressed", function(widget, event, text,...)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name == text then
				db.spells[text]["icon"] = icon
			end
		end
		O:UpdateScrollTableData()
		editBox:SetText("")
	end)
	container:AddChild(editBox)
	-- sound alert per spell
	O:AttachSpacer(container, 19)
	O.sound_alert_spell = A.Libs.AceGUI:Create("LSM30_Sound")
	O.sound_alert_spell:SetList(A.LSM:HashTable("sound"))
	O.sound_alert_spell:SetCallback("OnValueChanged", function(widget, _, value)
		widget:SetValue(value)
		--VDT_AddData(db.spells,"dbspells")
		db.spells[O.selected_spell]["sound"] = value
		O:UpdateScrollTableData()
	end)
	container:AddChild(O.sound_alert_spell)
	O.sound_alert_spell:SetDisabled(true)

	local col1 = {
		name         = '',
		width        = 24,
		align        = 'CENTER',
		index        = 'delete',
		format       = 'icon',
		sortable     = false,
		color        = {r = 1, g = 1, b = 1, a = 1},
		events	     = {
			OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				local spellName = data.columns[3].text:GetText()
				db.spells[spellName] = nil
				O:UpdateScrollTableData()
			end
		},
	}

	local col2 = {
		name         = '',
		width        = 24,
		align        = 'CENTER',
		index        = 'icon',
		format       = 'icon',
		sortable     = false,
		color        = {r = 1, g = 1, b = 1, a = 1},
		events	     = {
			OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				local spellName = data.columns[3].text:GetText()
				O.selected_spell = spellName
				O.sound_alert_spell:SetDisabled(false)
				O.sound_alert_spell:SetLabel("Set sound alert for "..spellName)
				local sound = data.columns[4].text:GetText()
				if sound ~= nil and sound ~= "" then O.sound_alert_spell:SetValue(sound) end
			end
		},
	}

	local col3 = {
		name         = '',
		width        = 140,
		align        = 'LEFT',
		index        = 'spellName',
		format       = 'text',
		sortable     = false,
		color        = {r = 1, g = 1, b = 1, a = 1},
		events	     = {
			OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				local spellName = data.columns[3].text:GetText()
				O.selected_spell = spellName
				O.sound_alert_spell:SetDisabled(false)
				O.sound_alert_spell:SetLabel("Set sound alert for "..spellName)
				local sound = data.columns[4].text:GetText()
				if sound ~= nil and sound ~= "" then O.sound_alert_spell:SetValue(sound) end
			end
		},
	}

	local col4 = {
		name         = '',
		width        = 95,
		align        = 'LEFT',
		index        = 'sound',
		format       = 'text',
		sortable     = false,
		color        = {r = 1, g = 1, b = 1, a = 1},
		events	     = {
			OnClick = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				local spellName = data.columns[3].text:GetText()
				O.selected_spell = spellName
				O.sound_alert_spell:SetDisabled(false)
				O.sound_alert_spell:SetLabel("Set sound alert for "..spellName)
				local sound = data.columns[4].text:GetText()
				if sound ~= nil and sound ~= "" then O.sound_alert_spell:SetValue(sound) end
			end
		},
	}
	local cols = {col1,col2,col3,col4}

	function O:UpdateScrollTableData()
		local data = {}
		for i,v in pairs(db.spells) do
			local row = {
				delete = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga",
				icon = v["icon"],
				spellName = i,
				sound = v["sound"]
			}
			tinsert(data, row)
		end
		O.scrollTable:SetData(data)
	end

	local scrollTableContainer = O:AttachGroup(container, "scrollTableContainer", false)
	scrollTableContainer:SetAutoAdjustHeight(false)
	scrollTableContainer:SetHeight(110)

	if O.scrollTable ~= nil then
		O.scrollTable:Show()
	else
		O.scrollTable = A.Libs.StdUi:ScrollTable(scrollTableContainer.frame, cols, 5, 18)
		O.scrollTable:EnableSelection(false)
	end

	A.Libs.StdUi:GlueTop(O.scrollTable, scrollTableContainer.frame, 2, -10, "LEFT")
	O:UpdateScrollTableData()

end



function O:DropDownOnChange(widget, event)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	path[key] = widget.value
end
