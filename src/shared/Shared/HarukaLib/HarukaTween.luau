local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

local wait = task.wait


local DATA_TYPES = {
    number = function(a, b, t)
        return a + ((b - a) * t)
    end,

    V3 = function(a, b, t)
        return a:Lerp(b, t)
    end
}


local function fastBubbleSort(arr)
    local n = #arr
    while n > 1 do
        local newN = 0
        for i = 1, n - 1 do
            if arr[i].Time > arr[i + 1].Time then
                arr[i], arr[i + 1] = arr[i + 1], arr[i]
                newN = i
            end
        end
        n = newN
    end
end
DATA_TYPES.NumberSequence = function(a, b, t)
    local keyPoints = {}

    for index: number, keypoint: NumberSequenceKeypoint in a.Keypoints do
        local nextKeypoint = b.Keypoints[index] :: NumberSequenceKeypoint

        table.insert(keyPoints, NumberSequenceKeypoint.new(
            math.clamp(DATA_TYPES.number(keypoint.Time, nextKeypoint.Time, t), 0, 1),
            DATA_TYPES.number(keypoint.Value, nextKeypoint.Value, t),
            DATA_TYPES.number(keypoint.Envelope, nextKeypoint.Envelope, t)
        ))
    end
    fastBubbleSort(keyPoints)

    return NumberSequence.new(keyPoints)
end
DATA_TYPES.ColorSequence = function(a, b, t)
    local keyPoints = {}

    for index: number, keypoint: ColorSequenceKeypoint in a.KeyPoints do
        local nextKeypoint = b.Keypoints[index] :: ColorSequenceKeypoint

        table.insert(keyPoints, ColorSequenceKeypoint.new(
            math.clamp(DATA_TYPES.number(keypoint.Time, nextKeypoint.Time, t), 0, 1),
            DATA_TYPES.V3(keypoint.Value, nextKeypoint.Value, math.clamp(t, 0, 1))
        ))
    end
    fastBubbleSort(keyPoints)


    return ColorSequence.new(keyPoints)
end
DATA_TYPES.NumberRange = function(a, b, t)
    return NumberRange.new(
        DATA_TYPES.number(a.Min, b.Min, t),
        DATA_TYPES.number(a.Max, b.Max, t)
    )
end


return function (object: Instance, style: TweenInfo, goal: { any }, needSignal: boolean)
	local properties = {}
	local tweenSignal = nil

    if needSignal then
        tweenSignal = Signal.new()
    end


	for name: string, _: any in goal do
		if name == "Pivot" then
			properties[name] = {
                Goal = object:GetPivot(),
                Type = "V3"
            }
		else
			properties[name] = {
                Goal = object[name],
                Type = typeof(object[name])
            }
		end
	end

	--- update task
	local startTime = tick()
	task.defer(function()
		local reverse = false
		local repeated = 0

		while true do
            if not object then break end
			if not object.Parent then break end

			local alpha = (tick() - startTime) / style.Time
			local t = math.min(alpha, 1)

			if style.Reverses then alpha = 1 - t end


			local lerp = TweenService:GetValue(alpha, style.EasingStyle, style.EasingDirection)
			for name: string, val: any in goal do
				local originalInfo = properties[name]

				if name == "Pivot" then
					object:PivotTo(DATA_TYPES.V3(originalInfo.Goal, val, lerp))
				else
					object[name] = DATA_TYPES[originalInfo.Type](originalInfo.Goal, val, lerp)
				end
			end
			if t == 1 then
				if style.Reverses and not reverse then
					reverse = true
					startTime = tick()

				elseif repeated ~= style.RepeatCount then
					repeated += 1
					reverse = false
					startTime = tick()
				else
					break
				end
			end
			wait()
		end

        if tweenSignal then
            tweenSignal:Fire("Completed")
		    tweenSignal:Destroy()
        end
	end)

	return tweenSignal
end