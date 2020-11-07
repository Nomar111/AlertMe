-- upvalues
local InCombatLockdown, strsplit = InCombatLockdown, strsplit
-- set addon environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}
O.Widgets = {}

-- *************************************************************************************
-- prepare the widgets & functions
local function showOptions(container, uniqueValue)			-- 	uniqueValue = the value from tree widget
	P.options.lastMenu = uniqueValue
	local lvl1, lvl2 = strsplit("\001", uniqueValue)
	if lvl1 == "ShowAlerts" and lvl2 then
		if O[lvl1] then
			O[lvl1](O, container, lvl2)
		end
	elseif lvl1 ~= "ShowAlerts" then
		if O[lvl1] then
			O[lvl1](O, container)
		end
	end
end

local function groupSelected(widget, event, uniqueValue)	-- will be the callback function for clicking a tree item
	-- release content
	widget:ReleaseChildren()
	-- create new content container
	local contentGroup =  O.attachGroup(widget, "simple", _,  {fullWidth = true, fullHeight = true , layout = "none"})
	local scrollGroup = A.Libs.AceGUI:Create("ScrollFrame")
	scrollGroup:SetLayout("List")
	scrollGroup:SetFullHeight(true)
	scrollGroup:SetFullWidth(true)
	contentGroup:AddChild(scrollGroup)
	showOptions(scrollGroup, uniqueValue)
end

local function createNavTree(container)
	-- function to draw the groupd
	local treeStructure = {}
	treeStructure[1] = {value = "ShowGeneral", text = "General"}
	treeStructure[2] = {value = "ShowScrollingText", text = "Scrolling Text"}
	treeStructure[3] = {value = "ShowBars", text = "Bar Setup"}
	treeStructure[4] = {value = "ShowMessages", text = "Messages"}
	treeStructure[5] = {value = "ShowGlow", text = "Glow"}
	treeStructure[6] = {value = "ShowAlerts", text = "Alerts", children = {}}
	treeStructure[7] = {value = "ShowProfiles", text = "Profiles"}
	treeStructure[8] = {value = "ShowInfo", text = "Info"}
	-- loop over alert submenu
	for handle, menu in pairs(A.menus) do
		treeStructure[6].children[menu.order]  = { value = handle, text = menu.text }
	end
	-- create the tree group
	local tree = A.Libs.AceGUI:Create("TreeGroup")
	tree:EnableButtonTooltips(false)
	tree.width = "fill"
	tree.height = "fill"
	tree:SetTree(treeStructure)
	tree:SetCallback("OnGroupSelected", groupSelected)
	tree:SelectByPath(strsplit("\001", P.options.lastMenu))
	tree:SetTreeWidth(150)		-- if initially called set the last selected menu
	container:AddChild(tree)
end

-- *************************************************************************************
-- open the options window
function O:OpenOptions()
	-- no options during combat - safety first!
	if InCombatLockdown() then
		print("Can't open AlertMe options because of ongoing combat.")
		return
	end
	-- callback for closing
	local function close(widget,...)
		O.Popup:closeAll()		-- close all popups
		O.Widgets = nil			-- delete pointers to widgets
		O.Widgets = {}
		O.Options = nil
		A.Libs.AceGUI:Release(widget)
		A:InitSpellOptions()
		A:HideAllGUIs()			-- hide all bars/glows
	end
	-- check if already open
	if O.Options then
		close(O.Options)
		return
	end
	-- create main frame for options
	local f = A.Libs.AceGUI:Create("Frame")
	f:SetTitle("AlertMe Options")
	f:EnableResize(true)
	f:SetLayout("Flow")
	f:SetCallback("OnClose", close)
	f:SetWidth(720)
	f:SetHeight(620)
	O.Options = f
	-- create navigation
	createNavTree(f)
end

function O:ReOpenOptions()
	if O.Options then
		local widget = O.Options
		O.Options = nil
		A.Libs.AceGUI:Release(widget)
		O:OpenOptions()
	end
end
