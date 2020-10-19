-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function O:ShowGlow(container)
	dprint(3, "O:ShowGlow")
	local sliderWidth = 200
	local db = P.glow
	-- header
	O.AttachHeader(container, "Custom Glow Settings")
	local enableGroup = O.AttachGroup(container, "simple", _, {fullWidth = true})
	-- enable
	O.AttachCheckBox(enableGroup, "Enable aura bars", db ,"enabled", 140)
	O.AttachCheckBox(enableGroup, "Unlock bars", db ,"unlocked", 140, containerLock)
	O.AttachSpacer(container, _, "medium")
	-- buttons
end
