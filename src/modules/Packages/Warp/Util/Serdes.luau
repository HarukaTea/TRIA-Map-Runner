--!nocheck

local RunService = game:GetService("RunService")
local SerInt = 0

local Event = require(script.Parent.Parent.Event)

return function(Identifier: string, timeout: number?): number
	if RunService:IsServer() then
		if not Event:GetAttribute(Identifier) then
			SerInt += 1

			Event:SetAttribute(Identifier, SerInt)
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
