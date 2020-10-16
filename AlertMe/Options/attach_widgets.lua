-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

local LSMWidgets = {
	sound = "LSM30_Sound",
	statusbar = "LSM30_Statusbar",
	font = "LSM30_Font",
	background = "LSM30_Background",
	border = "LSM30_Border"
}

local LSMTables = {
	sound = A.Sounds,
	statusbar = A.Statusbars,
	font = A.Fonts,
	background = A.Backgrounds,
	border = A.Borders
}

--**********************************************************************************************************************************
-- attach AceGUI widgets
--**********************************************************************************************************************************
function O.AttachButton(container, text, width)
	dprint(3, "O.AttachButton", container, text, width)
	local widget = A.Libs.AceGUI:Create("Button")
	widget:SetText(text)
	if width then widget:SetWidth(width) end
	container:AddChild(widget)
	return widget
end

function O.AttachCheckBox(container, label, db, key, width, func)
	dprint(3, "O.AttachCheckBox", container, label, db, key, width)
	local widget = A.Libs.AceGUI:Create("CheckBox")
	widget:SetValue(db[key])
	widget:SetCallback("OnValueChanged", function(_, _, value)
		db[key] = value
		if func ~= nil then func() end
	end)
	widget:SetLabel(label)
	if width then widget:SetWidth(width) end
	container:AddChild(widget)
	return widget
end

function O.AttachColorPicker(container, label, db, key, alpha, width, func)
	dprint(3, "O.AttachLSM", container, label, db, key, alpha, width, func)
	local widget = A.Libs.AceGUI:Create("ColorPicker")
	widget:SetColor(unpack(db[key]))
	widget:SetLabel(label)
	widget:SetHasAlpha(alpha)
	widget:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
		db[key] = {r,g,b,a}
		if func ~= nil then func() end
	end)
	container:AddChild(widget)
	return widget
end

function O.AttachDropdown(container, label, db, key, list, width, func, toolTip)
	dprint(3, "O.AttachDropdown", container, label, db, key, list, width, func, toolTip)
	local widget = A.Libs.AceGUI:Create("Dropdown")
	if label then widget:SetLabel(label) end
	widget:SetMultiselect(false)
	if width then widget:SetWidth(width) end
	if list then widget:SetList(list) end
	widget:SetValue(db[key])
	widget:SetCallback("OnValueChanged", function(_, _, value)
		db[key] = value
		if func ~= nil then func() end
	end)
	if toolTip ~= nil then
		O.SetToolTip(widget, toolTip)
	end
	container:AddChild(widget)
	return widget
end

function O.AttachEditBox(container, label, path, key, width, func, toolTip)
	dprint(3, "O.AttachEditBox", container, label, path, key, width)
	local widget = A.Libs.AceGUI:Create("EditBox")
	if label then widget:SetLabel(label) end
	if width then
		if width <= 1 then
			widget:SetRelativeWidth(width)
		else
			widget:SetWidth(width)
		end
	end
	widget:SetText(path[key])
	widget:SetCallback("OnEnterPressed", function(_, event, text)
		path[key] = text
		if func ~= nil then func() end
	end)
	if toolTip ~= nil then
		O.SetToolTip(widget, toolTip)
	end
	container:AddChild(widget)
	return widget
end

function O.AttachGroup(container, type, title, format)
	dprint(3, "O.AttachGroupNew", container, type, title, format)
	type = type or "simple"
	local layout = ""
	if format == nil or format.layout == nil then
		layout ="Flow"
	else
		layout = format.layout
	end
	-- create group
	local widget = {}
	if type == "inline" then
		widget = A.Libs.AceGUI:Create("InlineGroup")
		widget:SetTitle(title)
	elseif type == "simple" then
		widget = A.Libs.AceGUI:Create("SimpleGroup")
	end
	-- format
	if format then
		if format.fullWidth == true then widget:SetFullWidth(true) end
		if format.fullHeight == true then widget:SetFullHeight(true) end
		if format.autoHeight == false then widget:SetAutoAdjustHeight(false) end
		if format.relWidth ~= nil then widget:SetRelativeWidth(format.relWidth) end
		if format.width ~= nil then widget:SetWidth(format.width) end
		if format.height ~= nil then
			widget:SetAutoAdjustHeight(false)
			widget:SetHeight(format.height)
		end
	end
	if layout ~= "none" then
		widget:SetLayout(layout)
	 end
	-- attach & return
	container:AddChild(widget)
	return widget
end

function O.AttachHeader(container, text)
	dprint(3, ".:AttachHeader", container, text)
	local widget = A.Libs.AceGUI:Create("Heading")
	widget:SetText(text)
	widget.width = "fill"
	container:AddChild(widget)
	return widget
end

function O.AttachIcon(container, image, size, onClick, toolTip, ofs_y)
	dprint(3, "O.AttachIcon", container, image, size, onClick, toolTip, ofs_y)
	-- standards
	ofs_y = ofs_y or 0
	size = size or 16
	-- create
	local widget = A.Libs.AceGUI:Create("Icon")
	widget:SetImage(image)
	widget:SetImageSize(size, size)
	widget:SetWidth(size)
	widget:SetHeight(size)
	widget.image:SetPoint("TOP", ofs_y, 0)
	-- callbacks
	if onClick ~= nil then widget:SetCallback("OnClick", onClick) end
	if toolTip ~= nil then
		O.SetToolTip(widget, toolTip)
	end
	-- add and return
	container:AddChild(widget)
	return widget
