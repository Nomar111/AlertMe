dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, type, unpack, pairs, print, tcopy, strsplit = _G, dprint, FCF_GetNumActiveChatFrames, type, unpack, pairs, print, table.copy, strsplit
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}

-- *************************************************************************************
-- open the options window
function O:OpenOptions()
	dprint(2, "O:OpenOptions")
	-- create main frame for options
	O.Frame = A.Libs.AceGUI:Create("Frame")
	O.Frame:SetTitle("AlertMe Options")
	--Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
	O.Frame:EnableResize(true)
	O.Frame:SetLayout("Flow")
	O.Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget) end)
	O.Frame:SetWidth(900)
	O.Frame:SetHeight(650)
	VDT_AddData(O.Frame, "OptionsFrame")
	-- create navigation
	O:CreateNavTree(O.Frame)
end

-- *************************************************************************************
-- creates navigation tree
function O:CreateNavTree(container)
	dprint(2, "O:CreateNavTree")
	-- function to draw the groupd
	local tree_structure = {}
	tree_structure[1] = {value = "general", text = "General"}
	tree_structure[2] = {value = "events", text = "Events"}
	tree_structure[3] = {value = "alerts", text = "Alerts", children = {}}
	tree_structure[4] = {value = "profiles", text = "Profiles"}
	tree_structure[5] = {value = "info", text = "Info"}
	-- loop over events and add them as children of alerts
	for _, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			tree_structure[3].children[tbl.options_order]  = {
				value = tbl.short,
				text = tbl.options_name
			}
		end
	end
	-- create the tree group
	local tree = A.Libs.AceGUI:Create("TreeGroup")
	tree:EnableButtonTooltips(false)
	tree.width = "fill"
	tree.height = "fill"
	tree:SetTree(tree_structure)

	-- callbacks
	local function GroupSelected(widget, event, uniquevalue)
		-- delete whatever is shown on the right side
		widget:ReleaseChildren()
		if O.scrollTable ~= nil then O.scrollTable:Hide() end
		-- create new content container
		local content_group = A.Libs.AceGUI:Create("SimpleGroup")
		content_group:SetLayout("Flow")
		content_group.width = "fill"
		widget:AddChild(content_group)
		-- call function to draw the various settings  on the right
		O:DrawOptions(content_group, uniquevalue)
	end
	tree:SetCallback("OnGroupSelected", GroupSelected)
	container:AddChild(tree)
end

function O:DrawOptions(container, uniquevalue)
	dprint(2, "clicked on", uniquevalue)
	local delim = "\001"
	local lvl1, lvl2 = strsplit(delim, uniquevalue)
	if lvl1 == "profiles" then O:DrawProfileOptions(container)
		elseif lvl1 == "general" then O:DrawGeneralOptions(container)
		elseif lvl1 == "info" then O:DrawInfoOptions(container)
		--elseif lvl1 == "events" then O:DrawTest(container)
		elseif lvl1 == "alerts" and lvl2 ~= nil then O:DrawAlertsOptions(container, lvl2)
	end
end

-- creates the general options tab
function O:DrawGeneralOptions(container)
	dprint(2, "O:DrawGeneralOptions")
	--VDT_AddData(container, "General")
	-- header
	O:AttachHeader(container, "General Settings")
	-- zones
	local zones = O:AttachGroup(container, "Addon is enabled in", true)
	local cb1 = O:AttachCheckBox(zones, "Battlegrounds", P.general.zones, "bg", 150)
	local cb2 = O:AttachCheckBox(zones, "World", P.general.zones, "world")
	-- chat frames
	local chat_frames = O:AttachGroup(container, "Post addon messages in the following chat windows", true)
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			O:AttachCheckBox(chat_frames, name, P.general.chat_frames, "ChatFrame"..i, 150)
		end
	end
	-- scrolling text setup
	local scrolling = O:AttachGroup(container, "Scrolling text settings", true)
	local db = P.general.scrolling_text
	-- enable
	O:AttachCheckBox(scrolling, "Enable Scrolling Text Frame", db ,"enabled", 600)
	-- show
	local btn_show = O:AttachButton(scrolling, "Show Frame", 120)
	btn_show:SetCallback("OnClick", function() A:ScrollingTextShow(true) end)
	-- hide
	O:AttachSpacer(scrolling, 10)
	local btn_hide = O:AttachButton(scrolling, "Hide Frame", 120)
	btn_hide:SetCallback("OnClick", function() A:ScrollingTextHide() end)
	-- reset
	O:AttachSpacer(scrolling, 10)
	local btn_reset = O:AttachButton(scrolling, "Reset position", 120)
	btn_reset:SetCallback("OnClick", function() A:ScrollingTextSetPosition(true) end)
	O:AttachSpacer(scrolling, 10)
	-- width
	local width = O:AttachSlider(scrolling, "Set width", db, "width", 300, 1000, 20, false, 250, true)
	local slider_width = 156
	-- background alpha
	local alpha = O:AttachSlider(scrolling, "Background alphah", db, "alpha", 0, 1, 0.01, true, slider_width, true)
	O:AttachSpacer(scrolling, 5)
	-- font size
	local font_size = O:AttachSlider(scrolling, "Font size", db, "font_size", 8, 22, 1, false, slider_width, true)
	O:AttachSpacer(scrolling, 5)
	-- visible lines
	local visible_lines = O:AttachSlider(scrolling, "Visible lines", db, "visible_lines", 1, 12, 1, false, slider_width, true)
	O:AttachSpacer(scrolling, 5)
	-- max lines
	local maxlines = O:AttachSlider(scrolling, "Max. lines (history)", db, "maxlines", 25, 500, 25, false, slider_width, true)
	-- fading
	local fading_cb = O:AttachCheckBox(scrolling, "Enable fading", db, "fading", slider_width)
	fading_cb:SetCallback("OnValueChanged", function(widget, event, value)
		db["fading"] = value
		A:ScrollingTextInitOrUpdate()
	end)
	O:AttachSpacer(scrolling, 5)
	-- time visible
	local timevisible = O:AttachSlider(scrolling, "Fade after (s)", db, "timevisible", 1, 30, 1, false, slider_width, true)
	O:AttachSpacer(scrolling, 5)
	-- align
	local align_list = {[1] = "CENTER", [2] = "LEFT", [3] = "RIGHT"}
	O:AttachDropdown(scrolling, "Alignment", db, "align", align_list, slider_width)
	-- inline docu
	O:AttachLabel(scrolling, " ", GameFontHighlightSmall, nil, 1)
	local text = "Shift + Left Click for moving the frame. Right Click for closing the frame. Mousewheel to scroll through the text."
	O:AttachLabel(scrolling, text, GameFontHighlightSmall, nil, 1)
