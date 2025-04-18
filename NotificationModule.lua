-- ModuleScript: MobileNotificationModule
local MobileNotificationModule = {}

-- Configuration
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
    Size = UDim2.new(0.85, 0, 0, 100),
    AnchorOffset = 20,
    ZIndex = 999
}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Internal
local ScreenGui, Container
local ActiveNotifications = {}

-- Setup GUI
local function InitContainer()
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "MobileNotifications"
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Parent = ScreenGui
    end
end

-- Update stacked positions
local function UpdatePositions()
    local yOffset = CONFIG.AnchorOffset
    for _, notif in ipairs(ActiveNotifications) do
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -CONFIG.Size.X.Offset / 2, 0, yOffset)
        }):Play()
        yOffset += notif.AbsoluteSize.Y + CONFIG.Spacing
    end
end

-- Create new notification
function MobileNotificationModule.Notify(params)
    InitContainer()

    if #ActiveNotifications >= CONFIG.MaxNotifications then
        local removed = table.remove(ActiveNotifications, 1)
        removed:Destroy()
    end

    local type = params.Type or "Info"
    local title = params.Title or "Notice"
    local message = params.Message or ""
    local duration = params.Duration or CONFIG.Duration
    local accentColor = CONFIG.AccentColors[type] or CONFIG.AccentColors.Info

    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = CONFIG.BackgroundColor
    notif.Size = CONFIG.Size
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.Position = UDim2.new(0.5, 0, 1, 0)
    notif.ZIndex = CONFIG.ZIndex
    notif.ClipsDescendants = true
    notif.Parent = Container

    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1

    local accent = Instance.new("Frame", notif)
    accent.BackgroundColor3 = accentColor
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Text = title
    titleLabel.Font = CONFIG.Font
    titleLabel.TextSize = CONFIG.TitleSize
    titleLabel.TextColor3 = CONFIG.TextColor
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local messageLabel = Instance.new("TextLabel", notif)
    messageLabel.Text = message
    messageLabel.Font = CONFIG.Font
    messageLabel.TextSize = CONFIG.MessageSize
    messageLabel.TextColor3 = CONFIG.TextColor
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 10, 0, 34)
    messageLabel.Size = UDim2.new(1, -20, 1, -40)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true

    table.insert(ActiveNotifications, notif)
    UpdatePositions()

    -- Animate In
    TweenService:Create(notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -CONFIG.Size.X.Offset / 2, 0, notif.Position.Y.Offset)
    }):Play()

    -- Auto remove
    task.delay(duration, function()
        for i, n in ipairs(ActiveNotifications) do
            if n == notif then
                table.remove(ActiveNotifications, i)
                break
            end
        end
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -CONFIG.Size.X.Offset / 2, 1, 20)
        }):Play()
        task.delay(0.3, function()
            notif:Destroy()
            UpdatePositions()
        end)
    end)
end

return MobileNotificationModule