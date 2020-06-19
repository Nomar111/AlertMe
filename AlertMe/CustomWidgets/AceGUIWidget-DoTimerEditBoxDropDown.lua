local Type, Version = "EditBoxDropDown", 5
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[
This is a from-scratch AceGUI-style implementation of the combination drop-
down editboxes seen in DoTimer's option menus.  Typing in the editbox adds
entries to a list; clicking the scrolldown button displays the list in a
dropdown; clicking on an entry in the dropdown removes it from the list.

(This type of widget may actually have a more formal name already.  I first
encountered it in DoTimer, so that's what I named it after.)

The implementation does not borrow any of DoTimer's actual code.  I've tried
writing this to imitate the look-and-feel of an interface that many players
will find familiar and easy to use.

Version 2 is a rehash to follow the same form of the rest of the AceGUI widgets
after their rewrite, and to work with the new EditBox behavior.

Version 3 adds the EditBoxDropDownOptionControl variant, specifically for use
as a 'dialogControl' in AceConfig option tables.  Details follow; the more
disappointing restrictions are because AceConfig never gives the programmer any
direct link to the widgets in use.
- 'desc' option field ignored
- 'name' field may contain an embedded tab ('\t') followed by more text to be
  used as the tooltip text when hovering over the editbox field
- 'get' field must be a function, returning a function to be used as the
  OnTextEnterPressed callback; this is typically how new entries should be
  added to data
- 'values' field must be a function, returning the usual list of entries, PLUS
  the callback used for 'get' as a key, e.g., 
    values = function()
        local ret = build_real_dropdown_table()
        ret[get_callback] = true  -- assuming "function get_callback (widget, event, text) .... end"
        return ret
    end
  The callback will be immediately removed from the table, but is required to
  be present to pass tests in the AceConfig source.
- 'set' receives the key of the dropdown table, but that entry will already be
  removed by the time the 'set' function is called

Version 4 was never released.

Version 5 adds the OnDropdownShown callback.


EditBoxDropDown API

:SetLabel(txt)
   forwards to the editbox's SetLabel

:SetText(txt)
   forwards to the editbox's SetText

:SetEditBoxTooltip(txt)
   sets text for the tooltip shown when hovering over the editbox
   no default

:SetButtonTooltip(txt)
   sets text for the tooltip shown when hovering over the dropdown button
   default "Click on entries to remove them."

:SetList(t)
   T is a table to be shown in the dropdown list; the values will be displayed
   in the dropdown
   When entries are clicked, they will be removed from T.  T is not copied,
   the table is edited "live" before firing the callback below.


EditBoxDropDown Callbacks

OnTextEnterPressed
   same as the editbox's OnEnterPressed

OnListItemClicked
   similar to a Dropdown widget's OnValueChanged, the key and value from the
   table given to :SetList are passed

OnDropdownShown
   when the down arrow is clicked to display the list


farmbuyer@gmail.com
]]

local button_hover_text_default = "Click on entries to remove them."
local maps  -- from actual editbox frame back to this widget


