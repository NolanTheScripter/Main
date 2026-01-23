--!strict
-- Advanced Client Toolkit v3.0
-- Modular client-side utilities for Roblox

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

assert(RunService:IsClient(), "Client-only module")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local camera = workspace.CurrentCamera

-- Signal Class
local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({
		_connections = {},
		_isDestroyed = false
	}, Signal)
	return self
end

function Signal:Connect(callback)
	if self._isDestroyed then return end
	
	local conn = {
		callback = callback,
		connected = true,
		Disconnect = function(c)
			c.connected = false
		end
	}
	
	table.insert(self._connections, conn)
	return conn
end

function Signal:Fire(...)
	if self._isDestroyed then return end
	
	for i = #self._connections, 1, -1 do
		local conn = self._connections[i]
		if not conn.connected then
			table.remove(self._connections, i)
		else
			task.spawn(conn.callback, ...)
		end
	end
end

function Signal:Wait()
	if self._isDestroyed then return end
	
	local thread = coroutine.running()
	local conn
	
	conn = self:Connect(function(...)
		conn:Disconnect()
		task.spawn(thread, ...)
	end)
	
	return coroutine.yield()
end

function Signal:Destroy()
	self._isDestroyed = true
	table.clear(self._connections)
end

-- Janitor Class
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
	return setmetatable({_tasks = {}}, Janitor)
end

function Janitor:Add(task, methodName)
	local taskType = typeof(task)
	
	if taskType == "RBXScriptConnection" then
		table.insert(self._tasks, {task = task, cleanup = "Disconnect"})
	elseif taskType == "Instance" then
		table.insert(self._tasks, {task = task, cleanup = "Destroy"})
	elseif taskType == "function" then
		table.insert(self._tasks, {task = task, cleanup = "call"})
	elseif taskType == "table" and task.Destroy then
		table.insert(self._tasks, {task = task, cleanup = methodName or "Destroy"})
	end
	
	return task
end

function Janitor:Cleanup(task)
	for i, t in ipairs(self._tasks) do
		if t.task == task then
			if t.cleanup == "call" then
				t.task()
			elseif t.cleanup == "Disconnect" and t.task.Connected then
				t.task:Disconnect()
			else
				pcall(function() t.task[t.cleanup](t.task) end)
			end
			table.remove(self._tasks, i)
			break
		end
	end
end

function Janitor:Destroy()
	for _, t in ipairs(self._tasks) do
		if t.cleanup == "call" then
			pcall(t.task)
		elseif t.cleanup == "Disconnect" and typeof(t.task) == "RBXScriptConnection" then
			if t.task.Connected then
				t.task:Disconnect()
			end
		else
			pcall(function() t.task[t.cleanup](t.task) end)
		end
	end
	table.clear(self._tasks)
end

-- Platform Module
local Platform = {}

function Platform.Get()
	local p = UserInputService:GetPlatform()
	
	if p == Enum.Platform.Windows or p == Enum.Platform.OSX then
		return "Desktop"
	elseif p == Enum.Platform.IOS or p == Enum.Platform.Android then
		return "Mobile"
	elseif p == Enum.Platform.XBoxOne or p == Enum.Platform.PS4 then
		return "Console"
	end
	
	return "Unknown"
end

function Platform.IsMobile()
	return Platform.Get() == "Mobile"
end

function Platform.IsDesktop()
	return Platform.Get() == "Desktop"
end

function Platform.IsConsole()
	return Platform.Get() == "Console"
end

function Platform.HasTouch()
	return UserInputService.TouchEnabled
end

function Platform.HasMouse()
	return UserInputService.MouseEnabled
end

function Platform.HasGamepad()
	return UserInputService.GamepadEnabled
end

function Platform.GetAspectRatio()
	local vp = camera.ViewportSize
	return vp.X / vp.Y
end

function Platform.IsPortrait()
	return Platform.GetAspectRatio() < 1
end

function Platform.IsLandscape()
	return Platform.GetAspectRatio() > 1
end

