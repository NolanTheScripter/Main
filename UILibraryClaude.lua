--[[
    PRODUCTION-READY ROBLOX UI LIBRARY
    A comprehensive, scalable UI system following industry best practices
    Author: Generated with Claude
    Version: 1.0.0
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- ============================================================================
-- SERVICES
-- ============================================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================================================
-- UTILITIES
-- ============================================================================

local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in properties do
        if prop == "Children" then
            for _, child in ipairs(value) do
                child.Parent = instance
            end
        else
            instance[prop] = value
        end
    end
    return instance
end

-- ============================================================================
-- THEME
-- ============================================================================

local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    BackgroundSecondary = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(0, 120, 215),
    AccentHover = Color3.fromRGB(20, 140, 235),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Error = Color3.fromRGB(244, 67, 54),
    Info = Color3.fromRGB(33, 150, 243),
    Border = Color3.fromRGB(60, 60, 60),
    Hover = Color3.fromRGB(45, 45, 45),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    Padding = 10,
    BorderRadius = UDim.new(0, 6),
    TransitionSpeed = 0.3
}

-- ============================================================================
-- JANITOR (CLEANUP SYSTEM)
-- ============================================================================

local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
    return setmetatable({_tasks = {}}, Janitor)
end

function Janitor:Add(task)
    table.insert(self._tasks, task)
    return task
end

function Janitor:Destroy()
    for _, task in ipairs(self._tasks) do
        if type(task) == "function" then
            task()
        elseif typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        end
    end
    self._tasks = {}
end

-- ============================================================================
-- SIGNAL (EVENT SYSTEM)
-- ============================================================================

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({_connections = {}}, Signal)
end

function Signal:Connect(callback)
    local connection = {
        Connected = true,
        _callback = callback
    }
    
    function connection:Disconnect()
        self.Connected = false
        self._callback = nil
    end
    
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            task.spawn(connection._callback, ...)
        end
    end
end

function Signal:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    self._connections = {}
end

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local State = {}
State.__index = State

function State.new(initialValue)
    local self = setmetatable({
        _value = initialValue,
        Changed = Signal.new()
    }, State)
    return self
end

function State:Get()
    return self._value
end

function State:Set(newValue)
    if self._value ~= newValue then
        self._value = newValue
        self.Changed:Fire(newValue)
    end
end

-- ============================================================================
-- TWEEN UTILITY
-- ============================================================================

local function CreateTween(instance, duration, properties, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or Theme.TransitionSpeed,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(instance, tweenInfo, properties)
end

-- ============================================================================
-- BUTTON COMPONENT
-- ============================================================================

local Button = {}
Button.__index = Button

function Button.new(options)
    local self = setmetatable({}, Button)
    self.Janitor = Janitor.new()
    self.Clicked = Signal.new()
    
    options = options or {}
    local text = options.Text or "Button"
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local size = options.Size or UDim2.new(0, 200, 0, 40)
    
    self.Container = Create("TextButton", {
        Name = "Button",
        Text = "",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = position,
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.Container
    })
    
    self.Label = Create("TextLabel", {
        Name = "Label",
        Text = text,
        Font = Theme.FontBold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = self.Container
    })
    
    self.Janitor:Add(self.Container.MouseEnter:Connect(function()
        CreateTween(self.Container, 0.2, {BackgroundColor3 = Theme.AccentHover}):Play()
    end))
    
    self.Janitor:Add(self.Container.MouseLeave:Connect(function()
        CreateTween(self.Container, 0.2, {BackgroundColor3 = Theme.Accent}):Play()
    end))
    
    self.Janitor:Add(self.Container.MouseButton1Click:Connect(function()
        self.Clicked:Fire()
    end))
    
    return self
end

function Button:SetText(text)
    self.Label.Text = text
end

function Button:SetEnabled(enabled)
    self.Container.Active = enabled
    self.Container.BackgroundColor3 = enabled and Theme.Accent or Theme.Border
end

function Button:Destroy()
    self.Janitor:Destroy()
    self.Clicked:Destroy()
    self.Container:Destroy()
end

-- ============================================================================
-- DROPDOWN COMPONENT
-- ============================================================================

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(options)
    local self = setmetatable({}, Dropdown)
    self.Janitor = Janitor.new()
    self.Changed = Signal.new()
    
    options = options or {}
    local items = options.Items or {"Option 1", "Option 2", "Option 3"}
    local defaultIndex = options.DefaultIndex or 1
    local maxVisible = options.MaxVisibleItems or 5
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local size = options.Size or UDim2.new(0, 200, 0, 40)
    
    self.Items = items
    self.SelectedIndex = defaultIndex
    self.IsExpanded = false
    
    self.Container = Create("Frame", {
        Name = "Dropdown",
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 10,
        Parent = parent
    })
    
    self.Display = Create("TextButton", {
        Name = "Display",
        Text = "",
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        AutoButtonColor = false,
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.Display
    })
    
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = self.Display
    })
    
    self.DisplayLabel = Create("TextLabel", {
        Name = "Label",
        Text = items[defaultIndex],
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.Padding, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Parent = self.Display
    })
    
    self.Chevron = Create("TextLabel", {
        Name = "Chevron",
        Text = "▼",
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Parent = self.Display
    })
    
    local optionHeight = 36
    local maxHeight = optionHeight * math.min(#items, maxVisible)
    
    self.OptionsContainer = Create("ScrollingFrame", {
        Name = "Options",
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, optionHeight * #items),
        Visible = false,
        ZIndex = 11,
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.OptionsContainer
    })
    
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = self.OptionsContainer
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.OptionsContainer
    })
    
    for i, item in ipairs(items) do
        local option = Create("TextButton", {
            Name = "Option" .. i,
            Text = "",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, optionHeight),
            LayoutOrder = i,
            AutoButtonColor = false,
            Parent = self.OptionsContainer
        })
        
        local label = Create("TextLabel", {
            Text = item,
            Font = Theme.Font,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, Theme.Padding, 0, 0),
            Size = UDim2.new(1, -Theme.Padding * 2, 1, 0),
            Parent = option
        })
        
        self.Janitor:Add(option.MouseEnter:Connect(function()
            option.BackgroundTransparency = 0
            CreateTween(option, 0.15, {BackgroundColor3 = Theme.Hover}):Play()
        end))
        
        self.Janitor:Add(option.MouseLeave:Connect(function()
            CreateTween(option, 0.15, {BackgroundTransparency = 1}):Play()
        end))
        
        self.Janitor:Add(option.MouseButton1Click:Connect(function()
            self:SelectIndex(i)
            self:Toggle()
        end))
    end
    
    self.Janitor:Add(self.Display.MouseButton1Click:Connect(function()
        self:Toggle()
    end))
    
    local function checkClickOutside()
        if not self.IsExpanded then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local containerPos = self.Container.AbsolutePosition
        local containerSize = self.Container.AbsoluteSize
        local optionsSize = self.OptionsContainer.AbsoluteSize
        
        local totalHeight = containerSize.Y + optionsSize.Y + 4
        
        if mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
           mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + totalHeight then
            self:Toggle()
        end
    end
    
    self.Janitor:Add(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait()
            checkClickOutside()
        end
    end))
    
    return self
