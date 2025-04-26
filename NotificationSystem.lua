-- NotificationSystem.lua
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

-- Sound IDs (replace with your own sound assets)
local SOUND_IDS = {
    NOTIFICATION = "rbxassetid://9046302452",
    CRITICAL = "rbxassetid://9046302452"
}

-- Default settings
local DEFAULT_SETTINGS = {
    position = "TopRight",
    maxNotifications = 5,
    animationStyle = "Slide",
    soundsEnabled = true,
    priorityColors = {
        Low = Color3.fromRGB(52, 152, 219),
        Normal = Color3.fromRGB(46, 204, 113),
        High = Color3.fromRGB(243, 156, 18),
        Critical = Color3.fromRGB(231, 76, 60),
        Group = Color3.fromRGB(155, 89, 182),
        Media = Color3.fromRGB(26, 188, 156)
    }
}

-- Animation styles
local ANIMATION_STYLES = {
    Slide = {
        In = {Position = UDim2.new(1.2, 0, 0, 0), End = UDim2.new(0, 0, 0, 0)},
        Out = {Position = UDim2.new(0, 0, 0, 0), End = UDim2.new(-1.2, 0, 0, 0)}
    },
    Fade = {
        In = {BackgroundTransparency = 1, End = 0},
        Out = {BackgroundTransparency = 0, End = 1}
    },
    Scale = {
        In = {Size = UDim2.new(0, 0, 0, 0), End = UDim2.new(1, 0, 1, 0)},
        Out = {Size = UDim2.new(1, 0, 1, 0), End = UDim2.new(0, 0, 0, 0)}
    }
}

-- Utility functions
local function tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function playSound(soundId, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = parent or workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength + 1)
end

function NotificationSystem.new(parentFrame)
    local self = setmetatable({}, NotificationSystem)
    
    -- Initialize properties
    self.notifications = {}
    self.paused = false
    self.settings = table.clone(DEFAULT_SETTINGS)
    self.analytics = {
        totalShown = 0,
        totalClicked = 0,
        totalDismissed = 0,
        totalDisplayTime = 0,
        startTimes = {}
    }
    
    -- Create main container
    self.container = Instance.new("Frame")
    self.container.Name = "NotificationContainer"
    self.container.Size = UDim2.new(0.3, 0, 1, 0)
    self.container.Position = UDim2.new(0.7, 0, 0, 0)
    self.container.BackgroundTransparency = 1
    self.container.ClipsDescendants = true
    self.container.Parent = parentFrame or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create UIListLayout for notifications
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.Parent = self.container
    
    -- Apply initial settings
    self:applySettings()
    
    return self
end

function NotificationSystem:applySettings()
    -- Position the container based on settings
    if self.settings.position == "TopRight" then
        self.container.AnchorPoint = Vector2.new(1, 0)
        self.container.Position = UDim2.new(1, -10, 0, 10)
    elseif self.settings.position == "TopLeft" then
        self.container.AnchorPoint = Vector2.new(0, 0)
        self.container.Position = UDim2.new(0, 10, 0, 10)
    elseif self.settings.position == "BottomRight" then
        self.container.AnchorPoint = Vector2.new(1, 1)
        self.container.Position = UDim2.new(1, -10, 1, -10)
    elseif self.settings.position == "BottomLeft" then
        self.container.AnchorPoint = Vector2.new(0, 1)
        self.container.Position = UDim2.new(0, 10, 1, -10)
    end
    
    -- Update list layout based on position
    local listLayout = self.container:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        if self.settings.position:find("Bottom") then
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        else
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        end
        
        if self.settings.position:find("Left") then
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        else
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        end
    end
end

