-- Compiled with roblox-ts v3.0.0
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
--[[
	***********************************************************
	 * UTILITIES
	 * Description: Functions and classes for general use
	 * Last updated: Jan. 14, 2025
	 ***********************************************************
]]
local _binding = os
local clock = _binding.clock
local _binding_1 = task
local cancel = _binding_1.cancel
local defer = _binding_1.defer
local delay = _binding_1.delay
local spawn = _binding_1.spawn
local _binding_2 = math
local abs = _binding_2.abs
local atan2 = _binding_2.atan2
local cos = _binding_2.cos
local clamp = _binding_2.clamp
local max = _binding_2.max
local pi = _binding_2.pi
local rad = _binding_2.rad
local sin = _binding_2.sin
local sqrt = _binding_2.sqrt
local EPSILON = 5e-3
local PI, TAU, SEMI, DEG60, DEG45 = pi, 2 * pi, pi / 2, pi / 3, pi / 4
local VECTOR3_2D, VECTOR3_ZERO = Vector3.new(1, 0, 1), Vector3.zero
local WORLD_UP, WORLD_RIGHT, WORLD_FORWARD = Vector3.new(0, 1, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1)
local wrapRad = function(angle)
	return ((angle % TAU) + TAU) % TAU
end
--[[
	*
	 * A simple representation of RBXScriptConnection for custom events.
	 
]]
local Connection
do
	Connection = setmetatable({}, {
		__tostring = function()
			return "Connection"
		end,
	})
	Connection.__index = Connection
	function Connection.new(...)
		local self = setmetatable({}, Connection)
		return self:constructor(...) or self
	end
	function Connection:constructor(disconnect, Connected)
		if Connected == nil then
			Connected = true
		end
		self.disconnect = disconnect
		self.Connected = Connected
	end
	function Connection:Disconnect()
		self.disconnect()
		self.Connected = false
	end
end
--[[
	*
	 * Tracks connections, instances, functions, threads, and objects to be later destroyed.
	 
]]
--[[
	*
	 * Tracks connections, instances, functions, threads, and objects to be later destroyed.
	 
]]
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return item
	end
	function Bin:destroy()
		while self.head do
			local item = self.head.item
			if type(item) == "function" then
				item()
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif isrenderobj(item) then
				item:Destroy()
			elseif item.destroy ~= nil then
				item:destroy()
			elseif item.Destroy ~= nil then
				item:Destroy()
			elseif item.disconnect ~= nil then
				item:disconnect()
			elseif item.Disconnect ~= nil then
				item:Disconnect()
			elseif item.cancel ~= nil then
				item:cancel()
			end
			self.head = self.head.next
		end
		-- list is now empty, so we can clear the tail
		self.tail = nil
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end
--[[
	*
	 * Waits for a child instance to be added to the given parent object and returns it.
	 
]]
local function expectChild(obj, criteria, timeout)
	if timeout == nil then
		timeout = 1e4
	end
	local _binding_3 = criteria
	local kind = _binding_3[1]
	local name = _binding_3[2]
	local isValid = if name == nil then function(obj)
		return obj:IsA(kind)
	end else function(obj)
		return obj.Name == name and obj:IsA(kind)
	end
	for _, v in obj:GetChildren() do
		if isValid(v) then
			return v
		end
	end
	-- Wait for the child to be added
	local v
	local thread = coroutine.running()
	local c, d = obj.ChildAdded:Connect(function(i)
		if isValid(i) then
			v = i
			spawn(thread)
		end
	end), delay(timeout, function()
		return spawn(thread)
	end)
	coroutine.yield()
	if v then
		cancel(d)
	end
	if c.Connected then
		c:Disconnect()
	end
	return v
