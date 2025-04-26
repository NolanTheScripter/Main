local library = {}

-- Dependencies
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    Position = "BottomRight", -- Options: "BottomRight", "TopRight", "TopLeft", "BottomLeft"
    MaxNotifications = 5,     -- Maximum simultaneous visible notifications
    NotificationWidth = 350,
    MinNotificationHeight = 80,
    MaxNotificationHeight = 200,
    Padding = 10,
    InternalPadding = 10,
    IconSize = 40,
    DisplayTime = 5,
    
    BackgroundColor = Color3.fromRGB(45, 45, 45),
    BackgroundTransparency = 0.1,
    StrokeColor = Color3.fromRGB(80, 80, 80),
    StrokeThickness = 1,
    TextColor = Color3.fromRGB(240, 240, 240),
    
    TitleFont = Enum.Font.SourceSansSemibold,
    TitleSize = 18,
    ContentFont = Enum.Font.SourceSans,
    ContentSize = 15,
    
    EntryEasingStyle = Enum.EasingStyle.Back,
    EntryEasingDirection = Enum.EasingDirection.Out,
    EntryTime = 0.5,
    
    ExitEasingStyle = Enum.EasingStyle.Quad,
    ExitEasingDirection = Enum.EasingDirection.In,
    ExitTime = 0.4,
    
    Icons = {
        Info = "rbxassetid://112082878863231",
        Warn = "rbxassetid://117107314745025",
        Error = "rbxassetid://77067602950967"
    }
}

-- Internal state
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = nil
local notifications = {}
local initialized = false

-- Position calculations
local positionConfig = {
    BottomRight = {
        anchor = Vector2.new(1, 1),
        startPos = UDim2.new(1, 0, 1, 0),
        direction = -1
    },
    TopRight = {
        anchor = Vector2.new(1, 0),
        startPos = UDim2.new(1, 0, 0, 0),
        direction = 1
    },
    TopLeft = {
        anchor = Vector2.new(0, 0),
        startPos = UDim2.new(0, 0, 0, 0),
        direction = 1
    },
    BottomLeft = {
        anchor = Vector2.new(0, 1),
        startPos = UDim2.new(0, 0, 1, 0),
        direction = -1
    }
}

-- UI initialization
local function initializeUI()
    if initialized then return end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationLibrary"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.ResetOnSpawn = false
    
    initialized = true
end

