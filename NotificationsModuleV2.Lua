local Notification = {}

Notification.Type = {
    ["Success"] = {Color = Color3.fromRGB(0, 125, 0), Icon = "rbxassetid://12345678"},
    ["Error"] = {Color = Color3.fromRGB(125, 0, 0), Icon = "rbxassetid://87654321"},
    ["Info"] = {Color = Color3.fromRGB(0, 0, 125), Icon = "rbxassetid://23456789"},
    ["Warning"] = {Color = Color3.fromRGB(255, 255, 0), Icon = "rbxassetid://98765432"},
    ["Debug"] = {Color = Color3.fromRGB(0, 255, 255), Icon = "rbxassetid://34567890"},
    ["Critical"] = {Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://09876543"},
    ["Notification"] = {Color = Color3.fromRGB(0, 0, 0), Icon = "rbxassetid://45678901"}
}

local function getNotificationContainer(screenGui)
    local notificationContainer = screenGui:FindFirstChild("NotificationContainer")
    if not notificationContainer then
        notificationContainer = Instance.new("Frame")
        notificationContainer.Name = "NotificationContainer"
        notificationContainer.Size = UDim2.new(0, 300, 1, 0)
        notificationContainer.Position = UDim2.new(1, -310, 0, 0)
        notificationContainer.AnchorPoint = Vector2.new(1, 0)
        notificationContainer.BackgroundTransparency = 1
        notificationContainer.Parent = screenGui

        local layout = Instance.new("UIListLayout", notificationContainer)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)
    end
    return notificationContainer
end

local function createNotificationFrame(notificationType, title, description)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.BackgroundColor3 = notificationType.Color
    notificationFrame.Size = UDim2.new(0, 300, 0, 100)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.BackgroundTransparency = 0.2

    local icon = Instance.new("ImageLabel", notificationFrame)
    icon.Image = notificationType.Icon
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 5, 0, 5)
    icon.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", notificationFrame)
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -40, 0.3, 0)
    titleLabel.Position = UDim2.new(0, 35, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local descriptionLabel = Instance.new("TextLabel", notificationFrame)
    descriptionLabel.Text = description
    descriptionLabel.Size = UDim2.new(1, -10, 0.7, -30)
    descriptionLabel.Position = UDim2.new(0, 5, 0.3, 5)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 18
    descriptionLabel.TextColor3 = Color3.new(1, 1, 1)
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

    return notificationFrame
end

function Notification:Notify(Type, Title, Description, Duration)
    local notificationType = self.Type[Type]
    
    if not notificationType then
        error("Invalid notification type: " .. tostring(Type))
    end

    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", playerGui)
    
    local notificationContainer = getNotificationContainer(screenGui)
    
    local notificationFrame = createNotificationFrame(notificationType, Title, Description)
    notificationFrame.Parent = notificationContainer

    local sound = Instance.new("Sound", notificationFrame)
    sound.SoundId = "rbxassetid://123456789"
    sound:Play()

    notificationFrame.Visible = true
    notificationFrame.Position = UDim2.new(1, 310, 0, 0)
    notificationFrame:TweenPosition(
        UDim2.new(1, -310, 0, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Bounce,
        0.5,
        true
    )

    notificationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            notificationFrame:Destroy()
        end
    end)

    delay(Duration or 5, function()
        notificationFrame:TweenPosition(
            UDim2.new(1, 310, 0, 0),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Quad,
            0.5,
            true,
            function()
                notificationFrame:Destroy()
            end
        )
    end)
end

return Notification