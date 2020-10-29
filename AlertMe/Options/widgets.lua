-- upvales
local LSMTables = {
	sound =  _G.AlertMe.A.Sounds,
	statusbar =  _G.AlertMe.A.Statusbars,
	font =  _G.AlertMe.A.Fonts,
	background =  _G.AlertMe.A.Backgrounds,
	border =  _G.AlertMe.A.Borders
}
local _G, libs, pairs = _G, _G.AlertMe.A.Libs, _G.pairs


-- set addon environment to "O"
setfenv(1, _G.AlertMe.O)
local unpack = _G.unpack

local LSMWidgets = {
	sound = "LSM30_Sound",
	statusbar = "LSM30_Statusbar",
	font = "LSM30_Font",
	background = "LSM30_Background",
	border = "LSM30_Border"
}

--**********************************************************************************************************************************
-- attach AceGUI widgets
--**********************************************************************************************************************************
function AttachButton(container, text, width, func)
	local widget = libs.AceGUI:Create("Button")
	widget:SetText(text)
	if width then widget:SetWidth(width) end
	widget:SetCallback("OnClick", func)
	container:AddChild(widget)
	return widget
end

function AttachCheckBox(container, label, db, key, width, func, toolTip)
	local widget = libs.AceGUI:Create("CheckBox")
	widget:SetValue(db[key])
	widget:SetCallback("OnValueChanged", function(_, _, value)
		db[key] = value
		if func then func() end
	end)
	widget:SetLabel(label)
	if width then widget:SetWidth(width) end
	if toolTip then	SetToolTip(widget, toolTip) end
	container:AddChild(widget)
	return widget
end

function AttachColorPicker(container, label, db, key, alpha, width, func)
	local widget = libs.AceGUI:Create("ColorPicker")
	widget:SetColor(unpack(db[key]))
	widget:SetLabel(label)
	widget:SetHasAlpha(alpha)
	widget:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
		db[key] = {r,g,b,a}
		if func then func() end
	end)
	container:AddChild(widget)
	return widget
end

function AttachDropdown(container, label, db, key, list, width, func, toolTip)
	local widget = libs.AceGUI:Create("Dropdown")
	if label then widget:SetLabel(label) end
	widget:SetMultiselect(false)
	if width then widget:SetWidth(width) end
	if list then widget:SetList(list) end
	widget:SetValue(db[key])
	widget:SetCallback("OnValueChanged", function(_, _, value)
		db[key] = value
		if func then func() end
	end)
	if toolTip then	SetToolTip(widget, toolTip) end
	container:AddChild(widget)
	return widget
end

function AttachEditBox(container, label, path, key, width, func, toolTip)
	local widget = libs.AceGUI:Create("EditBox")
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
		if func then func() end
	end)
	if toolTip then	SetToolTip(widget, toolTip) end
	container:AddChild(widget)
	return widget
end

function AttachGroup(container, type, title, format)
	type = type or "simple"
	local layout = (format and format.layout) and format.layout or "Flow"
	local widget = {}
	if type == "inline" then
		widget = libs.AceGUI:Create("InlineGroup")
		widget:SetTitle(title)
	elseif type == "simple" then
		widget = libs.AceGUI:Create("SimpleGroup")
	end
	-- format
	if format then
		if format.fullWidth then widget:SetFullWidth(true) end
		if format.fullHeight then widget:SetFullHeight(true) end
		if format.autoHeight == false then widget:SetAutoAdjustHeight(false) end
		if format.relWidth then widget:SetRelativeWidth(format.relWidth) end
		if format.width then widget:SetWidth(format.width) end
		if format.height then
			widget:SetAutoAdjustHeight(false)
			widget:SetHeight(format.height)
		end
	end
	if layout ~= "none" then widget:SetLayout(layout) end
	-- attach & return
	container:AddChild(widget)
	return widget
end

function AttachHeader(container, text)
	local widget = libs.AceGUI:Create("Heading")
	widget:SetText(text)
	widget.width = "fill"
	container:AddChild(widget)
	return widget
end

function AttachIcon(container, image, size, onClick, toolTip, ofs_y)
	-- standards
	ofs_y = ofs_y or 0
	size = size or 16
	-- create
	local widget = libs.AceGUI:Create("Icon")
	widget:SetImage(image)
	widget:SetImageSize(size, size)
	widget:SetWidth(size)
	widget:SetHeight(size)
	widget.image:SetPoint("TOP", ofs_y, 0)
	-- callbacks
	if onClick then widget:SetCallback("OnClick", onClick) end
	if toolTip then	SetToolTip(widget, toolTip) end
	-- add and return
	container:AddChild(widget)
	return widget
