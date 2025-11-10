
export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),

	__index: Connection,
	_head: Connection,
	_fn: (...any) -> (),
	_next: Connection,
	_prev: boolean,
	_signal: SignalClass,
	_varargs: { any } | boolean
}

export type SignalClass = {
	Connect: (self: SignalClass, fn: (...any) -> ()) -> Connection,
	Once: (self: SignalClass, fn: (...any) -> ()) -> Connection,
	Wait: (self: SignalClass) -> any,
	Fire: (self: SignalClass, ...any) -> (),
	DisconnectAll: (self: SignalClass) -> (),
	Destroy: (self: SignalClass) -> (),

	_head: boolean | Connection
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

local function disconnect(self: Connection)
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


local function connect(self: SignalClass, fn: (...any) -> (), ...: any?): Connection
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

local function once(self: SignalClass, fn: (...any) -> (), ...: any?) : Connection
	local cn

	cn = connect(self, function(...)
		disconnect(cn)
		fn(...)
	end, ...)

	return cn
end

local function wait(self: SignalClass): unknown
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

local function fire(self: SignalClass, ...: any)
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

local function disconnectAll(self: SignalClass)
	local cn = self._head
	while cn do
		disconnect(cn)
		cn = cn._next
	end
end

local function destroy(self: SignalClass)
	disconnectAll(self)
end


function Signal.new()
	return setmetatable({ _head = false }, Signal)
end


--\\ Methods
Signal.Connect = connect
Signal.Once = once
Signal.Wait = wait
Signal.Fire = fire
Signal.DisconnectAll = disconnectAll
Signal.Destroy = destroy

return { new = Signal.new } :: {
	new: () -> SignalClass
}