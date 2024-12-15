--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if not hit then return end

    local action = hit:GetAttribute("_action") :: string?

    if action == "WalkSpeed" then
        char.Humanoid.WalkSpeed = hit:GetAttribute("WalkSpeed") or 20

    elseif action == "JumpPower" then
        char.Humanoid.JumpPower = hit:GetAttribute("JumpPower") or 50

    elseif action == "Kill" then
        char.Humanoid.Health = 0

    elseif action == "Gravity" then
        local style = hit:GetAttribute("EasingStyle") or "Linear"
        local duration = hit:GetAttribute("TweenDuration") or 1

        TS:Create(workspace, TweenInfo.new(
            duration, Enum.EasingStyle[style], Enum.EasingDirection.InOut
        ), {
            Gravity = hit:GetAttribute("Gravity") or 196.2
        }):Play()

    elseif action == "BouncePad" then
        local normal = hit.CFrame.UpVector

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.one * math.huge
        bv.Velocity = normal * (hit:GetAttribute("Power") or 100)
        bv.Parent = char.PrimaryPart

        Debris:AddItem(bv, 0.01)
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
