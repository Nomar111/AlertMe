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
		elseif lvl1 == "events" then O:DrawTest(container)
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
	local cb1 = O:AttachCheckBox(zones, "Battlegrounds", P.general.zones.bg, 150)
	local cb2 = O:AttachCheckBox(zones, "World", P.general.zones.world)
	-- chat frames
	local chat_frames = O:AttachGroup(container, "Post addon messages in the following chat windows", true)
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			O:AttachCheckBox(chat_frames, name, P.general.chat_frames["ChatFrame"..i], 150)
		end
	end
	O:AttachCheckBox(container, "Test", P.general.test)
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
function O:AttachHeader(container, text)
	local header = A.Libs.AceGUI:Create("Heading")
	header:SetText(text)
	header.width = "fill"
	container:AddChild(header)
	return header
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

function O:AttachSpacer(container, width)
	local control = A.Libs.AceGUI:Create("InteractiveLabel")
	control:SetText("")
	control:SetWidth(width)
	container:AddChild(control)
	return control
end

function O:AttachCheckBox(container, label, db, width)
	local control = A.Libs.AceGUI:Create("CheckBox")
	control:SetValue(db)
	control:SetCallback("OnValueChanged", function(widget, event, value) db = value end)
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
