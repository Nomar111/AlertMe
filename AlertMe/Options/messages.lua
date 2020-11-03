-- set addon environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	container:ReleaseChildren()
	-- update chat frames
	InitChatFrames()
	-- set sv
	local db = P.messages
	-- header
	O.attachHeader(container, "Message Settings")
	O.attachCheckBox(container, "Enable addon messages", db, "enabled", 300, _)
	O.attachSpacer(container, _, "small")
	O.attachCheckBox(container, "Enable chat announcements", db, "chatEnabled", 300, _)
	O.attachSpacer(container, _, "small")
	-- chat frames
	local label = "Post addon messages (only visible for you) in"
	local chatFramesGroup = O.attachGroup(container, "inline", "", {fullWidth = true})
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
	O.attachEditBox(container, "Message on aura gained/refreshed", db, "gain", 1)
	O.attachEditBox(container, "Message on spell dispel", db, "dispel", 1)
	O.attachEditBox(container, "Message on cast start", db, "start", 1)
	O.attachEditBox(container, "Message on cast success", db, "success", 1)
	O.attachEditBox(container, "Message on spell missed", db, "missed", 1)
	O.attachEditBox(container, "Message on interrupt", db, "interrupt", 1)
	O.attachEditBox(container, "Message prefix", db, "prefix", 200)
	O.attachEditBox(container, "Message postfix", db, "postfix", 200)
end
