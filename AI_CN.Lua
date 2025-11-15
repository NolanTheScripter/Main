-- NotificationModule.lua
-- Cross-platform notification system with UIAspectRatioConstraint support

local NotificationModule = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
NotificationModule.Config = {
    DefaultDuration = 5,
    MaxNotifications = 3,
    Spacing = 10,
    AnimationDuration = 0.3
}

-- Internal state
NotificationModule.Queue = {}
NotificationModule.ActiveNotifications = {}
NotificationModule.NotificationPool = {}
NotificationModule.ScreenGui = nil

-- Theme configuration
NotificationModule.Themes = {
    Success = {
        BackgroundColor = Color3.fromRGB(76, 175, 80),
        TextColor = Color3.fromRGB(255, 255, 255),
        Icon = "✅"
    },
    Error = {
        BackgroundColor = Color3.fromRGB(244, 67, 54),
        TextColor = Color3.fromRGB(255, 255, 255),
        Icon = "❌"
    },
    Warning = {
        BackgroundColor = Color3.fromRGB(255, 193, 7),
        TextColor = Color3.fromRGB(0, 0, 0),
        Icon = "⚠️"
    },
    Info = {
        BackgroundColor = Color3.fromRGB(33, 150, 243),
        TextColor = Color3.fromRGB(255, 255, 255),
        Icon = "ℹ️"
    }
}

-- Platform detection
function NotificationModule:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

function NotificationModule:IsPC()
    return UserInputService.MouseEnabled
end

-- Initialize the module
function NotificationModule:Initialize()
    self:CreateScreenGui()
    self:SetupContainers()
end

-- Create main ScreenGui
function NotificationModule:CreateScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationSystem"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    self.ScreenGui = screenGui
end

-- Setup notification containers
function NotificationModule:SetupContainers()
    -- Top container for notifications
    local topContainer = Instance.new("Frame")
    topContainer.Name = "TopNotifications"
    topContainer.BackgroundTransparency = 1
    topContainer.Size = UDim2.new(1, 0, 0.3, 0)
    topContainer.Position = UDim2.new(0, 0, 0, 10)
    topContainer.Parent = self.ScreenGui
    
    -- Aspect ratio constraint for container
    local containerAspect = Instance.new("UIAspectRatioConstraint")
    containerAspect.AspectRatio = 4.0
    containerAspect.AspectType = Enum.AspectType.ScaleWithParentSize
    containerAspect.Parent = topContainer
    
    -- UIListLayout for stacking notifications
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, self.Config.Spacing)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = topContainer
end

