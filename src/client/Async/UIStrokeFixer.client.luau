--!nocheck

local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui

local camera = workspace.CurrentCamera
local normalUIStrokes = {}
local billboardUIStrokes = {}

local DESIGN_VP_SIZE = Vector2.new(1172.8, 464)


--// Helper functions

local function _calScreenRatio() : number
	local x = camera.ViewportSize.X / DESIGN_VP_SIZE.X
	local y = camera.ViewportSize.Y / DESIGN_VP_SIZE.Y

	return (x + y) / 2
end
local function _getInstancePosition(instance: Instance): Vector3
	if instance == nil then
		return Vector3.zero
	end
	if instance:IsA("BasePart") then
		instance = instance :: BasePart

		return instance.Position

	elseif instance:IsA("Model") then
		instance = instance :: Model

		local cf, _ = instance:GetBoundingBox()
		return cf.Position
	end

	return Vector3.zero
end
local function _updateStroke(stroke: UIStroke, belongTo: "Billboard" | "Normal", info: {
	Thickness: number,
	UIScale: UIScale?
})
    local finalThickness = 0

	local scale = 1
	if info.UIScale then scale = info.UIScale.Scale end

    if belongTo == "Billboard" then
        local billboardGui = stroke:FindFirstAncestorOfClass("BillboardGui")
        local adornee = billboardGui.Adornee
        local origin = _getInstancePosition(adornee)
        local magnitude = (camera.CFrame.Position - origin).Magnitude
        local distanceRatio = ((billboardGui:GetAttribute("Distance") or 31) / magnitude)

        finalThickness = info.Thickness * distanceRatio * _calScreenRatio() * scale
        finalThickness = math.clamp(finalThickness, 1, 3)

    elseif belongTo == "Normal" then
        finalThickness = info.Thickness * _calScreenRatio() * scale
        finalThickness = math.clamp(finalThickness, 1, 999)
    end

    stroke.Thickness = finalThickness
end
local function _updateSize()
	for stroke: UIStroke, info: { any } in normalUIStrokes do
		if not stroke.Parent then
			normalUIStrokes[stroke] = nil
		else
			_updateStroke(stroke, "Normal", info)
		end
	end
	for stroke: UIStroke, info: { any } in billboardUIStrokes do
		if not stroke.Parent then
			billboardUIStrokes[stroke] = nil
		else
			_updateStroke(stroke, "Billboard", info)
		end
	end
end
local function _strokeAdded(added: Instance)
	if (added:IsA("UIStroke") or added:IsA("Path2D"))
		and not added:GetAttribute("AlreadyTransformed")
		and not added:GetAttribute("IgnoreDPI") then

		if added:FindFirstAncestorOfClass("BillboardGui") then
			billboardUIStrokes[added] = {
				Thickness = added.Thickness,
				UIScale = added:FindFirstAncestorOfClass("UIScale")
			}

			_updateStroke(added, "Billboard", billboardUIStrokes[added])
		else
			normalUIStrokes[added] = {
				Thickness = added.Thickness,
				UIScale = added:FindFirstAncestorOfClass("UIScale")
			}

			_updateStroke(added, "Normal", normalUIStrokes[added])
		end

		added:SetAttribute("AlreadyTransformed", true)
	end
end


--// Init

for _, child: Instance in plrGui:GetDescendants() do
	_strokeAdded(child)
end
plrGui.DescendantAdded:Connect(_strokeAdded)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_updateSize)
