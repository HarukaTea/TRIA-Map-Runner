--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local function setup()
    RepS.Package.Unloads.Underwater.Parent = SoundService

    RepS.Package.Sounds.Parent = workspace
    for _, sound: Sound in workspace.Sounds:GetDescendants() do
        if sound:IsA("Sound") then sound.SoundGroup = SoundService.Underwater end
    end
end
setup()
