
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")


local lastJumped = tick()

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit
        and hit:GetAttribute("_action") == "Orb"
        and tick() - lastJumped > 0.07 then

        if char.PrimaryPart:FindFirstChild("Blackhole") then return end -- fix duplicate

        local orb = hit.Parent :: Model

        local orbType = orb:GetAttribute("Type") :: string
        local power = orb:GetAttribute("Power") :: number
        local timeout = orb:GetAttribute("Timeout") :: number

        if not orbType or not power or not timeout then return end --- check if orb is valid

        local bp = Instance.new("BodyPosition")
        bp.Name = "Blackhole"
        bp.D = 220
        bp.Position = hit.Position
        bp.MaxForce = Vector3.one * math.huge
        bp.Parent = char.PrimaryPart
        Debris:AddItem(bp, timeout)

        local oldSpeed, oldJump = char.Humanoid.WalkSpeed, char.Humanoid.JumpPower
        char.Humanoid.WalkSpeed = 0
        char.Humanoid.JumpPower = 0

        local jumped = false
        local now = tick()

        task.spawn(function()
            UIS.JumpRequest:Wait()

            jumped = true
        end)
        repeat RS.RenderStepped:Wait() until jumped or tick() - now > timeout

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
end))

--// Clear
char.Humanoid.Died:Once(Empty)