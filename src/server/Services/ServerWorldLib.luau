
local MaterialService = game:GetService("MaterialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")


local ServerWorldLib = {}

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local wait = task.wait


function ServerWorldLib:Init()
    for funcId: string, func: (self) -> nil in ServerWorldLib do
        if string.find(funcId, "_Do") and typeof(func) == "function" then
            Promise.try(func, self):catch(function(err)
                warn(tostring(err))
            end):await()
        end
    end
end


--// Private functions



function ServerWorldLib:_DoMakeAllModelsPersistent()
    local function _setPersistent(ins: Instance)
		if ins:IsA("Model") then ins.ModelStreamingMode = Enum.ModelStreamingMode.Persistent end
	end
	for _, child: Instance in workspace:GetDescendants() do
		_setPersistent(child)
	end
	workspace.DescendantAdded:Connect(_setPersistent)
	workspace.ChildAdded:Connect(_setPersistent)
end



function ServerWorldLib:_DoMapOptimization()
    for _, pathLink: PackageLink in ReplicatedStorage:GetDescendants() do
        if pathLink:IsA("PackageLink") then
            pathLink:Destroy()
        end
    end
    for _, part: BasePart in workspace:GetDescendants() do
        if HarukaLib:IsBasePartType(part) then
            part.EnableFluidForces = false
        end
    end


    local function _optimize(container: Instance)
        for _, part: BasePart in container:GetDescendants() do
            if HarukaLib:IsBasePartType(part) then
                part.EnableFluidForces = false

                if part.Material == Enum.Material.Plastic then
                    part.Material = Enum.Material.SmoothPlastic
                end
            end
        end
    end
    _optimize(workspace)
    _optimize(ReplicatedStorage)
end



function ServerWorldLib:_DoInitSoundGroups()
    ReplicatedStorage.Packages.Unloads.Underwater.Parent = SoundService
	ReplicatedStorage.Packages.Sounds.Parent = SoundService


    for _, sound: Sound in SoundService.Sounds:GetDescendants() do
        if sound:IsA("Sound") then sound.SoundGroup = SoundService.Underwater end
    end
end


function ServerWorldLib:_DoInitMaterials2022()
    ReplicatedStorage.Packages.Unloads.Pre2022Materials.Parent = MaterialService

	for _, mat: MaterialVariant in MaterialService.Pre2022Materials:GetChildren() do
		mat.Parent = MaterialService
	end
end


return ServerWorldLib