end
--[[
	*
	 * Runs for the all child instance that matches the given name and kind.
	 
]]
local function forChildThen(obj, criteria, callback, n)
	if n == nil then
		n = 9e9
	end
	local _binding_3 = criteria
	local kind = _binding_3[1]
	local name = _binding_3[2]
	local isValid = if name == nil then function(obj)
		return obj:IsA(kind)
	end else function(obj)
		return obj.Name == name and obj:IsA(kind)
	end
	for _, v in obj:GetChildren() do
		if isValid(v) then
			spawn(callback, v)
			n -= 1
			if n == 0 then
				return Connection.new(function() end)
			end
		end
	end
	local connection
	connection = obj.ChildAdded:Connect(function(v)
		if isValid(v) then
			spawn(callback, v)
			n -= 1
			if n == 0 then
				connection:Disconnect()
			end
		end
	end)
	return Connection.new(function()
		if connection.Connected then
			connection:Disconnect()
		end
	end)
end
--[[
	*
	 * Runs for the first child instance that matches the given name and kind.
	 
]]
local function whenChildThen(obj, criteria, callback, timeout)
	if timeout == nil then
		timeout = 1e4
	end
	local connection
	local thread = delay(timeout, function()
		if connection.Connected then
			connection:Disconnect()
		end
	end)
	connection = forChildThen(obj, criteria, function(child)
		cancel(thread)
		callback(child)
	end, 1)
	return connection
end
--[[
	***********************************************************
	 * VARIABLES
	 * Description: Functions and classes for general use
	 * Last updated: Jan. 14, 2025
	 ***********************************************************
]]
local LocalPlayer = Players.LocalPlayer
--[[
	***********************************************************
	 * CLASSES
	 * Description: Functions and classes for general use
	 * Last updated: Jan. 14, 2025
	 ***********************************************************
]]
local CameraController
local LocationMarker
do
	LocationMarker = setmetatable({}, {
		__tostring = function()
			return "LocationMarker"
		end,
	})
	LocationMarker.__index = LocationMarker
	function LocationMarker.new(...)
		local self = setmetatable({}, LocationMarker)
		return self:constructor(...) or self
	end
	function LocationMarker:constructor(origin)
		self.bin = Bin.new()
		self.OFFSET = Vector2.new(0, 5)
		self.origin = origin
		local label = Drawing.new("Text")
		local marker = Drawing.new("Circle")
		self.label = label
		self.marker = marker
		local bin = self.bin
		bin:add(label)
		bin:add(marker)
		-- initialize
		label.Center = true
		label.Outline = true
		marker.Filled = true
		marker.NumSides = 6
	end
	function LocationMarker:setTitle(title)
		self.label.Text = title
		return self
	end
	function LocationMarker:setSize(radius, textSize)
		self.marker.Radius = radius
		self.label.Size = textSize
		return self
	end
	function LocationMarker:setColor(color)
		self.label.Color = color
		self.marker.Color = color
		return self
	end
	function LocationMarker:setPosition(position)
		self.origin = position
		return self
	end
	function LocationMarker:setEnabled(enabled)
		local renderer = self.renderer
		local _result = renderer
		if _result ~= nil then
			_result:Disconnect()
		end
		if enabled then
			local _binding_3 = self
			local origin = _binding_3.origin
			local bin = _binding_3.bin
			local label = _binding_3.label
			local marker = _binding_3.marker
			local OFFSET = _binding_3.OFFSET
			renderer = bin:add(RunService.RenderStepped:Connect(function()
				local VPC, onscreen = CameraController.worldToViewportPoint(origin)
				if onscreen then
					local PC = Vector2.new(VPC.X, VPC.Y)
					label.Position = PC + OFFSET
					marker.Position = PC
					label.Visible = true
					marker.Visible = true
				else
					label.Visible = false
					marker.Visible = false
				end
			end))
		else
			self.renderer = nil
			self.label.Visible = false
			self.marker.Visible = false
		end
		return self
	end
	function LocationMarker:destroy()
		self.bin:destroy()
	end
end
--[[
	***********************************************************
	 * COMPONENTS
	 * Description: Classes for specific entities/objects
	 * Last updated: Feb. 14, 2024
	 ***********************************************************
]]
local BaseComponent
do
	BaseComponent = setmetatable({}, {
		__tostring = function()
			return "BaseComponent"
		end,
	})
	BaseComponent.__index = BaseComponent
	function BaseComponent.new(...)
		local self = setmetatable({}, BaseComponent)
		return self:constructor(...) or self
	end
	function BaseComponent:constructor(instance)
		self.instance = instance
		self.bin = Bin.new()
		self.bin:add(instance.Destroying:Connect(function()
			return self:destroy()
		end))
	end
	function BaseComponent:destroy()
		self.bin:destroy()
	end
