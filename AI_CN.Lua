-- ExpandedNotificationModule.lua

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local NotificationModule = {}
NotificationModule.ActiveNotifications = {}

-- SETTINGS
NotificationModule.Settings = {
    WidthScale = 0.35,
    AspectRatio = 4,
    AnimationTime = 0.3,
    Padding = UDim.new(0,12),
    DefaultDuration = 3,
    MaxOnScreen = 3,
    BackgroundColors = {
        info = Color3.fromRGB(24, 116, 205),
        success = Color3.fromRGB(34, 139, 34),
        warning = Color3.fromRGB(255,165,0),
        error = Color3.fromRGB(178,34,34),
        default = Color3.fromRGB(60, 60, 60)
    },
    TextColor = Color3.new(1,1,1)
}

-- UI Position Presets
local NotificationPositions = {
    ["Top"] = UDim2.new(0.5,0,0.1,0),
    ["Bottom"] = UDim2.new(0.5,0,0.9,0)
}

-- Create notification UI
function NotificationModule:CreateNotificationFrame(args)
    local title = args.title or ""
    local message = args.message or ""
    local notifType = args.type or "default"
    local duration = args.duration or self.Settings.DefaultDuration
    local position = args.position or "Top"

    -- Notification container
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Size = UDim2.new(self.Settings.WidthScale, 0, 0, 96)
    frame.Position = NotificationPositions[position] or NotificationPositions["Top"]
    frame.BackgroundColor3 = self.Settings.BackgroundColors[notifType] or self.Settings.BackgroundColors["default"]
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0
    frame.ClipsDescendants = true

    -- Aspect Ratio
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = self.Settings.AspectRatio
    aspect.DominantAxis = Enum.DominantAxis.Width
    aspect.Parent = frame

    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    -- Title
    if #title > 0 then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -44, 0.4, -4)
        titleLabel.Position = UDim2.new(0, 12, 0, 4)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = self.Settings.TextColor
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame
    end

    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -44, 0.6, -8)
    msgLabel.Position = UDim2.new(0, 12, 0.4, 0)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = self.Settings.TextColor
    msgLabel.TextScaled = true
    msgLabel.TextWrapped = true
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = frame

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextScaled = true
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.Parent = frame

    closeBtn.MouseButton1Click:Connect(function()
        self:DismissNotification(frame)
    end)

    return frame, duration
end

-- Dismiss animation and removal
function NotificationModule:DismissNotification(frame)
    if not frame or not frame.Parent then return end
    local goal = {BackgroundTransparency = 1, Position = UDim2.new(frame.Position.X.Scale, 0, frame.Position.Y.Scale - 0.1, 0)}
    local tween = TweenService:Create(frame, TweenInfo.new(self.Settings.AnimationTime), goal)
    tween:Play()
    tween.Completed:Wait()
    frame:Destroy()
    for i,v in ipairs(self.ActiveNotifications) do
        if v == frame then
            table.remove(self.ActiveNotifications, i)
            break
        end
    end
    self:UpdateStack()
end

-- Handle stacked display & repositioning
function NotificationModule:UpdateStack()
    for idx, frame in ipairs(self.ActiveNotifications) do
        local yBase = 0.1 + (idx-1) * 0.15 -- Separate stacked items
        TweenService:Create(frame, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, yBase, 0)}):Play()
    end
end

-- Public API: Show a notification
function NotificationModule:Notify(args)
    -- args: table with title, message, duration, type, position
    PlayerGui:FindFirstChild("NotificationGui") -- Can create once for optimization.
    local frame, duration = self:CreateNotificationFrame(args)
    frame.Parent = PlayerGui
    table.insert(self.ActiveNotifications, 1, frame)
    self:UpdateStack()
    task.delay(duration, function()
        if frame and frame.Parent then
            self:DismissNotification(frame)
        end
    end)
    -- Limit stack
    while #self.ActiveNotifications > self.Settings.MaxOnScreen do
        self:DismissNotification(self.ActiveNotifications[#self.ActiveNotifications])
    end
end

return NotificationModul