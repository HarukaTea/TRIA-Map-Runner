--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

return {
    CreateHint = Warp("CreateHint"),
    ChangeMusic = Warp("ChangeMusic"),
    ChangeLighting = Warp("ChangeLighting")
}