end

-- creates the info tab
function O:DrawInfoOptions(container)
	O:AttachHeader(container, "Addon Info")
	local text = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR
	local description = O:AttachLabel(container, text, GameFontHighlight)
end

-- creates / refreshes the profiles tab
function O:DrawProfileOptions(container)
	dprint(2, "O:CreateProfileOptions", container)
	-- get options table and override order
	O.config.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	-- register options table and assign to frame
	A.Libs.AceConfig:RegisterOptionsTable("AlertMeProfile", O.config.profiles)
	A.Libs.AceConfigDialog:Open("AlertMeProfile", container)
end

--*******************************************************************************************************************************************
-- helper function for AceGUI
function O:AttachSlider(container, label, db, key, min, max, step, isPercent, width, scrolling)
	local slider = A.Libs.AceGUI:Create("Slider")
	slider:SetLabel(label)
	slider:SetSliderValues(min, max, step)
	slider:SetIsPercent(isPercent)
	slider:SetValue(db[key])
	slider:SetCallback("OnMouseUp", function(widget, event, value)
		--dprint(1, widget, event, value)
		--VDT_AddData(db,"dbslider")
		db[key] = value
		if scrolling == true then A:ScrollingTextInitOrUpdate() end
	end)
	if width then slider:SetWidth(width) end
	container:AddChild(slider)
	return slider
end


function O:AttachHeader(container, text)
	local header = A.Libs.AceGUI:Create("Heading")
	header:SetText(text)
	header.width = "fill"
	container:AddChild(header)
	return header
end

function O:AttachButton(container, text, width)
	local button = A.Libs.AceGUI:Create("Button")
	button:SetText(text)
	if width then button:SetWidth(width) end
	container:AddChild(button)
	return button
end

function O:AttachGroup(container, title, inline)
	local group = {}
	if inline == true then
		group = A.Libs.AceGUI:Create("InlineGroup")
		group:SetTitle(title)
	else
		group = A.Libs.AceGUI:Create("SimpleGroup")
	end
	group:SetRelativeWidth(1)
	group:SetLayout("Flow")
	container:AddChild(group)
	return group
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

function O:AttachInteractiveLabel(container, text, font_object, color, relative_width)
	local label = A.Libs.AceGUI:Create("Label")
	label:SetText(text)
	label:SetRelativeWidth(relative_width or 1)
	if font_object == nil then font_object = GameFontHighlight end -- GameFontHighlightLarge, GameFontHighlightSmall
	label:SetFontObject(font_object)
	--label:SetHighlight(0.7,0.7,0.7,1)
	if color ~= nil then label:SetColor(color[1], color[2], color[3]) end
	container:AddChild(label)
	return label
end

function O:AttachSpacer(container, width)
	local control = A.Libs.AceGUI:Create("InteractiveLabel")
	control:SetText("")
	control:SetWidth(width)
	container:AddChild(control)
	return control
end

function O:AttachCheckBox(container, label, db, key, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	control:SetValue(db[key])
	control:SetCallback("OnValueChanged", function(widget, event, value) db[key] = value end)
	control:SetLabel(label)
	if width then control:SetWidth(width) end
	container:AddChild(control)
	return control
end

function O:AttachDropdown(container, label, db, key, list, width)
	local dropdown = A.Libs.AceGUI:Create("Dropdown")
	dropdown:SetLabel(label)
	dropdown:SetMultiselect(false)
	dropdown:SetWidth(width)
	dropdown:SetList(list)
	dropdown:SetValue(db[key])
	dropdown:SetCallback("OnValueChanged", function(_, _, value) db[key] = value end)
	container:AddChild(dropdown)
	return dropdown
end

function O:AttachIcon(container, image, size)
	local icon = A.Libs.AceGUI:Create("Icon")
	icon:SetImage(image)
	icon:SetImageSize(size, size)
	icon:SetWidth(size)
	container:AddChild(icon)
	return icon
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
