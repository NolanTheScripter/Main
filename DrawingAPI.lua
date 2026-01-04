--[[
	DrawingAPI - High-Performance Multi-Platform Drawing Library
	Author: Lead Roblox Engine Engineer
	
	A drop-in replacement for Drawing.new() using native Roblox UI instances.
	Features object pooling, metatable-based property management, and optimized rendering.
]]

local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local DrawingAPI = {}

-- Configuration
local CONFIG = {
	SCREEN_GUI_NAME = "DrawingAPI_Layer",
	POOL_FOLDER_NAME = "DrawingAPI_Pool",
	MAX_POOL_SIZE = 1000,
	RENDER_PRIORITY = 2147483647, -- Maximum DisplayOrder
	DEFAULT_THICKNESS = 1,
	DEFAULT_COLOR = Color3.new(1, 1, 1),
	DEFAULT_TRANSPARENCY = 0,
}

-- Object Pools (Dormant & Active tracking)
local ObjectPools = {
	Line = {},
	Circle = {},
	Square = {},
	Text = {},
	Triangle = {},
	Quad = {},
}

local ActiveObjects = {}
local ScreenGui = nil
local PoolFolder = nil
local GuiInset = Vector2.new(0, 0)

-- Utility Functions
local function CreateScreenGui()
	if ScreenGui then return ScreenGui end
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = CONFIG.SCREEN_GUI_NAME
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = CONFIG.RENDER_PRIORITY
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = playerGui
	
	return ScreenGui
end

local function CreatePoolFolder()
	if PoolFolder then return PoolFolder end
	
	PoolFolder = Instance.new("Folder")
	PoolFolder.Name = CONFIG.POOL_FOLDER_NAME
	PoolFolder.Parent = game:GetService("ReplicatedStorage")
	
	return PoolFolder
end

local function UpdateGuiInset()
	GuiInset = GuiService:GetGuiInset()
end

-- Initialize GUI inset tracking
UpdateGuiInset()
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(UpdateGuiInset)

-- Object Creation Functions
local function CreateLineInstance()
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = CONFIG.DEFAULT_COLOR
	frame.BackgroundTransparency = CONFIG.DEFAULT_TRANSPARENCY
	frame.ZIndex = CONFIG.RENDER_PRIORITY
	return frame
end

local function CreateCircleInstance()
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = CONFIG.DEFAULT_COLOR
	frame.BackgroundTransparency = CONFIG.DEFAULT_TRANSPARENCY
	frame.ZIndex = CONFIG.RENDER_PRIORITY
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
	
	local stroke = Instance.new("UIStroke")
	stroke.Enabled = false
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
	
	return frame
end

local function CreateSquareInstance()
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = CONFIG.DEFAULT_COLOR
	frame.BackgroundTransparency = CONFIG.DEFAULT_TRANSPARENCY
	frame.ZIndex = CONFIG.RENDER_PRIORITY
	
	local stroke = Instance.new("UIStroke")
	stroke.Enabled = false
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
	
	return frame
end

local function CreateTextInstance()
	local label = Instance.new("TextLabel")
	label.BorderSizePixel = 0
	label.BackgroundTransparency = 1
	label.TextColor3 = CONFIG.DEFAULT_COLOR
	label.TextSize = 18
	label.Font = Enum.Font.SourceSans
	label.ZIndex = CONFIG.RENDER_PRIORITY
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	
	local stroke = Instance.new("UIStroke")
	stroke.Enabled = false
	stroke.Thickness = 1
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Parent = label
	
	return label
end

local function CreateQuadInstance()
	-- Using two triangular frames for quad representation
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(0, 100, 0, 100)
	container.ZIndex = CONFIG.RENDER_PRIORITY
	
	-- Store quad data in container for later rendering
	container:SetAttribute("IsQuad", true)
	
	return container
end

-- Object Pooling System
local function GetFromPool(objectType)
	local pool = ObjectPools[objectType]
	if #pool > 0 then
		local instance = table.remove(pool)
		instance.Parent = ScreenGui or CreateScreenGui()
		instance.Visible = false
		return instance
	end
	
	-- Create new instance if pool is empty
	local createFunc = {
		Line = CreateLineInstance,
		Circle = CreateCircleInstance,
		Square = CreateSquareInstance,
		Text = CreateTextInstance,
		Quad = CreateQuadInstance,
	}
	
	local instance = createFunc[objectType]()
	instance.Parent = ScreenGui or CreateScreenGui()
	instance.Visible = false
	return instance
end

local function ReturnToPool(objectType, instance)
	local pool = ObjectPools[objectType]
	
	if #pool >= CONFIG.MAX_POOL_SIZE then
		instance:Destroy()
		return
	end
	
	instance.Visible = false
	instance.Parent = PoolFolder or CreatePoolFolder()
	table.insert(pool, instance)
