dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame
local GameTooltip = GameTooltip
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)

	local spellNames = {}
	for spellName,_ in pairs(S.cache) do
		tinsert(spellNames, spellName)
	end

	local edit = A.Libs.AceGUI:Create('EditBox-AutoComplete')
	edit:SetValueList(spellNames)
	edit:SetButtonCount(20)
	edit:SetLabel("Type in spell name")
	--edit:SetCallback("OnEnterPressed", function(widget, event, text)
	container:AddChild(edit)

	local editBox = A.Libs.AceGUI:Create("Spell_EditBox")
	VDT_AddData(editBox, "editBox")
	editBox:SetLabel("Spell name")
	editBox:SetWidth(200)
	--editBox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
	container:AddChild(editBox)


	local auraBox = A.Libs.AceGUI:Create("Aura_EditBox")
	VDT_AddData(auraBox, "auraBox")
	auraBox:SetLabel("Aura name")
	auraBox:SetWidth(200)
	--editBox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
	container:AddChild(auraBox)


end
