
local task = nil -- Disable usage of Roblox's task scheduler
--[[
	The entry point for the Fusion library.
]]

local Types = require(script.Types)
local External = require(script.External)

type Fusion = Types.Fusion

export type Animatable = Types.Animatable
export type UsedAs<T> = Types.UsedAs<T>
export type Computed<T> = Types.Computed<T>
export type Contextual<T> = Types.Contextual<T>
export type GraphObject = Types.GraphObject
export type For<KO, VO> = Types.For<KO, VO>
export type Observer = Types.Observer
export type PropertyTable = Types.PropertyTable
export type Scope<Constructors = Fusion> = Types.Scope<Constructors>
export type ScopedObject = Types.ScopedObject
export type SpecialKey = Types.SpecialKey
export type StateObject<T> = Types.StateObject<T>
export type Task = Types.Task
export type Tween<T> = Types.Tween<T>
export type Use = Types.Use
export type Value<T, S = T> = Types.Value<T, S>
export type Version = Types.Version

-- Down the line, this will be conditional based on whether Fusion is being
-- compiled for Roblox.
do
	local RobloxExternal = require(script.RobloxExternal)
	External.setExternalProvider(RobloxExternal)
end

local Fusion: Fusion = table.freeze {
	-- General
	version = {major = 0, minor = 4, isRelease = false},
	Contextual = require(script.Utility.Contextual),

	-- Memory
	deriveScope = require(script.Memory.deriveScope),
	doCleanup = require(script.Memory.doCleanup),
	innerScope = require(script.Memory.innerScope),
	scoped = require(script.Memory.scoped),

	-- Graph
	Observer = require(script.Graph.Observer),

	-- State
	Computed = require(script.State.Computed),
	ForPairs = require(script.State.ForPairs) :: Types.ForPairsConstructor,
	ForValues = require(script.State.ForValues) :: Types.ForValuesConstructor,
	peek = require(script.State.peek),
	Value = require(script.State.Value),

	-- Roblox API
	Attribute = require(script.Instances.Attribute),
	Children = require(script.Instances.Children),
	New = require(script.Instances.New),
	OnChange = require(script.Instances.OnChange),
	OnEvent = require(script.Instances.OnEvent),
	Out = require(script.Instances.Out),

	-- Animation
	Tween = require(script.Animation.Tween),
}

return Fusion