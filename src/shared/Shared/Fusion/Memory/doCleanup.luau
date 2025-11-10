
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local ExternalDebug = require(Package.ExternalDebug)

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local FusionAdd, FusionEmpty = HarukaLib.Bin()

local alreadyDestroying: {[Types.Task]: true} = {}

local function doCleanup(
	task: Types.Task
): ()
	if alreadyDestroying[task] then
		return External.logError("destroyedTwice")
	end
	alreadyDestroying[task] = true

	if typeof(task) == "table" then
		local task = (task :: any) :: {Destroy: (...unknown) -> (...unknown)?, destroy: (...unknown) -> (...unknown)?}

		if task[1] ~= nil then
			-- It is important to iterate backwards through the table, since
			-- objects are added in order of construction.
			for index = #task, 1, -1 do
				doCleanup(task[index])
				task[index] = nil
			end

			ExternalDebug.untrackScope(task)
		end
	end

	FusionAdd(task)
	FusionEmpty()

	alreadyDestroying[task] = nil
end

return doCleanup