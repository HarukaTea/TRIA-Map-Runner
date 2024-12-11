--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local MaterialService = game:GetService("MaterialService")
local SSS = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local Signals = require(SSS.Server.Modules.Library.ServerSignals)


Signals.ReloadCharacter:Connect(function(plr: Player)
	plr.Character = nil

    local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
	local r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)

	r6Char.Name = plr.Name
	r6Char:PivotTo(CFrame.new(Vector3.yAxis * 1599))
	r6Char.Humanoid.DisplayName = plr.DisplayName
	r6Char.Animate:Destroy()

	for _, cScript in StarterPlayer.StarterCharacterScripts:GetChildren() do
		cScript:Clone().Parent = r6Char
	end
	plr.Character = r6Char

	r6Char.Parent = workspace
end)


local function setup()
	Players.CharacterAutoLoads = false

    RepS.Package.Unloads.Underwater.Parent = SoundService
	pcall(function()
		RepS.Package.Unloads.Pre2022Materials.Parent = MaterialService

		for _, mat: MaterialVariant in MaterialService.Pre2022Materials:GetChildren() do
			mat.Parent = MaterialService
		end
	end)

    RepS.Package.Sounds.Parent = workspace
    for _, sound: Sound in workspace.Sounds:GetDescendants() do
        if sound:IsA("Sound") then sound.SoundGroup = SoundService.Underwater end
    end


	local function _setPersistent(ins: Instance)
		if ins:IsA("Model") then ins.ModelStreamingMode = Enum.ModelStreamingMode.Persistent end
	end
	for _, child: Instance in workspace:GetDescendants() do
		_setPersistent(child)
	end
	workspace.DescendantAdded:Connect(_setPersistent)
	workspace.ChildAdded:Connect(_setPersistent)

	StarterPlayer.CharacterUseJumpPower = true


    workspace:SetAttribute("ServerInited", true)
end
setup()



