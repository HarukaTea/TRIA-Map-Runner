--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")



Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if not hit then return end

    local action = hit:GetAttribute("_action") :: string?

    if action == "WalkSpeed" then
        local power = hit:GetAttribute("WalkSpeed") or 20
        local style = hit:GetAttribute("EasingStyle")
        local duration = hit:GetAttribute("TweenDuration") or 3

        if style then
            HarukaLib:CreateTween(char.Humanoid, TweenInfo.new(
                duration, Enum.EasingStyle[style], Enum.EasingDirection.InOut
            ), {
                WalkSpeed = power
            }):Play()
        else
            char.Humanoid.WalkSpeed = power
        end

    elseif action == "JumpPower" then
        local power = hit:GetAttribute("JumpPower") or 50
        local style = hit:GetAttribute("EasingStyle")
        local duration = hit:GetAttribute("TweenDuration") or 3

        if style then
            HarukaLib:CreateTween(char.Humanoid, TweenInfo.new(
                duration, Enum.EasingStyle[style], Enum.EasingDirection.InOut
            ), {
                JumpPower = power
            }):Play()
        else
            char.Humanoid.JumpPower = power
        end

    elseif action == "Kill" then
        char.Humanoid.Health = -1

    elseif action == "Gravity" then
        local power = hit:GetAttribute("Gravity") or 196.2
        local style = hit:GetAttribute("EasingStyle")
        local duration = hit:GetAttribute("TweenDuration") or 3

        if style then
            HarukaLib:CreateTween(workspace, TweenInfo.new(
                duration, Enum.EasingStyle[style], Enum.EasingDirection.InOut
            ), {
                Gravity = hit:GetAttribute("Gravity") or 196.2
            }):Play()
        else
            workspace.Gravity = power
        end

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
