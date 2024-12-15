--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator

local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(RepS.Package.Keyframes.WallHang)

local walljumpAnim = animator:LoadAnimation(animation)
local lastJumped = tick()

local isWallRunning = false

Add(char.Humanoid.Touched:Connect(function()
    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = Ray.new(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit
            and (hit:GetAttribute("_action") == "WallRun" or hit:FindFirstChild("_WallRun"))
            and tick() - lastJumped > 0.05
            and not isWallRunning then

            isWallRunning = true

            if hit:GetAttribute("UseFrontOnly") then
                local frontNormal = hit.CFrame.LookVector * 1

                if frontNormal:Dot(pos - hit.Position) <= 0 then return end
            end

            humanoid.AutoRotate = false
            char.PrimaryPart.Anchored = true
            char.PrimaryPart.CFrame = CFrame.new(char.PrimaryPart.Position, char.PrimaryPart.Position + normal)

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hit
            weld.Part1 = char.PrimaryPart
            weld.Parent = char.PrimaryPart

            walljumpAnim:Play()

            local jumped = false
            task.spawn(function()
                UIS.JumpRequest:Wait()

                jumped = true
            end)

            repeat
                RS.Heartbeat:Wait()

                local ray1, ray2 = Ray.new(char.PrimaryPart.Position, -char.PrimaryPart.CFrame.LookVector * 5), Ray.new(char.PrimaryPart.Position, hit:GetPivot().LookVector * -normal)
                local rHit1, _, rNormal1 = workspace:FindPartOnRay(ray1, char)
                local rHit2, _, rNormal2 = workspace:FindPartOnRay(ray2, char)

                local finalHit, finalNormal = nil, nil

                if rHit1 then finalHit, finalNormal = rHit1, rNormal1 end
                if rHit2 then finalHit, finalNormal = rHit2, rNormal2 end

                if finalHit then
                    RS.Heartbeat:Once(function(delta)
                        char.PrimaryPart.CFrame = CFrame.lookAlong(char.PrimaryPart.Position + (finalHit.CFrame.LookVector * (hit:GetAttribute("Speed") or 20) * delta), finalNormal)
                    end)

                    hit = finalHit
                    normal = finalNormal
                end
            until jumped or finalHit == nil

            lastJumped = tick()

            humanoid.AutoRotate = true
            char.PrimaryPart.Anchored = false

            walljumpAnim:Stop()
            if weld then weld:Destroy() end

            if jumped then
                local momentum = hit:GetAttribute("Momentum") or 0.88
                local speed = hit:GetAttribute("Speed") or 20
                local lookVector = char.PrimaryPart.CFrame.LookVector
                local jp = char.Humanoid.JumpPower

                local DEBUG_FACTOR = 0.95
                --// FIXME: this may be inaccurate, need to check again in TRIA 1.0
                char.PrimaryPart.Velocity = hit:GetPivot().LookVector * (speed * momentum) + Vector3.new(
                    lookVector.X * jp,
                    (lookVector.Y * jp + char.PrimaryPart.CFrame.UpVector.Y * jp) * DEBUG_FACTOR,
                    lookVector.Z * jp
                )
            else
                local jp = 15

                char.PrimaryPart.Velocity = Vector3.new(
                    normal.X * jp,
                    jp + normal.Y * jp,
                    normal.Z * jp
                )
            end

            isWallRunning = false
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
