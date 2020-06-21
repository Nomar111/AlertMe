dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame
local GameTooltip, GetSpellInfo = GameTooltip, GetSpellInfo
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)
	O.spells = {}
	VDT_AddData(O.spells, "spells")

	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	VDT_AddData(editBox, "editBox")
	editBox:SetLabel("Spell name")
	editBox:SetWidth(320)
	editBox:SetCallback("OnEnterPressed", function(widget, event, text,...)
		for i,v in pairs(editBox.predictFrame.buttons) do
			local name, _, icon = GetSpellInfo(v.spellID)
			if name == text then
				O.spells[text] = icon
			end
		end
		O:UpdateScrollTableData()
		editBox:SetText("")
	end)
	--editBox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
	container:AddChild(editBox)

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
				O.spells[spellName] = nil
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
			OnEnter = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				-- event handler
			end,
			onLeave = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				-- event handler
			end
		},
	}

	local col3 = {
		name         = '',
		width        = 237,
		align        = 'LEFT',
		index        = 'spellName',
		format       = 'text',
		sortable     = false,
		color        = {r = 1, g = 1, b = 1, a = 1},
		events	     = {
			OnEnter = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				-- event handler
			end,
			onLeave = function(rowFrame, cellFrame, data, cols, row, realRow, column, table, button, ...)
				-- event handler
			end
		},
	}
	local cols = {col1,col2,col3}

	function O:UpdateScrollTableData()
		local data = {}
		for i,v in pairs(O.spells) do
			local row = {
				delete = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga",
				icon = v,
				spellName = i
			}
			tinsert(data, row)
		end
		O.scrollTable:SetData(data)
	end
	-- local data = {
	-- 		{delete = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga", icon = 134715, spellName = "Free Action"},
	-- 		{delete = "Interface\\AddOns\\AlertMe\\Media\\Textures\\delete.tga", icon = 136078, spellName = "Mark of the Wild"},
	-- }
	local scrollTableContainer = O:AttachGroup(container, "scrollTableContainer", false)
	scrollTableContainer:SetAutoAdjustHeight(false)
	scrollTableContainer:SetHeight(170)

	if O.scrollTable ~= nil then
		O.scrollTable:Show()
	else
		O.scrollTable = A.Libs.StdUi:ScrollTable(scrollTableContainer.frame, cols, 8, 18)
		O.scrollTable:EnableSelection(false)
	end

	-- O.scrollTable.head = nil
	-- O.scrollTable.headerEvents = nil
	VDT_AddData(O.scrollTable, "st")
	A.Libs.StdUi:GlueTop(O.scrollTable, scrollTableContainer.frame, 2, -10, "LEFT")
	VDT_AddData(container, "cnt")
	O:AttachLabel(container, "Test")

end
