
return function (src: Script)
    if src.Parent:FindFirstChild("_Delay") then
		local delayTime = src.Parent["_Delay"].Value :: number

		if typeof(delayTime) == "number" then
			task.wait(delayTime)
		end
	end
end
