dprint(2, "options.lua")
-- upvalues
local _G, dprint, FCF_GetNumActiveChatFrames, type, unpack, pairs, print = _G, dprint, FCF_GetNumActiveChatFrames, type, unpack, pairs, print
-- get engine environment
local A, _, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.options = nil
O.order = 1
O.elvl = 2 -- That's the level functions assume the events to be

-- *************************************************************************************
-- open the options window
function O:OpenOptions(tab)
	dprint(2, "O:OpenOptions")
	-- create main frame for options
	--if O.Frame == nil then
		O.Frame = A.Libs.AceGUI:Create("Frame")
		O.Frame:SetTitle("AlertMe Options")
		--Frame:SetStatusText("Version: "..ADDON_VERSION.." created by "..ADDON_AUTHOR)
		O.Frame:EnableResize(true)
		O.Frame:SetLayout("Flow")
		O.Frame:SetCallback("OnClose", function(widget) A.Libs.AceGUI:Release(widget) end)
		O.Frame:SetWidth(900)
		O.Frame:SetHeight(650)
	--else
		--O.Frame:Show()
	--end
	VDT_AddData(O.Frame, "OptionsFrame")
	O.Frame.userdata = {[1]="Rootframe"}
	O:CreateMainTree(O.Frame)
end

-- *************************************************************************************
-- creates the basic layout and first level tabs/tree
function O:CreateMainTree(container)
	dprint(2, "O:CreateMainTree")
	-- function to draw the groupd
	local tree_structure = {
		{
			value = "general",
			text = "General",
		},
		{
			value = "event",
			text = "Event specific",
		},
		{
			value = "alerts",
			text = "Alerts",
			children = {},
		},
		{
			value = "profiles",
			text = "Profiles",
		},
		{
			value = "info",
			text = "Info",
		}
	}
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
	-- callbacks
	-- cursor on button
	local function TreeOnButtonEnter(widget, event, uniquevalue, button)
		--dprint(1,"TreeOnButtonEnter",widget, event, uniquevalue, button)
		-- > AceConfigDialog
	end
	-- cursor leaves the area
	local function TreeOnButtonLeave(widget, event, value, button)
		--dprint(1,"TreeOnButtonLeave",widget, event, value, button)
		--AceConfigDialog.tooltip:Hide()
	end

	local function GroupSelected(widget, event, uniquevalue)
		dprint(1,"GroupSelected",widget, event, uniquevalue)
		VDT_AddData(widget, "widget")			local GroupContainer = A.Libs.AceGUI:Create("SimpleGroup")
		local user = widget.userdata
		VDT_AddData(user, "userdata")
		widget:ReleaseChildren()
		local GroupContainer = A.Libs.AceGUI:Create("SimpleGroup")
		if uniquevalue == "general" then


			--GroupContainer:SetTitle("General Settings")
			GroupContainer.width = "fill"
			GroupContainer:SetLayout("flow")
			widget:AddChild(GroupContainer)
			widget.hasChildGroups = true
			widget = GroupContainer
			local heading = A.Libs.AceGUI:Create("Heading")
			heading:SetText("Überschrift")
			heading:SetFullWidth(true)
			widget:AddChild(heading)
		end
	end
		--widget:GetUserDataTable()
		--widget:SetUserData(key, value)
		--widget:GetUserData(key)
		-- local user = widget:GetUserDataTable()
		-- local options = user.options
		-- local option = user.option
		-- local path = user.path
		-- local rootframe = user.rootframe
		-- local feedpath = new()
		-- for i = 1, #path do
		-- 	feedpath[i] = path[i]
		-- end
		-- --BuildPath(feedpath, ("\001"):split(uniquevalue))
		-- widget:ReleaseChildren()
		--AceConfigDialog:FeedGroup(user.appName,options,widget,rootframe,feedpath)
		--del(feedpath)
	tree:SetCallback("OnGroupSelected", GroupSelected)
	tree:SetCallback("OnButtonEnter", TreeOnButtonEnter)
	tree:SetCallback("OnButtonLeave", TreeOnButtonLeave)
	--OnTreeResize(width) - Fires when the tree was resized by the user.
	--[[
	SetTree(tree) - Set the tree to be displayed. See above for the format of the tree table.
	SelectByPath(...) - Set the path in the tree given the raw keys.
	SelectByValue(uniquevalue) - Set the path in the tree by a given unique value.
	EnableButtonTooltips(flag) - Toggle the tooltips on the tree buttons.
	SetStatusTable(table) - Set an external status table.
	]]
	--tree:SetStatusTable(status.groups)
	tree:SetTree(tree_structure)
	tree:SetUserData("tree",treedefinition)
	tree:SetUserData("config", {
		general = {
				header = "General Settings"
			},
		})
	--[[
	if container then
		f = container
		f:ReleaseChildren()
		f:SetUserData("appName", appName)
		f:SetUserData("iscustom", true)
		if #path > 0 then
			f:SetUserData("basepath", copy(path))
		end
		local status = AceConfigDialog:GetStatusTable(appName)
		if not status.width then
			status.width =  700
		end
		if not status.height then
			status.height = 500
		end
		if f.SetStatusTable then
			f:SetStatusTable(status)
		end
		if f.SetTitle then
			f:SetTitle(name or "")
		end
		]]
	container:AddChild(tree)
	-- APIs
	-- SetTree(tree) - Set the tree to be displayed. See above for the format of the tree table.
	-- SelectByPath(...) - Set the path in the tree given the raw keys.
	-- SelectByValue(uniquevalue) - Set the path in the tree by a given unique value.
	-- EnableButtonTooltips(flag) - Toggle the tooltips on the tree buttons.
	-- SetStatusTable(table) - Set an external status table.

