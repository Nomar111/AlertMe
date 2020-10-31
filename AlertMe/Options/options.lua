-- upvalues
local InCombatLockdown, strsplit = InCombatLockdown, strsplit
-- set addon environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}

-- *************************************************************************************
-- prepare the widgets & functions
local function showOptions(container, uniqueValue)			-- 	uniqueValue = the value from tree widget
	P.options.lastMenu = uniqueValue
	local lvl1, lvl2 = strsplit("\001", uniqueValue)
	if lvl1 == "showAlerts" and lvl2 then
		O[lvl1](O, container, lvl2)
	elseif lvl1 ~= "showAlerts" then
		O[lvl1](O, container)
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
	treeStructure[1] = {value = "showGeneral", text = "General"}
	treeStructure[2] = {value = "showScrollingText", text = "Scrolling Text"}
	treeStructure[3] = {value = "showBars", text = "Bar Setup"}
	treeStructure[4] = {value = "showMessages", text = "Messages"}
	treeStructure[5] = {value = "showGlow", text = "Glow"}
	treeStructure[6] = {value = "showAlerts", text = "Alerts", children = {}}
	treeStructure[7] = {value = "showProfiles", text = "Profiles"}
	treeStructure[8] = {value = "showInfo", text = "Info"}
	-- loop over alert submenus
	for handle, menu in pairs(menus) do
		treeStructure[6].children[menu.order]  = { value = handle, text = menu.text }
	end
	-- create the tree group
	local tree = A.Libs.AceGUI:Create("TreeGroup")
	tree:EnableButtonTooltips(false)
	tree.width = "fill"
	tree.height = "fill"
	tree:SetTree(treeStructure)
	tree:SetCallback("OnGroupSelected", groupSelected)
	tree:SelectByPath(strsplit("\001", P.options.lastMenu))			-- if initially called set the last selected menu
	container:AddChild(tree)
end

-- *************************************************************************************
-- open the options window
function O:openOptions()
	-- no options during combat - safety first!
	if InCombatLockdown() then
		print("Can't open AlertMe options because of ongoing combat.")
		return
	end
	-- callback for closing
	local function close()
		A:initSpellOptions()
		A.Libs.AceGUI:Release(O.options)
		O.options = nil
		A:hideAllGUIs()
	end
	-- check if already open
	if O.options then
		close()
		return
	end
	-- create main frame for options
	local f = A.Libs.AceGUI:Create("Frame")
	f:SetTitle("AlertMe Options")
	f:EnableResize(true)
	f:SetLayout("Flow")
	f:SetCallback("OnClose", close)
	f:SetWidth(840)
	f:SetHeight(670)
	O.options = f
	-- create navigation
	createNavTree(f)
end
