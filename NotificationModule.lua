local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationManager = {}
NotificationManager.__index = NotificationManager

-- Configuration
local CONFIG = {
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 300, 0, 0), -- Height auto-calculated
    MaxNotifications = 4,
    DisplayDuration = 5,
    AnimationDuration = 0.25,
    Padding = 10, -- Space between notifications
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(60, 60, 60),
        Title = Color3.fromRGB(255, 255, 255),
        Message = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(0, 162, 255)
    },
    Fonts = {
        Title = Enum.Font.GothamBold,
        Message = Enum.Font.Gotham
    },
    TextSizes = {
        Title = 18,
        Message = 14
    },
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 1,
    ContentPadding = 15, -- Internal padding
    Icon = "rbxassetid://3926305904", -- Default icon ID (blue info icon)
    IconSize = 24
}

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    self.notificationQueue = {}
    self.activeNotifications = 0
    
    self:setupUI()
    
    return self
end

function NotificationManager:setupUI()
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NotificationManager"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = self.playerGui
    
    -- Container Frame
    self.container = Instance.new("Frame")
    self.container.Name = "Container"
    self.container.Size = UDim2.new(0, CONFIG.Size.X.Offset + 40, 1, 0)
    self.container.Position = UDim2.new(1, 0, 0, 0)
    self.container.AnchorPoint = Vector2.new(1, 0)
    self.container.BackgroundTransparency = 1
    self.container.ClipsDescendants = true
    self.container.Parent = self.screenGui
    
    -- UIListLayout for automatic spacing
    self.listLayout = Instance.new("UIListLayout")
    self.listLayout.Padding = UDim.new(0, CONFIG.Padding)
    self.listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    self.listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    self.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.listLayout.Parent = self.container
end

function NotificationManager:createNotification(title, message, icon)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = CONFIG.Size
    notificationFrame.BackgroundColor3 = CONFIG.Colors.Background
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.BorderSizePixel = 0
    notificationFrame.LayoutOrder = -self.activeNotifications -- Newest on top
    notificationFrame.AutomaticSize = Enum.AutomaticSize.Y
    notificationFrame.Parent = self.container
    
    -- UI Corner
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = CONFIG.CornerRadius
    uiCorner.Parent = notificationFrame
    
    -- UI Stroke
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = CONFIG.StrokeThickness
    uiStroke.Color = CONFIG.Colors.Border
    uiStroke.Parent = notificationFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = notificationFrame
    
    -- Content frame for padding
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -CONFIG.ContentPadding * 2, 1, -CONFIG.ContentPadding * 2)
    contentFrame.Position = UDim2.new(0, CONFIG.ContentPadding, 0, CONFIG.ContentPadding)
    contentFrame.BackgroundTransparency = 1
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.Parent = notificationFrame
    
    -- UIListLayout for content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    -- Icon (optional)
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0, CONFIG.IconSize, 0, CONFIG.IconSize)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = icon or CONFIG.Icon
    iconImage.ImageColor3 = CONFIG.Colors.Accent
    iconImage.LayoutOrder = 1
    iconImage.Parent = contentFrame
    
    -- Text container
    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -CONFIG.IconSize - 10, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.AutomaticSize = Enum.AutomaticSize.Y
    textContainer.LayoutOrder = 2
    textContainer.Parent = contentFrame
    
    -- UIListLayout for text
    local textLayout = Instance.new("UIListLayout")
    textLayout.Padding = UDim.new(0, 5)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Parent = textContainer
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, CONFIG.TextSizes.Title + 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = CONFIG.Fonts.Title
    titleLabel.TextSize = CONFIG.TextSizes.Title
    titleLabel.TextColor3 = CONFIG.Colors.Title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.LayoutOrder = 1
    titleLabel.Parent = textContainer
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = CONFIG.Fonts.Message
    messageLabel.TextSize = CONFIG.TextSizes.Message
    messageLabel.TextColor3 = CONFIG.Colors.Message
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.LayoutOrder = 2
    messageLabel.Parent = textContainer
    
    -- Progress bar for timeout
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.AnchorPoint = Vector2.new(0, 1)
    progressBar.BackgroundColor3 = CONFIG.Colors.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notificationFrame
    
    local uiCornerBar = Instance.new("UICorner")
    uiCornerBar.CornerRadius = UDim.new(0, 2)
    uiCornerBar.Parent = progressBar
    
    -- Initial hidden state (off-screen right)
    notificationFrame.Position = UDim2.new(2, 0, 0, 0)
    
    return notificationFrame
end

function NotificationManager:show(title, message, icon)
    if self.activeNotifications >= CONFIG.MaxNotifications then
        table.insert(self.notificationQueue, {
            Title = title,
            Message = message,
            Icon = icon
        })
        return
    end
    
    self.activeNotifications += 1
    local notification = self:createNotification(title, message, icon)
    
    -- Animate in
    local tweenIn = TweenService:Create(
        notification,
        TweenInfo.new(CONFIG.AnimationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, 0, 0, 0)}
    )
    tweenIn:Play()
    
    -- Animate progress bar
    local progressBar = notification:FindFirstChild("ProgressBar")
    if progressBar then
        local tweenProgress = TweenService:Create(
            progressBar,
            TweenInfo.new(CONFIG.DisplayDuration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 0, 2)}
        )
        tweenProgress:Play()
    end
    
    -- Auto-dismiss
    task.delay(CONFIG.DisplayDuration, function()
        self:dismiss(notification)
    end)
end

function NotificationManager:dismiss(notification)
    if not notification or not notification.Parent then return end
    
    -- Animate out
    local tweenOut = TweenService:Create(
        notification,
        TweenInfo.new(CONFIG.AnimationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(2, 0, 0, notification.Position.Y.Offset)}
    )
    tweenOut:Play()
    
    tweenOut.Completed:Connect(function()
        notification:Destroy()
        self.activeNotifications -= 1
        self:processQueue()
    end)
end

function NotificationManager:processQueue()
    if #self.notificationQueue > 0 and self.activeNotifications < CONFIG.MaxNotifications then
        local nextNotif = table.remove(self.notificationQueue, 1)
        self:show(nextNotif.Title, nextNotif.Message, nextNotif.Icon)
    end
end

-- Initialize the manager
local notificationManager = NotificationManager.new()

-- Export functions
local Notifications = {}

function Notifications.show(title, message, icon)
    notificationManager:show(title, message, icon)
end

function Notifications.error(message, icon)
    notificationManager:show("Error", message, icon) -- Red X icon
end

function Notifications.success(message, icon)
    notificationManager:show("Success", message, icon) -- Green check icon
end

function Notifications.warning(message, icon)
    notificationManager:show("Warning", message, icon) -- Yellow warning icon
end

return Notifications