function NotificationSystem:showNotification(options)
    -- Check max notifications
    if #self.notifications >= self.settings.maxNotifications then
        self:removeNotification(self.notifications[1].id, false)
    end
    
    -- Create notification frame
    local notificationId = tick()
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification_"..notificationId
    notificationFrame.Size = UDim2.new(1, 0, 0, 0)
    notificationFrame.AutomaticSize = Enum.AutomaticSize.Y
    notificationFrame.BackgroundColor3 = self.settings.priorityColors[options.priority or "Normal"]
    notificationFrame.BackgroundTransparency = 0.1
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ClipsDescendants = true
    notificationFrame.LayoutOrder = -notificationId -- Newest on top
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notificationFrame
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = notificationFrame
    
    -- Main layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = notificationFrame
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = notificationFrame
    
    -- Header (title + time)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.BackgroundTransparency = 1
    headerFrame.Size = UDim2.new(1, 0, 0, 0)
    headerFrame.AutomaticSize = Enum.AutomaticSize.Y
    
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.Padding = UDim.new(0, 10)
    headerLayout.Parent = headerFrame
    
    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingBottom = UDim.new(0, 5)
    headerPadding.Parent = headerFrame
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://"..(options.icon or "6022668888") -- Default bell icon
    icon.Parent = headerFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -30, 0, 0)
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.BackgroundTransparency = 1
    title.Text = options.title or "Notification"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = headerFrame
    
    -- Time
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(0, 50, 0, 0)
    timeLabel.AutomaticSize = Enum.AutomaticSize.Y
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M")
    timeLabel.TextColor3 = Color3.new(1, 1, 1)
    timeLabel.TextSize = 14
    timeLabel.TextTransparency = 0.3
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Parent = headerFrame
    
    headerFrame.Parent = notificationFrame
    
    -- Message
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(1, 0, 0, 0)
    message.AutomaticSize = Enum.AutomaticSize.Y
    message.BackgroundTransparency = 1
    message.Text = options.message or ""
    message.TextColor3 = Color3.new(1, 1, 1)
    message.TextSize = 16
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.Font = Enum.Font.Gotham
    message.Parent = notificationFrame
    
    -- Media content (image)
    if options.image then
        local image = Instance.new("ImageLabel")
        image.Name = "Image"
        image.Size = UDim2.new(1, 0, 0, 150)
        image.BackgroundColor3 = Color3.new(0, 0, 0)
        image.BackgroundTransparency = 0.5
        image.BorderSizePixel = 0
        image.ScaleType = Enum.ScaleType.Crop
        image.Image = options.image
        image.Parent = notificationFrame
        
        notificationFrame.BackgroundColor3 = self.settings.priorityColors.Media
    end
    
    -- Progress bar (for timed notifications)
    if options.duration and options.duration > 0 then
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.AnchorPoint = Vector2.new(0, 1)
        progressBar.BackgroundColor3 = Color3.new(1, 1, 1)
        progressBar.BackgroundTransparency = 0.7
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notificationFrame
        
        local progressFill = Instance.new("Frame")
        progressFill.Name = "ProgressFill"
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.new(1, 1, 1)
        progressFill.BorderSizePixel = 0
        progressFill.Parent = progressBar
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 10)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundTransparency = 0.8
    closeButton.TextColor3 = Color3.new(0, 0, 0)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = notificationFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Add to container
    notificationFrame.Parent = self.container
    
    -- Play sound if enabled
    if self.settings.soundsEnabled then
        local soundId = (options.priority == "Critical") and SOUND_IDS.CRITICAL or SOUND_IDS.NOTIFICATION
        playSound(soundId, notificationFrame)
    end
    
    -- Critical notification effect
    if options.priority == "Critical" then
        task.spawn(function()
            while notificationFrame and notificationFrame.Parent do
                notificationFrame.BackgroundColor3 = Color3.new(1, 0, 0)
                task.wait(0.5)
                if notificationFrame then
                    notificationFrame.BackgroundColor3 = self.settings.priorityColors.Critical
                end
                task.wait(0.5)
            end
        end)
    end
    
    -- Store notification data
    local notificationData = {
        id = notificationId,
        frame = notificationFrame,
        duration = options.duration or 3000,
        timer = nil,
        isPaused = false,
        startTime = tick()
    }
    
    table.insert(self.notifications, notificationData)
    self.analytics.totalShown += 1
    self.analytics.startTimes[notificationId] = tick()
    
    -- Animate in
    self:animateNotification(notificationFrame, "In")
    
    -- Set up close button
    closeButton.MouseButton1Click:Connect(function()
        self:removeNotification(notificationId, true)
    end)
    
    -- Set up click handler if provided
    if options.onClick then
        notificationFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                options.onClick()
                self.analytics.totalClicked += 1
            end
        end)
    end
    
    -- Start timer if duration is set
    if options.duration and options.duration > 0 then
        self:startNotificationTimer(notificationData)
    end
    
    return notificationData
end

function NotificationSystem:animateNotification(frame, direction)
    local style = ANIMATION_STYLES[self.settings.animationStyle or "Slide"]
    if not style then return end
    
    local animProps = style[direction]
    if not animProps then return end
    
    -- Set initial state
    for prop, value in pairs(animProps) do
        if prop ~= "End" then
            if prop == "Position" then
                frame.Position = value
            elseif prop == "Size" then
                frame.Size = value
            elseif prop == "BackgroundTransparency" then
                frame.BackgroundTransparency = value
            end
        end
    end
    
    -- Tween to end state
    local endProps = {}
    for prop, value in pairs(animProps) do
        if prop == "End" then
            if direction == "In" then
                if value == UDim2.new(0, 0, 0, 0) then
                    endProps.Position = UDim2.new(0, 0, 0, 0)
                elseif value == UDim2.new(1, 0, 1, 0) then
                    endProps.Size = UDim2.new(1, 0, 0, frame.AutomaticSize == Enum.AutomaticSize.Y and 0 or frame.Size.Y.Offset)
                else
                    endProps.BackgroundTransparency = value
                end
            end
        end
    end
    
    tween(frame, endProps, 0.5)
