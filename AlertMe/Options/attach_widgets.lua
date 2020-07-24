dprint(3, "attach_widgets.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

--**********************************************************************************************************************************
-- attach AceGUI widgets
--**********************************************************************************************************************************
function O:AttachHeader(container, text)
	dprint(3, "O:AttachHeader", container, text)
	local header = A.Libs.AceGUI:Create("Heading")
	header:SetText(text)
	header.width = "fill"
	container:AddChild(header)
	return header
end

function O:AttachGroup(container, title, inline, width, height, layout)
	dprint(3, "O:AttachGroup", container, title, inline, width, height, layout)
	local group = {}
	layout = layout or "Flow"

	if inline == true then
		group = A.Libs.AceGUI:Create("InlineGroup")
		group:SetTitle(title)
	else
		group = A.Libs.AceGUI:Create("SimpleGroup")
	end

	if width ~= nil and width <= 1 then
		group:SetRelativeWidth(width)
	elseif width ~= nil and width > 1 then
		group:SetWidth(width)
	end

	if height ~= nil and height == 1 then
		group:SetFullHeight(true)
	elseif height ~= nil and height > 1 then
		group:SetHeight(height)
	end

	group:SetLayout(layout)
	container:AddChild(group)
	return group
end

function O:AttachSlider(container, label, db, key, min, max, step, isPercent, width, func)
	dprint(3, "O:AttachSlider", container, label, db, key, min, max, step, isPercent, width, func)
	local slider = A.Libs.AceGUI:Create("Slider")
	slider:SetLabel(label)
	slider:SetSliderValues(min, max, step)
	slider:SetIsPercent(isPercent)
	slider:SetValue(db[key])
	slider:SetCallback("OnMouseUp", function(widget, event, value)
		db[key] = value
		if func ~= nil then func() end
		--if scrolling == true then A:ScrollingTextInitOrUpdate() end
	end)
	if width then slider:SetWidth(width) end
	container:AddChild(slider)
	return slider
end

function O:AttachEditBox(container, label, path, key, width, func)
	dprint(3, "O:AttachEditBox", container, label, path, key, width)
	local edit = A.Libs.AceGUI:Create("EditBox")
	edit:SetLabel(label)
	if width then
		if width <= 1 then
			edit:SetRelativeWidth(width)
		else
			edit:SetWidth(width)
		end
	end
	edit:SetText(path[key])
	edit:SetCallback("OnEnterPressed", function(widget, event, text)
		path[key] = text
		if func ~= nil then func() end
	end)
	container:AddChild(edit)
	return edit
end

function O:AttachButton(container, text, width)
	dprint(3, "O:AttachButton", container, text, width)
	local button = A.Libs.AceGUI:Create("Button")
	button:SetText(text)
	if width then button:SetWidth(width) end
	container:AddChild(button)
	return button
end

function O:AttachLabel(container, text, fontObject, color, absWidth, relWidth)
	dprint(3, "O:AttachLabel", container, text, fontObject, color,  absWidth, relWidth)
	local label = A.Libs.AceGUI:Create("Label")
	label:SetText(text)
	if absWidth ~= nil then
		label:SetWidth(absWidth)
	else
		label:SetRelativeWidth(relWidth or 1)
	end
	if fontObject == nil then fontObject = GameFontHighlight end
	label:SetFontObject(fontObject)
	if color ~= nil then label:SetColor(color[1], color[2], color[3]) end
	container:AddChild(label)
	return label
end

function O:AttachInteractiveLabel(container, text, fontObject, color, absWidth, relWidth)
	dprint(3, "O:AttachInteractiveLabel", container, text, fontObject, color,  absWidth, relWidth)
	local label = A.Libs.AceGUI:Create("Label")
	label:SetText(text)
	if absWidth ~= nil then
		label:SetWidth(absWidth)
	else
		label:SetRelativeWidth(relWidth or 1)
	end
	if fontObject == nil then fontObject = GameFontHighlight end
	label:SetFontObject(fontObject)
	if color ~= nil then label:SetColor(color[1], color[2], color[3]) end
	container:AddChild(label)
	return label
end

function O:AttachSpacer(container, width, height)
	dprint(3, "O:AttachSpacer", container, width, height)
	local control = A.Libs.AceGUI:Create("InteractiveLabel")
	if width then control:SetWidth(width) end
	if height then
		if height == "small" then control:SetFontObject(GameFontHighlightSmall) end
		if height == "large" then control:SetFontObject(GameFontHighlightLarge) end
		if height == "medium" then control:SetFontObject(GameFontHighlight) end
		control:SetText(" ")
	else
		control:SetText("")
	end
	container:AddChild(control)
	return control
end

function O:AttachCheckBox(container, label, db, key, width, func)
	dprint(3, "O:AttachCheckBox", container, label, db, key, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	control:SetValue(db[key])
	control:SetCallback("OnValueChanged", function(widget, event, value)
		db[key] = value
		if func ~= nil then func() end
	end)
	control:SetLabel(label)
	if width then control:SetWidth(width) end
	container:AddChild(control)
	return control
end

function O:AttachDropdown(container, label, db, key, list, width, func)
	dprint(3, "O:AttachDropdown", container, label, db, key, list, width, func)
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel(label)
	dropdown:SetMultiselect(false)
	dropdown:SetWidth(width)
	dropdown:SetList(list)
	dropdown:SetValue(db[key])
	dropdown:SetCallback("OnValueChanged", function(_, _, value)
		db[key] = value
		if func ~= nil then func() end
	end)
	container:AddChild(dropdown)
	return dropdown
end

function O:AttachIcon(container, image, size)
	dprint(3, "O:AttachIcon", container, image, size)
	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage(image)
	icon:SetImageSize(size, size)
	icon:SetWidth(size)
	icon:SetHeight(size)
	icon.image:SetPoint("TOP", 0, 0)
	container:AddChild(icon)
	return icon
end

function O:AttachMultiLineEditBox(container, path, key, label, lines)
	dprint(3, "O:AttachMultiLineEditBox", container, path, key, label, lines)
	local edit = A.Libs.AceGUI:Create("MultiLineEditBox")
	edit:SetLabel(label)
	edit:SetNumLines(lines)
	edit:SetRelativeWidth(1)
	edit:SetText(path[key])
	edit:SetUserData("path", path)
	edit:SetUserData("key", key)
	edit:SetCallback("OnEnterPressed", function(widget, text)
		path[key] = text
	end)
	container:AddChild(edit)
	return edit
end

local LSMWidgets = {
	sound = "LSM30_Sound",
	statusbar = "LSM30_Statusbar",
	font = "LSM30_Font",
	sound = "LSM30_Sound",
	background = "LSM30_Background",
	border = "LSM30_Border"
}

function O:AttachLSM(container, type, label, db, key, width, func)
	dprint(3, "O:AttachLSM", container, type, label, db, key, width, func)
	local control = {}
	control = A.Libs.AceGUI:Create(LSMWidgets[type])
	control:SetList(A.LSM:HashTable(type))
	control:SetLabel(label)
	control:SetCallback("OnValueChanged", function(widget, _, value)
		widget:SetValue(value)
		db[key] = value
		if func ~= nil then func() end
	end)
	if width ~= nil then control:SetWidth(width) end
	control:SetValue(db[key])
	container:AddChild(control)
end

function O:AttachColorPicker(container, label, db, key, alpha, width, func)
	dprint(3, "O:AttachLSM", container, label, db, key, alpha, width, func)
	local control = A.Libs.AceGUI:Create("ColorPicker")
	control:SetColor(unpack(db[key]))
	control:SetLabel(label)
	control:SetHasAlpha(alpha)
	control:SetCallback("OnValueConfirmed", function(widget, _, r, g, b, a)
		db[key] = {r,g,b,a}
		if func ~= nil then func() end
	end)
	container:AddChild(control)
end