end
local CharacterRig
do
	local super = BaseComponent
	CharacterRig = setmetatable({}, {
		__tostring = function()
			return "CharacterRig"
		end,
		__index = super,
	})
	CharacterRig.__index = CharacterRig
	function CharacterRig.new(...)
		local self = setmetatable({}, CharacterRig)
		return self:constructor(...) or self
	end
	function CharacterRig:constructor(instance)
		super.constructor(self, instance)
		self.health = 100
		self._subHealth = {}
		local root = expectChild(instance, { "BasePart", "HumanoidRootPart" }, 30)
		if not root then
			error("[CharacterRig]: " .. tostring(instance) .. " is missing HumanoidRootPart!")
		end
		local humanoid = expectChild(instance, { "Humanoid", "Humanoid" }, 30)
		if not humanoid then
			error("[CharacterRig]: " .. tostring(instance) .. " is missing Humanoid!")
		end
		self.root = root
		self.humanoid = humanoid
		self.health = humanoid.Health
		local _binding_3 = self
		local bin = _binding_3.bin
		bin:add(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			return self:onHumanoidHealthChanged()
		end))
		-- initialize
		spawn(function()
			return self:onHumanoidHealthChanged()
		end)
	end
	function CharacterRig:onHumanoidHealthChanged()
		local health = self.humanoid.Health
		if health == 0 then
			return self:destroy()
		end
		self.health = health
		local _exp = self._subHealth
		-- ▼ ReadonlyMap.forEach ▼
		local _callback = function(callback)
			return spawn(callback, health)
		end
		for _k, _v in _exp do
			_callback(_v, _k, _exp)
		end
		-- ▲ ReadonlyMap.forEach ▲
	end
	function CharacterRig:subscribeHealth(callback)
		local id = {}
		local _binding_3 = self
		local _subHealth = _binding_3._subHealth
		local bin = _binding_3.bin
		local health = _binding_3.health
		local _callback = callback
		_subHealth[id] = _callback
		spawn(callback, health)
		return bin:add(Connection.new(function()
			_subHealth[id] = nil
		end))
	end
	function CharacterRig:getRoot()
		return self.root
	end
	function CharacterRig:getHumanoid()
		return self.humanoid
	end
	function CharacterRig:getHealth()
		return self.health
	end
	function CharacterRig:getPivot()
		return self.root.CFrame
	end
	function CharacterRig:getPosition()
		return self.root.Position
	end
end
local MonsterComponent
do
	local super = BaseComponent
	MonsterComponent = setmetatable({}, {
		__tostring = function()
			return "MonsterComponent"
		end,
		__index = super,
	})
	MonsterComponent.__index = MonsterComponent
	function MonsterComponent.new(...)
		local self = setmetatable({}, MonsterComponent)
		return self:constructor(...) or self
	end
	function MonsterComponent:constructor(instance, name)
		if name == nil then
			name = instance.Name
		end
		super.constructor(self, instance)
		self.instance = instance
		self.name = name
		local label = Drawing.new("Text")
		self.label = label
		local _binding_3 = self
		local bin = _binding_3.bin
		bin:add(label)
		bin:add(instance.AncestryChanged:Connect(function()
			return self:destroy()
		end))
		-- initialize
		label.Text = name
		label.Size = 14
		label.Center = true
		label.Outline = true
	end
	function MonsterComponent:setColor(color)
		self.label.Color = color
	end
	function MonsterComponent:setEnabled(enabled)
		local _binding_3 = self
		local renderer = _binding_3.renderer
		local _result = renderer
		if _result ~= nil then
			_result:Disconnect()
		end
		if enabled then
			local _binding_4 = self
			local bin = _binding_4.bin
			local root = _binding_4.root
			local label = _binding_4.label
			self.renderer = bin:add(RunService.RenderStepped:Connect(function()
				local pivot = root.CFrame
				local position = root.Position
				local VPC = CameraController.worldToViewportPoint(position)
				if VPC.Z > 0 then
					local PC = Vector2.new(VPC.X, VPC.Y)
					-- Label
					label.Position = PC
					label.Visible = true
				else
					label.Visible = false
				end
			end))
		else
			self.renderer = nil
			self.label.Visible = false
		end
	end
