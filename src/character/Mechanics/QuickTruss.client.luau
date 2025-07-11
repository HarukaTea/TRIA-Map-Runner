--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local humanoid = char.Humanoid :: Humanoid

local lastTick = tick()
local climbingState = Enum.HumanoidStateType.Climbing


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")


--// Private
local function _trussStartJump()
    humanoid:SetStateEnabled(climbingState, false)

    lastTick = tick()

    local currentVel = char.PrimaryPart.Velocity
    char.PrimaryPart.Velocity = Vector3.new(currentVel.X, 0, currentVel.Z)

    if not humanoid:GetStateEnabled(climbingState) then
        task.delay(0.2, function()
            if tick() - lastTick >= 0.2 then humanoid:SetStateEnabled(climbingState, true) end
        end)
    end

    char.PrimaryPart.Velocity = Vector3.new(currentVel.X, 55, currentVel.Z)
end
local function _trussEndJump()
    if tick() < lastTick + 0.1 then
        char.PrimaryPart.CFrame *= CFrame.new(0, 0, 0.1)

        local currentVel = char.PrimaryPart.Velocity
        char.PrimaryPart.Velocity = Vector3.new(currentVel.X, humanoid.JumpPower * 1.1, currentVel.Z)
    end
end

--// Connections
Add(RunService.PostSimulation:Connect(function()
    if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        if humanoid:GetStateEnabled(climbingState) then
            _trussStartJump()
            _trussEndJump()

            local currentVel = char.PrimaryPart.Velocity
            char.PrimaryPart.Velocity = Vector3.new(
                currentVel.X,
                math.clamp(currentVel.Y, -100000, humanoid.JumpPower * 1.1),
                currentVel.Z
            )
        end
    end
end))
Add(humanoid.Jumping:Connect(function(isJumping: boolean)
    if isJumping and humanoid:GetStateEnabled(climbingState) then
        _trussStartJump()
        _trussEndJump()

        local currentVel = char.PrimaryPart.Velocity
        char.PrimaryPart.Velocity = Vector3.new(
            currentVel.X,
            math.clamp(currentVel.Y, -100000, humanoid.JumpPower * 1.1),
            currentVel.Z
        )
    end
end))
Add(humanoid.Climbing:Connect(function()
    lastTick = tick()
end))
Add(humanoid.FallingDown:Connect(function()
    char.PrimaryPart.Velocity = Vector3.zero

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end))

--// Clear
humanoid.Died:Once(Empty)
