--!nocheck

local module = {}
module.Segment = 8.75

function module:Lerp(a, b, c)
	return a + (b - a) * c
end

function module:GetPointDstance(points)
	local increment = 0
	for i = 1, #points - 1 do
		increment += ((points[i].Position - points[i + 1].Position).Magnitude)
	end
	return math.ceil(increment * 2)
end

function module:GetBezier(t, ...)
	local points = {...}
	while (#points > 1) do
		for i = 1, #points - 1 do
			points[i] = module:Lerp(points[i], points[i + 1], t)
		end
		points[#points] = nil
	end
	return points[1]
end

function module:Sort(points)
	table.sort(points, function(a, b)
		local pointNum = tonumber(a.Name)
		local nextPointNum = tonumber(b.Name)

		if (pointNum ~= nil) and (nextPointNum ~= nil) then
			return pointNum < nextPointNum
		end
	end)
end

function module:ConnectPoint(p, nextP, color, material, parent)
	local Rope, Length = Instance.new("Part"), (p - nextP).Magnitude

	Rope.Name = "RopePart"
	Rope.Anchored = true
	Rope.Material = material
	Rope.Size = Vector3.new(0.3, 0.3, Length)
	Rope.CFrame = CFrame.lookAt(p, nextP, Vector3.new(0, 1, 0)) * CFrame.new(0, 0, Rope.Size.Z / -2)
	Rope.Color = color
	Rope.CanCollide = false
	Rope.Parent = parent

	return Rope, Length
end

function module:CreateOrb(name, point)
	local Orb = Instance.new("Part")

	Orb.Name = name
	Orb.Anchored = true
	Orb.CanCollide = false
	Orb.Shape = "Ball"
	Orb.Material = "Neon"
	Orb.Size = Vector3.new(3.75, 3.75, 3.75)
	Orb.CFrame = point.CFrame + Vector3.new(0, 0.25, 0)
	Orb.Color = Color3.new(1, 1, 1)
	Orb.Transparency = 0.75
	Orb.Parent = point.Parent

	return Orb
end

function module:MakeBezier(parent, ...)
	local points, pointsPos = {...}, {}
	local piece, length, ropeNum = nil, nil, 0

	local parts = Instance.new("Folder")
	parts.Name = "Parts"
	parts.Parent = parent

	for i = 1, #points do
		table.insert(pointsPos, points[i].Position)
	end

	local Length = 0
	local Increment = (1 / math.floor(module:GetPointDstance(points) / module.Segment))


	for i = 0, 1, Increment do
		local point = module:GetBezier(math.clamp(i, 0, 1), unpack(pointsPos))
		local nextpoint = module:GetBezier(math.clamp(i + Increment, 0, 1), unpack(pointsPos))

		piece, length = module:ConnectPoint(point, nextpoint, points[1].Color, points[1].Material, parts)
		Length = Length + length
		ropeNum = ropeNum + 1

		piece.Name = "RopePiece" .. ropeNum
	end

	Length = Length + length
	return parts, Length
end

function module:Run(parent)
	local points = {}

	for _, child in pairs(parent:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(points, child)
		end
	end

	module:Sort(points)
	module:MakeBezier(parent, unpack(points))

	for i = 1, #points do
		points[i].Transparency = 1
	end

	module:CreateOrb("StartOrb", points[1])
end

return module