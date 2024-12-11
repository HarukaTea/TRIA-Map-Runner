--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)

local camera = workspace.CurrentCamera
local plr = Players.LocalPlayer
local plrGui = plr:FindFirstChildOfClass("PlayerGui")

local uiStrokes = {}

local DESIGN_VP_SIZE = Vector2.new(1172, 466.4)

--// Private
local function __getBox(vector: Vector2) : number
	return math.min(vector.X, vector.Y)
end
local function _calScreenRatio() : number
	return __getBox(camera.ViewportSize) / __getBox(DESIGN_VP_SIZE)
end
local function _getInstancePosition(instance: Instance): Vector3
	if instance:IsA("Part") then
		return instance.Position

	elseif instance:IsA("Model") then
		local cf, size = instance:GetBoundingBox()
		return cf.Position
	end

	return Vector3.zero
end

--// Pre-defined functions
local function _strokeCalInWB(stroke: UIStroke)
	local thickness = stroke.Thickness
	local disconnect: () -> () = nil

	local function _update()
		if not stroke.Parent then
			disconnect()
		else
			local billboardGui = stroke:FindFirstAncestorOfClass("BillboardGui")
			local adornee = billboardGui.Adornee
			local origin = adornee and _getInstancePosition(adornee) or _getInstancePosition(billboardGui.Parent)
			local magnitude = (camera.CFrame.Position - origin).Magnitude
			local distanceRatio = ((billboardGui:GetAttribute("Distance") or 15.99) / magnitude)

			stroke.Thickness = thickness * distanceRatio * _calScreenRatio()
		end
	end
	_update()
	disconnect = HarukaLib.Clock(0.1, _update)

	stroke:SetAttribute("AlreadyTransformed", true)
end
local function _strokeAdded(added: Instance)
	if added:IsA("UIStroke") and not added:GetAttribute("AlreadyTransformed") then
		if added:FindFirstAncestorOfClass("BillboardGui") then
			_strokeCalInWB(added)
			return
		end
		uiStrokes[added] = added.Thickness

		added.Thickness *= _calScreenRatio()
		added:SetAttribute("AlreadyTransformed", true)
	end
end

--// Setups
for _, child: Instance in plrGui:GetDescendants() do
	_strokeAdded(child)
end
plrGui.DescendantAdded:Connect(_strokeAdded)

--// Connections
local function _updateSize()
	for stroke: UIStroke, thickness: number in uiStrokes do
		if not stroke.Parent then
			uiStrokes[stroke] = nil
		else
			stroke.Thickness = thickness * _calScreenRatio()
		end
	end
end
HarukaLib.Clock(1, _updateSize)

return true
