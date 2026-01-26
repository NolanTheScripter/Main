--!strict

--[[
	Dynamic UI System
	API:
		- DynamicUI.new() -> DynamicUI
		- :AddComponent(name: string, config: ComponentConfig) -> ()
		- :RemoveComponent(name: string) -> ()
		- :Toggle() -> ()
		- :Cleanup() -> ()
]]

-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- // Types
type ComponentConfig = {
	Type: string,
	Text: string?,
	Callback: (() -> ())?,
	Value: any?,
	Min: number?,
	Max: number?,
	Increment: number?
}

type Janitor = {
	Connections: {RBXScriptConnection},
	Instances: {Instance},
	Cleanup: (self: Janitor) -> ()
}

-- // Theme Provider
local Theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(30, 30, 35),
	Accent = Color3.fromRGB(100, 120, 255),
	Text = Color3.fromRGB(240, 240, 245),
	Border = Color3.fromRGB(50, 50, 60),
	
	Font = Enum.Font.GothamMedium,
	
	Padding = 8,
	CornerRadius = 6,
	BorderSize = 1
}

-- // Instance Factory
local function Create(className: string, properties: {[string]: any}): Instance
	local instance = Instance.new(className)
	for key, value in properties do
		(instance :: any)[key] = value
	end
	return instance
end

-- // Janitor Constructor
local function NewJanitor(): Janitor
	local self = {
		Connections = {},
		Instances = {}
	}
	
	function self:Cleanup()
		for _, conn in self.Connections do
			conn:Disconnect()
		end
		for _, inst in self.Instances do
			inst:Destroy()
		end
		table.clear(self.Connections)
		table.clear(self.Instances)
	end
	
	return self
end

-- // Signal Class
local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	return self
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Connect(callback: (...any) -> ())
	return self._bindable.Event:Connect(callback)
end

function Signal:Destroy()
	self._bindable:Destroy()
end

-- // Draggable Function
local function MakeDraggable(frame: Frame, janitor: Janitor)
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = UDim2.new()
	
	local conn1 = frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = frame.Position
		end
	end)
	
	local conn2 = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	local conn3 = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	table.insert(janitor.Connections, conn1)
	table.insert(janitor.Connections, conn2)
	table.insert(janitor.Connections, conn3)
end

-- // DynamicUI Class
local DynamicUI = {}
DynamicUI.__index = DynamicUI

