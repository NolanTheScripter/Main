-- ModuleScript: NotificationModule
local NotificationModule = {}

-- Configuration
local CONFIG = {
    DefaultDuration = 5,
    PositionAnchor = "BottomRight", -- "BottomRight" or "TopRight"
    MaxNotifications = 5,
    Size = UDim2.new(0, 300, 0, 0), -- Height will auto-adjust
    AspectRatio = 3, -- Width:Height ratio (e.g., 3 means width is 3x height)
    MaxWidth = 300,
    MinWidth = 200,
    Spacing = 10,
    ZIndex = 100,
    
    -- Responsive settings
    MobileBreakpoint = 600, -- Screen width in pixels
    MobileSize = UDim2.new(0.9, 0, 0, 0), -- Takes 90% of screen width on mobile
    MobileAspectRatio = 2.5, -- Slightly wider ratio for mobile
    MobileMaxWidth = math.huge, -- No max width on mobile
    MobileMinWidth = 0,
    MobileSpacing = 8,
    
    -- Colors
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    BackgroundTransparency = 0.2,
    StrokeColor = Color3.fromRGB(80, 80, 80),
    
    -- Text styles
    TitleFont = Enum.Font.GothamBold,
    MessageFont = Enum.Font.Gotham,
    TitleSize = 18,
    MessageSize = 14,
    MobileTitleSize = 16,
    MobileMessageSize = 13,
    
    -- Icons
    Icons = {
        Success = "rbxassetid://6031091004",
        Error = "rbxassetid://6031090988",
        Warning = "rbxassetid://6031090997",
        Info = "rbxassetid://6031090990"
    },
    IconSize = 18,
    MobileIconSize = 16,
    
    -- Animations
    SlideInDuration = 0.3,
    SlideOutDuration = 0.3,
    ProgressSpeed = 1, -- 1 = normal speed
    StackAnimationDelay = 0.05, -- Delay between stacked notifications animations
}

-- Types
local TYPES = {
    Success = {
        AccentColor = Color3.fromRGB(76, 175, 80),
        Icon = CONFIG.Icons.Success
    },
    Error = {
        AccentColor = Color3.fromRGB(244, 67, 54),
        Icon = CONFIG.Icons.Error
    },
    Warning = {
        AccentColor = Color3.fromRGB(255, 152, 0),
        Icon = CONFIG.Icons.Warning
    },
    Info = {
        AccentColor = Color3.fromRGB(33, 150, 243),
        Icon = CONFIG.Icons.Info
    }
}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

-- Internal variables
local notifications = {}
local container
local screenGui
local isMobile = false
local currentScreenSize

-- Check if device is mobile
local function checkMobile()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    currentScreenSize = viewportSize
    isMobile = viewportSize.X <= CONFIG.MobileBreakpoint
    return isMobile
end

-- Get configuration value based on device
local function getConfigValue(key)
    if isMobile and CONFIG["Mobile"..key] ~= nil then
        return CONFIG["Mobile"..key]
    end
    return CONFIG[key]
end

-- Create the container if it doesn't exist
local function ensureContainer()
    if not container then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NotificationSystem"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        
        container = Instance.new("Frame")
        container.Name = "NotificationContainer"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 1, 0)
        container.Position = UDim2.new(0, 0, 0, 0)
        container.Parent = screenGui
        
        -- Handle screen size changes
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            checkMobile()
            NotificationModule.UpdatePositions()
        end)
        
        checkMobile()
    end
end

