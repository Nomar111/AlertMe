dprint(3, "options.lua")
-- upvalues
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
-- (re)set some variables
O.config = {}

-- *************************************************************************************
-- open the options window
function O:OpenOptions()
	dprint(2, "O:OpenOptions")
	local function close()
		A:InitSpellOptions()
		A.RegisterCLEU("Options")
		A.Libs.AceGUI:Release(O.OptionsFrame)
		O.OptionsFrame = nil
	end
	-- check if already open
	if O.OptionsFrame ~= nil then
		close()
		return
	end
	-- create main frame for options
	local f = A.Libs.AceGUI:Create("Frame")
	f:SetTitle("AlertMe Options")
	f:EnableResize(true)
	f:SetLayout("Flow")
	f:SetCallback("OnClose", close)
	f:SetWidth(900)
	f:SetHeight(680)
	O.OptionsFrame = f
	-- create navigation
	O:CreateNavTree(f)
end

-- *************************************************************************************
-- creates navigation tree
function O:CreateNavTree(container)
	dprint(2, "O:CreateNavTree")
	-- function to draw the groupd
	local tree_structure = {}
	tree_structure[1] = {value = "general", text = "General"}
	tree_structure[2] = {value = "scrolling", text = "Scrolling Text"}
	tree_structure[3] = {value = "bars", text = "Bar Setup"}
	tree_structure[4] = {value = "messages", text = "Messages"}
	tree_structure[5] = {value = "alerts", text = "Alerts", children = {}}
	tree_structure[6] = {value = "profiles", text = "Profiles"}
	tree_structure[7] = {value = "info", text = "Info"}
	-- loop over events and add them as children of alerts
	for _, tbl in pairs(A.Events) do
		if tbl.optionsDisplay ~= nil and tbl.optionsDisplay == true then
			tree_structure[5].children[tbl.optionsOrder]  = {
				value = tbl.short,
				text = tbl.optionsText
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
	local function GroupSelected(widget, event, uniqueValue)
		dprint(2, widget, event, uniqueValue)
		-- release content
		widget:ReleaseChildren()

		-- create new content container
		local  contentGroup =  O.AttachGroup(widget, "simple", _,  {fullWidth = true, fullHeight = true , layout = "none"})
		local scrollGroup = A.Libs.AceGUI:Create("ScrollFrame")
		scrollGroup:SetLayout("List")
		scrollGroup:SetFullHeight(true)
		scrollGroup:SetFullWidth(true)
		scrollGroup.frame:SetBackdrop(nil)
		contentGroup:AddChild(scrollGroup)
		O:ShowOptions(scrollGroup, uniqueValue)
	end
	tree:SetCallback("OnGroupSelected", GroupSelected)
	container:AddChild(tree)
	--tree:SelectByPath(5)
end

function O:ShowOptions(container, uniqueValue)
	dprint(2, "O:ShowOptions", uniqueValue)
	local delim = "\001"
	local lvl1, lvl2 = strsplit(delim, uniqueValue)
	if lvl1 == "general" then O:ShowGeneral(container)
	elseif lvl1 == "scrolling" then O:ShowScrollingText(container)
	elseif lvl1 == "bars" then O:ShowBars(container)
	elseif lvl1 == "messages" then O:ShowMessages(container)
	elseif lvl1 == "profiles" then O:ShowProfiles(container)
	elseif lvl1 == "info" then O:ShowInfo(container)
	elseif lvl1 == "alerts" and lvl2 ~= nil then O:ShowAlerts(container, lvl2)
	end
end
