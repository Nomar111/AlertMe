-- get addon environment
local AlertMe = _G.AlertMe
-- wow upvalues
local print = print
-- misc upvalues
local LibStub = LibStub
-- set addon environment as new global environment
setfenv(1, AlertMe)

-- init AceGUI
local AceGUI = LibStub("AceGUI-3.0")
-- Create a container frame
local frame = AceGUI:Create("Frame")
frame:SetTitle("Example Frame")
frame:SetStatusText("AceGUI-3.0 Example Container Frame")
frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
frame:SetLayout("Flow")
-- editbox
local editbox = AceGUI:Create("EditBox")
editbox:SetLabel("Insert text:")
editbox:SetWidth(200)
editbox:SetCallback("OnEnterPressed", function(widget, event, text) textStore = text end)
frame:AddChild(editbox)
-- button
local button = AceGUI:Create("Button")
button:SetText("Click Me!")
button:SetWidth(200)
button:SetCallback("OnClick", function() print(textStore) end)
frame:AddChild(button)
