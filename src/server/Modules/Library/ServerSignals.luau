--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Shared.Shared.Signal).new

return {
    BtnPressed = Signal(),
    ReloadCharacter = Signal(),
}
