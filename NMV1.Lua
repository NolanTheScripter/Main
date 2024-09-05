local NotificationServer = {}

local FlameIcon = "rbxassetid://11803247078"
local Duration = 5
local Width = 300 / 1.4
local Height = 100 / 1.4

function NotificationServer:Notify(title, description, icon, duration)
    icon = icon or FlameIcon
    duration = duration or Duration

    local screenGui = game:GetService("CoreGui"):FindFirstChild("NotificationGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "NotificationGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
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
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.ZIndex = 1
    frame.Parent = screenGui.NotificationFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
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

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.ZIndex = 2
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenIn = game:GetService("TweenService"):Create(frame, tweenInfoIn, { Position = UDim2.new(0.5, -Width / 2, 0.1, 0) })
    tweenIn:Play()

    task.spawn(function()
        task.wait(duration)
        local tweenInfoOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local tweenOut = game:GetService("TweenService"):Create(frame, tweenInfoOut, { Position = UDim2.new(0.5, -Width / 2, -0.2, 0) })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

return NotificationServer