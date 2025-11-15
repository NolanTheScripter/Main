local NotificationService = {}
NotificationService.__index = NotificationService

-- Module dependencies
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

function NotificationService.new(config)
    local self = setmetatable({}, NotificationService)
    
    self.config = {
        duration = config.duration or 5,
        position = config.position or "TopRight",
        animationStyle = config.animationStyle or "Slide",
        maxNotifications = config.maxNotifications or 5,
        mobileOptimized = config.mobileOptimized or true
    }
    
    self.notifications = {}
    self.notificationQueue = {}
    self.activeNotifications = 0
    self.screenGui = nil
    self.isMobile = RunService:IsMobilePlatform()
    
    self:_setupScreenGui()
    self:_createTemplates()
    
    return self
end

function NotificationService:_setupScreenGui()
    -- Create ScreenGui with proper scaling
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NotificationSystem"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Add UIAspectRatioConstraint for consistent scaling
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.AspectRatio = 1.777 -- 16:9 standard ratio
    aspectRatio.DominantAxis = Enum.DominantAxis.Width -- Scale based on width
    aspectRatio.Parent = self.screenGui
    
    self.screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

function NotificationService:_createTemplates()
    -- Base notification template with responsive design
    self.template = Instance.new("Frame")
    self.template.Name = "NotificationTemplate"
    self.template.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.template.BorderSizePixel = 0
    self.template.ClipsDescendants = true
    self.template.Visible = false -- Hide template
    
    -- Responsive sizing using UIScale and constraints
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = self.template
    
    -- Size constraint for different devices
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(400, 200)
    sizeConstraint.MinSize = Vector2.new(250, 80)
    sizeConstraint.Parent = self.template
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.template
    
    -- Stroke for better visibility
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1
    stroke.Parent = self.template
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = self.isMobile and 16 or 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = self.template
    
    -- Message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 1, -50)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = self.isMobile and 14 or 16
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = self.template
    
    -- Close button (only show on PC)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = self.isMobile and 16 or 18
    closeButton.Visible = not self.isMobile -- Hide on mobile
    closeButton.Parent = self.template
    
    -- Progress bar for duration
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.AnchorPoint = Vector2.new(0, 1)
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar
    
    progressBar.Parent = self.template
    
    self.template.Parent = self.screenGui
end

-- MISSING FUNCTION: Apply notification styles based on type
function NotificationService:_applyNotificationStyle(notification, notificationType)
    local styleMap = {
        Info = {
            BackgroundColor = Color3.fromRGB(45, 45, 45),
            ProgressColor = Color3.fromRGB(0, 170, 255),
            StrokeColor = Color3.fromRGB(100, 100, 100)
        },
        Success = {
            BackgroundColor = Color3.fromRGB(40, 80, 40),
            ProgressColor = Color3.fromRGB(0, 255, 0),
            StrokeColor = Color3.fromRGB(100, 200, 100)
        },
        Warning = {
            BackgroundColor = Color3.fromRGB(80, 80, 40),
            ProgressColor = Color3.fromRGB(255, 255, 0),
            StrokeColor = Color3.fromRGB(200, 200, 100)
        },
        Error = {
            BackgroundColor = Color3.fromRGB(80, 40, 40),
            ProgressColor = Color3.fromRGB(255, 0, 0),
            StrokeColor = Color3.fromRGB(200, 100, 100)
        },
        Achievement = {
            BackgroundColor = Color3.fromRGB(80, 40, 80),
            ProgressColor = Color3.fromRGB(255, 0, 255),
            StrokeColor = Color3.fromRGB(200, 100, 200)
        }
    }
    
    local style = styleMap[notificationType] or styleMap.Info
    
    notification.BackgroundColor3 = style.BackgroundColor
    notification.ProgressBar.BackgroundColor3 = style.ProgressColor
    notification.UIStroke.Color = style.StrokeColor
end

