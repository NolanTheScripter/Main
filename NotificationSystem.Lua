local NotificationSystem = {}

-- Utility function to create a new instance with properties
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Ensure the notification GUI exists
local function ensureNotificationGui()
    if not game.CoreGui:FindFirstChild("NotificationSystemGUI") then
        local notificationGui = createInstance("ScreenGui", {
            Name = "NotificationSystemGUI",
            Parent = game.CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })

        local frame = createInstance("Frame", {
            Parent = notificationGui,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 300, 0, 500),
            Position = UDim2.new(0.7, 0, 0.1, 0)
        })

        createInstance("UIListLayout", {
            Parent = frame,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    end
end

-- Create a new notification
function NotificationSystem:NewNotification(data)
    ensureNotificationGui()

    local notification = createInstance("Frame", {
        Parent = game.CoreGui.NotificationSystemGUI.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 70),
        Visible = false
    })

    local design = createInstance("Frame", {
        Parent = notification,
        BackgroundColor3 = data.BackgroundColor or Color3.fromRGB(26, 26, 26),
        Size = UDim2.new(0, 280, 0, 60)
    })

    createInstance("UICorner", {
        Parent = design,
        CornerRadius = UDim.new(0, 4)
    })

    createInstance("TextLabel", {
        Parent = design,
        Text = data.Title or "Title",
        TextColor3 = data.TitleColor or Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 220, 0, 25),
        Position = UDim2.new(0.2, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.FredokaOne,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    createInstance("TextLabel", {
        Parent = design,
        Text = data.Description or "Description",
        TextColor3 = data.DescriptionColor or Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 220, 0, 35),
        Position = UDim2.new(0.2, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local function dismissNotification()
        local tween = game:GetService("TweenService"):Create(notification, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 70)})
        tween:Play()
        tween.Completed:Connect(function() notification:Destroy() end)
    end

    local closeButton = createInstance("TextButton", {
        Parent = design,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0.9, 0, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.FredokaOne,
        TextSize = 14
    })
    closeButton.MouseButton1Click:Connect(dismissNotification)

    notification.Visible = true
    local openTween = game:GetService("TweenService"):Create(notification, TweenInfo.new(0.2), {Size = UDim2.new(0, 280, 0, 70)})
    openTween:Play()

    if data.Timeout then
        delay(data.Timeout, dismissNotification)
    end

    if data.SoundId then
        local sound = createInstance("Sound", {
            Parent = workspace,
            SoundId = data.SoundId,
            Volume = data.Volume or 1
        })
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end
end

return NotificationSystem
