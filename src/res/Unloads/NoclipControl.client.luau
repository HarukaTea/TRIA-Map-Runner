
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local PlayerScripts = plr:FindFirstChildOfClass("PlayerScripts")
local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule", 999))
local ControlModule = PlayerModule:GetControls()


local noclip = script.Parent :: HopperBin


local function _getNextMovement(deltaTime) : Vector3
    local nextMove = ControlModule:GetMoveVector() or Vector3.zero

    if UIS:IsKeyDown("Space") then
        nextMove = Vector3.new(nextMove.X, 1, nextMove.Z)

    elseif UIS:IsKeyDown("LeftControl") then
        nextMove = Vector3.new(nextMove.X, nextMove.Y - 1, nextMove.Z)
    end

    nextMove = nextMove.Magnitude > 1 and nextMove.Unit or nextMove
    nextMove = nextMove * deltaTime * (ReplicatedStorage:GetAttribute("_HARUKA_GlobalNoclipSpeed") or 60)

    return nextMove
end

local conn: RBXScriptConnection = nil
local function onSelected()
    local char = Players.LocalPlayer.Character

    if char then
        local humanoid = char:WaitForChild("Humanoid")
        local HRP = humanoid.RootPart
        local head = char:WaitForChild("Head") :: BasePart
        local camera = workspace.CurrentCamera

        HRP.Anchored = true
        HRP.Velocity = Vector3.zero
        HRP.CanTouch = false

        humanoid.PlatformStand = true
        head.CanTouch = false

        conn = RunService.Heartbeat:Connect(function(dt)
            local movement = _getNextMovement(dt)

            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + camera.CFrame.LookVector) * CFrame.new(movement)
        end)
    end
end
local function onDeselected()
    local char = Players.LocalPlayer.Character

    if conn then conn:Disconnect() end
    if char then
        local humanoid = char:WaitForChild("Humanoid")
        local HRP = humanoid.RootPart
        local head = char:WaitForChild("Head")

        HRP.Anchored = false
        HRP.Velocity = Vector3.zero
        humanoid.PlatformStand = false

        HRP.CanTouch = true
        head.CanTouch = true

        --// avoid fling
        HRP.CFrame = CFrame.fromOrientation(
            -math.pi / 4,
            (select(2, HRP.CFrame:ToOrientation())),
            0
        ) + HRP.Position
    end
end
noclip.Equipped:Connect(onSelected)
noclip.Unequipped:Connect(onDeselected)