-- Create notification template
function NotificationModule:CreateNotificationTemplate()
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    notificationFrame.BackgroundTransparency = 0.1
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ClipsDescendants = true
    notificationFrame.Visible = false
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notificationFrame
    
    -- Shadow effect
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Transparency = 0.7
    shadow.Thickness = 2
    shadow.Parent = notificationFrame
    
    -- Main aspect ratio constraint
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.AspectRatio = self:IsMobile() and 2.2 or 4.375
    aspectRatio.DominantAxis = Enum.DominantAxis.Width
    aspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
    aspectRatio.Parent = notificationFrame
    
    -- Icon label
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = ""
    iconLabel.TextSize = 20
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notificationFrame
    
    -- Icon aspect ratio
    local iconAspect = Instance.new("UIAspectRatioConstraint")
    iconAspect.AspectRatio = 1.0
    iconAspect.Parent = iconLabel
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.7, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 50, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Notification"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = self:IsMobile() and 16 or 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = notificationFrame
    
    -- Title aspect ratio
    local titleAspect = Instance.new("UIAspectRatioConstraint")
    titleAspect.AspectRatio = 8.0
    titleAspect.Parent = titleLabel
    
    -- Message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(0.7, -50, 0, 40)
    messageLabel.Position = UDim2.new(0, 50, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = self:IsMobile() and 14 or 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notificationFrame
    
    -- Message aspect ratio
    local messageAspect = Instance.new("UIAspectRatioConstraint")
    messageAspect.AspectRatio = 4.0
    messageAspect.Parent = messageLabel
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = self:IsMobile() and UDim2.new(0, 40, 0, 40) or UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = self:IsMobile() and 24 or 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = notificationFrame
    
    -- Close button aspect ratio
    local closeAspect = Instance.new("UIAspectRatioConstraint")
    closeAspect.AspectRatio = 1.0
    closeAspect.Parent = closeButton
    
    -- Progress bar for auto-dismiss
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Visible = false
    progressBar.Parent = notificationFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar
    
    return {
        Frame = notificationFrame,
        Icon = iconLabel,
        Title = titleLabel,
        Message = messageLabel,
        CloseButton = closeButton,
        ProgressBar = progressBar
    }
end

-- Get notification from pool or create new one
function NotificationModule:GetFromPool()
    if #self.NotificationPool > 0 then
        local notification = table.remove(self.NotificationPool)
        notification.Frame.Visible = false
        return notification
    else
        return self:CreateNotificationTemplate()
    end
end

-- Return notification to pool
function NotificationModule:ReturnToPool(notification)
    notification.Frame.Visible = false
    notification.Frame.Parent = nil
    
    -- Clean up tweens
    for _, tween in pairs(notification.ActiveTweens or {}) do
        tween:Cancel()
    end
    notification.ActiveTweens = {}
    
    table.insert(self.NotificationPool, notification)
end

-- Apply platform-specific layout
function NotificationModule:ApplyPlatformLayout(notification)
    local isMobile = self:IsMobile()
    
    -- Update aspect ratios based on platform
    local aspectRatio = notification.Frame:FindFirstChildOfClass("UIAspectRatioConstraint")
    if aspectRatio then
        aspectRatio.AspectRatio = isMobile and 2.2 or 4.375
    end
    
    -- Update text sizes
    notification.Title.TextSize = isMobile and 16 or 14
    notification.Message.TextSize = isMobile and 14 or 12
    notification.CloseButton.TextSize = isMobile and 24 or 18
    notification.CloseButton.Size = isMobile and UDim2.new(0, 40, 0, 40) or UDim2.new(0, 25, 0, 25)
end

-- Create and configure notification
function NotificationModule:CreateNotification(data)
    local notification = self:GetFromPool()
    local theme = self.Themes[data.Type or "Info"] or self.Themes.Info
    
    -- Apply theme
    notification.Frame.BackgroundColor3 = theme.BackgroundColor
    notification.Icon.Text = theme.Icon
    notification.Title.Text = data.Title or "Notification"
    notification.Message.Text = data.Message or ""
    notification.Title.TextColor3 = theme.TextColor
    notification.Icon.TextColor3 = theme.TextColor
    
    -- Apply platform-specific adjustments
    self:ApplyPlatformLayout(notification)
    
    -- Store notification data
    notification.Data = data
    notification.ActiveTweens = {}
    
    -- Set up close button
    notification.CloseButton.MouseButton1Click:Connect(function()
        self:DismissNotification(notification)
    end)
    
    -- Set up touch events for mobile
    if self:IsMobile() then
        notification.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                self:DismissNotification(notification)
            end
        end)
    end
    
    return notification
end

-- Calculate target position for notification
function NotificationModule:CalculateTargetPosition(notification, index)
    local container = self.ScreenGui:FindFirstChild("TopNotifications")
    if not container then return UDim2.new(0.5, -150, 0, 10) end
    
    local yOffset = (index or 1) * (notification.Frame.AbsoluteSize.Y + self.Config.Spacing)
    return UDim2.new(0.5, -notification.Frame.AbsoluteSize.X / 2, 0, yOffset)
end

