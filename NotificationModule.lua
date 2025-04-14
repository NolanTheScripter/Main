-- Dragnir Ultra Notification System v1.0
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8),
    Colors = {
        Success = Color3.fromRGB(60, 220, 130),
        Error = Color3.fromRGB(255, 75, 75),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(85, 170, 255),
        Fail = Color3.fromRGB(120, 120, 120),
    },
    DefaultDuration = 7,
    MaxVisibleNotifications = 5,
}

-- Rate Limiter
local RateLimiter = {
    Enabled = true,
    Cooldown = 1.5,
    PerTypeCooldown = {
        ["Error"] = 2,
        ["Success"] = 0.5,
        ["Fail"] = 3,
        ["Warning"] = 1,
        ["Info"] = 1,
        ["Custom"] = 0.8,
    },
    LastSent = {}
}

-- Helper Functions
local function CanSendNotification(notificationType)
    if not RateLimiter.Enabled then return true end
    local now = tick()
    local lastTime = RateLimiter.LastSent[notificationType] or 0
    local cooldown = RateLimiter.PerTypeCooldown[notificationType] or RateLimiter.Cooldown
    if now - lastTime >= cooldown then
        RateLimiter.LastSent[notificationType] = now
        return true
    end
    return false
end

local function PlayAnimation(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- UI Initialization
local DragnirNotificationGui = Instance.new("ScreenGui")
DragnirNotificationGui.Name = "DragnirNotificationGui"
DragnirNotificationGui.IgnoreGuiInset = true
DragnirNotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DragnirNotificationGui.ResetOnSpawn = false
DragnirNotificationGui.DisplayOrder = 1000
DragnirNotificationGui.Parent = PlayerGui

local NotificationContainer = Instance.new("ScrollingFrame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0.3, 0, 0.8, 0)
NotificationContainer.Position = UDim2.new(0.7, 0, 0.1, 0)
NotificationContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
NotificationContainer.ScrollBarThickness = 6
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = DragnirNotificationGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = NotificationContainer

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = NotificationContainer

-- Notification System
local Notification = {}

function Notification:Create(config)
    if not CanSendNotification(config.Type) then return end

    -- Create Notification Frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(1, 0, 0, 100)
    NotificationFrame.BackgroundColor3 = config.Color or Config.Colors[config.Type] or Config.Colors.Info
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationContainer

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = Config.CornerRadius
    UICorner.Parent = NotificationFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = NotificationFrame

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -40, 0.3, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Font = Config.Font
    TitleLabel.Text = config.Title or "Notification"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = NotificationFrame

    -- Message Label
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "MessageLabel"
    MessageLabel.Size = UDim2.new(1, -20, 0.6, 0)
    MessageLabel.Position = UDim2.new(0, 10, 0.35, 0)
    MessageLabel.Text = config.Message or ""
    MessageLabel.TextWrapped = true
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Parent = NotificationFrame

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -30, 0, 10)
    CloseButton.Text = "X"
    CloseButton.Font = Config.Font
    CloseButton.TextColor3 = Color3.fromRGB(255, 75, 75)
    CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CloseButton.Parent = NotificationFrame

    local CloseUICorner = Instance.new("UICorner")
    CloseUICorner.CornerRadius = UDim.new(0, 4)
    CloseUICorner.Parent = CloseButton

    -- Entry Animation
    NotificationFrame.Position = UDim2.new(1, 0, 0, 0)
    PlayAnimation(NotificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)

    -- Auto-Dismiss
    if not config.Sticky then
        task.delay(config.Duration or Config.DefaultDuration, function()
            Notification:Dismiss(NotificationFrame)
        end)
    end

    -- Close Button Functionality
    CloseButton.MouseButton1Click:Connect(function()
        Notification:Dismiss(NotificationFrame)
        if config.OnDismiss then
            config.OnDismiss()
        end
    end)
end

function Notification:Dismiss(frame)
    -- Exit Animation
    local tween = PlayAnimation(frame, {BackgroundTransparency = 1}, 0.5)
    tween.Completed:Connect(function()
        frame:Destroy()
    end)
end

return Notification