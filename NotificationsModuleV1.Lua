local TweenService = game:GetService("TweenService")

local NotificationModule = {}

local function createScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    return screenGui
end

local screenGui = createScreenGui()

local function createNotificationFrame(parent)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
    notificationFrame.Position = UDim2.new(1, -20, 1, -20)
    notificationFrame.AnchorPoint = Vector2.new(1, 1)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.Parent = parent

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = notificationFrame

    return notificationFrame
end

local notificationFrame = createNotificationFrame(screenGui)

local notificationColors = {
    Info = {bg = Color3.fromRGB(45, 125, 255), text = Color3.new(1, 1, 1)},
    Success = {bg = Color3.fromRGB(40, 167, 69), text = Color3.new(1, 1, 1)},
    Warning = {bg = Color3.fromRGB(255, 193, 7), text = Color3.new(0, 0, 0)},
    Error = {bg = Color3.fromRGB(220, 53, 69), text = Color3.new(1, 1, 1)},
    Neutral = {bg = Color3.fromRGB(108, 117, 125), text = Color3.new(1, 1, 1)},
    Achievement = {bg = Color3.fromRGB(255, 215, 0), text = Color3.new(0, 0, 0)},
    Update = {bg = Color3.fromRGB(0, 123, 255), text = Color3.new(1, 1, 1)},
    Reminder = {bg = Color3.fromRGB(255, 87, 34), text = Color3.new(1, 1, 1)}
}

local function createNotificationTemplate(notificationType)
    local template = Instance.new("Frame")
    template.Size = UDim2.new(1, 0, 0.2, 0)
    template.BackgroundTransparency = 1
    template.BorderSizePixel = 0
    template.ClipsDescendants = true

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = template

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.7
    uiStroke.Parent = template

    template.BackgroundColor3 = notificationColors[notificationType].bg
    uiStroke.Color = notificationColors[notificationType].bg

    return template
end

local function createTextLabel(parent, position, size, text, textColor)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextSize = 14
    label.TextTransparency = 1
    label.TextColor3 = textColor
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

local function animateNotification(notificationTemplate, titleLabel, descriptionLabel, duration)
    notificationTemplate.Position = UDim2.new(1.5, 0, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset)
    local slideInTween = TweenService:Create(notificationTemplate, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset), BackgroundTransparency = 0})
    local titleFadeInTween = TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
    local descriptionFadeInTween = TweenService:Create(descriptionLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
    slideInTween:Play()
    titleFadeInTween:Play()
    descriptionFadeInTween:Play()

    coroutine.wrap(function()
        wait(duration)

        local slideOutTween = TweenService:Create(notificationTemplate, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset), BackgroundTransparency = 1})
        local titleFadeOutTween = TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {TextTransparency = 1})
        local descriptionFadeOutTween = TweenService:Create(descriptionLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {TextTransparency = 1})
        slideOutTween:Play()
        titleFadeOutTween:Play()
        descriptionFadeOutTween:Play()

        slideOutTween.Completed:Connect(function()
            notificationTemplate:Destroy()
        end)
    end)()
end

function NotificationModule.createNotification(title, description, notificationType, duration)
    description = description or ""
    duration = duration or 5
    notificationType = notificationType or "Info"

    if not notificationColors[notificationType] then
        warn("Invalid notification type: " .. notificationType)
        notificationType = "Info"
    end

    local notificationTemplate = createNotificationTemplate(notificationType)

    local titleLabel = createTextLabel(notificationTemplate, UDim2.new(0, 5, 0, 5), UDim2.new(1, -10, 0.5, -10), title, notificationColors[notificationType].text)
    titleLabel.Font = Enum.Font.GothamBold

    local descriptionLabel = createTextLabel(notificationTemplate, UDim2.new(0, 5, 0.5, 5), UDim2.new(1, -10, 0.5, -10), description, notificationColors[notificationType].text)

    notificationTemplate.Visible = true
    notificationTemplate.Parent = notificationFrame

    animateNotification(notificationTemplate, titleLabel, descriptionLabel, duration)
end

return NotificationModule