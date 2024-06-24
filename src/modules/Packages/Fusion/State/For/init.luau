--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	The generic implementation for all `For` objects.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
local ForTypes = require(Package.State.For.ForTypes)
-- Utility
local never = require(Package.Utility.never)
local nicknames = require(Package.Utility.nicknames)

local Disassembly = require(Package.State.For.Disassembly)

local class = {}
class.type = "State"
class.kind = "For"
class.timeliness = "lazy"

local METATABLE = table.freeze {__index = class}

local function For<S, KI, KO, VI, VO>(
	scope: table,
	inputTable: any,
	constructor: (
		any,
		initialKey: KI,
		initialValue: VI
	) -> any
): any

	local self = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = {},
			_disassembly = Disassembly(
				scope,
				inputTable,
				constructor
			)
		}, 
		METATABLE
	) :: any

	local destroy = function()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	nicknames[self.oldestTask] = "For"
	table.insert(scope, destroy)

	return self
end

function class.get<S, KI, KO, VI, VO>(
	_self
): any
	External.logError("stateGetWasRemoved")
	return never()
end

function class._evaluate<S, KI, KO, VI, VO>(
	self
): boolean
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & any

	depend(self, self._disassembly)
	table.clear(self._EXTREMELY_DANGEROUS_usedAsValue)
	self._disassembly:populate(
		function<T>(
			maybeState: any
		): T
			local state = castToState(maybeState)
			if state ~= nil then
				depend(self, state)
			end
			return peek(maybeState)
		end,
		self._EXTREMELY_DANGEROUS_usedAsValue
	)

	return true
end

table.freeze(class)
return For