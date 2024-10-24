--!nocheck

local TextChatService = game:GetService("TextChatService")

local chatWindow = TextChatService.ChatWindowConfiguration
local chatInput = TextChatService.ChatInputBarConfiguration
local bubbleChat = TextChatService.BubbleChatConfiguration

chatWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
chatWindow.BackgroundTransparency = 0.5
chatWindow.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
chatWindow.TextSize = 17

chatInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
chatInput.BackgroundTransparency = 0.3
chatInput.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
chatInput.TextSize = 15
chatInput.TextStrokeTransparency = 1

bubbleChat:ClearAllChildren()
bubbleChat.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bubbleChat.BackgroundTransparency = 0.15
bubbleChat.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
bubbleChat.TextSize = 16
bubbleChat.TextColor3 = Color3.new(1, 1, 1)
bubbleChat.BubbleDuration = 6
