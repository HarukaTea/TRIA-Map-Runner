
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Bindables = require(SSS.HarukaServer.Library.ServerBindables)
local DelayCheck = require(SS.HarukaRes.Unloads.ButtonEvents._DelayEvent)


local objList = {
	["BasePart"] = true,
	["Part"] = true,
	["UnionOperation"] = true,
	["TrussPart"] = true,
	["WedgePart"] = true,
	["CornerWedgePart"] = true
}

local index = string.sub(script.Parent.Name, 9)
local realIndex = string.gsub(index, "%a", "")

Bindables.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	DelayCheck(script)

	local function _explosionEffect(obj: Instance)
		local explosion = Instance.new('Explosion')
		explosion.BlastPressure = 0
		explosion.BlastRadius = 8
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position = obj.Position
		explosion.Parent = workspace.Map

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/collide.wav"
        sound.Parent = workspace.Map
        sound:Play()

        obj:Destroy()
	end

	local obj = script.Parent.Parent :: Instance
	if objList[obj.ClassName] then
		_explosionEffect(obj)

	elseif obj:IsA("Model") then
		for _, child: Instance in obj:GetDescendants() do
			if objList[child.ClassName] then _explosionEffect(child) end
		end
	end
end)