-- Animate notification
function NotificationModule:AnimateNotification(notification, show, callback)
    local goal = {}
    
    if show then
        goal.Position = self:CalculateTargetPosition(notification, #self.ActiveNotifications + 1)
        goal.Size = UDim2.new(0, self:IsMobile() and 280 or 350, 0, self:IsMobile() and 100 or 80)
    else
        goal.Position = UDim2.new(0.5, -75, -0.5, 0)
        goal.Size = UDim2.new(0, 0, 0, 0)
    end
    
    local tweenInfo = TweenInfo.new(
        self.Config.AnimationDuration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(notification.Frame, tweenInfo, goal)
    table.insert(notification.ActiveTweens, tween)
    
    tween:Play()
    tween.Completed:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return tween
end

-- Animate progress bar
function NotificationModule:AnimateProgressBar(notification, duration)
    if not notification.Data.Duration or notification.Data.Duration == 0 then
        return
    end
    
    notification.ProgressBar.Visible = true
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(notification.ProgressBar, tweenInfo, {Size = UDim2.new(0, 0, 0, 3)})
    table.insert(notification.ActiveTweens, tween)
    tween:Play()
end

-- Display notification
function NotificationModule:DisplayNotification(notification)
    local container = self.ScreenGui:FindFirstChild("TopNotifications")
    if not container then return end
    
    notification.Frame.Parent = container
    notification.Frame.Visible = true
    notification.Frame.LayoutOrder = #self.ActiveNotifications + 1
    
    -- Initial state for entrance animation
    notification.Frame.Position = UDim2.new(0.5, -75, -0.5, 0)
    notification.Frame.Size = UDim2.new(0, 0, 0, 0)
    
    -- Animate entrance
    self:AnimateNotification(notification, true, function()
        table.insert(self.ActiveNotifications, notification)
        
        -- Start auto-dismiss timer if duration is set
        local duration = notification.Data.Duration or self.Config.DefaultDuration
        if duration > 0 then
            self:AnimateProgressBar(notification, duration)
            
            task.delay(duration, function()
                if table.find(self.ActiveNotifications, notification) then
                    self:DismissNotification(notification)
                end
            end)
        end
    end)
end

-- Dismiss notification
function NotificationModule:DismissNotification(notification)
    local index = table.find(self.ActiveNotifications, notification)
    if index then
        table.remove(self.ActiveNotifications, index)
        
        self:AnimateNotification(notification, false, function()
            self:ReturnToPool(notification)
            self:ProcessQueue()
        end)
    end
end

-- Dismiss oldest notification
function NotificationModule:DismissOldest()
    if #self.ActiveNotifications > 0 then
        self:DismissNotification(self.ActiveNotifications[1])
    end
end

-- Process notification queue
function NotificationModule:ProcessQueue()
    while #self.ActiveNotifications >= self.Config.MaxNotifications do
        self:DismissOldest()
    end
    
    if #self.Queue > 0 and #self.ActiveNotifications < self.Config.MaxNotifications then
        local notificationData = table.remove(self.Queue, 1)
        local notification = self:CreateNotification(notificationData)
        self:DisplayNotification(notification)
    end
end

-- Main function to show notification
function NotificationModule:ShowNotification(data)
    -- Validate data
    if not data or (not data.Title and not data.Message) then
        warn("NotificationModule: Invalid notification data")
        return
    end
    
    -- Add to queue
    table.insert(self.Queue, data)
    self:ProcessQueue()
end

-- Convenience methods for different notification types
function NotificationModule:Success(title, message, duration)
    self:ShowNotification({
        Title = title,
        Message = message,
        Type = "Success",
        Duration = duration or self.Config.DefaultDuration
    })
end

function NotificationModule:Error(title, message, duration)
    self:ShowNotification({
        Title = title,
        Message = message,
        Type = "Error", 
        Duration = duration or self.Config.DefaultDuration
    })
end

function NotificationModule:Warning(title, message, duration)
    self:ShowNotification({
        Title = title,
        Message = message,
        Type = "Warning",
        Duration = duration or self.Config.DefaultDuration
    })
end

function NotificationModule:Info(title, message, duration)
    self:ShowNotification({
        Title = title,
        Message = message,
        Type = "Info",
        Duration = duration or self.Config.DefaultDuration
    })
end

-- Cleanup method
function NotificationModule:Cleanup()
    for _, notification in ipairs(self.ActiveNotifications) do
        self:ReturnToPool(notification)
    end
    
    for _, notification in ipairs(self.NotificationPool) do
        if notification.Frame then
            notification.Frame:Destroy()
        end
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    
    self.ActiveNotifications = {}
    self.Queue = {}
    self.NotificationPool = {}
end

-- Update configuration
function NotificationModule:UpdateConfig(newConfig)
    for key, value in pairs(newConfig) do
        if self.Config[key] ~= nil then
            self.Config[key] = value
        end
    end
end

-- Auto-initialize when required
task.spawn(function()
    NotificationModule:Initialize()
end)

return NotificationModule