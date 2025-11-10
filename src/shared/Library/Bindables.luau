
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

local signals = {
    CreateHint = Signal.new(),
    PlayerChatted = Signal.new(),

    TRIA_SkillCancel = Signal.new()
}

return signals