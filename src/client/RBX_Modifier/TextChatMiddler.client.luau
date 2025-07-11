--!nocheck

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)


TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    local properties = Instance.new("TextChatMessageProperties")

    if message.TextSource then
        local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
        if sender:IsDescendantOf(Players) then
            Bindables.PlayerChatted:Fire(message.Text, sender)
        end
    end

    return properties
end