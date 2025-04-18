local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local NotificationModule = {}
local screenGui = nil
local notifications = {}

local CONFIG = {
    Size = UDim2.new(0.25, 0, 0.1, 0),
    Padding = 10,
    MaxOnScreen = 4,
    Duration = 4,
    ZIndex = 50,

    Colors = {
        Success = Color3.fromRGB(76, 175, 80),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 193, 7),
        Info = Color3.fromRGB(33, 150, 243),
        Default = Color3.fromRGB(100, 100, 100),
    },

    Animation = {
        InTime = 0.35,
        OutTime = 0.35,
        Style = Enum.EasingStyle.Quint,
        DirIn = Enum.EasingDirection.Out,
        DirOut = Enum.EasingDirection.In
    }
}

-- UI init
local function ensureGui()
    if screenGui then return end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DragnirNotificationUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
end

-- Calculate Y offset for each notification
local function getYPosition(index)
    local height = Camera.ViewportSize.Y
    local notifHeight = CONFIG.Size.Y.Scale * height
    return -((notifHeight + CONFIG.Padding) * (index - 1)) - CONFIG.Padding
end

-- Create a single notification frame
local function createNotification(title, msg, type)
    local container = Instance.new("Frame")
    container.Size = CONFIG.Size
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1 + 0.05, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.ZIndex = CONFIG.ZIndex
    container.Parent = screenGui

    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 8)

    local accent = Instance.new("Frame", container)
    accent.Size = UDim2.new(0.015, 0, 1, 0)
    accent.BackgroundColor3 = CONFIG.Colors[type] or CONFIG.Colors.Default
    accent.BorderSizePixel = 0
    accent.ZIndex = CONFIG.ZIndex + 1

    local titleLabel = Instance.new("TextLabel", container)
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0.02, 10, 0, 5)
    titleLabel.Size = UDim2.new(1, -20, 0.4, -5)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = CONFIG.ZIndex + 1

    local messageLabel = Instance.new("TextLabel", container)
    messageLabel.Text = msg
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 15
    messageLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0.02, 10, 0.4, 0)
    messageLabel.Size = UDim2.new(1, -20, 0.6, -5)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = CONFIG.ZIndex + 1

    return container
end

-- Move and stack notifications
local function repositionNotifications()
    for i, notif in ipairs(notifications) do
        local targetY = getYPosition(i)
        local tween = TweenService:Create(notif, TweenInfo.new(CONFIG.Animation.InTime, CONFIG.Animation.Style, CONFIG.Animation.DirIn), {
            Position = UDim2.new(1, -CONFIG.Padding, 1, targetY)
        })
        tween:Play()
    end
end

-- Main notification function
function NotificationModule:Notify(title, msg, type)
    ensureGui()

    -- Remove oldest if too many
    if #notifications >= CONFIG.MaxOnScreen then
        local oldest = table.remove(notifications, 1)
        if oldest then oldest:Destroy() end
    end

    local notification = createNotification(title or "Notification", msg or "", type or "Default")
    table.insert(notifications, notification)

    -- Animate in
    TweenService:Create(notification, TweenInfo.new(CONFIG.Animation.InTime, CONFIG.Animation.Style, CONFIG.Animation.DirIn), {
        Position = UDim2.new(1, -CONFIG.Padding, 1, getYPosition(#notifications))
    }):Play()

    -- Auto-remove after duration
    task.delay(CONFIG.Duration, function()
        if notification and notification.Parent then
            -- Animate out
            local outTween = TweenService:Create(notification, TweenInfo.new(CONFIG.Animation.OutTime, CONFIG.Animation.Style, CONFIG.Animation.DirOut), {
                Position = UDim2.new(1 + 0.1, 0, 1, notification.Position.Y.Offset)
            })
            outTween:Play()
            outTween.Completed:Wait()

            -- Cleanup
            for i, notif in ipairs(notifications) do
                if notif == notification then
                    table.remove(notifications, i)
                    break
                end
            end
            if notification then
                notification:Destroy()
            end

            repositionNotifications()
        end
    end)

    return notification
end

function NotificationModule:ClearAll()
    for _, notif in ipairs(notifications) do
        if notif then notif:Destroy() end
    end
    table.clear(notifications)
end

-- Viewport change = reposition all
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(repositionNotifications)

return NotificationModule