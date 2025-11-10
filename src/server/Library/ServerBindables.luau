
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    BtnPressed = Signal.new(),
    BtnTouched = Signal.new(),

    RToSpawnChar = Signal.new(),
}