local function Menu_OnClick (button, userlist_key, widget)
	local v = widget.list[userlist_key]
	widget.list[userlist_key] = nil
	widget.dropdown.is_on = nil
    -- firing these off changes widget contents, must be done last :-(
	widget:Fire("OnListItemClicked", userlist_key, v)
	widget:Fire("OnValueChanged", userlist_key)
end

local function BuildList (widget)
	local ret = {}
	if widget.list then for k,v in pairs(widget.list) do
		table.insert (ret, {
			text = tostring(v) or tostring(k),
			func = Menu_OnClick,
			arg1 = k,
			arg2 = widget,
			notCheckable = true,
		})
	end end
	return ret
end


local function ddEditBox_OnMouseEnter (editbox)
	if editbox.tooltip_text then
		GameTooltip:SetOwner(editbox.frame, "ANCHOR_RIGHT")
		GameTooltip:SetText(editbox.tooltip_text, nil, nil, nil, nil, 1)
	end
end

local function ddEditBox_OnMouseLeave (editbox_or_button)
	GameTooltip:Hide()
end

local function ddEditBox_Clear (editboxframe)
	editboxframe:SetText("")
end

local function ddEditBox_Reset (editboxframe)  -- :ClearFocus triggers this
	editboxframe:SetText(maps[editboxframe].editbox_basetext or "")
end

local function ddEditBox_OnEnterPressed (editbox, _, text)
	editbox.obj:Fire("OnTextEnterPressed", text)
	ddEditBox_Reset(editbox.editbox)
	editbox.editbox:ClearFocus()  -- cursor still blinking in there, one more time
end

local function Button_OnClick (button)
	local dd = button.obj.dropdown
	-- Annoyingly, it's very tedious to find the correct nested frame to use
	-- for :IsShown() here.  We'll avoid it all by using our own flag.
	if dd.is_on then
		dd.is_on = nil
		HideDropDownMenu(--[[level=]]1)   -- EasyMenu always uses top/1 level
	else
		dd.is_on = true
		local t = BuildList(button.obj)
		EasyMenu (t, button.obj.dropdown, button.obj.frame, 0, 0, "MENU")
		PlaySound("igMainMenuOptionCheckBoxOn")
		button.obj:Fire("OnDropdownShown")
	end
end

local function Button_OnEnter (button)
	if button.tooltip_text then
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		GameTooltip:SetText(button.tooltip_text, nil, nil, nil, nil, 1)
	end
end


--local base_SetWidth = AceGUI.WidgetBase.SetWidth
local methods = {
	["OnAcquire"] = function (self)
		self:SetHeight(20)
		self:SetWidth(100)
		self.button.tooltip_text = button_hover_text_default
		self:SetList(nil)
		self.editbox:DisableButton(true)

		maps = maps or {}
		maps[self.editbox.editbox] = self
	end,
--[=[
	["SetWidth"] = function (self, width)
		print("got",width)
		base_SetWidth(self, width)
		self.frame.width = width + 45
	end,

	["GetWidth"] = function (self)
		return self.frame:GetWidth() + 45
	end,
]=]
	["OnRelease"] = function (self)
		self.frame:ClearAllPoints()
		self.frame:Hide()
		self.editbox.tooltip_text = nil
		self.button.tooltip_text = nil
		self:SetList(nil)
		maps[self.editbox.editbox] = nil
	end,

	["SetParent"] = function (self, parent)
		self.frame:SetParent(nil)
		self.frame:SetParent(parent.content)
		self.parent = parent
		self.editbox:SetParent(parent)
	end,

	["SetText"] = function (self, text)
		self.editbox_basetext = text
		return self.editbox:SetText(text)
	end,

	["SetLabel"] = function (self, text)
		return self.editbox:SetLabel(text)
	end,

	["SetDisabled"] = function (self, disabled)
		self.editbox:SetDisabled(disabled)
		if disabled then
			self.button:Disable()
		else
			self.button:Enable()
		end
	end,

	["SetList"] = function (self, list)
		self.list = list
	end,

	["SetEditBoxTooltip"] = function (self, text)
		self.editbox.tooltip_text = text
	end,

	["SetButtonTooltip"] = function (self, text)
		self.button.tooltip_text = text
	end,
}

-- called with the 'name' entry
local function optcontrol_SetLabel (self, text)
    local name, desc = ('\t'):split(text)
    if desc then
        self:SetEditBoxTooltip(desc)
    end
    self.editbox:SetLabel(name)
end

local function optcontrol_SetValue (self, epcallback)
    -- set the callback
    self:SetCallback("OnTextEnterPressed", epcallback)
    -- remove the fake entry from the values table
    self.list[epcallback] = nil
end


local function Constructor(is_option_control)
	local num = AceGUI:GetNextWidgetNum(Type)

	-- Its frame becomes our widget frame, else its frame is never shown.  Gluing
	-- them together seems a little evil, but it beats making this widget into a
	-- formal containter.  Inspired by new-style InteractiveLabel.
	local editbox = AceGUI:Create("EditBox")
	local frame = editbox.frame
	editbox:SetHeight(20)
	editbox:SetWidth(100)
	--frame:SetWidth(frame:GetWidth()+15)
	--frame.width = frame:GetWidth() + 15
	editbox:SetCallback("OnEnter", ddEditBox_OnMouseEnter)
	editbox:SetCallback("OnLeave", ddEditBox_OnMouseLeave)
	editbox:SetCallback("OnEnterPressed", ddEditBox_OnEnterPressed)
	editbox.editbox:SetScript("OnEditFocusGained", ddEditBox_Clear)
	editbox.editbox:SetScript("OnEditFocusLost", ddEditBox_Reset)
	--editbox.editbox:SetScript("OnEscapePressed", ddEditBox_Reset)

	local button = CreateFrame("Button", nil, frame)
	button:SetHeight(20)
	button:SetWidth(24)
	button:SetPoint("LEFT", editbox.frame, "RIGHT", 0, 0)
	button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight","ADD")
	button:SetScript("OnClick", Button_OnClick)
	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", ddEditBox_OnMouseLeave)
	button.parent = frame

	local dropdown = CreateFrame("Frame", "AceGUI-3.0EditBoxDropDownMenu"..num, nil, "UIDropDownMenuTemplate")
	dropdown:Hide()

    local widget = {
        editbox   = editbox,
        button    = button,
        dropdown  = dropdown,
        frame     = frame,
        type      = Type
    }
	for method, func in pairs(methods) do
		widget[method] = func
	end
    editbox.obj, button.obj, dropdown.obj = widget, widget, widget
    if is_option_control then
        widget.is_option_control = true
        widget.SetLabel = optcontrol_SetLabel
        widget.SetValue = optcontrol_SetValue
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType (Type, Constructor, Version)

AceGUI:RegisterWidgetType (Type.."OptionControl", function() return Constructor(true) end, Version)

