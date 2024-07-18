--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

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
                or hit:FindFirstChild("_WallJump")
                or hit:GetAttribute("_action") == "WallRun"
            )
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

            --// wallrun
            local bv: BodyVelocity = nil
            if hit:GetAttribute("_action") == "WallRun" then
                char.PrimaryPart.Anchored = false

                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.one * 10000
                bv.Velocity = CFrame.new(char.PrimaryPart.Position, (hit.CFrame * CFrame.new(0, 0, -hit.Size.Z / 2)).Position).LookVector * hit:GetAttribute("Speed")
                bv.Parent = char.PrimaryPart

                char.PrimaryPart.Velocity = CFrame.new(char.PrimaryPart.Position, (hit.CFrame * CFrame.new(0, 0, -hit.Size.Z / 2)).Position).LookVector * hit:GetAttribute("Speed")
            end

            local start = tick()
            local jumped = false
            Spawn(function()
                UserInputService.JumpRequest:Wait()
                jumped = true
            end)

            if hit:GetAttribute("_action") == "WallRun" then
                repeat RunService.RenderStepped:Wait()
                    until jumped
                    or (char.PrimaryPart.Position - (hit.CFrame * CFrame.new(0, 0, -hit.Size.Z / 2)).Position).Magnitude < 1.2
                    or hit.Size.Z < (char.PrimaryPart.Position - hit.Position).Magnitude

            elseif (hit:GetAttribute("_action") == "WallJump" or hit:FindFirstChild("_WallJump")) then
                repeat RunService.RenderStepped:Wait()
                    until jumped
                    or tick() - start > (hit:GetAttribute("Timeout") or math.huge)
            end

            lastJumped = tick()

            if bv then bv:Destroy() end
            humanoid.AutoRotate = true
            char.PrimaryPart.Anchored = false

            walljumpAnim:Stop()

            if jumped then
                local momentum = hit:GetAttribute("Momentum") or 1

                char.PrimaryPart.Velocity = Vector3.new(
                    normal.X * 50,
                    50 * momentum + normal.Y * 50,
                    normal.Z * 50
                )

                walljumpAnim:Stop()
            else
                char.PrimaryPart.Velocity = Vector3.new()
                walljumpAnim:Stop()
            end
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
