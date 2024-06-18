--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local BezierLib = require(RepS.Modules.Packages.BezierLib)

local Zipline = {}
Zipline.__index = Zipline

local instanceNew = Instance.new
local insert = table.insert
local v3New = Vector3.new
local floor, clamp = math.floor, math.clamp
local cfNew = CFrame.new

function Zipline:Ride(model: Model)
    if model.Name == "Zipline" and model:IsA("Model") then
        local points = {}
		local pointsPos = {}
		local bezierPos = {}
		local pointCount = 0

        local humanoid = self.humanoid :: Humanoid
        local rootPart = humanoid.RootPart

		self.ziplineAnim:Play()

        --- count route
		for _, child in pairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				insert(points, child)

				pointCount += 1
			end
		end

		BezierLib:Sort(points)

		if pointCount == 2 then
			local point1 = model["1"].Position :: Vector3
			local point2 = model["2"].Position :: Vector3
			local midPoint = ((point1 + point2) / 2) - v3New(0, 8, 0)

			insert(pointsPos, point1)
			insert(pointsPos, midPoint)
			insert(pointsPos, point2)
		else
			for i = 1, pointCount do
				local point = model:FindFirstChild(i) :: BasePart

				if point then
					local pos = point.Position :: Vector3

					insert(pointsPos, pos)
				end
			end
		end

		local first = points[1]
		local last = points[#points]

		local bp = instanceNew("BodyPosition")
		bp.Name = "ZiplineBP"
		bp.Position = rootPart.Position
		bp.MaxForce = v3New(10000, 10000, 10000)
		bp.P = 10000
		bp.Parent = rootPart

		local increment = (1 / floor(BezierLib:GetPointDstance(points) / BezierLib.Segment))
		local length = (last.Position - first.Position).Magnitude
		local rideTime = (0.01666 / (length / model:GetAttribute("Speed")))

		for i = 0, 1.025, increment do
			insert(bezierPos, BezierLib:GetBezier(clamp(i, 0, 1), unpack(pointsPos)))
		end

		local num = 0
		while RS.Heartbeat:Wait() do
			local t = tick()
			local p = floor(#bezierPos * num)

			if humanoid.Health > 0 and bezierPos[p + 2] then
				local nextP = p + 1
				local lerp1 = (num - p / #bezierPos) / (nextP / #bezierPos - p / #bezierPos)
				local lerp2 = bezierPos[nextP + 2] and bezierPos[p + 2]:Lerp(bezierPos[nextP + 2], lerp1)

				local vel = cfNew(
					bezierPos[p + 1]:Lerp(bezierPos[nextP + 1], lerp1),
					lerp2 or bezierPos[nextP + 1]
				)

				rootPart.CFrame = vel * cfNew(0, -2.57, 0)
				rootPart.Velocity = v3New()
				rootPart.RotVelocity = v3New()
				bp.Position = rootPart.Position

				num += rideTime * ((tick() - t + RS.RenderStepped:Wait()) / 0.01666)
				if (num >= 1) then break end
			else
				break
			end
		end

		local lookVector = rootPart.CFrame.LookVector
		rootPart.CFrame = cfNew(
			rootPart.Position,
			v3New(
				rootPart.Position.X + lookVector.X,
				rootPart.Position.Y + lookVector.Y,
				rootPart.Position.Z + lookVector.Z
			)
		)

		self.ziplineAnim:Stop()
		bp:Destroy()
    end
end

return function (plr: Player)
    local self = setmetatable({}, Zipline)

    self.isRiding = false
    self.char = plr.Character or plr.CharacterAdded:Wait()
    self.humanoid = self.char.Humanoid

    local animator = self.humanoid.Animator :: Animator
    local animation = instanceNew("Animation")
    animation.AnimationId = KSP:RegisterKeyframeSequence(RepS.Package.Keyframes.Zipline)

    self.ziplineAnim = animator:LoadAnimation(animation)

    self.char.Humanoid.Touched:Connect(function(hit)
        if hit:IsA("BasePart") and hit.Parent and hit.Name == "StartOrb" then
            self:Ride(hit.Parent)
        end
    end)
end