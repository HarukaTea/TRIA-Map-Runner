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

Add(char.Humanoid.Touched:Connect(function()
    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = Ray.new(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, char)

        if hit
            and (hit:GetAttribute("_action") == "WallJump"
                or hit:FindFirstChild("_WallJump"))
            and tick() - lastJumped > 0.07 then

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
            workspace.Sounds.SFXs.Walljump:Play()

            local start = tick()
            local jumped = false
            task.spawn(function()
                UserInputService.JumpRequest:Wait()

                jumped = true
            end)

            repeat RunService.RenderStepped:Wait()
                until jumped
                or tick() - start > (hit:GetAttribute("Timeout") or math.huge)

            lastJumped = tick()

            humanoid.AutoRotate = true
            char.PrimaryPart.Anchored = false

            walljumpAnim:Stop()

            if jumped then
                if weld then weld:Destroy() end

                local jp = char.Humanoid.JumpPower :: number

                char.PrimaryPart.Velocity = Vector3.new(
                    normal.X * jp,
                    jp + normal.Y * jp,
                    normal.Z * jp
                )


                walljumpAnim:Stop()
            else
                if weld then weld:Destroy() end

                char.PrimaryPart.Velocity = Vector3.new()

                walljumpAnim:Stop()
            end
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