-- Notification management
local function createNotification(content, title, notifType, options)
    initializeUI()
    options = options or {}
    
    -- Merge options with config
    local displayTime = options.DisplayTime or CONFIG.DisplayTime
    local icon = options.Icon or CONFIG.Icons[notifType]
    
    -- Cleanup old notifications if exceeding max
    while #notifications >= CONFIG.MaxNotifications do
        local oldest = table.remove(notifications, 1)
        if oldest and oldest.Close then oldest:Close() end
    end

    -- Create frame
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(0, CONFIG.NotificationWidth, 0, CONFIG.MinNotificationHeight)
    frame.BackgroundColor3 = CONFIG.BackgroundColor
    frame.BackgroundTransparency = CONFIG.BackgroundTransparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = screenGui
    
    -- Position setup
    local posInfo = positionConfig[CONFIG.Position]
    frame.AnchorPoint = posInfo.anchor
    frame.Position = posInfo.startPos + UDim2.new(0, CONFIG.Padding * 2, 0, posInfo.direction * CONFIG.Padding * 2)
    
    -- Styling
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = frame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = CONFIG.StrokeColor
    uiStroke.Thickness = CONFIG.StrokeThickness
    uiStroke.Parent = frame
    
    local uiPadding = Instance.new("UIPadding")
    uiPadding.Padding = UDim.new(0, CONFIG.InternalPadding)
    uiPadding.Parent = frame
    
    -- Content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, CONFIG.InternalPadding)
    layout.Parent = contentFrame
    
    -- Icon
    local iconFrame = Instance.new("ImageLabel")
    iconFrame.Size = UDim2.fromOffset(CONFIG.IconSize, CONFIG.IconSize)
    iconFrame.Image = icon
    iconFrame.ScaleType = Enum.ScaleType.Fit
    iconFrame.BackgroundTransparency = 1
    iconFrame.Parent = contentFrame
    
    -- Text container
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -CONFIG.IconSize - CONFIG.InternalPadding, 1, 0)
    textContainer.AutomaticSize = Enum.AutomaticSize.Y
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = contentFrame
    
    local textLayout = Instance.new("UIListLayout")
    textLayout.Padding = UDim.new(0, 4)
    textLayout.Parent = textContainer
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or notifType
    titleLabel.Font = CONFIG.TitleFont
    titleLabel.TextSize = CONFIG.TitleSize
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, CONFIG.TitleSize)
    titleLabel.Parent = textContainer
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Text = content or ""
    contentLabel.Font = CONFIG.ContentFont
    contentLabel.TextSize = CONFIG.ContentSize
    contentLabel.TextColor3 = CONFIG.TextColor
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.Size = UDim2.new(1, 0, 0, CONFIG.ContentSize)
    contentLabel.Parent = textContainer
    
    -- Animation setup
    local entryOffset = posInfo.anchor.X == 1 and CONFIG.NotificationWidth or -CONFIG.NotificationWidth
    local entryPos = frame.Position + UDim2.new(0, entryOffset, 0, 0)
    frame.Position = entryPos
    
    local tweenInfo = TweenInfo.new(
        CONFIG.EntryTime,
        CONFIG.EntryEasingStyle,
        CONFIG.EntryEasingDirection
    )
    
    local tween = TweenService:Create(frame, tweenInfo, {
        Position = posInfo.startPos + UDim2.new(0, CONFIG.Padding, 0, posInfo.direction * CONFIG.Padding)
    })
    tween:Play()
    
    -- Notification object
    local notification = {
        _frame = frame,
        _tweens = { tween },
        Closed = false
    }
    
    function notification:Close()
        if self.Closed then return end
        self.Closed = true
        
        -- Cancel all tweens
        for _, t in ipairs(self._tweens) do
            t:Cancel()
        end
        
        -- Exit animation
        local exitTween = TweenService:Create(frame, TweenInfo.new(
            CONFIG.ExitTime,
            CONFIG.ExitEasingStyle,
            CONFIG.ExitEasingDirection
        ), {
            Position = entryPos,
            BackgroundTransparency = 1
        })
        
        -- Fade children
        for _, child in ipairs(frame:GetDescendants()) do
            if child:IsA("UIStroke") then
                table.insert(self._tweens, TweenService:Create(child, TweenInfo.new(0.2), { Transparency = 1 })
            elseif child:IsA("TextLabel") or child:IsA("ImageLabel") then
                table.insert(self._tweens, TweenService:Create(child, TweenInfo.new(0.2), { TextTransparency = 1, ImageTransparency = 1 }))
            end
        end
        
        exitTween:Play()
        exitTween.Completed:Wait()
        
        -- Cleanup
        frame:Destroy()
        for i, n in ipairs(notifications) do
            if n == self then
                table.remove(notifications, i)
                break
            end
        end
    end
    
    -- Auto-close timer
    if displayTime > 0 then
        task.delay(displayTime, function()
            if not notification.Closed then
                notification:Close()
            end
        end)
    end
    
    table.insert(notifications, notification)
    return notification
end

-- Public API
function library.Info(content, title, options)
    return createNotification(content, title, "Info", options)
end

function library.Warn(content, title, options)
    return createNotification(content, title, "Warn", options)
end

function library.Error(content, title, options)
    return createNotification(content, title, "Error", options)
end

function library.SetConfig(newConfig)
    for k, v in pairs(newConfig) do
        if CONFIG[k] ~= nil then
            CONFIG[k] = v
        end
    end
end

return library