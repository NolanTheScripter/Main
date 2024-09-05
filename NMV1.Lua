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
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game:GetService("CoreGui")

        local notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "NotificationFrame"
        notificationFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
        notificationFrame.Position = UDim2.new(1, -20, 1, -20)
        notificationFrame.AnchorPoint = Vector2.new(1, 1)
        notificationFrame.BackgroundColor3 =
Color3.fromRGB(0,0,0) -- Black
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
    frame.ZIndex = 2
    frame.Parent = screenGui.NotificationFrame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.AnchorPoint = Vector2.new(0, 0)
    shadow.Image = "rbxassetid://1316045217" -- Replace with a flame-like image if available
    shadow.ImageColor3 = Color3.fromRGB(255, 69, 0) -- Flame-like color
    shadow.BackgroundTransparency = 1
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 1
    shadow.Parent = frame

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
    titleLabel.ZIndex = 3
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
    descriptionLabel.ZIndex = 3
    descriptionLabel.Parent = frame

    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0, 50, 0, 50)
    iconImage.Position = UDim2.new(0, 5, 0, 45)
    iconImage.Image = icon
    iconImage.BackgroundTransparency = 1
    iconImage.ZIndex = 3
    iconImage.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.ZIndex = 3
    closeButton.Parent = frame

    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    local function updatePosition()
        local screenSize = workspace.CurrentCamera.ViewportSize
        local startX = math.clamp((screenSize.X - Width) / 2, 0, screenSize.X - Width)
        local startY = screenSize.Y - Height - 20
        frame.Position = UDim2.new(0, startX, 0, startY)
    end

    updatePosition()

    local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenIn = game:GetService("TweenService"):Create(frame, tweenInfoIn, { Position = frame.Position + UDim2.new(0, 0, 0, -20) })
    tweenIn:Play()

    task.spawn(function()
        task.wait(duration)
        local tweenInfoOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local tweenOut = game:GetService("TweenService"):Create(frame, tweenInfoOut, { Position = frame.Position + UDim2.new(0, 0, 0, 20) })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

return NotificationServer