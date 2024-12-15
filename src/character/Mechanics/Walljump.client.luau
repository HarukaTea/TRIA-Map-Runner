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

local isWallJumping = false

Add(char.Humanoid.Touched:Connect(function()
    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = Ray.new(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit
            and (hit:GetAttribute("_action") == "WallJump" or hit:FindFirstChild("_WallJump"))
            and tick() - lastJumped > 0.07
            and not isWallJumping then

            isWallJumping = true

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

            local start = tick()
            local jumped = false
            task.spawn(function()
                UIS.JumpRequest:Wait()

                jumped = true
            end)

            repeat RS.RenderStepped:Wait()
                until jumped
                or tick() - start > (hit:GetAttribute("Timeout") or math.huge)

            lastJumped = tick()

            humanoid.AutoRotate = true
            char.PrimaryPart.Anchored = false

            walljumpAnim:Stop()
            if weld then weld:Destroy() end

            if jumped then
                local jp = char.Humanoid.JumpPower :: number

                char.PrimaryPart.Velocity = Vector3.new(
                    normal.X * jp,
                    jp + normal.Y * jp,
                    normal.Z * jp
                )
            else
                local jp = 25

                char.PrimaryPart.Velocity = Vector3.new(
                    normal.X * jp,
                    jp + normal.Y * jp,
                    normal.Z * jp
                )
            end

            isWallJumping = false
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