-- Input Module
local Input = {
	_bindings = {},
	_janitor = Janitor.new()
}

function Input.Bind(name, callback, options)
	options = options or {}
	
	local binding = {
		callback = callback,
		key = options.Key,
		gamepad = options.Gamepad,
		priority = options.Priority or 0
	}
	
	Input._bindings[name] = binding
	
	if binding.key then
		Input._janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == binding.key then
				callback(input, Enum.UserInputState.Begin)
			end
		end))
		
		Input._janitor:Add(UserInputService.InputEnded:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == binding.key then
				callback(input, Enum.UserInputState.End)
			end
		end))
	end
	
	if binding.gamepad and Platform.HasGamepad() then
		Input._janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == binding.gamepad then
				callback(input, Enum.UserInputState.Begin)
			end
		end))
	end
end

function Input.Unbind(name)
	Input._bindings[name] = nil
end

function Input.GetMousePosition()
	return UserInputService:GetMouseLocation()
end

function Input.GetMouseDelta()
	local d = UserInputService:GetMouseDelta()
	return Vector2.new(d.X, d.Y)
end

-- Player Module
local Player = {}

function Player.Get()
	return player
end

function Player.GetCharacter()
	return player.Character
end

function Player.GetHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

function Player.GetRoot()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

function Player.GetPosition()
	local root = Player.GetRoot()
	return root and root.Position or Vector3.zero
end

function Player.GetHealth()
	local hum = Player.GetHumanoid()
	return hum and hum.Health or 0
end

function Player.GetMaxHealth()
	local hum = Player.GetHumanoid()
	return hum and hum.MaxHealth or 0
end

function Player.IsAlive()
	local hum = Player.GetHumanoid()
	return hum and hum.Health > 0
end

-- Camera Module
local Camera = {}

function Camera.Get()
	return camera
end

function Camera.GetCFrame()
	return camera.CFrame
end

function Camera.GetPosition()
	return camera.CFrame.Position
end

function Camera.GetViewportSize()
	return camera.ViewportSize
end

function Camera.WorldToScreen(worldPos)
	local screenPoint, visible = camera:WorldToScreenPoint(worldPos)
	return Vector2.new(screenPoint.X, screenPoint.Y), visible
end

function Camera.ScreenToWorld(screenPoint, depth)
	local ray = camera:ScreenPointToRay(screenPoint.X, screenPoint.Y, depth or 0)
	return ray.Origin + ray.Direction * (depth or 0)
end

-- Math Module
local Math = {}

function Math.Lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

function Math.InverseLerp(a, b, value)
	return a ~= b and math.clamp((value - a) / (b - a), 0, 1) or 0
end

function Math.LerpVector3(a, b, t)
	return Vector3.new(
		Math.Lerp(a.X, b.X, t),
		Math.Lerp(a.Y, b.Y, t),
		Math.Lerp(a.Z, b.Z, t)
	)
end

function Math.Distance(a, b)
	return (a - b).Magnitude
end

function Math.DistanceSquared(a, b)
	local diff = a - b
	return diff:Dot(diff)
end

function Math.Direction(from, to)
	return (to - from).Unit
end

function Math.Clamp(value, min, max)
	return math.clamp(value, min, max)
end

function Math.Round(num, precision)
	precision = precision or 0
	local mult = 10 ^ precision
	return math.floor(num * mult + 0.5) / mult
end

function Math.Map(value, inMin, inMax, outMin, outMax)
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- Table Module
local Table = {}

function Table.DeepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = type(v) == "table" and Table.DeepCopy(v) or v
	end
	return copy
end

function Table.Merge(target, source)
	for k, v in pairs(source) do
		target[k] = v
	end
	return target
end

