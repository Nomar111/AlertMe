-- set addon environment
setfenv(1, _G.AlertMe)

function O:ShowMessages(container)
	-- update chat frames
	InitChatFrames()
	-- set sv
	local db = P.messages
	-- header
	O.attachHeader(container, "Message Settings")
	O.attachCheckBox(container, "Enable addon messages", P.messages, "enabled", 300, _)
	O.attachSpacer(container, _, "small")
	O.attachCheckBox(container, "Enable chat announcements", P.messages, "chatEnabled", 300, _)
	O.attachSpacer(container, _, "small")
	-- chat frames
	local title = "Post addon messages in the following chat windows (only visible for you)"
	local chatFramesGroup = O.attachGroup(container, "inline", title, {fullWidth = true})
	for name, frame in pairs(chatFrames) do
		O.attachCheckBox(chatFramesGroup, name, db.chatFrames, frame, 150)
	end
	-- event specific messages
	O.attachHeader(container, "Event specific settings")
	O.attachEditBox(container, "Message on aura gained/refreshed", db, "gain", 1)
	O.attachEditBox(container, "Message on spell dispel", db, "dispel", 1)
	O.attachEditBox(container, "Message on cast start", db, "start", 1)
	O.attachEditBox(container, "Message on cast success", db, "success", 1)
	O.attachEditBox(container, "Message on interrupt", db, "interrupt", 1)
	O.attachEditBox(container, "Message prefix", db, "prefix", 200)
	O.attachEditBox(container, "Message postfix", db, "postfix", 200)
end
