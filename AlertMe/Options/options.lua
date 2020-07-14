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
	-- create main frame for options
	O.Frame = A.Libs.AceGUI:Create("Frame")
	O.Frame:SetTitle("AlertMe Options")
	O.Frame:EnableResize(false)
	O.Frame:SetLayout("Flow")
	O.Frame:SetCallback("OnClose", function(widget)
		A:InitSpellOptions()
		A.Libs.AceGUI:Release(widget)
	end)
	O.Frame:SetWidth(900)
	O.Frame:SetHeight(680)
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
	tree_structure[2] = {value = "scrolling", text = "Scrolling Text"}
	tree_structure[3] = {value = "bars", text = "Bar Setup"}
	tree_structure[4] = {value = "messages", text = "Messages"}
	tree_structure[5] = {value = "alerts", text = "Alerts", children = {}}
	tree_structure[6] = {value = "profiles", text = "Profiles"}
	tree_structure[7] = {value = "info", text = "Info"}
	-- loop over events and add them as children of alerts
	for _, tbl in pairs(A.Events) do
		if tbl.options_display ~= nil and tbl.options_display == true then
			tree_structure[5].children[tbl.options_order]  = {
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
	local function GroupSelected(widget, event, uniqueValue)
		-- delete whatever is shown on the right side
		widget:ReleaseChildren()
		-- hide scrollTable (not an Ace widget)
		if O.scrollTable ~= nil then O.scrollTable:Hide() end
		-- create new content container
		local contentGroup = A.Libs.AceGUI:Create("SimpleGroup")
		contentGroup:SetLayout("Flow")
		contentGroup.width = "fill"
		widget:AddChild(contentGroup)
		-- call function to draw the various settings  on the right
		O:ShowOptions(contentGroup, uniqueValue)
	end
	tree:SetCallback("OnGroupSelected", GroupSelected)
	container:AddChild(tree)
	tree:SelectByPath(5)
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