-- Update all notification positions
function NotificationModule.UpdatePositions()
    if not container or #notifications == 0 then return end
    
    local positionOffset = 0
    local spacing = getConfigValue("Spacing")
    local anchorPoint = CONFIG.PositionAnchor == "BottomRight" and 1 or 0
    
    for i, notif in ipairs(notifications) do
        local notification = notif.Instance
        local absoluteSize = notification.AbsoluteSize
        
        -- Calculate new position
        local newPosition
        if CONFIG.PositionAnchor == "BottomRight" then
            newPosition = UDim2.new(
                1, -20, 
                1, -positionOffset - absoluteSize.Y - (i > 1 and spacing or 0)
            )
        else -- TopRight
            newPosition = UDim2.new(
                1, -20,
                0, positionOffset + (i > 1 and spacing or 0)
            )
        end
        
        -- Animate to new position with delay for stacking effect
        task.delay(CONFIG.StackAnimationDelay * (i-1), function()
            if notification and notification.Parent then
                TweenService:Create(
                    notification,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = newPosition}
                ):Play()
            end
        end)
        
        positionOffset += absoluteSize.Y + (i > 1 and spacing or 0)
    end
end

-- Create a new notification
function NotificationModule.Notify(params)
    ensureContainer()
    
    local title = params.Title or "Notification"
    local message = params.Message or ""
    local duration = params.Duration or CONFIG.DefaultDuration
    local notificationType = params.Type or "Info"
    local callback = params.Callback
    
    -- Get type configuration
    local typeConfig = TYPES[notificationType] or TYPES.Info
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification_"..tostring(os.clock())
    notification.BackgroundColor3 = CONFIG.BackgroundColor3
    notification.BackgroundTransparency = CONFIG.BackgroundTransparency
    notification.Size = getConfigValue("Size")
    notification.AnchorPoint = Vector2.new(1, CONFIG.PositionAnchor == "BottomRight" and 1 or 0)
    notification.ZIndex = CONFIG.ZIndex
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.ClipsDescendants = true
    notification.Parent = container
    
    -- Add aspect ratio constraint
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.AspectRatio = getConfigValue("AspectRatio")
    aspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
    aspectRatio.DominantAxis = Enum.DominantAxis.Width
    aspectRatio.Parent = notification
    
    -- Add size constraint for mobile
    if isMobile then
        local sizeConstraint = Instance.new("UISizeConstraint")
        sizeConstraint.MaxSize = Vector2.new(getConfigValue("MobileMaxWidth"), math.huge)
        sizeConstraint.MinSize = Vector2.new(getConfigValue("MobileMinWidth"), 0)
        sizeConstraint.Parent = notification
    else
        local sizeConstraint = Instance.new("UISizeConstraint")
        sizeConstraint.MaxSize = Vector2.new(getConfigValue("MaxWidth"), math.huge)
        sizeConstraint.MinSize = Vector2.new(getConfigValue("MinWidth"), 0)
        sizeConstraint.Parent = notification
    end
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = CONFIG.StrokeColor
    stroke.Thickness = 1
    stroke.Parent = notification
    
    -- Add accent
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = typeConfig.AccentColor
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.ZIndex = CONFIG.ZIndex + 1
    accent.Parent = notification
    
    -- Add layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = notification
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        -- Update aspect ratio based on content
        local contentSize = layout.AbsoluteContentSize
        if contentSize.Y > 0 then
            local newRatio = math.clamp(contentSize.X / contentSize.Y, 1.5, 5)
            aspectRatio.AspectRatio = newRatio
        end
    end)
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = notification
    
    -- Add icon and title container
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.BackgroundTransparency = 1
    titleContainer.Size = UDim2.new(1, 0, 0, getConfigValue("TitleSize"))
    titleContainer.LayoutOrder = 1
    titleContainer.AutomaticSize = Enum.AutomaticSize.Y
    titleContainer.Parent = notification
    
    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.Padding = UDim.new(0, 8)
    titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    titleLayout.Parent = titleContainer
    
    -- Add icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Image = typeConfig.Icon
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, getConfigValue("IconSize"), 0, getConfigValue("IconSize"))
    icon.LayoutOrder = 1
    icon.Parent = titleContainer
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Font = getConfigValue("TitleFont")
    titleLabel.TextSize = getConfigValue("TitleSize")
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -getConfigValue("IconSize") - 8, 0, getConfigValue("TitleSize"))
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 2
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.TextWrapped = true
    titleLabel.Parent = titleContainer
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Text = message
    messageLabel.Font = getConfigValue("MessageFont")
    messageLabel.TextSize = getConfigValue("MessageSize")
    messageLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.LayoutOrder = 2
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Add progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.AnchorPoint = Vector2.new(0, 1)
    progressBar.LayoutOrder = 3
    progressBar.ZIndex = CONFIG.ZIndex + 1
    progressBar.Parent = notification
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.BackgroundColor3 = typeConfig.AccentColor
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.Parent = progressBar
    
    -- Initial position (off-screen)
    local initialX = 20
    notification.Position = UDim2.new(1, initialX, CONFIG.PositionAnchor == "BottomRight" and 1 or 0, 0)
    
    -- Slide in animation
    local slideIn = TweenService:Create(
        notification,
        TweenInfo.new(CONFIG.SlideInDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -20, CONFIG.PositionAnchor == "BottomRight" and 1 or 0, 0)}
    )
    
    -- Progress animation
    local progressTween = TweenService:Create(
        progressFill,
        TweenInfo.new(duration * CONFIG.ProgressSpeed, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}
    )
    
    -- Add to notifications table
    local notificationData = {
        Instance = notification,
        SlideIn = slideIn,
        ProgressTween = progressTween,
        StartTime = os.clock(),
        Duration = duration,
        Callback = callback
    }
    
    table.insert(notifications, 1, notificationData) -- Insert at beginning for bottom-up stacking
    
    -- Enforce max notifications
    if #notifications > CONFIG.MaxNotifications then
        NotificationModule.Dismiss(notifications[#notifications].Instance)
    end
    
    -- Start progress if duration > 0
    if duration > 0 then
        progressTween:Play()
        
        -- Set up auto-removal
        task.delay(duration, function()
            if notification and notification.Parent then
                NotificationModule.Dismiss(notification)
            end
        end)
    end
    
    -- Make notification clickable if there's a callback
    if callback then
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                callback()
                NotificationModule.Dismiss(notification)
            end
        end)
    end
    
    -- Play slide in animation after a small delay for stacking effect
    task.delay(CONFIG.StackAnimationDelay * (#notifications-1), function()
        if notification and notification.Parent then
            slideIn:Play()
            NotificationModule.UpdatePositions()
        end
    end)
    
    return notification
end

-- Dismiss a specific notification
function NotificationModule.Dismiss(notification)
    for i, notif in ipairs(notifications) do
        if notif.Instance == notification then
            -- Cancel any running tweens
            if notif.ProgressTween then
                notif.ProgressTween:Cancel()
            end
            
            -- Slide out animation
            local slideOut = TweenService:Create(
                notification,
                TweenInfo.new(CONFIG.SlideOutDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(
                    1, 20, 
                    CONFIG.PositionAnchor == "BottomRight" and 1 or 0, 
                    notification.Position.Y.Offset
                )}
            )
            
            slideOut:Play()
            slideOut.Completed:Connect(function()
                if notification.Parent then
                    notification:Destroy()
                end
                
                -- Remove from table
                table.remove(notifications, i)
                
                -- Update positions of remaining notifications
                NotificationModule.UpdatePositions()
            end)
            
            -- Call callback if dismissed early
            if notif.Callback and os.clock() - notif.StartTime < notif.Duration then
                notif.Callback()
            end
            
            break
        end
    end
end

-- Clear all notifications
function NotificationModule.ClearAll()
    for i = #notifications, 1, -1 do
        NotificationModule.Dismiss(notifications[i].Instance)
    end
end

-- Predefined notification types
function NotificationModule.Success(params)
    params.Type = "Success"
    return NotificationModule.Notify(params)
end

function NotificationModule.Error(params)
    params.Type = "Error"
    return NotificationModule.Notify(params)
end

function NotificationModule.Warning(params)
    params.Type = "Warning"
    return NotificationModule.Notify(params)
end

function NotificationModule.Info(params)
    params.Type = "Info"
    return NotificationModule.Notify(params)
end

-- Initialize
checkMobile()

return NotificationModule