--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator

local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(ReplicatedStorage.Package.Keyframes.WallHang)

local walljumpAnim = animator:LoadAnimation(animation)
local lastJumped = tick()

Add(RunService.Heartbeat:Connect(function()
    local allowJump = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if allowJump and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = Ray.new(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector.Unit)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit and hit:GetAttribute("_action") == "WallRun"
            and tick() - lastJumped > 0.07 then

            if hit:GetAttribute("UseFrontOnly") then
                local frontNormal = hit.CFrame.LookVector * 1

                if frontNormal:Dot(pos - hit.Position) <= 0 then return end
            end

            humanoid.AutoRotate = false
            char.PrimaryPart.Anchored = true
            char.PrimaryPart.CFrame = CFrame.new(char.PrimaryPart.Position, char.PrimaryPart.Position + normal)

            walljumpAnim:Play()
            workspace.Sounds.SFXs.Walljump:Play()

            local start = tick()
            local jumped = false
            task.spawn(function()
                UserInputService.JumpRequest:Wait()

                jumped = true
            end)

            repeat RunService.Heartbeat:Wait()

            local ray1, ray2 = Ray.new(char.PrimaryPart.Position, -normal), Ray.new(char.PrimaryPart.Position, hit:GetPivot().LookVector * -normal)
            local rHit1, _, rNormal1 = workspace:FindPartOnRay(ray1, char)
            local rHit2, _, rNormal2 = workspace:FindPartOnRay(ray2, char)

            local finalHit, finalNormal = nil, nil

            if rHit1 then finalHit, finalNormal = rHit1, rNormal1 end
            if rHit2 then finalHit, finalNormal = rHit2, rNormal2 end

            if finalHit then
                RunService.Heartbeat:Once(function(delta)
                    char.PrimaryPart.CFrame = CFrame.lookAlong(char.PrimaryPart.Position + (finalHit.CFrame.LookVector * (hit:GetAttribute("Speed") or 20) * delta), finalNormal)
                end)
            end

            until jumped or finalHit == nil

            lastJumped = tick()

            humanoid.AutoRotate = true
            char.PrimaryPart.Anchored = false

            walljumpAnim:Stop()

            if jumped then
                local momentum = hit:GetAttribute("Momentum") or 1
                local speed = hit:GetAttribute("Speed") or 20
                local lookVector = char.PrimaryPart.CFrame.LookVector
                local jp = char.Humanoid.JumpPower

                char.PrimaryPart.Velocity = hit:GetPivot().LookVector * (speed * momentum) + Vector3.new(
                    lookVector.X * jp,
                    lookVector.Y * jp + char.PrimaryPart.CFrame.UpVector.Y * jp,
                    lookVector.Z * jp
                )

                walljumpAnim:Stop()
            else
                local lookVector = char.PrimaryPart.CFrame.LookVector
                local jp = char.Humanoid.JumpPower

                char.PrimaryPart.Velocity = Vector3.new(
                    lookVector.X * jp,
                    lookVector.Y * jp + char.PrimaryPart.CFrame.UpVector.Y * jp,
                    lookVector.Z * jp
                )

                walljumpAnim:Stop()
            end
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
