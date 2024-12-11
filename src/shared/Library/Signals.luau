--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Shared.Shared.Signal)

local signals = {
    CreateHint = Signal.new()
}

return signals
