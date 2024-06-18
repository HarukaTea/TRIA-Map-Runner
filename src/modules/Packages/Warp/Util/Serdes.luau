--!strict

local RunService = game:GetService("RunService")
local SerInt = 0

local Event = require(script.Parent.Parent.Event).Reliable

return function(Identifier: string, timeout: number?): number
	if RunService:IsServer() then
		if not Event:GetAttribute(Identifier) then
			SerInt += 1
			Event:SetAttribute(Identifier, SerInt)
			--Event:SetAttribute(Identifier, string.pack("I1", SerInt)) -- I1 -> 255 max, I2 -> ~ 6.5e4 max. (SerInt), removed/disabled for buffer migration.
		end
	else
		local retreived = false
		task.delay(timeout or 10,  function()
			if retreived then return end
			retreived = true
			error(`Serdes: {Identifier} is taking too long to retrieve, seems like not replicated on server.`, 2)
		end)
		while (not retreived) and (not Event:GetAttribute(Identifier)) do
			task.wait(0.5)
		end
		retreived = true
	end
	return Event:GetAttribute(Identifier)
end