end
local FingerprintComponent
do
	local super = BaseComponent
	FingerprintComponent = setmetatable({}, {
		__tostring = function()
			return "FingerprintComponent"
		end,
		__index = super,
	})
	FingerprintComponent.__index = FingerprintComponent
	function FingerprintComponent.new(...)
		local self = setmetatable({}, FingerprintComponent)
		return self:constructor(...) or self
	end
	function FingerprintComponent:constructor(instance)
		super.constructor(self, instance)
		self.fingerprint = instance
		local marker = LocationMarker.new(instance.Position):setTitle(instance.Name):setSize(5, 10):setColor(Color3.new(1, 0.5, 0)):setEnabled(true)
		self.marker = marker
		local _binding_3 = self
		local bin = _binding_3.bin
		bin:add(marker)
		bin:add(instance.AncestryChanged:Connect(function()
			return self:destroy()
		end))
	end
end
local ItemComponent
do
	local super = BaseComponent
	ItemComponent = setmetatable({}, {
		__tostring = function()
			return "ItemComponent"
		end,
		__index = super,
	})
	ItemComponent.__index = ItemComponent
	function ItemComponent.new(...)
		local self = setmetatable({}, ItemComponent)
		return self:constructor(...) or self
	end
	function ItemComponent:constructor(instance)
		super.constructor(self, instance)
		local handle = expectChild(instance, { "BasePart", "Handle" }, 30)
		self.handle = handle
		if not handle then
			error("[ItemComponent]: " .. tostring(instance) .. " is missing Handle")
		end
		local marker = LocationMarker.new(instance:GetPivot().Position):setTitle(instance:GetAttribute("ItemName")):setSize(5, 10):setColor(Color3.new(0.5, 1, 0.5)):setEnabled(true)
		self.marker = marker
		local _binding_3 = self
		local bin = _binding_3.bin
		bin:add(marker)
		bin:add(instance.AncestryChanged:Connect(function()
			return self:destroy()
		end))
	end
end
local CursedPossesionHolderComponent
do
	local super = BaseComponent
	CursedPossesionHolderComponent = setmetatable({}, {
		__tostring = function()
			return "CursedPossesionHolderComponent"
		end,
		__index = super,
	})
	CursedPossesionHolderComponent.__index = CursedPossesionHolderComponent
	function CursedPossesionHolderComponent.new(...)
		local self = setmetatable({}, CursedPossesionHolderComponent)
		return self:constructor(...) or self
	end
	function CursedPossesionHolderComponent:constructor(instance)
		super.constructor(self, instance)
		local primary = instance.PrimaryPart
		self.primary = primary
		if not primary then
			error("[CursedPossesionHolderComponent]: " .. tostring(instance) .. " is missing a primary part!")
		end
		self.primary = primary
		local _position = instance:GetPivot().Position
		local _vector3 = Vector3.new(0, 3, 0)
		local marker = LocationMarker.new(_position + _vector3):setTitle(instance:GetAttribute("ItemName")):setSize(5, 14):setColor(Color3.new(1, 0, 0)):setEnabled(true)
		self.marker = marker
		local _binding_3 = self
		local bin = _binding_3.bin
		bin:add(marker)
		bin:add(instance.AncestryChanged:Connect(function()
			return self:destroy()
		end))
	end
