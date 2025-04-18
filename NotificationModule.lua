local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local NotificationModule = {}

-- Configuration with better organization and more options
local CONFIG = {
    Notification = {
        Duration = 4,
        MaxNotifications = 3,
        Spacing = 10,
        Size = UDim2.new(0.3, 0, 0.1, 0),
        ZIndex = 999,
    },
    Appearance = {
        BackgroundColor = Color3.fromRGB(35, 35, 35),
        BackgroundTransparency = 0.1,
        CornerRadius = UDim.new(0, 8),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TitleSize = 18,
        MessageSize = 15,
        TextPadding = 10,
        AccentBarWidth = 0.015,
    },
    AccentColors = {
        Success = Color3.fromRGB(76, 175, 80),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 193, 7),
        Info = Color3.fromRGB(33, 150, 243),
        Default = Color3.fromRGB(100, 100, 100)
    },
    Animations = {
        SlideInDuration = 0.35,
        SlideOutDuration = 0.4,
        SlideInEasing = Enum.EasingStyle.Quint,
        SlideOutEasing = Enum.EasingStyle.Quint,
        SlideInDirection = Enum.EasingDirection.Out,
        SlideOutDirection = Enum.EasingDirection.In
    }
}

-- Cache for better performance
local notifications = {}
local screenGui = nil
local isGuiInitialized = false

-- Utility functions
local function initializeGui()
    if isGuiInitialized then return end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = CoreGui
    
    isGuiInitialized = true
end

local function cleanupNotifications()
    for i = #notifications, 1, -1 do
        if not notifications[i] or not notifications[i].Parent then
            table.remove(notifications, i)
        end
    end
end

local function calculatePosition(index)
    local resolution = Camera.ViewportSize
    local notificationHeight = CONFIG.Notification.Size.Y.Scale * resolution.Y
    local spacing = CONFIG.Notification.Spacing
    
    return -spacing - ((notificationHeight + spacing) * (index - 1))
end

local function createNotificationFrame()
    local container = Instance.new("Frame")
    container.Size = CONFIG.Notification.Size
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1 + 0.05, 0, 1, 0) -- Start offscreen
    container.BackgroundColor3 = CONFIG.Appearance.BackgroundColor
    container.BackgroundTransparency = CONFIG.Appearance.BackgroundTransparency
    container.BorderSizePixel = 0
    container.ZIndex = CONFIG.Notification.ZIndex
    container.ClipsDescendants = true
    
    -- Add corner rounding
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = CONFIG.Appearance.CornerRadius
    uiCorner.Parent = container
    
    return container
end

local function createAccentBar(container, notificationType)
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(CONFIG.Appearance.AccentBarWidth, 0, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = CONFIG.AccentColors[notificationType] or CONFIG.AccentColors.Default
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = CONFIG.Notification.ZIndex + 1
    accentBar.Parent = container
    
    return accentBar
end

local function createTextLabel(container, text, size, yPosition, ySize)
    local padding = CONFIG.Appearance.TextPadding
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = CONFIG.Appearance.Font
    label.TextSize = size
    label.TextColor3 = CONFIG.Appearance.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(CONFIG.Appearance.AccentBarWidth.Scale, padding, yPosition.Scale, yPosition.Offset)
    label.Size = UDim2.new(1 - CONFIG.Appearance.AccentBarWidth.Scale, -padding, ySize.Scale, ySize.Offset)
    label.ZIndex = CONFIG.Notification.ZIndex + 1
    label.TextWrapped = true
    label.Parent = container
    
    return label
end

local function animateNotification(container, targetY, duration, easingStyle, easingDirection, onComplete)
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(container, tweenInfo, {
        Position = UDim2.new(1, 0, 1, targetY)
    })
    
    tween:Play()
    
    if onComplete then
        tween.Completed:Connect(onComplete)
    end
end

function NotificationModule:Notify(title, message, notificationType)
    -- Initialize GUI if not already done
    initializeGui()
    
    -- Clean up any dead notifications
    cleanupNotifications()
    
    -- Remove oldest notification if we've reached max
    if #notifications >= CONFIG.Notification.MaxNotifications then
        local oldest = table.remove(notifications, 1)
        if oldest then
            oldest:Destroy()
        end
    end
    
    -- Create notification container
    local container = createNotificationFrame()
    container.Parent = screenGui
    
    -- Add accent bar
    createAccentBar(container, notificationType)
    
    -- Create title and message labels
    local titleLabel = createTextLabel(container, title or "Notification", 
        CONFIG.Appearance.TitleSize, UDim2.new(0, 5), UDim2.new(0.4, -5))
    
    local messageLabel = createTextLabel(container, message or "", 
        CONFIG.Appearance.MessageSize, UDim2.new(0.4, 0), UDim2.new(0.6, -5))
    
    -- Calculate position based on notification count
    local targetY = calculatePosition(#notifications + 1)
    
    -- Animate in
    animateNotification(container, targetY, 
        CONFIG.Animations.SlideInDuration, 
        CONFIG.Animations.SlideInEasing, 
        CONFIG.Animations.SlideInDirection)
    
    -- Add to notifications table
    table.insert(notifications, container)
    
    -- Set up removal after duration
    task.delay(CONFIG.Notification.Duration, function()
        -- Check if notification still exists
        if not container or not container.Parent then return end
        
        -- Animate out
        animateNotification(container, targetY, 
            CONFIG.Animations.SlideOutDuration, 
            CONFIG.Animations.SlideOutEasing, 
            CONFIG.Animations.SlideOutDirection,
            function()
                -- Remove from table and destroy
                for i, v in ipairs(notifications) do
                    if v == container then
                        table.remove(notifications, i)
                        break
                    end
                end
                container:Destroy()
            end)
    end)
    
    return container
end

-- Optional: Add a function to clear all notifications
function NotificationModule:ClearAll()
    for _, notification in ipairs(notifications) do
        if notification then
            notification:Destroy()
        end
    end
    table.clear(notifications)
end

-- Handle viewport changes to reposition notifications
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    for i, notification in ipairs(notifications) do
        if notification and notification.Parent then
            local targetY = calculatePosition(i)
            notification.Position = UDim2.new(1, 0, 1, targetY)
        end
    end
end)

return NotificationModule