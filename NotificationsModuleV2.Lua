local Notification = {}

Notification.Type = {
    ["Success"] = {Color = Color3.fromRGB(0, 125, 0), Icon = "rbxassetid://6031071053"},
    ["Error"] = {Color = Color3.fromRGB(125, 0, 0), Icon = "rbxassetid://6031071050"},
    ["Info"] = {Color = Color3.fromRGB(0, 0, 125), Icon = "rbxassetid://6031071051"},
    ["Warning"] = {Color = Color3.fromRGB(255, 255, 0), Icon = "rbxassetid://6031071052"},
    ["Debug"] = {Color = Color3.fromRGB(0, 255, 255), Icon = "rbxassetid://6031071054"},
    ["Critical"] = {Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://6031071055"},
    ["Notification"] = {Color = Color3.fromRGB(0, 0, 0), Icon = "rbxassetid://6031071056"}
}

local function getNotificationContainer(screenGui)
    local notificationContainer = screenGui:FindFirstChild("NotificationContainer")
    if not notificationContainer then
        notificationContainer = Instance.new("Frame")
        notificationContainer.Name = "NotificationContainer"
        notificationContainer.Size = UDim2.new(0, 300, 1, 0)
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

    notificationContainer.Position = UDim2.new(1, -10, 0, 0)

    return notificationContainer
end

local function createNotificationFrame(notificationType, title, description)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.BackgroundColor3 = notificationType.Color
    notificationFrame.Size = UDim2.new(0, 300, 0, 100)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.ClipsDescendants = true

    -- Rounded corners
    local corner = Instance.new("UICorner", notificationFrame)
    corner.CornerRadius = UDim.new(0, 10)

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
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local descriptionLabel = Instance.new("TextLabel", notificationFrame)
    descriptionLabel.Text = description
    descriptionLabel.Size = UDim2.new(1, -10, 0.7, -30)
    descriptionLabel.Position = UDim2.new(0, 5, 0.3, 5)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.TextSize = 18
    descriptionLabel.TextColor3 = Color3.new(1, 1, 1)
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

    -- Close button
    local closeButton = Instance.new("TextButton", notificationFrame)
    closeButton.Text = "✖"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = true

    -- Rounded corners for the button
    local buttonCorner = Instance.new("UICorner", closeButton)
    buttonCorner.CornerRadius = UDim.new(0, 15)

    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0) -- Darker red
    end)

    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Color3.new(1, 0, 0) -- Original red
    end)

    closeButton.MouseButton1Click:Connect(function()
        notificationFrame:Destroy()
    end)

    return notificationFrame
end

function Notification:Notify(Type, Title, Description, Duration)
    local success, err = pcall(function()
        local notificationType = self.Type[Type]
        
        if not notificationType then
            error("Invalid notification type: " .. tostring(Type))
        end

        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local screenGui = playerGui:FindFirstChild("ScreenGui")
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Parent = playerGui
        end
        
        local notificationContainer = getNotificationContainer(screenGui)
        
        local notificationFrame = createNotificationFrame(notificationType, Title, Description)
        notificationFrame.Parent = notificationContainer

        -- Initial animation: fade in and scale up
        notificationFrame.Position = UDim2.new(1, 310, 0, 0)
        notificationFrame:TweenPosition(
            UDim2.new(1, -10, 0, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Bounce,
            0.5,
            true
        )

        delay(Duration or 5, function()
            -- Fade out and scale down
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
    end)

    if not success then
        warn("Notification error: " .. tostring(err))
    end
end

return Notification