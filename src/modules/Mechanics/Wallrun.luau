--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Spawn = require(RepS.Modules.Packages.Spawn)

local Wallrun = {}
Wallrun.__index = Wallrun

local rayNew = Ray.new
local cfNew = CFrame.new
local v3New = Vector3.new
local instanceNew = Instance.new


function Wallrun:Stick()
    local humanoid = self.char.Humanoid :: Humanoid
    local HRP = humanoid.RootPart

    local isJumping = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
    local state = humanoid:GetState()

    local stateType = Enum.HumanoidStateType
    if isJumping and (state == stateType.Jumping or state == stateType.Freefall) then
        local ray = rayNew(HRP.Position, HRP.CFrame.LookVector * 2)
        local hit, pos, normal = workspace:FindPartOnRay(ray, self.char)

        if hit and hit:GetAttribute("_action") == "WallRun" and tick() - self.lastJumped > 0.02 then
            humanoid.AutoRotate = false
            humanoid.Sit = true

            self.WallrunAnim:Play()
            workspace.Sounds.SFXs.Walljump:Play()

            --- wallrun
            local bv = instanceNew("BodyVelocity")
            bv.MaxForce = v3New(10000, 10000, 10000)
            bv.Parent = HRP
            local bg = instanceNew("BodyGyro")
            bg.MaxTorque = v3New(10000, 10000, 10000)
            bg.D = 250
            bg.CFrame = hit.CFrame

            HRP.AssemblyLinearVelocity = cfNew(HRP.Position, (hit.CFrame * cfNew(0, 2.5, hit.Size.Z / 2 - 2)).Position).LookVector * hit:GetAttribute("Speed")
            bv.Velocity = cfNew(HRP.Position, (hit.CFrame * cfNew(0, 2.5, hit.Size.Z / 2 - 2)).Position).LookVector * hit:GetAttribute("Speed")

            local jumped = false
            Spawn(function()
                UIS.JumpRequest:Wait()

                jumped = true
            end)
            repeat RS.RenderStepped:Wait() until jumped

            self.lastJumped = tick()
            humanoid.AutoRotate = true
            humanoid.Sit = false
            humanoid.Jump = true

            bv:Destroy()
            bg:Destroy()
            self.WallrunAnim:Stop()

            HRP.AssemblyLinearVelocity = v3New(normal.X * 50, 50 + normal.Y * 50, normal.Z * 50)
        end
    end
end

return function (plr: Player)
    local self = setmetatable({}, Wallrun)

    local char = plr.Character or plr.CharacterAdded:Wait()
    local animator = char.Humanoid.Animator :: Animator
    self.char = char

    local animation = instanceNew("Animation")
    animation.AnimationId = KSP:RegisterKeyframeSequence(RepS.Package.Keyframes.Run)

    self.WallrunAnim = animator:LoadAnimation(animation)
    self.lastJumped = tick()

    char.Humanoid.Touched:Connect(function()
        self:Stick()
    end)
end