end

function NotificationSystem:startNotificationTimer(notificationData)
    if self.paused then
        notificationData.isPaused = true
        return
    end
    
    -- Animate progress bar if exists
    local progressBar = notificationData.frame:FindFirstChild("ProgressBar")
    if progressBar then
        local progressFill = progressBar:FindFirstChild("ProgressFill")
        if progressFill then
            tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, notificationData.duration / 1000)
        end
    end
    
    notificationData.timer = task.delay(notificationData.duration / 1000, function()
        if notificationData.frame and notificationData.frame.Parent then
            self:removeNotification(notificationData.id, true)
        end
    end)
end

function NotificationSystem:removeNotification(id, updateAnalytics)
    local index = table.find(self.notifications, function(n) return n.id == id end)
    if not index then return end
    
    local notification = self.notifications[index]
    
    -- Calculate display time for analytics
    if updateAnalytics and notification.startTime then
        local displayTime = tick() - notification.startTime
        self.analytics.totalDisplayTime += displayTime
        self.analytics.totalDismissed += 1
        self.analytics.startTimes[id] = nil
    end
    
    -- Animate out
    if notification.frame and notification.frame.Parent then
        self:animateNotification(notification.frame, "Out")
        
        -- Wait for animation to complete before destroying
        task.delay(0.5, function()
            if notification.frame and notification.frame.Parent then
                notification.frame:Destroy()
            end
        end)
    end
    
    -- Clean up timer
    if notification.timer then
        task.cancel(notification.timer)
    end
    
    -- Remove from notifications table
    table.remove(self.notifications, index)
end

function NotificationSystem:pauseAllNotifications()
    self.paused = true
    for _, notification in ipairs(self.notifications) do
        if notification.timer then
            task.cancel(notification.timer)
            notification.isPaused = true
            
            -- Calculate remaining time
            local elapsed = tick() - notification.startTime
            notification.remainingTime = notification.duration - (elapsed * 1000)
            
            -- Pause progress bar animation
            local progressFill = notification.frame and notification.frame:FindFirstChild("ProgressBar") and notification.frame.ProgressBar:FindFirstChild("ProgressFill")
            if progressFill then
                progressFill:TweenSize(progressFill.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0, true)
            end
        end
    end
end

function NotificationSystem:resumeAllNotifications()
    self.paused = false
    for _, notification in ipairs(self.notifications) do
        if notification.isPaused then
            notification.isPaused = false
            notification.startTime = tick()
            notification.duration = notification.remainingTime
            self:startNotificationTimer(notification)
        end
    end
end

function NotificationSystem:clearAllNotifications()
    for i = #self.notifications, 1, -1 do
        self:removeNotification(self.notifications[i].id, false)
    end
end

-- Convenience methods for common notification types
function NotificationSystem:showSuccess(title, message, duration)
    return self:showNotification({
        priority = "Normal",
        title = title or "Success",
        message = message or "Operation completed successfully",
        duration = duration or 3000,
        icon = "6026568195" -- Checkmark icon
    })
end

function NotificationSystem:showError(title, message, duration)
    return self:showNotification({
        priority = "Critical",
        title = title or "Error",
        message = message or "Something went wrong",
        duration = duration or 4000,
        icon = "6026568327" -- X icon
    })
end

function NotificationSystem:showWarning(title, message, duration)
    return self:showNotification({
        priority = "High",
        title = title or "Warning",
        message = message or "This action cannot be undone",
        duration = duration or 3500,
        icon = "6031094677" -- Warning icon
    })
end

function NotificationSystem:showInfo(title, message, duration)
    return self:showNotification({
        priority = "Low",
        title = title or "Information",
        message = message or "This is an informational message",
        duration = duration or 2500,
        icon = "6031091004" -- Info icon
    })
end

function NotificationSystem:showImageNotification(title, message, imageId, duration)
    return self:showNotification({
        priority = "Normal",
        title = title or "Image",
        message = message or "",
        image = "rbxassetid://"..imageId,
        duration = duration or 5000,
        icon = "6026568467" -- Image icon
    })
end

return NotificationSystem