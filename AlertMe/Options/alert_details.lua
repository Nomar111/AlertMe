dprint(2, "alert_details.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- creates the general options tab
function O:DrawAlertDetails(container, event)
	dprint(2, "O:DrawAlertDetails", event)
	VDT_AddData(container, "alert_details")
	-- release old widgets
	container:ReleaseChildren()
	-- abort if no alert is selected
	local uid = P.alerts_db[event]["selected_alert"]
	if uid == nil or uid == "" then return end
	-- set path to db for this event
	local path = P.alerts_db[event].alerts[uid]
	-- spell names
	local spell_aura = A:GetEventSettingByShort(event, "spell_aura")
	O:AttachHeader(container, spell_aura.." settings")
	local spell_add = O:AttachEditBox(container, path, "spell_add", "Insert new "..spell_aura.." name")
	spell_add:SetRelativeWidth(0.35)
	O.spell_dropdown = O:AttachDropdown(container, path, "spell_dropdown", "Added spells", path.spell_names, 200)

	-- unit selection
	O:AttachHeader(container, "Unit selection")
	local units_list = {[1] = "All players", [2] = "Friendly players", [3] = "Hostile players", [4] = "Target", [5] = "Myself"}
	local exclude_list = {[1] = "---", [2] = "Myself", [3] = "Target"}
	O:AttachDropdown(container, path, "source_units", "Source units", units_list, 160)
	O:AttachDropdown(container, path, "source_exclude", "excluding", exclude_list, 100)
	O:AttachSpacer(container, 50)
	O:AttachDropdown(container, path, "target_units", "Target units", units_list, 160)
	O:AttachDropdown(container, path, "target_exclude", "excluding", exclude_list, 100)
	-- display settings
	O:AttachHeader(container, "Display settings")
	O:AttachCheckBox(container, "Show progress bar", path, show_bar, 150)
	-- test dropdown

end


function O:UpdateSpellNames(text, path)
	dprint(1, "UpdateSpellNames", text, path)
	local spellName, spellId = S.CorrectAuraName(text)
	if spellName == "Invalid Spell ID" or spellName ==  "No Match Found" then
		dprint(1, spellName) -- popup!
	else
		path.spell_names[spellName] = spellName
		O.spell_dropdown:SetList(path.spell_names)
		O.spell_dropdown:SetValue(spellName)
	end
end

function O:AttachMultiLineEditBox(container, path, key, label, lines)
	local edit = A.Libs.AceGUI:Create("MultiLineEditBox")
	edit:SetLabel(label)
	edit:SetNumLines(lines)
	edit:SetRelativeWidth(1)
	edit:SetText(path[key])
	edit:SetUserData("path", path)
	edit:SetUserData("key", key)
	edit:SetCallback("OnEnterPressed", function(widget, text) O:MultiLineEditBoxOnEnter(widget, text) end)
	container:AddChild(edit)
	return edit
end

function O:MultiLineEditBoxOnEnter(widget, text)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	path[key] = widget:GetText()
end



function O:DropDownOnChange(widget, event)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	path[key] = widget.value
end