end
local MolesterComponent
do
	local super = MonsterComponent
	MolesterComponent = setmetatable({}, {
		__tostring = function()
			return "MolesterComponent"
		end,
		__index = super,
	})
	MolesterComponent.__index = MolesterComponent
	function MolesterComponent.new(...)
		local self = setmetatable({}, MolesterComponent)
		return self:constructor(...) or self
	end
	function MolesterComponent:constructor(instance)
		super.constructor(self, instance, "Ghost")
		local root = expectChild(instance, { "BasePart", "HumanoidRootPart" }, 30)
		if not root then
			error("[MolesterComponent]: " .. tostring(instance) .. " is missing HumanoidRootPart!")
		end
		local humanoid = expectChild(instance, { "Humanoid", "Humanoid" }, 30)
		if not humanoid then
			error("[MolesterComponent]: " .. tostring(instance) .. " is missing Humanoid!")
		end
		self.root = root
		self.humanoid = humanoid
		self:setColor(Color3.new(1, 0, 0))
		self:setEnabled(true)
	end
	function MolesterComponent:getPivot()
		return self.root.CFrame
	end
end
--[[
	*
	 ***********************************************************
	 * CONTROLLERS
	 * Description: Singletons that are used once
	 * Last updated: Jan. 14, 2025
	 ***********************************************************
	 
]]
local AgentController = {}
do
	local _container = AgentController
	local component
	local onCharacterAdded = function(character)
		local _result = component
		if _result ~= nil then
			_result:destroy()
		end
		component = CharacterRig.new(character)
	end
	local onCharacterRemoved = function()
		local _result = component
		if _result ~= nil then
			_result:destroy()
		end
		component = nil
	end
	local function __init()
		LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
		LocalPlayer.CharacterRemoving:Connect(onCharacterRemoved)
		local character = LocalPlayer.Character
		if character then
			spawn(onCharacterAdded, character)
		end
	end
	_container.__init = __init
	local function getRoot()
		local _result = component
		if _result ~= nil then
			_result = _result:getRoot()
		end
		return _result
	end
	_container.getRoot = getRoot
	local function getHumanoid()
		local _result = component
		if _result ~= nil then
			_result = _result:getHumanoid()
		end
		return _result
	end
	_container.getHumanoid = getHumanoid
	local function getHealth()
		local _result = component
		if _result ~= nil then
			_result = _result:getHealth()
		end
		return _result
	end
	_container.getHealth = getHealth
	local function getPosition()
		local _result = component
		if _result ~= nil then
			_result = _result:getPosition()
		end
		return _result
	end
	_container.getPosition = getPosition
	local function getPivot()
		local _result = component
		if _result ~= nil then
			_result = _result:getPivot()
		end
		return _result
	end
	_container.getPivot = getPivot
end
CameraController = {}
do
	local _container = CameraController
	local camera
	local screen_size
	local screen_center
	--[[
		*
		     *
		     * A simple wrapper around `Camera.WorldToViewportPoint`.
		     * @returns The viewport point
		     
	]]
	local function worldToViewportPoint(position)
		return camera:WorldToViewportPoint(position)
	end
	_container.worldToViewportPoint = worldToViewportPoint
	--[[
		*
		     *
		     * Projects a world point behind the camera onto the viewport.
		     * @returns point beyond the edge of the viewport
		     
	]]
	local function safeWorldToViewportPoint(position)
		local eye = camera.CFrame
		local relative = eye:PointToObjectSpace(position)
		local angle = atan2(relative.Y, relative.X) + pi
		local _cFrame = CFrame.new(0, 0, 0)
		local _arg0 = CFrame.Angles(0, 0, angle)
		local _arg0_1 = CFrame.Angles(0, SEMI - EPSILON, 0)
		local oriented = (_cFrame * _arg0 * _arg0_1).LookVector
		local worldPosition = eye:PointToWorldSpace(oriented)
		local viewportPoint = worldToViewportPoint(worldPosition)
		local _vector2 = Vector2.new(viewportPoint.X, viewportPoint.Y)
		local _screen_center = screen_center
		local direction = (_vector2 - _screen_center).Unit
		local _screen_center_1 = screen_center
		local _arg0_2 = direction * 1e5
		return _screen_center_1 + _arg0_2
	end
	_container.safeWorldToViewportPoint = safeWorldToViewpor