end

function Dropdown:Toggle()
    self.IsExpanded = not self.IsExpanded
    
    if self.IsExpanded then
        self.OptionsContainer.Visible = true
        local targetHeight = math.min(#self.Items * 36, 36 * 5)
        CreateTween(self.OptionsContainer, Theme.TransitionSpeed, {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
        CreateTween(self.Chevron, Theme.TransitionSpeed, {Rotation = 180}):Play()
    else
        CreateTween(self.OptionsContainer, Theme.TransitionSpeed, {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        CreateTween(self.Chevron, Theme.TransitionSpeed, {Rotation = 0}):Play()
        task.delay(Theme.TransitionSpeed, function()
            if not self.IsExpanded then
                self.OptionsContainer.Visible = false
            end
        end)
    end
end

function Dropdown:SelectIndex(index)
    if index >= 1 and index <= #self.Items then
        self.SelectedIndex = index
        self.DisplayLabel.Text = self.Items[index]
        self.Changed:Fire(index, self.Items[index])
    end
end

function Dropdown:GetValue()
    return self.Items[self.SelectedIndex]
end

function Dropdown:Destroy()
    self.Janitor:Destroy()
    self.Changed:Destroy()
    self.Container:Destroy()
end

-- ============================================================================
-- SLIDER COMPONENT
-- ============================================================================

local Slider = {}
Slider.__index = Slider

function Slider.new(options)
    local self = setmetatable({}, Slider)
    self.Janitor = Janitor.new()
    self.Changed = Signal.new()
    
    options = options or {}
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Step = options.Step or 1
    local defaultValue = options.Value or self.Min
    local showValue = options.ShowValue ~= false
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local size = options.Size or UDim2.new(0, 200, 0, 20)
    
    self.Value = defaultValue
    self.IsDragging = false
    
    self.Container = Create("Frame", {
        Name = "Slider",
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = parent
    })
    
    self.Track = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.Track
    })
    
    self.Fill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = self.Track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.Fill
    })
    
    self.Thumb = Create("ImageButton", {
        Name = "Thumb",
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        Parent = self.Track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.Thumb
    })
    
    if showValue then
        self.ValueLabel = Create("TextLabel", {
            Name = "ValueLabel",
            Text = tostring(self.Value),
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Parent = self.Container
        })
    end
    
    local function updateSlider(input)
        local trackPos = self.Track.AbsolutePosition.X
        local trackSize = self.Track.AbsoluteSize.X
        local mouseX = input.Position.X
        local relativeX = math.clamp(mouseX - trackPos, 0, trackSize)
        local percent = relativeX / trackSize
        
        local rawValue = self.Min + (percent * (self.Max - self.Min))
        local steppedValue = math.floor(rawValue / self.Step + 0.5) * self.Step
        steppedValue = math.clamp(steppedValue, self.Min, self.Max)
        
        self:SetValue(steppedValue)
    end
    
    self.Janitor:Add(self.Thumb.MouseButton1Down:Connect(function()
        self.IsDragging = true
    end))
    
    self.Janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end))
    
    self.Janitor:Add(UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end))
    
    self.Janitor:Add(self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            self.IsDragging = true
        end
    end))
    
    self.Janitor:Add(self.Thumb.MouseEnter:Connect(function()
        CreateTween(self.Thumb, 0.2, {Size = UDim2.new(0, 20, 0, 20)}):Play()
    end))
    
    self.Janitor:Add(self.Thumb.MouseLeave:Connect(function()
        if not self.IsDragging then
            CreateTween(self.Thumb, 0.2, {Size = UDim2.new(0, 16, 0, 16)}):Play()
        end
    end))
    
    self:SetValue(defaultValue)
    
    return self
