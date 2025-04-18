-- ModuleScript: NotificationModule
local NotificationModule = {}

-- Configuration
local CONFIG = {
    DefaultDuration = 5,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 300, 0, 0), -- Height will auto-adjust
    MaxWidth = 300,
    Spacing = 10,
    ZIndex = 100,
    
    -- Colors
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    BackgroundTransparency = 0.2,
    StrokeColor = Color3.fromRGB(80, 80, 80),
    
    -- Text styles
    TitleFont = Enum.Font.GothamBold,
    MessageFont = Enum.Font.Gotham,
    TitleSize = 18,
    MessageSize = 14,
    
    -- Icons
    Icons = {
        Success = "rbxassetid://6031091004",
        Error = "rbxassetid://6031090988",
        Warning = "rbxassetid://6031090997",
        Info = "rbxassetid://6031090990"
    },
    
    -- Animations
    SlideInDuration = 0.3,
    SlideOutDuration = 0.3,
    ProgressSpeed = 1, -- 1 = normal speed
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

-- Internal variables
local notifications = {}
local container
local screenGui

-- Create the container if it doesn't exist
local function ensureContainer()
    if not container then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NotificationSystem"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        
        container = Instance.new("Frame")
        container.Name = "NotificationContainer"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 1, 0)
        container.Position = UDim2.new(0, 0, 0, 0)
        container.Parent = screenGui
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
    notification.Name = "Notification"
    notification.BackgroundColor3 = CONFIG.BackgroundColor3
    notification.BackgroundTransparency = CONFIG.BackgroundTransparency
    notification.Size = CONFIG.Size
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.ZIndex = CONFIG.ZIndex
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.Parent = container
    
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
    titleContainer.Size = UDim2.new(1, 0, 0, CONFIG.TitleSize)
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
    icon.Size = UDim2.new(0, CONFIG.TitleSize, 0, CONFIG.TitleSize)
    icon.LayoutOrder = 1
    icon.Parent = titleContainer
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Font = CONFIG.TitleFont
    titleLabel.TextSize = CONFIG.TitleSize
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -CONFIG.TitleSize - 8, 0, CONFIG.TitleSize)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 2
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.Parent = titleContainer
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Text = message
    messageLabel.Font = CONFIG.MessageFont
    messageLabel.TextSize = CONFIG.MessageSize
    messageLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.LayoutOrder = 2
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
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
    
    -- Calculate position (stacking)
    local positionOffset = 0
    for _, notif in ipairs(notifications) do
        positionOffset += notif.Instance.AbsoluteSize.Y + CONFIG.Spacing
    end
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 20, 0, positionOffset)
    local slideIn = TweenService:Create(
        notification,
        TweenInfo.new(CONFIG.SlideInDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -20, 0, positionOffset)}
    )
    slideIn:Play()
    
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
    
    table.insert(notifications, notificationData)
    
    -- Start progress if duration > 0
    if duration > 0 then
        progressTween:Play()
        
        -- Set up auto-removal
        delay(duration, function()
            NotificationModule.Dismiss(notification)
        end)
    end
    
    -- Make notification clickable if there's a callback
    if callback then
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                callback()
                NotificationModule.Dismiss(notification)
            end
        end)
    end
    
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
                {Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)}
            )
            
            slideOut:Play()
            slideOut.Completed:Connect(function()
                notification:Destroy()
                
                -- Recalculate positions for remaining notifications
                local positionOffset = 0
                for j, remainingNotif in ipairs(notifications) do
                    if j < i then
                        positionOffset += remainingNotif.Instance.AbsoluteSize.Y + CONFIG.Spacing
                        
                        TweenService:Create(
                            remainingNotif.Instance,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            {Position = UDim2.new(1, -20, 0, positionOffset)}
                        ):Play()
                    end
                end
                
                table.remove(notifications, i)
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

return NotificationModule