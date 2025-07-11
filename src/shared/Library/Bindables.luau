--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

local signals = {
    CreateHint = Signal.new(),

    PlaySound = Signal.new(),

    PlayerChatted = Signal.new(),
}

return signals
