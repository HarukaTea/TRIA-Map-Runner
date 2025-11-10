
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    --@params: `(btnIndex: string)`
    BtnPressed = Signal.new(),

    --@params: `(btnType: string, index: number, button: Model)`
    BtnTouched = Signal.new(),

    --@params: `(player: Model)`
    RToSpawnChar = Signal.new(),
}