--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

return {
    BtnPressed = Signal(),
    ReloadCharacter = Signal(),
}