end

function Slider:SetValue(value)
    value = math.clamp(value, self.Min, self.Max)
    if self.Value ~= value then
        self.Value = value
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        self.Fill.Size = UDim2.fromScale(percent, 1)
        self.Thumb.Position = UDim2.fromScale(percent, 0.5)
        
        if self.ValueLabel then
            self.ValueLabel.Text = tostring(value)
        end
        
        self.Changed:Fire(value)
    end
end

function Slider:GetValue()
    return self.Value
end

function Slider:Destroy()
    self.Janitor:Destroy()
    self.Changed:Destroy()
    self.Container:Destroy()
end

-- ============================================================================
-- TOGGLE COMPONENT
-- ============================================================================

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(options)
    local self = setmetatable({}, Toggle)
    self.Janitor = Janitor.new()
    self.Changed = Signal.new()
    
    options = options or {}
    local label = options.Label or "Toggle"
    local defaultValue = options.DefaultValue or false
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    
    self.Value = defaultValue
    
    self.Container = Create("Frame", {
        Name = "Toggle",
        BackgroundTransparency = 1,
        Position = position,
        Size = UDim2.new(0, 250, 0, 44),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = parent
    })
    
    self.Switch = Create("TextButton", {
        Name = "Switch",
        Text = "",
        BackgroundColor3 = defaultValue and Theme.Accent or Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 50, 0, 26),
        AutoButtonColor = false,
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.Switch
    })
    
    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = self.Switch
    })
    
    self.Thumb = Create("Frame", {
        Name = "Thumb",
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Position = defaultValue and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = self.Switch
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.Thumb
    })
    
    self.Label = Create("TextLabel", {
        Name = "Label",
        Text = label,
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Parent = self.Container
    })
    
    self.Janitor:Add(self.Switch.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end))
    
    return self
