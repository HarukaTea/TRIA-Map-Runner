--!nocheck

local Spawn = require(script.Parent.Spawn)

local Promise = {}
Promise.__index = Promise

function Promise.new(Callback: (Resolve: (...any) -> (), Reject: (...any) -> ()) -> ())
	local self = setmetatable({}, Promise)

	self.Status = "Pending" :: "Pending" | "Resolved" | "Rejected"
	self.OnResolve = {} :: { (...any) -> () }
	self.OnReject = {} :: { (...any) -> () }

	self.Value = {} :: { any }

	self.Thread = coroutine.create(xpcall) :: thread?

	task.spawn(self.Thread :: thread, Callback, function(Error)
		(self :: any):_Reject(Error)
	end, function(...)
		(self :: any):_Resolve(...)
	end, function(...)
		(self :: any):_Reject(...)
	end)

	return self
end

export type Promise = typeof(Promise.new(...))

function Promise.Resolve(...: any): Promise
	local self = setmetatable({}, Promise)

	self.Status = "Resolved"
	self.OnResolve = {} :: { (...any) -> () }
	self.OnReject = {} :: { (...any) -> () }
	self.Value = { ... } :: { any }
	self.Thread = nil :: thread?

	return self
end

function Promise.Reject(...: any): Promise
	local self = setmetatable({}, Promise)

	self.Status = "Rejected"
	self.OnResolve = {} :: { (...any) -> () }
	self.OnReject = {} :: { (...any) -> () }
	self.Value = { ... } :: { any }
	self.Thread = nil :: thread?

	return self
end

function Promise.RetryWithDelay(MaxAttempts: number, Delay: number, Callback: (...any) -> (...any), ...)
	local Args = { ... }

	return Promise.new(function(Resolve, Reject)
		local Attempts = 0

		while Attempts < MaxAttempts do
			Attempts += 1

			local Result = { pcall(Callback, unpack(Args)) }

			if table.remove(Result, 1) then
				Resolve(unpack(Result))
				break
			elseif Attempts == MaxAttempts then
				Reject(unpack(Result))
				break
			else
				task.wait(Delay)
			end
		end
	end)
end

function Promise._Resolve(self: Promise, ...: any)
	assert(self.Status == "Pending", "Cannot resolve a promise that is not pending.")

	self.Status = "Resolved"
	self.Value = table.pack(...)

	for _, Callback in self.OnResolve do
		Spawn(Callback, ...)
	end

	task.defer(task.cancel, self.Thread :: thread)
end

function Promise._Reject(self: Promise, ...: any)
	assert(self.Status == "Pending", "Cannot reject a promise that is not pending.")

	self.Status = "Rejected"
	self.Value = table.pack(...)

	for _, Callback in self.OnReject do
		Spawn(Callback, ...)
	end

	task.defer(task.cancel, self.Thread :: thread)
end

function Promise.Then(self: Promise, OnResolve: ((...any) -> ...any)?, OnReject: ((...any) -> ...any)?): Promise
	return Promise.new(function(Resolve, Reject)
		local function PromiseResolutionProcedure(Value: Promise | any, ...: any)
			if type(Value) == "table" and getmetatable(Value) == Promise then
				if Value.Status == "Pending" then
					table.insert(Value.OnResolve, Resolve)
					table.insert(Value.OnReject, Reject)
				elseif Value.Status == "Resolved" then
					Resolve(unpack(Value.Value))
				elseif Value.Status == "Rejected" then
					Reject(unpack(Value.Value))
				end
			else
				Resolve(Value, ...)
			end
		end

		if self.Status == "Pending" then
			if OnResolve then
				table.insert(self.OnResolve, function(...)
					PromiseResolutionProcedure(OnResolve(...))
				end)
			else
				table.insert(self.OnResolve, PromiseResolutionProcedure)
			end

			if OnReject then
				table.insert(self.OnReject, function(...)
					PromiseResolutionProcedure(OnReject(...))
				end)
			else
				table.insert(self.OnReject, Reject)
			end
		elseif self.Status == "Resolved" then
			if OnResolve then
				PromiseResolutionProcedure(OnResolve(unpack(self.Value)))
			else
				Resolve(unpack(self.Value))
			end
		elseif self.Status == "Rejected" then
			if OnReject then
				PromiseResolutionProcedure(OnReject(unpack(self.Value)))
			else
				Reject(unpack(self.Value))
			end
		end
	end)
end

function Promise.Catch(self: Promise, OnReject: (...any) -> ()): Promise
	return self:Then(nil, OnReject)
end

function Promise.Finally(self: Promise, Finally: ("Pending" | "Resolved" | "Rejected") -> ()): Promise
	-- Callbacks return self because `Then` is supposed to adopt state of returned promises.
	return self:Then(function(...)
		Finally(self.Status :: any)

		return self
	end, function(Error)
		Finally(self.Status :: any)

		return self
	end)
end

return Promise