end

-- Rendering Functions
local function RenderLine(obj, properties)
	local from = properties.From
	local to = properties.To
	local thickness = properties.Thickness
	
	local delta = to - from
	local magnitude = delta.Magnitude
	local midpoint = (from + to) / 2
	local angle = math.deg(math.atan2(delta.Y, delta.X))
	
	obj.Instance.Position = UDim2.new(0, midpoint.X, 0, midpoint.Y)
	obj.Instance.Size = UDim2.new(0, magnitude, 0, thickness)
	obj.Instance.Rotation = angle
	obj.Instance.BackgroundColor3 = properties.Color
	obj.Instance.BackgroundTransparency = properties.Transparency
	obj.Instance.Visible = properties.Visible
	obj.Instance.ZIndex = properties.ZIndex
end

local function RenderCircle(obj, properties)
	local radius = properties.Radius
	local position = properties.Position
	
	obj.Instance.Position = UDim2.new(0, position.X, 0, position.Y)
	obj.Instance.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	obj.Instance.BackgroundColor3 = properties.Color
	obj.Instance.BackgroundTransparency = properties.Filled and properties.Transparency or 1
	obj.Instance.Visible = properties.Visible
	obj.Instance.ZIndex = properties.ZIndex
	
	local stroke = obj.Instance:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Enabled = not properties.Filled
		stroke.Thickness = properties.Thickness
		stroke.Color = properties.Color
		stroke.Transparency = properties.Transparency
	end
end

local function RenderSquare(obj, properties)
	local size = properties.Size
	local position = properties.Position
	
	obj.Instance.Position = UDim2.new(0, position.X, 0, position.Y)
	obj.Instance.Size = UDim2.new(0, size.X, 0, size.Y)
	obj.Instance.BackgroundColor3 = properties.Color
	obj.Instance.BackgroundTransparency = properties.Filled and properties.Transparency or 1
	obj.Instance.Visible = properties.Visible
	obj.Instance.ZIndex = properties.ZIndex
	
	local stroke = obj.Instance:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Enabled = not properties.Filled
		stroke.Thickness = properties.Thickness
		stroke.Color = properties.Color
		stroke.Transparency = properties.Transparency
	end
end

local function RenderText(obj, properties)
	local position = properties.Position
	
	obj.Instance.Position = UDim2.new(0, position.X, 0, position.Y)
	obj.Instance.Text = properties.Text
	obj.Instance.TextColor3 = properties.Color
	obj.Instance.TextTransparency = properties.Transparency
	obj.Instance.TextSize = properties.Size
	obj.Instance.Font = properties.Font
	obj.Instance.Visible = properties.Visible
	obj.Instance.ZIndex = properties.ZIndex
	obj.Instance.Size = UDim2.new(0, 1000, 0, properties.Size + 10)
	
	if properties.Center then
		obj.Instance.TextXAlignment = Enum.TextXAlignment.Center
		obj.Instance.TextYAlignment = Enum.TextYAlignment.Center
	else
		obj.Instance.TextXAlignment = Enum.TextXAlignment.Left
		obj.Instance.TextYAlignment = Enum.TextYAlignment.Top
	end
	
	local stroke = obj.Instance:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Enabled = properties.Outline
		stroke.Color = properties.OutlineColor or Color3.new(0, 0, 0)
	end
end

local function RenderQuad(obj, properties)
	-- Simplified quad rendering using a rotated square
	-- For true quad support, would need custom mesh or multiple frames
	local pointA = properties.PointA
	local pointB = properties.PointB
	local pointC = properties.PointC
	local pointD = properties.PointD
	
	-- Calculate center and approximate size
	local centerX = (pointA.X + pointB.X + pointC.X + pointD.X) / 4
	local centerY = (pointA.Y + pointB.Y + pointC.Y + pointD.Y) / 4
	local center = Vector2.new(centerX, centerY)
	
	local width = math.max(
		(pointB - pointA).Magnitude,
		(pointD - pointC).Magnitude
	)
	local height = math.max(
		(pointD - pointA).Magnitude,
		(pointC - pointB).Magnitude
	)
	
	obj.Instance.Position = UDim2.new(0, center.X, 0, center.Y)
	obj.Instance.Size = UDim2.new(0, width, 0, height)
	obj.Instance.BackgroundColor3 = properties.Color
	obj.Instance.BackgroundTransparency = properties.Transparency
	obj.Instance.Visible = properties.Visible
	obj.Instance.ZIndex = properties.ZIndex
end

-- Drawing Object Class
local DrawingObject = {}
DrawingObject.__index = function(self, key)
	if key == "Instance" or key == "_properties" or key == "_needsRender" or key == "_type" then
		return rawget(self, key)
	end
	return rawget(self, "_properties")[key] or DrawingObject[key]
end