function Table.Find(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then return k end
	end
	return nil
end

function Table.Filter(tbl, predicate)
	local result = {}
	for k, v in pairs(tbl) do
		if predicate(v, k) then
			result[k] = v
		end
	end
	return result
end

function Table.Map(tbl, transform)
	local result = {}
	for k, v in pairs(tbl) do
		result[k] = transform(v, k)
	end
	return result
end

function Table.Keys(tbl)
	local keys = {}
	for k in pairs(tbl) do
		table.insert(keys, k)
	end
	return keys
end

function Table.Values(tbl)
	local values = {}
	for _, v in pairs(tbl) do
		table.insert(values, v)
	end
	return values
end

function Table.IsEmpty(tbl)
	return next(tbl) == nil
end

-- Async Module
local Async = {}

function Async.Delay(seconds, callback)
	return task.delay(seconds, callback)
end

function Async.Spawn(callback)
	return task.spawn(callback)
end

function Async.Defer(callback)
	return task.defer(callback)
end

function Async.WaitFor(condition, timeout, interval)
	timeout = timeout or 10
	interval = interval or 0.1
	local start = os.clock()
	
	while os.clock() - start < timeout do
		if condition() then return true end
		task.wait(interval)
	end
	
	return condition()
end

-- Tween Module
local Tween = {}

function Tween.Create(object, properties, info)
	info = info or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(object, info, properties)
	tween:Play()
	return tween
end

function Tween.Promise(object, properties, info)
	local tween = Tween.Create(object, properties, info)
	return function()
		tween.Completed:Wait()
	end
end

-- Debounce Module
local Debounce = {
	_cache = {},
	_throttleCache = {}
}

function Debounce.Wrap(id, func, delay)
	return function(...)
		local now = os.clock()
		local last = Debounce._cache[id] or 0
		
		if now - last >= delay then
			Debounce._cache[id] = now
			return func(...)
		end
	end
end

function Debounce.Throttle(id, func, interval)
	return function(...)
		if Debounce._throttleCache[id] then return end
		
		Debounce._throttleCache[id] = true
		local result = func(...)
		
		task.delay(interval, function()
			Debounce._throttleCache[id] = false
		end)
		
		return result
	end
end

function Debounce.Once(func)
	local called = false
	return function(...)
		if not called then
			called = true
			return func(...)
		end
	end
end

-- GUI Module
local GUI = {}

function GUI.Create(className, props)
	local instance = Instance.new(className)
	for prop, value in pairs(props) do
		instance[prop] = value
	end
	return instance
end

function GUI.Notification(message, options)
	options = options or {}
	
	local duration = options.Duration or 3
	local bgColor = options.Color or Color3.fromRGB(30, 30, 30)
	local textColor = options.TextColor or Color3.fromRGB(255, 255, 255)
	
	local notif = GUI.Create("TextLabel", {
		Size = UDim2.new(0, 300, 0, 50),
		Position = UDim2.new(0.5, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = bgColor,
		BackgroundTransparency = 1,
		TextColor3 = textColor,
		TextTransparency = 1,
		Text = message,
		TextScaled = true,
		Font = Enum.Font.GothamSemibold,
		ZIndex = 100,
		Parent = playerGui
	})
	
	GUI.Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = notif
	})
	
	GUI.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = notif
	})
	
	local fadeIn = Tween.Create(notif, {
		BackgroundTransparency = 0.3,
		TextTransparency = 0
	})
	
	task.delay(duration, function()
		local fadeOut = Tween.Create(notif, {
			BackgroundTransparency = 1,
			TextTransparency = 1
		})
		fadeOut.Completed:Wait()
		notif:Destroy()
	end)
	
	return notif
end

-- Frame Module
local Frame = {}

function Frame.OnRenderStep(callback)
	return RunService.RenderStepped:Connect(callback)
end

function Frame.OnHeartbeat(callback)
	return RunService.Heartbeat:Connect(callback)
end

function Frame.OnStepped(callback)
	return RunService.Stepped:Connect(callback)
end

-- Toolkit Export
local Toolkit = {
	Signal = Signal,
	Janitor = Janitor,
	Platform = Platform,
	Input = Input,
	Player = Player,
	Camera = Camera,
	Math = Math,
	Table = Table,
	Async = Async,
	Tween = Tween,
	Debounce = Debounce,
	GUI = GUI,
	Frame = Frame
}

return Toolkit