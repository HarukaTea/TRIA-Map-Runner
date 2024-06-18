--!nocheck

local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local v2New = Vector2.new

local DESIGN_VP_SIZE = v2New(1172, 466)

local function _calScreenRatio() : number
	local function __average(vector2: Vector2) : number
		return (vector2.X + vector2.Y) / 2
	end

	return __average(workspace.CurrentCamera.ViewportSize) / __average(DESIGN_VP_SIZE)
end

local function setup()
	local uiStrokes = {}

	--// Connections
	local function _strokeAdded(added: UIStroke)
		uiStrokes[added] = added.Thickness

		added.Thickness *= _calScreenRatio()
	end
	CS:GetInstanceAddedSignal("ScreenStroke"):Connect(_strokeAdded)

	local function _uiAdded(added: Instance)
		if added:IsA("UIStroke") then CS:AddTag(added, "ScreenStroke") end
	end
	plr.PlayerGui.DescendantAdded:Connect(_uiAdded)

	local function _updateSize()
		for i: UIStroke, thickness: number in uiStrokes do
			if not i.Parent then
				uiStrokes[i] = nil
			else
				i.Thickness = thickness * _calScreenRatio()
			end
		end
	end
	_updateSize()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_updateSize)

	--// Setups
	for _, element in plr.PlayerGui:GetDescendants() do
		if element:IsA("UIStroke") then CS:AddTag(element, "ScreenStroke") end
	end
end
setup()