end

function Toggle:SetValue(value)
    self.Value = value
    
    local thumbPos = value and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 15, 0.5, 0)
    local bgColor = value and Theme.Accent or Theme.Background
    
    CreateTween(self.Thumb, Theme.TransitionSpeed, {Position = thumbPos}):Play()
    CreateTween(self.Switch, Theme.TransitionSpeed, {BackgroundColor3 = bgColor}):Play()
    
    self.Changed:Fire(value)
end

function Toggle:GetValue()
    return self.Value
end

function Toggle:Destroy()
    self.Janitor:Destroy()
    self.Changed:Destroy()
    self.Container:Destroy()
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================

local NotificationManager = {
    Container = nil,
    Queue = {},
    MaxVisible = 5
}

function NotificationManager:Initialize(screenGui)
    if self.Container then return end
    
    self.Container = Create("Frame", {
        Name = "NotificationContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 0),
        Parent = screenGui
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.Container
    })
end

function NotificationManager:Show(options)
    if not self.Container then
        warn("NotificationManager not initialized")
        return
    end
    
    local notifType = options.Type or "info"
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local duration = options.Duration or 5
    
    local typeColors = {
        info = Theme.Info,
        success = Theme.Success,
        warning = Theme.Warning,
        error = Theme.Error
    }
    
    local color = typeColors[notifType] or Theme.Info
    
    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80),
        LayoutOrder = #self.Queue + 1,
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = notif
    })
    
    Create("UIStroke", {
        Color = color,
        Thickness = 2,
        Parent = notif
    })
    
    local indicator = Create("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notif
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = indicator
    })
    
    local titleLabel = Create("TextLabel", {
        Text = title,
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -50, 0, 20),
        Parent = notif
    })
    
    if description ~= "" then
        Create("TextLabel", {
            Text = description,
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 32),
            Size = UDim2.new(1, -50, 0, 38),
            Parent = notif
        })
    end
    
    local closeBtn = Create("TextButton", {
        Text = "×",
        Font = Theme.FontBold,
        TextSize = 20,
        TextColor3 = Theme.TextSecondary,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Parent = notif
    })
    
    local function dismiss()
        CreateTween(notif, 0.3, {
            Position = UDim2.new(1, 50, notif.Position.Y.Scale, notif.Position.Y.Offset),
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    
    notif.Position = UDim2.new(1, 50, 0, 0)
    CreateTween(notif, 0.4, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back):Play()
    
    if duration and duration > 0 then
        task.delay(duration, dismiss)
    end
    
    table.insert(self.Queue, notif)
end

-- ============================================================================
-- MAIN LIBRARY INITIALIZATION
-- ============================================================================

function UILibrary.new(parent)
    local self = setmetatable({}, UILibrary)
    
    self.ScreenGui = Create("ScreenGui", {
        Name = "UILibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    NotificationManager:Initialize(self.ScreenGui)
    
    return self
end

function UILibrary:CreateButton(options)
    options.Parent = options.Parent or self.ScreenGui
    return Button.new(options)
end

function UILibrary:CreateDropdown(options)
    options.Parent = options.Parent or self.ScreenGui
    return Dropdown.new(options)
end

function UILibrary:CreateSlider(options)
    options.Parent = options.Parent or self.ScreenGui
    return Slider.new(options)
end

function UILibrary:CreateToggle(options)
    options.Parent = options.Parent or self.ScreenGui
    return Toggle.new(options)
end

function UILibrary:Notify(options)
    NotificationManager:Show(options)
end

-- ============================================================================
-- INPUT FIELD COMPONENT
-- ============================================================================

local Input = {}
Input.__index = Input

function Input.new(options)
    local self = setmetatable({}, Input)
    self.Janitor = Janitor.new()
    self.TextChanged = Signal.new()
    self.FocusGained = Signal.new()
    self.FocusLost = Signal.new()
    
    options = options or {}
    local placeholder = options.PlaceholderText or "Enter text..."
    local inputType = options.InputType or "text"
    local maxLength = options.MaxLength or 100
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local size = options.Size or UDim2.new(0, 200, 0, 40)
    
    self.InputType = inputType
    self.MaxLength = maxLength
    self.IsFocused = false
    
    self.Container = Create("Frame", {
        Name = "Input",
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = position,
        Size = size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.Container
    })
    
    self.Stroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = self.Container
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, Theme.Padding),
        PaddingRight = UDim.new(0, Theme.Padding),
        Parent = self.Container
    })
    
    self.TextBox = Create("TextBox", {
        Name = "TextBox",
        Text = "",
        PlaceholderText = placeholder,
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = self.Container
    })
    
    if inputType == "numeric" then
        self.TextBox.PlaceholderText = "0"
    elseif inputType == "password" then
        self.TextBox.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    self.Janitor:Add(self.TextBox.Focused:Connect(function()
        self.IsFocused = true
        CreateTween(self.Stroke, 0.2, {Color = Theme.Accent}):Play()
        self.FocusGained:Fire()
    end))
    
    self.Janitor:Add(self.TextBox.FocusLost:Connect(function()
        self.IsFocused = false
        CreateTween(self.Stroke, 0.2, {Color = Theme.Border}):Play()
        self.FocusLost:Fire(self.TextBox.Text)
    end))
    
    self.Janitor:Add(self.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = self.TextBox.Text
        
        if inputType == "numeric" then
            text = text:gsub("[^%d%.]", "")
            local dotCount = 0
            text = text:gsub("%.", function()
                dotCount = dotCount + 1
                return dotCount == 1 and "." or ""
            end)
            self.TextBox.Text = text
        end
        
        if #text > maxLength then
            self.TextBox.Text = text:sub(1, maxLength)
        end
        
        self.TextChanged:Fire(self.TextBox.Text)
    end))
    
    return self