end

function O:GroupSelected(...)
	dprint(1, "O:GroupSelected", ...)
	print("GroupSelected")
end

function O:TreeOnButtonEnter(...)
	dprint(1, "O:TreeOnButtonEnter", ...)
	print("TreeOnButtonEnter")
end

function O:TreeOnButtonLeave(...)
	dprint(1, "O:TreeOnButtonLeave", ...)
	print("TreeOnButtonLeave")
end


-- creates the general options tab
function O:CreateGeneralOptions(o)
	-- some local tables for populating dropdowns etc.
	local zone_types = {bg = "Battlegrounds", world = "World", raid = "Raid Instances"}
	-- header
	o.header = O:CreateHeader("General Options")
	-- zones multi
	o.zones = {
		type = 'multiselect',
		name = "Addon is enabled in",
		order = 1,
		values = zone_types,
	}
	-- chat frames multi
	o.chat_frames = {
		type = 'multiselect',
		name = "Display addon messages in the following chat windows",
		order = 10,
		values = O:GetChatFrameInfo(),
	}
	o.test = {
		type = "toggle",
		name = "test",
		order = 99,
	}
end

-- creates the info tab
function O:CreateInfoOptions(o)
	o.header = O:CreateHeader("Addon Info")
	o.addonInfo = {
		type = "description",
		name = "Addon Name: AlertMe\n\n".."installed Version: "..ADDON_VERSION.."\n\nCreated by: "..ADDON_AUTHOR,
		fontSize = "medium",
		order = 2
	}
end

-- creates / refreshes the profiles tab
function O:CreateProfileOptions()
	-- check if options table is initialized - this function may get called by other functions too
	if not O.options then return end
	-- get options table and override order
	O.options.args.profiles = A.Libs.AceDBOptions:GetOptionsTable(A.db)
	O.options.args.profiles.order = 4
end

-- return a table reference and key from info
function O:GetInfoPath(info, relative, num)
	--dprint(1, unpack(info))
	--dprint(1, "rel", relative, "num", num)
	local count = num
	if relative == true then count = (#info + num) end
	local path = P
	-- loop until lvl
	for i = 1, count do
		dprint(1, info[i])
		path = path[info[i]]
	end
	--dprint(1, "ofs", num, "returned path", path)
	return path
end

-- standard get
function O:GetOption(info, key)
	--dprint(1, "GetOption", "key", key, unpack(info))
	local offset = 0
	-- get parent object
	if key == nil then
		key = info[#info]
		offset = -1
	end
	local parent = O:GetInfoPath(info, true, offset)
	return parent[key]
end

-- standard set
function O:SetOption(info, arg2, value)
	--dprint(1, "SetOption", unpack(info))
	local offset = 0
	-- get parent object
	if value == nil then
		key = info[#info]
		offset = -1
		value = arg2
	else
		key = arg2
	end
	local parent = O:GetInfoPath(info, true, offset)
	parent[key] = value
end

-- create standard header
function O:CreateHeader(name, order)
	local header = {
		type = "header",
		name = name,
		order = (order ~= nil) and order or 1,
	}
	return header
end

-- create standard groups with order
function O:CreateGroup(name, desc, order, childGroups)
	-- increase order numbers automatically if not provided
	if order == nil then
		order = O.order
	end
	local group = {
		type = "group",
		name = name,
		desc = desc,
		childGroups = childGroups,
		order = order,
		args = {}
	}
	O.order = order + 1
	return group
end

function O:CreateSpacer(order, width)
	local spacer = {
		name = '',
		type = 'description',
		order = order,
		cmdHidden = true,
		width = width/10,
	}
	return spacer
end

function O:GetChatFrameInfo()
	local chat_frames = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		local name = _G["ChatFrame"..i.."Tab"]:GetText()
		if name ~= "Combat Log" then
			chat_frames["ChatFrame"..i] = name
		end
	end
	return chat_frames
end
