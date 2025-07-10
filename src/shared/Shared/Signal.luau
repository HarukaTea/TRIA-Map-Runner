--!optimize 2
--!nocheck
--!native

export type Connection<U...> = {
	Connected: boolean,

	Disconnect: (self: Connection<U...>) -> (),
	Destroy: (self: Connection<U...>) -> (),
}

export type Signal<T...> = {
	Connect: <U...>(self: Signal<T...>, fn: (...any) -> (), U...) -> Connection<U...>,
	Once: <U...>(self: Signal<T...>, fn: (...any) -> (), U...) -> Connection<U...>,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

local freeThreads: { thread } = {}

local function runCallback(callback, thread, ...)
	callback(...)
	table.insert(freeThreads, thread)
end

local function yielder()
	while true do
		runCallback(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection

local function disconnect<U...>(self: Connection<U...>)
	if not self.Connected then
		return
	end
	self.Connected = false

	local next = self._next
	local prev = self._prev

	if next then
		next._prev = prev
	end
	if prev then
		prev._next = next
	end

	local signal = self._signal
	if signal._head == self then
		signal._head = next
	end
end
Connection.Disconnect = disconnect

--\\ Signal //--
local Signal = {}
Signal.__index = Signal


local function connect<T..., U...>(self: Signal<T...>, fn: (...any) -> (), ...: U...): Connection<U...>
	local head = self._head
	local cn = setmetatable({
		Connected = true,
		_signal = self,
		_fn = fn,
		_varargs = if not ... then false else { ... },
		_next = head,
		_prev = false,
	}, Connection)

	if head then
		head._prev = cn
	end
	self._head = cn

	--// allow for `HarukaLib.Bin` to collect garbage
	cn.Destroy = function()
		cn:Disconnect()
	end

	return cn
end

local function once<T..., U...>(self: Signal<T...>, fn: (...any) -> (), ...: U...)
	local cn
	cn = connect(self, function(...)
		disconnect(cn)
		fn(...)
	end, ...)
	return cn
end

local wait = if task
	then function<T...>(self: Signal<T...>): ...any
		local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, ...)
			end
		end)
		return coroutine.yield()
	end
	else function<T...>(self: Signal<T...>): ...any
		local thread = coroutine.running()
		local cn
		cn = connect(self, function(...)
			disconnect(cn)
			local passed, message = coroutine.resume(thread, ...)
			if not passed then
				error(message, 0)
			end
		end)
		return coroutine.yield()
	end

local fire = if task
	then function<T...>(self: Signal<T...>, ...: any)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				task.spawn(thread, cn._fn, thread, ...)
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count += 1
					args[count] = value
				end

				task.spawn(thread, cn._fn, thread, table.unpack(args))

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end
	else function<T...>(self: Signal<T...>, ...: any)
		local cn = self._head
		while cn do
			local thread
			if #freeThreads > 0 then
				thread = freeThreads[#freeThreads]
				freeThreads[#freeThreads] = nil
			else
				thread = coroutine.create(yielder)
				coroutine.resume(thread)
			end

			if not cn._varargs then
				local passed, message = coroutine.resume(thread, cn._fn, thread, ...)
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end
			else
				local args = cn._varargs
				local len = #args
				local count = len
				for _, value in { ... } do
					count += 1
					args[count] = value
				end

				local passed, message = coroutine.resume(thread, cn._fn, thread, table.unpack(args))
				if not passed then
					print(string.format("%s\nstacktrace:\n%s", message, debug.traceback()))
				end

				for i = count, len + 1, -1 do
					args[i] = nil
				end
			end

			cn = cn._next
		end
	end

local function disconnectAll<T...>(self: Signal<T...>)
	local cn = self._head
	while cn do
		disconnect(cn)
		cn = cn._next
	end
end

local function destroy<T...>(self: Signal<T...>)
	disconnectAll(self)
end

--\\ Constructors
function Signal.new<T...>(): Signal<T...>
	return setmetatable({ _head = false }, Signal)
end


--\\ Methods
Signal.Connect = connect
Signal.Once = once
Signal.Wait = wait
Signal.Fire = fire
Signal.DisconnectAll = disconnectAll
Signal.Destroy = destroy

return { new = Signal.new }