function DynamicUI.new()
	local self = setmetatable({}, DynamicUI)
	
	self._janitor = NewJanitor()
	self._visible = true
	self._components = {}
	self._toggleSignal = Signal.new()
	
	-- // ScreenGui
	local screenGui = Create("ScreenGui", {
		Name = "DynamicUI",
		Parent = PlayerGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	table.insert(self._janitor.Instances, screenGui)
	
	-- // UIScale
	local uiScale = Create("UIScale", {
		Scale = 0.75,
		Parent = screenGui
	})
	
	-- // MainFrame
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0
	})
	table.insert(self._janitor.Instances, mainFrame)
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, Theme.CornerRadius),
		Parent = mainFrame
	})
	
	Create("UIStroke", {
		Color = Theme.Border,
		Thickness = Theme.BorderSize,
		Parent = mainFrame
	})
	
	-- // Header
	local header = Create("Frame", {
		Name = "Header",
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, Theme.CornerRadius),
		Parent = header
	})
	
	local title = Create("TextLabel", {
		Name = "Title",
		Parent = header,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, Theme.Padding, 0.5, 0),
		Size = UDim2.new(0.8, -Theme.Padding, 1, 0),
		BackgroundTransparency = 1,
		Text = "Dynamic UI",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- // Close Button
	local closeBtn = Create("TextButton", {
		Name = "CloseButton",
		Parent = header,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -Theme.Padding, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundColor3 = Theme.Accent,
		Text = "X",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 14,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, 4),
		Parent = closeBtn
	})
	
	local closeBtnConn = closeBtn.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	table.insert(self._janitor.Connections, closeBtnConn)
	
	-- // Content Container
	local content = Create("ScrollingFrame", {
		Name = "Content",
		Parent = mainFrame,
		Position = UDim2.new(0, Theme.Padding, 0, 48),
		Size = UDim2.new(1, -Theme.Padding * 2, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	Create("UIListLayout", {
		Parent = content,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, Theme.Padding)
	})
	
	self._mainFrame = mainFrame
	self._content = content
	
	MakeDraggable(header, self._janitor)
	
	return self
end

function DynamicUI:AddComponent(name: string, config: ComponentConfig)
	if self._components[name] then
		return
	end
	
	local componentFrame = Create("Frame", {
		Name = name,
		Parent = self._content,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(0, Theme.CornerRadius),
		Parent = componentFrame
	})
	
	local label = Create("TextLabel", {
		Name = "Label",
		Parent = componentFrame,
		Position = UDim2.new(0, Theme.Padding, 0, 0),
		Size = UDim2.new(0.5, -Theme.Padding, 1, 0),
		BackgroundTransparency = 1,
		Text = config.Text or name,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	if config.Type == "Button" then
		local btn = Create("TextButton", {
			Name = "Button",
			Parent = componentFrame,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -Theme.Padding, 0.5, 0),
			Size = UDim2.new(0, 80, 0, 24),
			BackgroundColor3 = Theme.Accent,
			Text = "Execute",
			TextColor3 = Theme.Text,
			Font = Theme.Font,
			TextSize = 12,
			BorderSizePixel = 0
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = btn
		})
		
		if config.Callback then
			local conn = btn.MouseButton1Click:Connect(config.Callback)
			table.insert(self._janitor.Connections, conn)
		end
		
	elseif config.Type == "Toggle" then
		local toggle = Create("TextButton", {
			Name = "Toggle",
			Parent = componentFrame,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -Theme.Padding, 0.5, 0),
			Size = UDim2.new(0, 48, 0, 24),
			BackgroundColor3 = Theme.Border,
			Text = "",
			BorderSizePixel = 0
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = toggle
		})
		
		local indicator = Create("Frame", {
			Name = "Indicator",
			Parent = toggle,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = indicator
		})
		
		local state = false
		local conn = toggle.MouseButton1Click:Connect(function()
			state = not state
			local targetPos = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			local targetColor = state and Theme.Accent or Theme.Border
			
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
			TweenService:Create(indicator, tweenInfo, {Position = targetPos}):Play()
			TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = targetColor}):Play()
			
			if config.Callback then
				task.spawn(config.Callback)
			end
		end)
		table.insert(self._janitor.Connections, conn)
		
	elseif config.Type == "Slider" then
		local sliderBg = Create("Frame", {
			Name = "SliderBg",
			Parent = componentFrame,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -Theme.Padding, 0.5, 0),
			Size = UDim2.new(0, 120, 0, 6),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = sliderBg
		})
		
		local sliderFill = Create("Frame", {
			Name = "Fill",
			Parent = sliderBg,
			Size = UDim2.new(0.5, 0, 1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0
		})
		
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = sliderFill
		})
		
		local valueLabel = Create("TextLabel", {
			Name = "Value",
			Parent = componentFrame,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -136, 0.5, 0),
			Size = UDim2.new(0, 40, 1, 0),
			BackgroundTransparency = 1,
			Text = tostring(config.Value or 50),
			TextColor3 = Theme.Text,
			Font = Theme.Font,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right
		})
	end
	
	self._components[name] = componentFrame
end

function DynamicUI:RemoveComponent(name: string)
	local component = self._components[name]
	if component then
		component:Destroy()
		self._components[name] = nil
	end
end

function DynamicUI:Toggle()
	self._visible = not self._visible
	
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
	local targetSize = self._visible and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0, 0)
	
	TweenService:Create(self._mainFrame, tweenInfo, {Size = targetSize}):Play()
	
	self._toggleSignal:Fire(self._visible)
end

function DynamicUI:Cleanup()
	self._toggleSignal:Destroy()
	self._janitor:Cleanup()
end

return DynamicUI