-- MISSING FUNCTION: Reposition existing notifications
function NotificationService:_repositionNotifications(position)
    local padding = self.isMobile and 10 or 20
    local notificationHeight = self.isMobile and 100 or 120
    local spacing = self.isMobile and 5 or 10
    
    local basePositionMap = {
        TopLeft = UDim2.new(0, padding, 0, padding),
        TopCenter = UDim2.new(0.5, -150, 0, padding),
        TopRight = UDim2.new(1, -300 - padding, 0, padding),
        BottomLeft = UDim2.new(0, padding, 1, -notificationHeight - padding),
        BottomCenter = UDim2.new(0.5, -150, 1, -notificationHeight - padding),
        BottomRight = UDim2.new(1, -300 - padding, 1, -notificationHeight - padding)
    }
    
    local basePosition = basePositionMap[position] or basePositionMap.TopRight
    
    -- Reposition all notifications in the same position group
    for i, notificationData in ipairs(self.notifications) do
        if notificationData.data.position == position then
            local notification = notificationData.instance
            local offsetY = (i - 1) * (notificationHeight + spacing)
            
            if string.find(position, "Top") then
                notification.Position = UDim2.new(
                    basePosition.X.Scale,
                    basePosition.X.Offset,
                    basePosition.Y.Scale,
                    basePosition.Y.Offset + offsetY
                )
            else -- Bottom positions
                notification.Position = UDim2.new(
                    basePosition.X.Scale,
                    basePosition.X.Offset,
                    basePosition.Y.Scale,
                    basePosition.Y.Offset - offsetY
                )
            end
        end
    end
end

-- MISSING FUNCTION: Remove notification properly
function NotificationService:_removeNotification(notification, callback)
    -- Find and remove from notifications table
    for i, notificationData in ipairs(self.notifications) do
        if notificationData.instance == notification then
            table.remove(self.notifications, i)
            break
        end
    end
    
    -- Animate out
    self:_animateOut(notification, function()
        if notification and notification.Parent then
            notification:Destroy()
        end
        
        self.activeNotifications = math.max(0, self.activeNotifications - 1)
        
        -- Call callback if provided
        if callback then
            callback()
        end
        
        -- Process queued notifications
        self:_processQueue()
        
        -- Reposition remaining notifications
        self:_repositionAllNotifications()
    end)
end

-- NEW FUNCTION: Animate out
function NotificationService:_animateOut(notification, onComplete)
    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )
    
    local goals = {}
    
    if self.config.animationStyle == "Slide" then
        goals.Position = UDim2.new(
            notification.Position.X.Scale,
            notification.Position.X.Offset + 400,
            notification.Position.Y.Scale,
            notification.Position.Y.Offset
        )
    elseif self.config.animationStyle == "Fade" then
        goals.BackgroundTransparency = 1
        if notification:FindFirstChild("Title") then
            goals.TitleTextTransparency = 1
        end
        if notification:FindFirstChild("Message") then
            goals.MessageTextTransparency = 1
        end
    end
    
    local tween = TweenService:Create(notification, tweenInfo, goals)
    tween:Play()
    
    tween.Completed:Connect(function()
        if onComplete then
            onComplete()
        end
    end)
end

-- NEW FUNCTION: Process queued notifications
function NotificationService:_processQueue()
    if #self.notificationQueue > 0 and self.activeNotifications < self.config.maxNotifications then
        local nextNotification = table.remove(self.notificationQueue, 1)
        self:_createNotification(nextNotification)
    end
end

-- NEW FUNCTION: Reposition all notifications
function NotificationService:_repositionAllNotifications()
    local positions = {"TopLeft", "TopCenter", "TopRight", "BottomLeft", "BottomCenter", "BottomRight"}
    
    for _, position in ipairs(positions) do
        self:_repositionNotifications(position)
    end
end

function NotificationService:Notify(title, message, options)
    local notificationData = {
        title = title,
        message = message,
        duration = options and options.duration or self.config.duration,
        position = options and options.position or self.config.position,
        notificationType = options and options.notificationType or "Info",
        callback = options and options.callback
    }
    
    -- Queue notification if too many are active
    if self.activeNotifications >= self.config.maxNotifications then
        table.insert(self.notificationQueue, notificationData)
        return
    end
    
    self:_createNotification(notificationData)
end

