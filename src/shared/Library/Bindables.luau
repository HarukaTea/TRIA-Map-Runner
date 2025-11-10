
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    --@params: `(msg: string, color: string, duration: number)`
    CreateHint = Signal.new(),

    --@params: `(msg: string, sender: Player)`
    PlayerChatted = Signal.new(),

    --@params: `None`
    TRIA_SkillCancel = Signal.new()
}