--!nocheck

local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

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

Signals.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	if script.Parent:FindFirstChild("_Delay") then
		local delayTime = script.Parent["_Delay"].Value :: number
		task.wait(delayTime)
	end

	local obj = script.Parent.Parent :: Instance
	if objList[obj.ClassName] then
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

	elseif obj:IsA("Model") then
		for _, child in obj:GetDescendants() do
			if objList[child.ClassName] then
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

                child:Destroy()
			end
		end
	end
end)