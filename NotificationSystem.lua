--[[
    Modern Notification System
    Features: Multiple notification types, queue system, animations, auto-dismiss
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Theme Configuration
local Theme = {
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
    Warning = Color3.fromRGB(241, 196, 15),
    Info = Color3.fromRGB(52, 152, 219),
    Background = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(240, 240, 240),
    Font = Enum.Font.GothamMedium,
    Padding = 12,
    CornerRadius = 8
}

-- Helper Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in properties do
        instance[prop] = value
    end
    return instance
end

-- Janitor for Cleanup
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
    return setmetatable({_tasks = {}}, Janitor)
end

function Janitor:Add(task)
    table.insert(self._tasks, task)
    return task
end

function Janitor:Destroy()
    for _, task in ipairs(self._tasks) do
        if type(task) == "function" then
            task()
        elseif typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        end
    end
    self._tasks = {}
end

-- Notification Library
local NotificationLibrary = {}
NotificationLibrary.__index = NotificationLibrary

function NotificationLibrary.new()
    local self = setmetatable({}, NotificationLibrary)
    self.janitor = Janitor.new()
    self.queue = {}
    self.activeNotifications = {}
    self.maxVisible = 5
    
    self:_createContainer()
    return self
end

function NotificationLibrary:_createContainer()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    self.screenGui = self.janitor:Add(Create("ScreenGui", {
        Name = "NotificationSystem",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = playerGui
    }))
    
    self.container = self.janitor:Add(Create("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 350, 1, 0),
        Position = UDim2.new(1, -370, 0, 20),
        BackgroundTransparency = 1,
        Parent = self.screenGui
    }))
    
    self.janitor:Add(Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.container
    }))
end

function NotificationLibrary:_getTypeColor(notifType)
    local colors = {
        success = Theme.Success,
        error = Theme.Error,
        warning = Theme.Warning,
        info = Theme.Info
    }
    return colors[notifType] or Theme.Info
end

function NotificationLibrary:_createNotification(title, message, notifType, duration)
    local notifJanitor = Janitor.new()
    
    local frame = notifJanitor:Add(Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.container
    }))
    
    notifJanitor:Add(Create("UICorner", {
        CornerRadius = UDim.new(0, Theme.CornerRadius),
        Parent = frame
    }))
    
    local accentBar = notifJanitor:Add(Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = self:_getTypeColor(notifType),
        BorderSizePixel = 0,
        Parent = frame
    }))
    
    local contentFrame = notifJanitor:Add(Create("Frame", {
        Size = UDim2.new(1, -4, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Parent = frame
    }))
    
    notifJanitor:Add(Create("UIPadding", {
        PaddingLeft = UDim.new(0, Theme.Padding),
        PaddingRight = UDim.new(0, Theme.Padding),
        PaddingTop = UDim.new(0, Theme.Padding),
        PaddingBottom = UDim.new(0, Theme.Padding),
        Parent = contentFrame
    }))
    
    local titleLabel = notifJanitor:Add(Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = contentFrame
    }))
    
    local messageLabel = notifJanitor:Add(Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = contentFrame
    }))
    
    -- Calculate message height
    messageLabel.Size = UDim2.new(1, 0, 0, 1000)
    local textBounds = messageLabel.TextBounds.Y
    messageLabel.Size = UDim2.new(1, 0, 0, textBounds)
    
    local totalHeight = 24 + textBounds + (Theme.Padding * 2)
    
    return frame, notifJanitor, totalHeight
end

function NotificationLibrary:_animateIn(frame, targetHeight)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local goal = {Size = UDim2.new(1, 0, 0, targetHeight)}
    local tween = TweenService:Create(frame, tweenInfo, goal)
    tween:Play()
    return tween
end

function NotificationLibrary:_animateOut(frame)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local goal = {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    }
    local tween = TweenService:Create(frame, tweenInfo, goal)
    tween:Play()
    return tween
end

function NotificationLibrary:Notify(title, message, notifType, duration)
    notifType = notifType or "info"
    duration = duration or 5
    
    local frame, notifJanitor, height = self:_createNotification(title, message, notifType, duration)
    
    local notificationData = {
        frame = frame,
        janitor = notifJanitor,
        height = height
    }
    
    table.insert(self.activeNotifications, notificationData)
    
    -- Animate in
    local tweenIn = self:_animateIn(frame, height)
    
    tweenIn.Completed:Wait()
    
    -- Auto dismiss after duration
    task.delay(duration, function()
        if table.find(self.activeNotifications, notificationData) then
            self:_dismissNotification(notificationData)
        end
    end)
end

function NotificationLibrary:_dismissNotification(notificationData)
    local index = table.find(self.activeNotifications, notificationData)
    if not index then return end
    
    table.remove(self.activeNotifications, index)
    
    local tweenOut = self:_animateOut(notificationData.frame)
    
    tweenOut.Completed:Wait()
    notificationData.janitor:Destroy()
end

function NotificationLibrary:Success(title, message, duration)
    self:Notify(title, message, "success", duration)
end

function NotificationLibrary:Error(title, message, duration)
    self:Notify(title, message, "error", duration)
end

function NotificationLibrary:Warning(title, message, duration)
    self:Notify(title, message, "warning", duration)
end

function NotificationLibrary:Info(title, message, duration)
    self:Notify(title, message, "info", duration)
end

function NotificationLibrary:Destroy()
    self.janitor:Destroy()
    self.activeNotifications = {}
    self.queue = {}
end

-- Example Usage
local Notifications = NotificationLibrary.new()

-- Test notifications
task.wait(1)
Notifications:Success("Welcome!", "Notification system loaded successfully")

task.wait(2)
Notifications:Info("Information", "This is an informational notification with some longer text to demonstrate wrapping")

task.wait(2)
Notifications:Warning("Warning", "This is a warning notification")

task.wait(2)
Notifications:Error("Error", "Something went wrong!")

-- Custom notification
task.wait(2)
Notifications:Notify("Custom", "You can customize the duration and type", "success", 10)

return Notifications