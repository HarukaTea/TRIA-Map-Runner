--!nocheck

local BezierLib = {}

BezierLib.Segment = 8.75

--[[
	Create a bezier curve object
]]
function BezierLib:Run(parent: Instance)
	local points = {}
	for _, child in parent:GetChildren() do
		if child:IsA("BasePart") then table.insert(points, child) end
	end

	if #points < 1 then return end
	self.points = points

	BezierLib:Sort(points)
	BezierLib:_MakeBezier(parent, unpack(points))

	for i = 1, #points do points[i].Transparency = 1 end

	local startOrb = Instance.new("Part")
	startOrb.Name = "StartOrb"
	startOrb.Anchored = true
	startOrb.Transparency = 1
	startOrb.Size = Vector3.one * 2
	startOrb.CFrame = points[1].CFrame
	startOrb.CanCollide = false
	startOrb.CanQuery = false
	startOrb.Parent = parent
end

function BezierLib:Sort(points)
	table.sort(points, function(a, b)
		local pointNum = tonumber(a.Name)
		local nextPointNum = tonumber(b.Name)

		if (pointNum ~= nil) and (nextPointNum ~= nil) then
			return pointNum < nextPointNum
		end
	end)
end

function BezierLib:GetPointDstance(points)
	local increment = 0

	for i = 1, #points - 1 do
		increment += ((points[i].Position - points[i + 1].Position).Magnitude)
	end

	return math.ceil(increment * 2)
end

function BezierLib:GetBezier(t, ...)
	local points = {...}

	while (#points > 1) do
		for i = 1, #points - 1 do
			points[i] = BezierLib:_Lerp(points[i], points[i + 1], t)
		end
		points[#points] = nil
	end

	return points[1]
end

--// Private
function BezierLib:_Lerp(a, b, c)
	return a + (b - a) * c
end

function BezierLib:_ConnectPoint(p, nextP, parent)
	local rope, length = Instance.new("Part"), (p - nextP).Magnitude

	local point = self.points[1] :: BasePart
	local width, color, material =
		point:GetAttribute("Width") :: number,
		point:GetAttribute("Color") :: Color3,
	 	point:GetAttribute("Material") :: string

	rope.Name = "RopePart"
	rope.Anchored = true
	rope.Material = material
	rope.Size = Vector3.new(width, width, length)
	rope.CFrame = CFrame.lookAt(p, nextP, Vector3.new(0, 1, 0)) * CFrame.new(0, 0, rope.Size.Z / -2)
	rope.Color = color
	rope.CanCollide = false
	rope.CanTouch = false
	rope.CanQuery = false
	rope.Parent = parent

	return rope, length
end

function BezierLib:_MakeBezier(parent, ...)
	local points, pointsPos = {...}, {}
	local piece, length, ropeNum = nil, nil, 0

	local parts = Instance.new("Folder")
	parts.Name = "Parts"
	parts.Parent = parent

	for i = 1, #points do table.insert(pointsPos, points[i].Position) end

	local Length = 0
	local Increment = (1 / math.floor(BezierLib:GetPointDstance(points) / BezierLib.Segment))

	for i = 0, 1, Increment do
		local point = BezierLib:GetBezier(math.clamp(i, 0, 1), unpack(pointsPos))
		local nextpoint = BezierLib:GetBezier(math.clamp(i + Increment, 0, 1), unpack(pointsPos))

		piece, length = BezierLib:_ConnectPoint(point, nextpoint, parts)
		Length = Length + length
		ropeNum = ropeNum + 1

		piece.Name = "RopePiece" .. ropeNum
	end

	Length = Length + length
	return parts, Length
end


return BezierLib