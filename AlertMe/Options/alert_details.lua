dprint(2, "alert_details.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall = _G, dprint, type, unpack, pairs, time, tostring, xpcall
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall
-- get engine environment
local A, _, O = unpack(select(2, ...))
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
	O:AttachHeader(container, spell_aura.." names to be tracked")
	local spell_names = O:AttachEditBox(container, path, "spell_names", "")
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
end

function O:AttachEditBox(container, path, key, label)
	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetLabel(label)
	edit:SetRelativeWidth(1)
	edit:SetText(path[key])
	edit:SetUserData("path", path)
	edit:SetUserData("key", key)
	edit:SetCallback("OnEnterPressed", function(widget, text) O:EditBoxOnEnter(widget, text) end)
	container:AddChild(edit)
	return edit
end

function O:EditBoxOnEnter(widget, text)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	path[key] = widget:GetText()
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

function O:AttachDropdown(container, path, key, label, list, width)
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel(label)
	dropdown:SetMultiselect(false)
	dropdown:SetWidth(width)
	dropdown:SetList(list)
	dropdown:SetValue(path[key])
	dropdown:SetUserData("path", path)
	dropdown:SetUserData("key", key)
	dropdown:SetCallback("OnValueChanged", function(widget) O:DropDownOnChange(widget) end)
	container:AddChild(dropdown)
	return dropdown
end

function O:DropDownOnChange(widget, event)
	local path = widget:GetUserData("path")
	local key = widget:GetUserData("key")
	path[key] = widget.value
end

function O:AttachLabel(container, text, font_object, color, relative_width)
	local label = A.Libs.AceGUI:Create("Label")
	label:SetText(text)
	label:SetRelativeWidth(relative_width or 1)
	if font_object == nil then font_object = GameFontHighlight end -- GameFontHighlightLarge, GameFontHighlightSmall
	label:SetFontObject(font_object)
	if color ~= nil then label:SetColor(color[1], color[2], color[3]) end
	container:AddChild(label)
	return label
end
