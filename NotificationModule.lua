local Notification = {}

-- Configuration (can be modified or externally accessed)
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/NotificationConfig.lua")()

-- Internal Rate Limiter
local RateLimiter = {
    LastTypeSent = {},
    GlobalTimestamps = {}
}

-- Helper: Create Notification Template
local function createNotificationTemplate()
    local template = Instance.new("Frame")
    template.Name = "NotificationTemplate"
    template.Size = UDim2.new(0, 350, 0, 70)
    template.BackgroundTransparency = 0.8
    template.BackgroundColor3 = Config.Colors.Success
    template.BorderSizePixel = 0
    template.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Config.CornerRadius
    corner.Parent = template

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0.5, -20)
    icon.BackgroundTransparency = 1
    icon.Parent = template

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 250, 0, 25)
    title.Position = UDim2.new(0, 60, 0, 5)
    title.Text = "Notification Title"
    title.Font = Config.Fonts.Title
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = template

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0, 250, 0, 30)
    message.Position = UDim2.new(0, 60, 0, 30)
    message.Text = "This is a notification message."
    message.Font = Config.Fonts.Message
    message.TextSize = 14
    message.TextColor3 = Color3.fromRGB(255, 255, 255)
    message.BackgroundTransparency = 1
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Parent = template

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 16
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BackgroundTransparency = 0.6
    closeButton.BorderSizePixel = 0
    closeButton.Parent = template

    return template, icon, title, message, closeButton
end

-- Helper: Setup Progress Bar
local function setupProgressBar(notification, duration)
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 5)
    progressBar.Position = UDim2.new(0, 0, 1, -5)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBar.BackgroundTransparency = 0.6
    progressBar.Parent = notification

    local tween = game:GetService("TweenService"):Create(
        progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 0, 5) }
    )
    tween:Play()
    return tween
end

-- Helper: Setup Sound Playback
local function setupSound(notification, soundId)
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Parent = notification
        sound:Play()
    end
end

-- Helper: Animate Entry/Exit
local function animateNotification(notification, show)
    local goal = show and UDim2.new(0, 0, 0, 70) or UDim2.new(-1, 0, 0, notification.Position.Y.Offset)
    local tween = game:GetService("TweenService"):Create(
        notification,
        TweenInfo.new(0.5, Enum.EasingStyle.Quint),
        { Position = goal }
    )
    tween:Play()
    return tween
end

-- Function to send notifications
function Notification:Send(options)
    -- Check rate limit first
    if not self:CanSend(options.Type) then
        warn("Notification rate limit exceeded for type:", options.Type)
        return
    end

    -- Set up the notification display
    local screenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("DragnirNotificationGui")
    local container = screenGui:WaitForChild("NotificationContainer")
    local notification, icon, title, message, closeButton = createNotificationTemplate()

    -- Assign values based on the options provided
    title.Text = options.Title or "Notification"
    message.Text = options.Message or "This is a notification."
    icon.Image = Config.Icons[options.Type] or Config.Icons["Default"]
    notification.BackgroundColor3 = Config.Colors[options.Type] or Config.Colors.Success

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        animateNotification(notification, false):Completed:Connect(function()
            notification:Destroy()
            if options.OnDismiss then
                options.OnDismiss()
            end
        end)
    end)

    -- Add the notification to the container
    notification.Parent = container

    -- Optional: Add progress bar animation
    if options.Duration then
        setupProgressBar(notification, options.Duration).Completed:Connect(function()
            animateNotification(notification, false):Completed:Connect(function()
                notification:Destroy()
            end)
        end)
    end

    -- Optional: Sound Feedback
    setupSound(notification, options.Sound)

    -- Entry Animation
    notification.Position = UDim2.new(-1, 0, 0, #container:GetChildren() * 80)
    animateNotification(notification, true)
end

-- Rate limiter logic
function Notification:CanSend(type)
    if not Config.RateLimiter.Enabled then return true end
    local now = os.clock()

    -- Global flood check
    table.insert(RateLimiter.GlobalTimestamps, now)
    for i = #RateLimiter.GlobalTimestamps, 1, -1 do
        if now - RateLimiter.GlobalTimestamps[i] > 1 then
            table.remove(RateLimiter.GlobalTimestamps, i)
        end
    end
    if #RateLimiter.GlobalTimestamps > Config.RateLimiter.MaxPerSecond then
        return false
    end

    -- Per-type cooldown
    local last = RateLimiter.LastTypeSent[type] or 0
    local cooldown = Config.RateLimiter.PerTypeCooldown[type] or Config.RateLimiter.Cooldown
    if now - last < cooldown then
        return false
    end

    RateLimiter.LastTypeSent[type] = now
    return true
end

return Notification