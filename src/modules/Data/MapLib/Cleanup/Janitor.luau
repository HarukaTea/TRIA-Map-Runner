--!nocheck

local Janitor = {}

Janitor.__index = Janitor
Janitor.ClassName = "Janitor"

--[[
	Constructs a new Janitor class and is cached for later use.
]]
function Janitor.new()
	local self = setmetatable({}, Janitor)
	self._tasks = {}

	return self
end

--[[
	Returns true if the given class is a Janitor, if not it returns false.
]]
function Janitor.isJanitor(value: any): boolean
	return type(value) == "table" and value.ClassName == "Janitor"
end

--[[
	This method is used to give Janitor tasks to cleanup,
	these tasks can be anything,
	some examples include, functions, threads, coroutines or anything with a .Destroy function.
]]
function Janitor:Give(task)
	local function handleTask(subtask: any)
		assert(typeof(task) ~= "boolean", "Task cannot be a boolean")

		local taskId = #self._tasks + 1
		self._tasks[taskId] = subtask
		return subtask
	end

	--Task which contains multiple subTasks
	if typeof(task) == "table" then
		if not task.Destroy then
			for _, v in pairs(task) do
				handleTask(v)
			end
			return task
		else
			--Task with .Destroy method
			return handleTask(task)
		end
	end
	return handleTask(task)
end

--[[
	Calls for the Janitor to cleanup up all the tasks it was given.
]]
function Janitor:Cleanup(taskTable: { any }?)
	local tasks = taskTable or self._tasks

	--Influenced by Quenty's destructer implementation.

	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	local index, task = next(tasks)

	while task ~= nil do
		tasks[index] = nil

		if type(task) == "function" then
			task()
		elseif typeof(task) == "thread" then
			coroutine.close(task)
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			--Used for Janitor to Destroy other Janitors or a part with Destroy method
			task:Destroy()
			--cancel any promises given
		elseif getmetatable(task).prototype ~= nil then
			task:cancel()
		end
		index, task = next(tasks)
	end
end

--[[
	Completely destroys Janitor and all references to it.
	If the Janitor has tasks then those tasks are cleaned up.
]]
function Janitor:Destroy()
	self:Cleanup()
	self = nil
end

return Janitor