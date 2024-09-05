local NotificationServer = {}

local FlameIcon = "rbxassetid://11803247078"
local Duration = 5
local Width = 300
local Height = 100

function NotificationServer:Notify(title, description, icon, duration)
    icon = icon or FlameIcon
    duration = duration or Duration

    local screenGui = game:GetService("CoreGui"):FindFirstChild("NotificationGui")

    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NotificationGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game:GetService("CoreGui")

        local notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "NotificationFrame"
        notificationFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
        notificationFrame.Position = UDim2.new(1, -20, 1, -20)
        notificationFrame.AnchorPoint = Vector2.new(1, 1)
        notificationFrame.BackgroundTransparency = 1
        notificationFrame.Parent = screenGui

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        uiListLayout.Padding = UDim.new(0, 4)
        uiListLayout.Parent = notificationFrame
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, Width, 0, Height)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.ZIndex = 1
    frame.Parent = screenGui.NotificationFrame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, -Width / 2 - 10, 0.1, -10)
    shadow.AnchorPoint = Vector2.new(0.5, 0)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = frame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new(Color3.fromRGB(45, 45, 45), Color3.fromRGB(60, 60, 60))
    uiGradient.Rotation = 90
    uiGradient.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 3
    uiStroke.Color = Color3.fromRGB(255, 255, 255)
    uiStroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 30)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.ZIndex = 2
    titleLabel.Parent = frame

    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, -10, 0, 50)
    descriptionLabel.Position = UDim2.new(0, 5, 0, 35)
    descriptionLabel.Text = description
    descriptionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 18
    descriptionLabel.TextWrapped = true
    descriptionLabel.ZIndex = 2
    descriptionLabel.Parent = frame

    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0, 50, 0, 50)
    iconImage.Position = UDim2.new(0, 5, 0, 45)
    iconImage.Image = icon
    iconImage.BackgroundTransparency = 1
    iconImage.ZIndex = 2
    iconImage.Parent = frame

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(frame, tweenInfo, { Position = UDim2.new(0.5, -Width / 2, 0.1, 0) })
    tween:Play()

    task.spawn(function()
        task.wait(duration)
        local exitTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In)
        local exitTween = game:GetService("TweenService"):Create(frame, exitTweenInfo, { Position = UDim2.new(0.5, -Width / 2, -0.2, 0) })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

return NotificationServer