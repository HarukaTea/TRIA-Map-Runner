--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local events = {
    CreateHint = Warp("CreateHint")
}

return events
