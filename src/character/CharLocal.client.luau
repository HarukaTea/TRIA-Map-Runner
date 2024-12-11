--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.Shared.Library.Events)

local char = script:FindFirstAncestorOfClass("Model")

local function onDied()
	---// sometimes the reset button did not make server thinks player is dead
	Events.ForceReset.Fire({})
end
char.Humanoid.Died:Once(onDied)