end

function Input:GetText()
    return self.TextBox.Text
end

function Input:SetText(text)
    self.TextBox.Text = text
end

function Input:Clear()
    self.TextBox.Text = ""
end

function Input:SetEnabled(enabled)
    self.TextBox.TextEditable = enabled
    self.Container.BackgroundColor3 = enabled and Theme.BackgroundSecondary or Theme.Background
end

function Input:Destroy()
    self.Janitor:Destroy()
    self.TextChanged:Destroy()
    self.FocusGained:Destroy()
    self.FocusLost:Destroy()
    self.Container:Destroy()
end

function UILibrary:CreateInput(options)
    options.Parent = options.Parent or self.ScreenGui
    return Input.new(options)
end

-- ============================================================================
-- CHECKBOX COMPONENT
-- ============================================================================

local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox.new(options)
    local self = setmetatable({}, Checkbox)
    self.Janitor = Janitor.new()
    self.Changed = Signal.new()
    
    options = options or {}
    local label = options.Label or "Checkbox"
    local defaultValue = options.DefaultValue or false
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    
    self.Value = defaultValue
    
    self.Container = Create("Frame", {
        Name = "Checkbox",
        BackgroundTransparency = 1,
        Position = position,
        Size = UDim2.new(0, 250, 0, 44),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = parent
    })
    
    self.Box = Create("TextButton", {
        Name = "Box",
        Text = "",
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        AutoButtonColor = false,
        Parent = self.Container
    })
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.Box
    })
    
    self.Stroke = Create("UIStroke", {
        Color = defaultValue and Theme.Accent or Theme.Border,
        Thickness = 2,
        Parent = self.Box
    })
    
    self.Check = Create("TextLabel", {
        Name = "Check",
        Text = "✓",
        Font = Theme.FontBold,
        TextSize = 16,
        TextColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        TextTransparency = defaultValue and 0 or 1,
        Parent = self.Box
    })
    
    self.Label = Create("TextLabel", {
        Name = "Label",
        Text = label,
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Parent = self.Container
    })
    
    self.Janitor:Add(self.Box.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end))
    
    return self