end

function O.AttachLabel(container, text, fontObject, color, absWidth, relWidth)
	dprint(3, "O.AttachLabel", container, text, fontObject, color,  absWidth, relWidth)
	local widget = A.Libs.AceGUI:Create("InteractiveLabel")
	widget:SetText(text)
	if absWidth ~= nil then
		widget:SetWidth(absWidth)
	else
		widget:SetRelativeWidth(relWidth or 1)
	end
	if fontObject == nil then fontObject = GameFontHighlight end
	widget:SetFontObject(fontObject)
	if color ~= nil then widget:SetColor(color[1], color[2], color[3]) end
	container:AddChild(widget)
	return widget
end

function O.AttachInteractiveLabel(container, text, fontObject, color, absWidth, relWidth, func)
	dprint(3, "O.AttachLabel", container, text, fontObject, color,  absWidth, relWidth)
	local widget = A.Libs.AceGUI:Create("InteractiveLabel")
	widget:SetText(text)
	if absWidth ~= nil then
		widget:SetWidth(absWidth)
	else
		widget:SetRelativeWidth(relWidth or 1)
	end
	if fontObject == nil then fontObject = GameFontHighlight end
	widget:SetFontObject(fontObject)
	widget:SetCallback("OnClick", function(_widget, _button)
		if func ~= nil then func(_widget, event) end
	end)
	if color ~= nil then widget:SetColor(color[1], color[2], color[3]) end
	container:AddChild(widget)
	return widget
end

function O.AttachLSM(container, type, label, db, key, width, func)
	dprint(3, "O.AttachLSM", container, type, label, db, key, width, func)
	-- local variables/tables
	local widget = A.Libs.AceGUI:Create(LSMWidgets[type])
	widget:SetList(LSMTables[type])
	if label then widget:SetLabel(label) end
	widget:SetCallback("OnValueChanged", function(_widget, _, value)
		_widget:SetValue(value)
		db[key] = value
		if func ~= nil then func() end
	end)
	if width ~= nil then widget:SetWidth(width) end
	widget:SetValue(db[key])
	container:AddChild(widget)
	return widget
end

-- function O.AttachMultiLineEditBox(container, path, key, label, lines)
-- 	dprint(3, "O:AttachMultiLineEditBox", container, path, key, label, lines)
-- 	local edit = A.Libs.AceGUI:Create("MultiLineEditBox")
-- 	edit:SetLabel(label)
-- 	edit:SetNumLines(lines)
-- 	edit:SetRelativeWidth(1)
-- 	edit:SetText(path[key])
-- 	edit:SetUserData("path", path)
-- 	edit:SetUserData("key", key)
-- 	edit:SetCallback("OnEnterPressed", function(widget, text)
-- 		path[key] = text
-- 	end)
-- 	container:AddChild(edit)
-- 	return edit
-- end

function O.AttachSlider(container, label, db, key, min, max, step, isPercent, width, func)
	dprint(3, "O.AttachSlider", container, label, db, key, min, max, step, isPercent, width, func)
	local widget = A.Libs.AceGUI:Create("Slider")
	if label then widget:SetLabel(label) end
	widget:SetSliderValues(min, max, step)
	widget:SetIsPercent(isPercent)
	widget:SetValue(db[key])
	widget:SetCallback("OnMouseUp", function(_, _, value)
		db[key] = value
		if func ~= nil then func() end
		--if scrolling == true then A:ScrollingTextInitOrUpdate() end
	end)
	if width then widget:SetWidth(width) end
	container:AddChild(widget)
	return widget
end

function O.AttachSpacer(container, width, height)
	dprint(3, "O.AttachSpacer", container, width, height)
	local widget = A.Libs.AceGUI:Create("Label")
	if width then widget:SetWidth(width) end
	if height then
		if height == "small" then widget:SetFontObject(GameFontHighlightSmall) end
		if height == "large" then widget:SetFontObject(GameFontHighlightLarge) end
		if height == "medium" then widget:SetFontObject(GameFontHighlight) end
		widget:SetText(" ")
	else
		widget:SetText("")
	end
	container:AddChild(widget)
	return widget
end

function O.SetToolTip(widget, toolTip)
	dprint(3, "O.Tooltip", widget, toolTip, toolTip.wrap)
	-- show
	local wrap = true
	if toolTip.wrap ~= nil then	wrap = toolTip.wrap	end
	widget:SetCallback("OnEnter", function()
		O.ToolTip = O.ToolTip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
		O.ToolTip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		if toolTip.header then
			O.ToolTip:SetText(toolTip.header, 1, 1, 1, wrap)
		end
		if toolTip.lines then
			for _, line in pairs(toolTip.lines) do
				O.ToolTip:AddLine(line, 1, .82, 0, wrap)
			end
		end
		O.ToolTip:Show()
	end)
	-- hide
	widget:SetCallback("OnLeave", function()
		if O.ToolTip then O.ToolTip:Hide() end
	end)
end
