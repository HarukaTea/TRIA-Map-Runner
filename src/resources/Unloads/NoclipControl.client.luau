--!nocheck

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local tool = script.Parent :: Tool
local selected = false
local lastUpdate = 0

local wait = task.wait
local v3New, xAxis, yAxis, zAxis = Vector3.new, Vector3.xAxis, Vector3.yAxis, Vector3.zAxis
local cfNew = CFrame.new

local function _getNextMovement(deltaTime)
	local nextMove = v3New()

	if UIS:IsKeyDown("A") or UIS:IsKeyDown("Left") then
		nextMove = -xAxis
	elseif UIS:IsKeyDown("D") or UIS:IsKeyDown("Right") then
		nextMove = xAxis
	end

	if UIS:IsKeyDown("W") or UIS:IsKeyDown("Up") then
		nextMove -= zAxis
	elseif UIS:IsKeyDown("S") or UIS:IsKeyDown("Down") then
		nextMove += zAxis
	end

	if UIS:IsKeyDown("Space") then
		nextMove += yAxis
	elseif UIS:IsKeyDown("LeftControl") then
		nextMove -= yAxis
	end

	local speed = script.Parent:GetAttribute("Speed")
	return cfNew( nextMove * (speed * deltaTime) )
end

local function onSelected()
	local char = Players.LocalPlayer.Character

	if char then
		local humanoid = char:WaitForChild("Humanoid")
        local HRP = humanoid.RootPart
        local camera = workspace.CurrentCamera

        selected = true
        HRP.Anchored = true
        humanoid.PlatformStand = true

		lastUpdate = tick()

		while selected do
			wait()
			local delta = tick() - lastUpdate
			local look = (camera.Focus.Position - camera.CFrame.Position).Unit :: Vector3
			local move = _getNextMovement(delta)
			local pos = HRP.Position

			HRP.CFrame = cfNew(pos, pos + look) * move
			lastUpdate = tick()
		end

		HRP.Anchored = false
		HRP.Velocity = v3New()
		humanoid.PlatformStand = false
	end
end

local function onDeselected()
	selected = false
end

tool.Selected:Connect(onSelected)
tool.Deselected:Connect(onDeselected)
