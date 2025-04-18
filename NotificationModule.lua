local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local NotificationModule = {}

local CONFIG = {
    Duration = 4,
    MaxNotifications = 3,
    Spacing = 10,
    BackgroundColor = Color3.fromRGB(35, 35, 35),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColors = {
        Success = Color3.fromRGB(76, 175, 80),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 193, 7),
        Info = Color3.fromRGB(33, 150, 243)
    },
    Font = Enum.Font.GothamBold,
    TitleSize = 18,
    MessageSize = 15,
    Size = UDim2.new(0.30, 0, 0.1, 0),
    ZIndex = 999
}

local notifications = {}

-- UI Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileNotificationUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = CoreGui

function NotificationModule:Notify(title, message, type)
    local resolution = Camera.ViewportSize

    if #notifications >= CONFIG.MaxNotifications then
        table.remove(notifications, 1):Destroy()
    end

    local container = Instance.new("Frame")
    container.Size = CONFIG.Size
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1 + 0.05, 0, 1, -CONFIG.Spacing) -- start offscreen
    container.BackgroundColor3 = CONFIG.BackgroundColor
    container.BorderSizePixel = 0
    container.ZIndex = CONFIG.ZIndex
    container.Parent = screenGui

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0.015, 0, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = CONFIG.AccentColors[type] or CONFIG.AccentColors.Info
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = CONFIG.ZIndex + 1
    accentBar.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Notification"
    titleLabel.Font = CONFIG.Font
    titleLabel.TextSize = CONFIG.TitleSize
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0.025, 10, 0, 5)
    titleLabel.Size = UDim2.new(1, -20, 0.5, -5)
    titleLabel.ZIndex = CONFIG.ZIndex + 1
    titleLabel.Parent = container

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message or ""
    messageLabel.Font = CONFIG.Font
    messageLabel.TextSize = CONFIG.MessageSize
    messageLabel.TextColor3 = CONFIG.TextColor
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0.025, 10, 0.5, 0)
    messageLabel.Size = UDim2.new(1, -20, 0.5, -5)
    messageLabel.ZIndex = CONFIG.ZIndex + 1
    messageLabel.Parent = container

    -- Stack below previous
    local totalHeight = (CONFIG.Size.Y.Scale * resolution.Y + CONFIG.Spacing)
    local newY = -CONFIG.Spacing
    for _, notif in ipairs(notifications) do
        newY = newY - (totalHeight)
    end
    table.insert(notifications, container)

    -- Animate In
    TweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1 - 0.025, 0, 1, newY)
    }):Play()

    -- Wait & Animate Out
    task.delay(CONFIG.Duration, function()
        TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1 + 0.3, 0, 1, newY)
        }):Play()

        task.wait(0.5)
        for i, v in ipairs(notifications) do
            if v == container then
                table.remove(notifications, i)
                break
            end
        end
        container:Destroy()
    end)
end

return NotificationModule