function NotificationService:_createNotification(data)
    self.activeNotifications += 1
    
    -- Clone template
    local notification = self.template:Clone()
    notification.Name = "Notification_" .. self.activeNotifications
    notification.Parent = self.screenGui
    notification.Visible = true
    
    -- Set content
    notification.Title.Text = data.title
    notification.Message.Text = data.message
    
    -- Set type-based styling
    self:_applyNotificationStyle(notification, data.notificationType)
    
    -- Calculate responsive position
    self:_setNotificationPosition(notification, data.position)
    
    -- Set up close button
    notification.CloseButton.MouseButton1Click:Connect(function()
        self:_removeNotification(notification, data.callback)
    end)
    
    -- Mobile touch support
    if self.isMobile then
        self:_setupMobileTouch(notification, data.callback)
    end
    
    -- Animate in
    self:_animateIn(notification)
    
    -- Start timer and progress bar
    self:_startNotificationTimer(notification, data.duration, data.callback)
    
    table.insert(self.notifications, {
        instance = notification,
        data = data
    })
end

function NotificationService:_setNotificationPosition(notification, position)
    local padding = self.isMobile and 10 or 20
    local notificationHeight = self.isMobile and 100 or 120
    
    local positionMap = {
        TopLeft = UDim2.new(0, padding, 0, padding),
        TopCenter = UDim2.new(0.5, -150, 0, padding),
        TopRight = UDim2.new(1, -300 - padding, 0, padding),
        BottomLeft = UDim2.new(0, padding, 1, -notificationHeight - padding),
        BottomCenter = UDim2.new(0.5, -150, 1, -notificationHeight - padding),
        BottomRight = UDim2.new(1, -300 - padding, 1, -notificationHeight - padding)
    }
    
    notification.Position = positionMap[position] or positionMap.TopRight
    notification.Size = UDim2.new(0, self.isMobile and 280 or 300, 0, notificationHeight)
    
    -- Adjust for existing notifications
    self:_repositionNotifications(position)
end

function NotificationService:_animateIn(notification)
    local goalPosition = notification.Position
    
    -- Start position based on animation style
    if self.config.animationStyle == "Slide" then
        notification.Position = UDim2.new(
            goalPosition.X.Scale,
            goalPosition.X.Offset + 400,
            goalPosition.Y.Scale,
            goalPosition.Y.Offset
        )
    elseif self.config.animationStyle == "Fade" then
        notification.BackgroundTransparency = 1
        notification.Title.TextTransparency = 1
        notification.Message.TextTransparency = 1
    end
    
    -- Animate in
    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local goals = {}
    
    if self.config.animationStyle == "Slide" then
        goals.Position = goalPosition
    elseif self.config.animationStyle == "Fade" then
        goals.BackgroundTransparency = 0
        goals.TitleTextTransparency = 0
        goals.MessageTextTransparency = 0
    end
    
    local tween = TweenService:Create(notification, tweenInfo, goals)
    tween:Play()
end

function NotificationService:_startNotificationTimer(notification, duration, callback)
    local progressBar = notification.ProgressBar
    
    -- Progress bar animation
    local progressTween = TweenService:Create(
        progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 3)}
    )
    progressTween:Play()
    
    -- Auto-remove after duration
    task.delay(duration, function()
        if notification and notification.Parent then
            self:_removeNotification(notification, callback)
        end
    end)
end

function NotificationService:_setupMobileTouch(notification, callback)
    local touchStartTime = 0
    local touchStartPosition = nil
    
    notification.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStartTime = tick()
            touchStartPosition = input.Position
        end
    end)
    
    notification.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local touchDuration = tick() - touchStartTime
            
            -- Tap (short press) - trigger callback
            if touchDuration < 0.5 then
                if callback then
                    callback()
                end
            -- Long press - dismiss notification
            else
                self:_removeNotification(notification)
            end
        end
    end)
end

-- NEW FUNCTION: Clear all notifications
function NotificationService:ClearAll()
    for i = #self.notifications, 1, -1 do
        local notificationData = self.notifications[i]
        if notificationData.instance then
            notificationData.instance:Destroy()
        end
    end
    
    self.notifications = {}
    self.notificationQueue = {}
    self.activeNotifications = 0
end

-- NEW FUNCTION: Destroy the entire notification system
function NotificationService:Destroy()
    self:ClearAll()
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

return NotificationService -- FIXED: Return correct module name