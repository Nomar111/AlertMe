-- set addon environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	container:ReleaseChildren()
	-- update chat frames
	InitChatFrames()
	-- set sv
	local db = P.messages
	local tooltip
	-- header
	O.attachHeader(container, "Message Settings")
	local enableGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	tooltip = { lines = { "enable/disable addon messages", "which are only visible for you"}, wrap = false }
	O.attachCheckBox(enableGroup, "Enable addon messages", db, "enabled", 220, _, tooltip)
	O.attachSpacer(enableGroup, 20)
	tooltip = { lines = { "enable/disable chat announcements in:", "/raid /bg /party /say"}, wrap = false }
	O.attachCheckBox(enableGroup, "Enable chat announcements", db, "chatEnabled", 230, _, tooltip)
	O.attachSpacer(enableGroup, _, "small")
	-- chat frames
	local label = "Post addon messages (only visible for you) in:"
	local chatFramesGroup = O.attachGroup(container, "inline", label, {fullWidth = true})
	for name, frame in pairs(chatFrames) do
		O.attachCheckBox(chatFramesGroup, name, db.chatFrames, frame, 150)
	end
	-- event specific messages
	local function defaults()
		for handle, default in pairs(A.messages) do
			if P.messages[handle] then
				P.messages[handle] = default
			end
		end
		O:ShowMessages(container)
	end
	O.attachHeader(container, "Event specific settings")
	O.attachButton(container, "Reset to default", 150, defaults)
	O.attachSpacer(container, _, "small")
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %dstName, %spellName" } }
	O.attachEditBox(container, "Message on aura gained/refreshed", db, "gain", 1, _, tooltip)
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %dstName, %extraSpellName" } }
	O.attachEditBox(container, "Message on spell dispel", db, "dispel", 1, _, tooltip)
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %spellName, %targetName (= your target), %mouseoverName(= your mouseover)" } }
	O.attachEditBox(container, "Message on cast start", db, "start", 1, _, tooltip)
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %dstName, %spellName" } }
	O.attachEditBox(container, "Message on cast success", db, "success", 1, _, tooltip)
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %dstName, %spellName, %missType (= resisted, dodged...)" } }
	O.attachEditBox(container, "Message on spell missed", db, "missed", 1, _, tooltip)
	tooltip = { header = "Useful replacements:", lines = { "%srcName, %dstName, %extraSpellName, %lockout (= lockout in s), %extraSchool (= locked spell school)" } }
	O.attachEditBox(container, "Message on interrupt", db, "interrupt", 1, _, tooltip)
	local prefixGroup = O.attachGroup(container, "simple", _, {fullWidth = true})
	O.attachEditBox(prefixGroup, "Message prefix", db, "prefix", 200)
	O.attachSpacer(prefixGroup, 20)
	O.attachEditBox(prefixGroup, "Message postfix", db, "postfix", 200)
	-- label = "Usable replacements depending on event:\n%srcName, %dstName, %spellName, %extraSpellName, %extraSchool, %lockout, %targetName, %mouseoverName, %missType "
	-- O.attachLabel(container, label, _, _, _, 1)
end
