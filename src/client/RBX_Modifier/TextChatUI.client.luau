--!nocheck

local TextChatService = game:GetService("TextChatService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)

local chatWindow = TextChatService.ChatWindowConfiguration
local chatInput = TextChatService.ChatInputBarConfiguration
local bubbleChat = TextChatService.BubbleChatConfiguration
local channelTab = TextChatService.ChannelTabsConfiguration

chatWindow.BackgroundColor3 = Components.BLACK_COLOR
chatWindow.BackgroundTransparency = 0.5
chatWindow.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
chatWindow.TextSize = 17
chatWindow.WidthScale = 0.1599 * 5
chatWindow.TextColor3 = Components.WHITE_COLOR

chatInput.BackgroundColor3 = Components.BLACK_COLOR:Lerp(Color3.fromRGB(), 0.5)
chatInput.BackgroundTransparency = 0.3
chatInput.TextColor3 = Components.WHITE_COLOR
chatInput.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
chatInput.TextSize = 15
chatInput.TextStrokeTransparency = 1

bubbleChat:ClearAllChildren()
bubbleChat.BackgroundColor3 = Components.BLACK_COLOR
bubbleChat.BackgroundTransparency = 0.15
bubbleChat.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
bubbleChat.TextSize = 16
bubbleChat.TextColor3 = Components.WHITE_COLOR
bubbleChat.BubbleDuration = 6
bubbleChat.LocalPlayerStudsOffset = -Vector3.yAxis * 2
bubbleChat.VerticalStudsOffset = 2
bubbleChat.MaxDistance = 159

channelTab.Enabled = false