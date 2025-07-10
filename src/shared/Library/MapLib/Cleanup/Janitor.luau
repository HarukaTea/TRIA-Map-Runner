--!nocheck

local RS = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Janitor = {}

Janitor.__index = Janitor
Janitor.ClassName = "Janitor"

--// Private

local function _getJanitors() : table
	return require(script.Parent)._Janitors
end

--[[
	Constructs a new Janitor class and is cached for later use.
]]
function Janitor.new(name: string?)
	local self = setmetatable({}, Janitor)

	self._tasks = {}
	self.context = if RS:IsServer() then "Server" else "Client"
	self.name = name

	local janitors = _getJanitors()

	self.index = name or #janitors + 1
	janitors[self.index] = self

	self._Add, self._Empty = HarukaLib.Bin()

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
	self._Add(task)

	return task
end

--[[
	Calls for the Janitor to cleanup up all the tasks it was given.
]]
function Janitor:Cleanup(taskTable: { any }?)
	if taskTable then self._Add(taskTable) end

	self._Empty()
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