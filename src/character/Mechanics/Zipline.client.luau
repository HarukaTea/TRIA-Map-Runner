--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local BezierLib = require(RepS.Modules.Packages.BezierLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator

local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(RepS.Package.Keyframes.Zipline)

local ziplineAnim = animator:LoadAnimation(animation)
local isRiding = false

local touchCD = false
Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit.Parent
        and hit:IsA("BasePart")
        and hit.Name == "StartOrb"
        and hit.Parent:IsA("Model")
        and hit.Parent.Name == "Zipline" then

		if touchCD then return end
		touchCD = true
		Spawn(function()
			task.wait(0.5)
			touchCD = false
		end)

		if isRiding then return end
		isRiding = true

        local zipline = hit.Parent :: Model
        local points = {}
		local pointsPos = {}
		local bezierPos = {}
		local pointCount = 0

		ziplineAnim:Play()
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        --- count route
		for _, child in zipline:GetChildren() do
			if child:IsA("BasePart") and tonumber(child.Name) then
				table.insert(points, child)
				pointCount += 1
			end
		end
		BezierLib:Sort(points)

		if pointCount == 2 then
			local point1 = zipline["1"].Position :: Vector3
			local point2 = zipline["2"].Position :: Vector3
			local midPoint = ((point1 + point2) / 2) - Vector3.new(0, 8, 0)

			table.insert(pointsPos, point1)
			table.insert(pointsPos, midPoint)
			table.insert(pointsPos, point2)
		else
			for i = 1, pointCount do
				local point = zipline:FindFirstChild(tostring(i)) :: BasePart

				if point then
					local pos = point.Position :: Vector3
					table.insert(pointsPos, pos)
				end
			end
		end

		local first = points[1] :: BasePart
		local last = points[#points] :: BasePart

		local bp = Instance.new("BodyPosition")
		bp.Name = "ZiplineBP"
		bp.Position = char.PrimaryPart.Position
		bp.MaxForce = Vector3.one * 10000
		bp.P = 10000
		bp.Parent = char.PrimaryPart

		local sparklePart: BasePart = nil
		if zipline:GetAttribute("Sparkle") then
			sparklePart = Instance.new("Part")
			sparklePart.Name = "SparklePart"
			sparklePart.Size = Vector3.new(2, 2, 2)
			sparklePart.Anchored = true
			sparklePart.CanCollide = false
			sparklePart.CanTouch = false
			sparklePart.CanQuery = false
			sparklePart.Transparency = 1
			sparklePart.Parent = char

			local sparkle = Instance.new("Sparkles")
			sparkle.SparkleColor = Color3.new(1, 1, 1)
			sparkle.Parent = sparklePart
		end


		local increment = (1 / math.floor(BezierLib:GetPointDstance(points) / BezierLib.Segment))
		local length = (last.Position - first.Position).Magnitude
		local rideTime = (0.01666 / (length / zipline:GetAttribute("Speed") * 1.12))

		for i = 0, 1.025, increment do
			table.insert(bezierPos, BezierLib:GetBezier(math.clamp(i, 0, 1), unpack(pointsPos)))
		end

		local num = 0
		local jumped = false
		Spawn(function()
			repeat RunService.Heartbeat:Wait() until num > 0.01666

			if zipline:GetAttribute("Jumpable") then
				UserInputService.JumpRequest:Wait()
				jumped = true
			end
		end)

		while RunService.Heartbeat:Wait() do
			local t = tick()
			local p = math.floor(#bezierPos * num)

			if humanoid.Health > 0 and bezierPos[p + 2] and not jumped then
				local nextP = p + 1
				local lerp1 = (num - p / #bezierPos) / (nextP / #bezierPos - p / #bezierPos)
				local lerp2 = bezierPos[nextP + 2] and bezierPos[p + 2]:Lerp(bezierPos[nextP + 2], lerp1)

				local vel = CFrame.new(
					bezierPos[p + 1]:Lerp(bezierPos[nextP + 1], lerp1),
					lerp2 or bezierPos[nextP + 1]
				)

				char.PrimaryPart.CFrame = vel * CFrame.new(0, -2.57, 0)
				char.PrimaryPart.Velocity = Vector3.zero
				bp.Position = char.PrimaryPart.Position
				if sparklePart then sparklePart.CFrame = vel end

				num += rideTime * ((tick() - t + RunService.RenderStepped:Wait()) / 0.01666)
				if (num >= 1) then break end
			else
				break
			end
		end

		local lookVector = char.PrimaryPart.CFrame.LookVector
		char.PrimaryPart.CFrame = CFrame.new(
			char.PrimaryPart.Position,
			Vector3.new(
				char.PrimaryPart.Position.X + lookVector.X,
				char.PrimaryPart.Position.Y + lookVector.Y,
				char.PrimaryPart.Position.Z + lookVector.Z
			)
		)

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

		humanoid.AutoRotate = true
		humanoid.PlatformStand = false

		ziplineAnim:Stop()
		bp:Destroy()
		if sparklePart then sparklePart:Destroy() end

		if zipline:GetAttribute("Momentum") and jumped == false then
			local speed = zipline:GetAttribute("Speed") * 1.12 * 30

			char.PrimaryPart:ApplyImpulse(Vector3.new(
				lookVector.X * speed,
				lookVector.Y * speed,
				lookVector.Z * speed
			))
		end

		isRiding = false
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
