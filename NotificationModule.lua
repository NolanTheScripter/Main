-- Roblox Notification System
-- Paste this into a LocalScript in StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationSystem = {}

-- Configuration
local CONFIG = {
    MAX_NOTIFICATIONS = 5,              -- Max notifications visible at once
    DEFAULT_DURATION = 5,               -- Default display time in seconds
    CONTAINER_WIDTH = 300,              -- Width of notification container
    MARGIN = 20,                        -- Margin from screen edges
    SPACING = 10,                       -- Space between notifications
    BACKGROUND_COLOR = Color3.fromRGB(30, 30, 40),
    BACKGROUND_TRANSPARENCY = 0.2,
    TITLE_COLOR = Color3.fromRGB(200, 200, 255),
    MESSAGE_COLOR = Color3.fromRGB(255, 255, 255),
    CORNER_RADIUS = 6,                  -- Corner roundness in pixels
    ANIMATION_DURATION = 0.3,           -- Tween duration in seconds
    FONT = Enum.Font.Gotham,
    TITLE_FONT = Enum.Font.GothamBold,
    TITLE_SIZE = 14,
    MESSAGE_SIZE = 16
}

-- Initialize the notification container
local function initializeContainer()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, CONFIG.CONTAINER_WIDTH, 1, -CONFIG.MARGIN*2)
    container.Position = UDim2.new(1, -(CONFIG.CONTAINER_WIDTH + CONFIG.MARGIN), 0, CONFIG.MARGIN)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = playerGui
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, CONFIG.SPACING)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = container
    
    return container
end

local notificationContainer = initializeContainer()

-- Create notification template
local function createNotificationTemplate()
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Size = UDim2.new(1, 0, 0, 0)
    
    -- Background
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
    bg.BackgroundTransparency = CONFIG.BACKGROUND_TRANSPARENCY
    bg.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    corner.Parent = bg
    
    bg.Parent = frame
    
    -- Content frame
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.Parent = frame
    
    -- Title (optional)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Text = ""
    title.TextColor3 = CONFIG.TITLE_COLOR
    title.TextSize = CONFIG.TITLE_SIZE
    title.Font = CONFIG.TITLE_FONT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = content
    
    -- Message
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.TextWrapped = true
    message.AutomaticSize = Enum.AutomaticSize.Y
    message.Size = UDim2.new(1, 0, 0, 0)
    message.Text = ""
    message.TextColor3 = CONFIG.MESSAGE_COLOR
    message.TextSize = CONFIG.MESSAGE_SIZE
    message.Font = CONFIG.FONT
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.BackgroundTransparency = 1
    message.Parent = content
    
    return frame
end

-- Show a notification
function NotificationSystem.Show(title, message, duration)
    duration = duration or CONFIG.DEFAULT_DURATION
    
    -- Clean up old notifications if we've reached max
    if #notificationContainer:GetChildren() - 1 >= CONFIG.MAX_NOTIFICATIONS then
        local oldest
        for _, child in ipairs(notificationContainer:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Notification" then
                if not oldest or child.LayoutOrder < oldest.LayoutOrder then
                    oldest = child
                end
            end
        end
        if oldest then oldest:Destroy() end
    end
    
    -- Create new notification
    local notification = createNotificationTemplate()
    notification.Title.Text = title or ""
    notification.Message.Text = message
    
    -- Set initial state (offscreen right)
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.LayoutOrder = -os.clock() -- Newest notifications get higher priority
    notification.Parent = notificationContainer
    
    -- Animate in
    local tweenIn = TweenService:Create(
        notification,
        TweenInfo.new(CONFIG.ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 0)}
    )
    tweenIn:Play()
    
    -- Set up automatic removal
    task.delay(duration, function()
        local tweenOut = TweenService:Create(
            notification,
            TweenInfo.new(CONFIG.ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 0, 0, 0)}
        )
        
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
    
    return notification
end

-- Clear all notifications
function NotificationSystem.ClearAll()
    for _, child in ipairs(notificationContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Notification" then
            local tweenOut = TweenService:Create(
                child,
                TweenInfo.new(CONFIG.ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 0, 0, 0)}
            )
            
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                child:Destroy()
            end)
        end
    end
end

-- Example usage (can be removed in production)
task.delay(1, function()
    NotificationSystem.Show("System", "Notification system initialized successfully!")
    
    NotificationSystem.Show("Early | Wave 1", "This description is super long and should cause an overlap in wrapping. It will automatically wrap to the next line while maintaining proper spacing and alignment.", 8)
    
    NotificationSystem.Show("Alert", "Another notification with different duration", 3)
    
    NotificationSystem.Show(nil, "This notification has no title", 4)
end)

return NotificationSystem