end

function AttachLabel(container, text, fontObject, color, absWidth, relWidth)
	fontObject = fontObject or GameFontHighlight
	local widget = libs.AceGUI:Create("InteractiveLabel")
	widget:SetText(text)
	if absWidth then
		widget:SetWidth(absWidth)
	else
		widget:SetRelativeWidth(relWidth or 1)
	end
	widget:SetFontObject(fontObject)
	if color then widget:SetColor(color[1], color[2], color[3]) end
	container:AddChild(widget)
	return widget
end

function AttachInteractiveLabel(container, text, fontObject, color, absWidth, relWidth, func)
	fontObject = fontObject or GameFontHighlight
	local widget = libs.AceGUI:Create("InteractiveLabel")
	widget:SetText(text)
	if absWidth then
		widget:SetWidth(absWidth)
	else
		widget:SetRelativeWidth(relWidth or 1)
	end
	widget:SetFontObject(fontObject)
	widget:SetCallback("OnClick", function(_widget, _button)
		if func then func(_widget, event) end
	end)
	if color then widget:SetColor(color[1], color[2], color[3]) end
	container:AddChild(widget)
	return widget
end

function AttachLSM(container, type, label, db, key, width, func)
	local widget = libs.AceGUI:Create(LSMWidgets[type])
	widget:SetList(LSMTables[type])
	if label then widget:SetLabel(label) end
	widget:SetCallback("OnValueChanged", function(_widget, _, value)
		_widget:SetValue(value)
		db[key] = value
		if func then func() end
	end)
	if width then widget:SetWidth(width) end
	widget:SetValue(db[key])
	container:AddChild(widget)
	return widget
end

function AttachSlider(container, label, db, key, min, max, step, isPercent, width, func, toolTip)
	local widget = libs.AceGUI:Create("Slider")
	if label then widget:SetLabel(label) end
	widget:SetSliderValues(min, max, step)
	widget:SetIsPercent(isPercent)
	widget:SetValue(db[key])
	widget:SetCallback("OnMouseUp", function(_, _, value)
		db[key] = value
		if func then func() end
	end)
	if width then widget:SetWidth(width) end
	if toolTip then	SetToolTip(widget, toolTip) end
	container:AddChild(widget)
	return widget
end

function AttachSpacer(container, width, height)
	local widget = libs.AceGUI:Create("Label")
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

function AttachTabGroup(container, title, format, path, key, tabs, onSelect)
	local layout = (format and format.layout) and format.layout or "Flow"
	local widget = libs.AceGUI:Create("TabGroup")
	widget:SetTitle(title)
	-- set tabs if  provided
	if tabs then widget:SetTabs(tabs) end
	-- set current tab and callbacks
	widget:SelectTab(path[key])
	widget:SetCallback("OnGroupSelected", function(_, event, newKey)
		path[key] = newKey
		if onSelect then onSelect(widget, newKey) end
	end)
	-- format
	if format then
		if format.fullWidth == true then widget:SetFullWidth(true) end
		if format.fullHeight == true then widget:SetFullHeight(true) end
		if format.autoHeight == false then widget:SetAutoAdjustHeight(false) end
		if format.relWidth then widget:SetRelativeWidth(format.relWidth) end
		if format.width then widget:SetWidth(format.width) end
		if format.height then
			widget:SetAutoAdjustHeight(false)
			widget:SetHeight(format.height)
		end
	end
	if layout ~= "none" then widget:SetLayout(layout) end
	-- attach & return
	container:AddChild(widget)
	return widget
end

function SetToolTip(widget, toolTip)
	-- show
	local wrap = toolTip.wrap or false
	widget:SetCallback("OnEnter", function()
		ToolTip = ToolTip or CreateFrame("GameTooltip", "AlertMeTooltip", UIParent, "GameTooltipTemplate")
		ToolTip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		if toolTip.header then
			ToolTip:SetText(toolTip.header, 1, 1, 1, wrap)
		end
		if toolTip.lines then
			for _, line in pairs(toolTip.lines) do
				ToolTip:AddLine(line, 1, .82, 0, wrap)
			end
		end
		ToolTip:Show()
	end)
	-- hide
	widget:SetCallback("OnLeave", function()
		if ToolTip then ToolTip:Hide() end
	end)
end
