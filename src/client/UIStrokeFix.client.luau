--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

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

--// Pre-defined functions
local function _strokeAdded(added: Instance)
	if added:IsA("UIStroke") and not added:GetAttribute("AlreadyTransformed") then
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