end

function Checkbox:SetValue(value)
    self.Value = value
    
    local checkTransparency = value and 0 or 1
    local strokeColor = value and Theme.Accent or Theme.Border
    
    CreateTween(self.Check, 0.2, {TextTransparency = checkTransparency}):Play()
    CreateTween(self.Stroke, 0.2, {Color = strokeColor}):Play()
    
    if value then
        self.Box.BackgroundColor3 = Theme.Accent
        CreateTween(self.Box, 0.2, {BackgroundColor3 = Theme.BackgroundSecondary}):Play()
    end
    
    self.Changed:Fire(value)
end

function Checkbox:GetValue()
    return self.Value
end

function Checkbox:Destroy()
    self.Janitor:Destroy()
    self.Changed:Destroy()
    self.Container:Destroy()
end

function UILibrary:CreateCheckbox(options)
    options.Parent = options.Parent or self.ScreenGui
    return Checkbox.new(options)
end

-- ============================================================================
-- PARAGRAPH / TEXT BLOCK COMPONENT
-- ============================================================================

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(options)
    local self = setmetatable({}, Paragraph)
    self.Janitor = Janitor.new()
    
    options = options or {}
    local text = options.Text or ""
    local richText = options.RichText or false
    local maxHeight = options.MaxHeight
    local scrollable = options.Scrollable ~= false
    local parent = options.Parent
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local size = options.Size or UDim2.new(0, 400, 0, 200)
    
    if maxHeight and scrollable then
        self.Container = Create("ScrollingFrame", {
            Name = "Paragraph",
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Position = position,
            Size = size,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = parent
        })
    else
        self.Container = Create("Frame", {
            Name = "Paragraph",
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Position = position,
            Size = size,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Parent = parent
        })
    end
    
    Create("UICorner", {
        CornerRadius = Theme.BorderRadius,
        Parent = self.Container
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, Theme.Padding),
        PaddingRight = UDim.new(0, Theme.Padding),
        PaddingTop = UDim.new(0, Theme.Padding),
        PaddingBottom = UDim.new(0, Theme.Padding),
        Parent = self.Container
    })
    
    self.TextLabel = Create("TextLabel", {
        Name = "Text",
        Text = text,
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        RichText = richText,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        AutomaticSize = scrollable and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        Parent = self.Container
    })
    
    return self
end

function Paragraph:SetText(text)
    self.TextLabel.Text = text
end

function Paragraph:GetText()
    return self.TextLabel.Text
end

function Paragraph:Destroy()
    self.Janitor:Destroy()
    self.Container:Destroy()
end

function UILibrary:CreateParagraph(options)
    options.Parent = options.Parent or self.ScreenGui
    return Paragraph.new(options)
end

return UILibrary
