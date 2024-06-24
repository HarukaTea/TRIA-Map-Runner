--!nocheck

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local char = script.Parent.Parent :: Model

local lastJumped = tick()

char.Humanoid.RootPart.Touched:Connect(function(hit: BasePart)
    if hit
        and hit:GetAttribute("_action") == "Orb"
        and tick() - lastJumped > 0.1 then

        if char.PrimaryPart:FindFirstChild("Blackhole") then return end -- fix duplicate

        local orb = hit.Parent :: Model

        local orbType = orb:GetAttribute("Type") :: string
        local power = orb:GetAttribute("Power") or 300
        local timeout = orb:GetAttribute("Timeout") or 1.5

        local bp = Instance.new("BodyPosition")
        bp.Name = "Blackhole"
        bp.D = 220
        bp.Position = hit.Position
        bp.MaxForce = Vector3.one * math.huge
        bp.Parent = char.PrimaryPart
        Debris:AddItem(bp, timeout)

        workspace.Sounds.SFXs.Walljump:Play()

        local oldSpeed, oldJump = char.Humanoid.WalkSpeed, char.Humanoid.JumpPower
        char.Humanoid.WalkSpeed = 0
        char.Humanoid.JumpPower = 0

        local jumped = false
        local now = tick()

        Spawn(function()
            UserInputService.JumpRequest:Wait()

            jumped = true
        end)
        repeat RunService.RenderStepped:Wait() until jumped or tick() - now > timeout

        if bp then bp:Destroy() end
        char.Humanoid.WalkSpeed = oldSpeed
        char.Humanoid.JumpPower = oldJump

        lastJumped = tick()

        if not jumped then return end

        local vel: Vector3
        if orbType == "Launch" then
            vel = hit.Attachment.WorldSecondaryAxis * power
        elseif orbType == "Pivot" then
            vel = workspace.CurrentCamera.CFrame.LookVector * power
        end

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.one * math.huge
        bv.Velocity = vel
        bv.Parent = char.PrimaryPart
        Debris:AddItem(bv, 0.01)
    end
end)