DrawingObject.__newindex = function(self, key, value)
	local properties = rawget(self, "_properties")
	local objectType = rawget(self, "_type")
	
	-- Type validation
	if key == "From" or key == "To" or key == "Position" or key == "PointA" or key == "PointB" or key == "PointC" or key == "PointD" then
		assert(typeof(value) == "Vector2", string.format("%s must be a Vector2", key))
	elseif key == "Color" or key == "OutlineColor" then
		assert(typeof(value) == "Color3", string.format("%s must be a Color3", key))
	elseif key == "Visible" or key == "Filled" or key == "Center" or key == "Outline" then
		assert(typeof(value) == "boolean", string.format("%s must be a boolean", key))
	elseif key == "Thickness" or key == "Radius" or key == "Transparency" or key == "ZIndex" then
		assert(typeof(value) == "number", string.format("%s must be a number", key))
	elseif key == "Text" then
		assert(typeof(value) == "string", "Text must be a string")
	elseif key == "Font" then
		assert(typeof(value) == "EnumItem" and value.EnumType == Enum.Font, "Font must be an Enum.Font")
	elseif key == "Size" then
		if objectType == "Square" then
			assert(typeof(value) == "Vector2", "Size must be a Vector2 for Square")
		else
			assert(typeof(value) == "number", "Size must be a number for Text")
		end
	end
	
	properties[key] = value
	rawset(self, "_needsRender", true)
end

function DrawingObject:Remove()
	local objectType = rawget(self, "_type")
	local instance = rawget(self, "Instance")
	
	if instance then
		ReturnToPool(objectType, instance)
		rawset(self, "Instance", nil)
	end
	
	ActiveObjects[self] = nil
end

function DrawingObject:Destroy()
	self:Remove()
end

function DrawingObject:Show()
	rawget(self, "_properties").Visible = true
	rawset(self, "_needsRender", true)
end

function DrawingObject:Hide()
	rawget(self, "_properties").Visible = false
	rawset(self, "_needsRender", true)
end

function DrawingObject:_render()
	if not rawget(self, "_needsRender") then return end
	if not rawget(self, "Instance") then return end
	
	local objectType = rawget(self, "_type")
	local properties = rawget(self, "_properties")
	
	local renderFunc = {
		Line = RenderLine,
		Circle = RenderCircle,
		Square = RenderSquare,
		Text = RenderText,
		Quad = RenderQuad,
	}
	
	renderFunc[objectType](self, properties)
	rawset(self, "_needsRender", false)
end

-- Factory Function
function DrawingAPI.new(objectType)
	assert(type(objectType) == "string", "objectType must be a string")
	assert(ObjectPools[objectType], string.format("Invalid object type: %s", objectType))
	
	local instance = GetFromPool(objectType)
	
	local properties = {
		Visible = false,
		Color = CONFIG.DEFAULT_COLOR,
		Transparency = CONFIG.DEFAULT_TRANSPARENCY,
		ZIndex = CONFIG.RENDER_PRIORITY,
		Thickness = CONFIG.DEFAULT_THICKNESS,
	}
	
	-- Type-specific defaults
	if objectType == "Line" then
		properties.From = Vector2.new(0, 0)
		properties.To = Vector2.new(100, 100)
	elseif objectType == "Circle" then
		properties.Position = Vector2.new(0, 0)
		properties.Radius = 50
		properties.Filled = false
	elseif objectType == "Square" then
		properties.Position = Vector2.new(0, 0)
		properties.Size = Vector2.new(100, 100)
		properties.Filled = false
	elseif objectType == "Text" then
		properties.Position = Vector2.new(0, 0)
		properties.Text = ""
		properties.Size = 18
		properties.Font = Enum.Font.SourceSans
		properties.Center = false
		properties.Outline = false
		properties.OutlineColor = Color3.new(0, 0, 0)
	elseif objectType == "Quad" then
		properties.PointA = Vector2.new(0, 0)
		properties.PointB = Vector2.new(100, 0)
		properties.PointC = Vector2.new(100, 100)
		properties.PointD = Vector2.new(0, 100)
	end
	
	local obj = setmetatable({
		Instance = instance,
		_properties = properties,
		_needsRender = true,
		_type = objectType,
	}, DrawingObject)
	
	ActiveObjects[obj] = true
	return obj
end

-- Render Loop (Batched Updates)
local lastRenderTime = 0
local RENDER_THROTTLE = 1/120 -- Max 120 updates per second

RunService.RenderStepped:Connect(function()
	local currentTime = tick()
	if currentTime - lastRenderTime < RENDER_THROTTLE then return end
	lastRenderTime = currentTime
	
	for obj in pairs(ActiveObjects) do
		obj:_render()
	end
end)

-- Cleanup
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
	for obj in pairs(ActiveObjects) do
		obj:Remove()
	end
end)

return DrawingAPI