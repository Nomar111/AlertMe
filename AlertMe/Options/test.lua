dprint(2, "test.lua")
-- upvalues
local _G, dprint, type, unpack, pairs, time, tostring, xpcall, tinsert = _G, dprint, type, unpack, pairs, time, tostring, xpcall, table.insert
local GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame = GameFontHighlight, GameFontHighlightLarge, GameFontHighlightSmall, CreateFrame
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:DrawTest(container)
	local spellNames = {}
	for spellName,_ in pairs(S.cache) do
		tinsert(spellNames, spellName)
	end
	VDT_AddData(spellNames, "spellNames")
	--local valueList = {"Suggestion 1", "Suggestion 2","Another Suggestion","One More Suggestion"}
	local maxButtonCount = 20
	local text = A.Libs.AceGUI:Create('EditBox-AutoComplete')
	text:SetValueList(spellNames)
	text:SetButtonCount(maxButtonCount)
	container:AddChild(text)

	local data = {}
	for i=1,200 do
		data[i] = {spellNames[i], "delete"}
	end

	VDT_AddData(data,"data")

	-- local data = {
	-- 	["cols"] = {
	-- 			{
	-- 				["value"] = function(min, max)
	-- 					return math.random(min, max)
	-- 				end},
	-- 				["args"] = {
	-- 					1,
	-- 					100,
	-- 				},
	-- 			}, -- [1] Column 1
	-- 			{
	-- 				["value"] = "Row 1, Col 2",
	-- 				["color"] = {
	-- 					["r"] = 1.0,
	-- 					["g"] = 1.0,
	-- 					["b"] = 1.0,
	-- 					["a"] = 1.0,
	-- 				},  -- Cell color
	-- 			}, -- [2] Column 2
	-- 		},
	-- 	}, -- [1] Row 1
	-- 	{
	-- 		["cols"] = {
	-- 			{
	-- 				["value"] = "Row 2, Col 1",
	-- 			}, -- [1] Column 1
	-- 			{
	-- 				["value"] = "Row 2, Col 2",
	-- 			}, -- [2] Column 2
	-- 		},
	-- 		["color"] = {
	-- 			["r"] = 0.0,
	-- 			["g"] = 1.0,
	-- 			["b"] = 1.0,
	-- 			["a"] = 1.0,
	-- 		},  -- Row color
	-- 	}, -- [2] Row 2
	-- }
	--
	-- local highlight = {
	-- 	["r"] = 1.0,
	-- 	["g"] = 0.9,
	-- 	["b"] = 0.0,
	-- 	["a"] = 0.5, -- important, you want to see your text!
	-- }

	local col1 = {
		["name"] = "Spallname",
		["width"] = 300.0,
		["align"] = "LEFT",
		["color"] = {
			["r"] = 242/255,
			["g"] = 242/255,
			["b"] = 242/255,
			["a"] = 1.0
					},
		["colorargs"] = nil,
		["bgcolor"] = {
			["r"] = 13/255,
			["g"] = 13/255,
			["b"] = 13/255,
			["a"] = 1.0
		},
		["defaultsort"] = "dsc",
		["sortnext"]= 4,
		["comparesort"] = function (cella, cellb, column)
			return cella.value < cellb.value;
		end,
		["DoCellUpdate"] = nil,
	}

	local col2 = {
		["name"] = "delete",
		["width"] = 100.0,
		["align"] = "LEFT",
		["color"] = {
			["r"] = 242/255,
			["g"] = 242/255,
			["b"] = 242/255,
			["a"] = 1.0
					},
		["colorargs"] = nil,
		["bgcolor"] = {
			["r"] = 13/255,
			["g"] = 13/255,
			["b"] = 13/255,
			["a"] = 1.0
		},
		["defaultsort"] = "dsc",
		["sortnext"]= 4,
		["comparesort"] = function (cella, cellb, column)
			return cella.value < cellb.value;
		end,
		["DoCellUpdate"] = nil,
	}

	-- local data = {
	-- 	{ "Sachmo", 12, 4 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- 	{ "Josua", 8, 2 },
	-- }
--cols, numRows, rowHeight, highlight, parent
	local table = A.Libs.ScrollingTable:CreateST({col1, col2}, 10, 15, nil, O.Frame.frame)
	table:SetData(data, true)
	table:EnableSelection(true)
	VDT_AddData(table,"table")

	table:RegisterEvents({
    ["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
		scrollingTable:ClearSelection()
		scrollingTable:SortData()
		dprint(1, rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ... )
    end})

	-- if data is updated
	--table:SortData()-- no need to call Refresh, it is called internally.
	-- if a color is updated
	--table:Refresh()
	container:AddChild(table)
	VDT_AddData(container,"container")
end
