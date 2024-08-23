local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Notification = {}

Notification.Type = {
    ["Success"] = {Color = Color3.fromRGB(76, 175, 80), Icon = "rbxassetid://6031071053"},
    ["Error"] = {Color = Color3.fromRGB(244, 67, 54), Icon = "rbxassetid://6031071050"},
    ["Info"] = {Color = Color3.fromRGB(33, 150, 243), Icon = "rbxassetid://6031071051"},
    ["Warning"] = {Color = Color3.fromRGB(255, 152, 0), Icon = "rbxassetid://6031071052"},
    ["Debug"] = {Color = Color3.fromRGB(0, 188, 212), Icon = "rbxassetid://6031071054"},
    ["Critical"] = {Color = Color3.fromRGB(255, 0, 0), Icon = "rbxassetid://6031071055"},
    ["Notification"] = {Color = Color3.fromRGB(158, 158, 158), Icon = "rbxassetid://6031071056"},
    ["Achievement"] = {Color = Color3.fromRGB(255, 215, 0), Icon = "rbxassetid://6031071057"},
    ["Update"] = {Color = Color3.fromRGB(0, 123, 255), Icon = "rbxassetid://6031071058"},
    ["Reminder"] = {Color = Color3.fromRGB(255, 87, 34), Icon = "rbxassetid://6031071059"}
}

local function getNotificationContainer(screenGui)
    local notificationContainer = screenGui:FindFirstChild("NotificationContainer")
    if not notificationContainer then
        notificationContainer = Instance.new("Frame")
        notificationContainer.Name = "NotificationContainer"
        notificationContainer.Size = UDim2.new(0.3, 0, 0.5, 0)
        notificationContainer.AnchorPoint = Vector2.new(1, 1)
        notificationContainer.Position = UDim2.new(1, -20, 1, -20)
        notificationContainer.BackgroundTransparency = 1
        notificationContainer.Parent = screenGui

        local layout = Instance.new("UIListLayout", notificationContainer)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
    end

    return notificationContainer
end

local function calculateYSize(title, description)
    local titleSize = TextService:GetTextSize(title, 24, Enum.Font.GothamBold, Vector2.new(300, math.huge))
    local descriptionSize = TextService:GetTextSize(description, 18, Enum.Font.Gotham, Vector2.new(300, math.huge))
    local totalHeight = titleSize.Y + descriptionSize.Y + 40 -- Adding padding
    return UDim2.new(1, 0, 0, totalHeight), UDim2.new(1, -50, 0, titleSize.Y), UDim2.new(1, -10, 0, descriptionSize.Y)
end

local function createNotificationFrame(notificationType, title, description, priority)
    local frameSize, titleSize, descriptionSize = calculateYSize(title, description)

    local notificationFrame = Instance.new("Frame")
    notificationFrame.BackgroundColor3 = notificationType.Color
    notificationFrame.Size = frameSize
    notificationFrame.BorderSizePixel = 0
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.ClipsDescendants = true
    notificationFrame.LayoutOrder = priority

    -- UI Enhancements
    local corner = Instance.new("UICorner", notificationFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local gradient = Instance.new("UIGradient", notificationFrame)
    gradient.Color = ColorSequence.new(notificationType.Color, Color3.new(1, 1, 1))

    local icon = Instance.new("ImageLabel", notificationFrame)
    icon.Image = notificationType.Icon
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1

    local titleLabel = Instance.new("TextLabel", notificationFrame)
    titleLabel.Text = title
    titleLabel.Size = titleSize
    titleLabel.Position = UDim2.new(0, 50, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local descriptionLabel = Instance.new("TextLabel", notificationFrame)
    descriptionLabel.Text = description
    descriptionLabel.Size = descriptionSize
    descriptionLabel.Position = UDim2.new(0, 10, 0, titleSize.Y + 10)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Font = Enum.Font.Gotham
    descriptionLabel.TextSize = 18
    descriptionLabel.TextColor3 = Color3.new(1, 1, 1)
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

    -- Interactive Close button with hover effects
    local closeButton = Instance.new("TextButton", notificationFrame)
    closeButton.Text = "✖"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BorderSizePixel = 0
    closeButton.AutoButtonColor = true
    closeButton.TextScaled = true

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

function Notification:Notify(Type, Title, Description, Duration, Priority)
    local success, err = pcall(function()
        local notificationType = self.Type[Type]
        
        if not notificationType then
            error("Invalid notification type: " .. tostring(Type))
        end

        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local screenGui = playerGui:FindFirstChild("NotificationGui")
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "NotificationGui"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = playerGui
        end
        
        local notificationContainer = getNotificationContainer(screenGui)
        
        local notificationFrame = createNotificationFrame(notificationType, Title, Description, Priority or 1)
        notificationFrame.Parent = notificationContainer

        -- Initial animation: slide in and scale up
        local targetSize = notificationFrame.Size
        notificationFrame.Size = UDim2.new(0, 0, targetSize.Y.Scale, targetSize.Y.Offset) -- Start with zero width
        notificationFrame.Position = UDim2.new(1.5, 0, notificationFrame.Position.Y.Scale, notificationFrame.Position.Y.Offset)
        local slideInTween = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(1, -10, notificationFrame.Position.Y.Scale, notificationFrame.Position.Y.Offset), Size = targetSize, BackgroundTransparency = 0})
        slideInTween:Play()

        delay(Duration or 5, function()
            -- Fade out and slide out
            local slideOutTween = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, notificationFrame.Position.Y.Scale, notificationFrame.Position.Y.Offset), BackgroundTransparency = 1})
            slideOutTween:Play()
            slideOutTween.Completed:Connect(function()
                notificationFrame:Destroy()
            end)
        end)
    end)

    if not success then
        warn("Notification error: " .. tostring(err))
    end
end

return Notification