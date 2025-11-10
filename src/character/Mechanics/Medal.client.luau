
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")

local wait = task.wait


local function _handleMedal(medal: BasePart)
    wait()
    local sparkle = Instance.new('Sparkles')
    sparkle.SparkleColor = Color3.fromRGB(255, 255, 255)
    sparkle.Parent = medal

    medal.CanCollide = false
    medal.CanTouch = true
    medal.CanQuery = false


    Add(task.spawn(function()
        while wait(0.01) do
            medal.CFrame *= CFrame.Angles(0, math.rad(3), 0)
        end
    end))
end
for _, medal: BasePart in CollectionService:GetTagged("MedalEntity") do
    _handleMedal(medal)
end
Add(CollectionService:GetInstanceAddedSignal("MedalEntity"):Connect(_handleMedal))



Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if not hit then return end
    if not hit.Parent then return end

    if hit:HasTag("MedalEntity") then
        SoundService.Sounds.SFXs.MedalCollected:Play()

        hit:Destroy()
    end
end))


--// Clear
char.Humanoid.Died:Once(Empty)