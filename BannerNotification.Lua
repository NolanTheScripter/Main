local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")

local Notification = {}
Notification.__index = Notification

local notification_height = 50
local notification_padding = UDim.new(0, 5)
local notification_corner_radius = UDim.new(0, 10)
local fade_duration = 0.5

local color_schemes = {
    info = {
        background = Color3.fromRGB(52, 152, 219),
        text = Color3.fromRGB(255, 255, 255)
    },
    success = {
        background = Color3.fromRGB(46, 204, 113),
        text = Color3.fromRGB(255, 255, 255)
    },
    error = {
        background = Color3.fromRGB(231, 76, 60),
        text = Color3.fromRGB(255, 255, 255)
    },
    warning = {
        background = Color3.fromRGB(241, 196, 15),
        text = Color3.fromRGB(0, 0, 0)
    }
}

local function is_mobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function create_screen_gui()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "NotificationGui"
    screen_gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = "NotificationContainer"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = screen_gui

    local list_layout = Instance.new("UIListLayout")
    list_layout.SortOrder = Enum.SortOrder.LayoutOrder
    list_layout.VerticalAlignment = Enum.VerticalAlignment.Top
    list_layout.Padding = notification_padding
    list_layout.Parent = frame

    return screen_gui
end

local function create_notification(notification_type, title, description, notification_width)
    local notification_frame = Instance.new("Frame")
    notification_frame.Size = UDim2.new(0, notification_width, 0, notification_height)
    notification_frame.BackgroundColor3 = color_schemes[notification_type].background
    notification_frame.BackgroundTransparency = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = notification_corner_radius
    corner.Parent = notification_frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = notification_frame

    local text_label = Instance.new("TextLabel")
    text_label.Size = UDim2.new(1, -20, 1, -20)
    text_label.Position = UDim2.new(0, 10, 0, 10)
    text_label.BackgroundTransparency = 1
    text_label.Font = Enum.Font.GothamSemibold
    text_label.TextColor3 = color_schemes[notification_type].text
    text_label.TextSize = 14
    text_label.TextWrapped = true
    text_label.Text = title .. "\n" .. description
    text_label.Parent = notification_frame

    local close_button = Instance.new("TextButton")
    close_button.Size = UDim2.new(0, 20, 0, 20)
    close_button.Position = UDim2.new(1, -25, 0, 5)
    close_button.BackgroundTransparency = 1
    close_button.Font = Enum.Font.GothamBold
    close_button.TextColor3 = color_schemes[notification_type].text
    close_button.TextSize = 14
    close_button.Text = "X"
    close_button.Parent = notification_frame

    return notification_frame
end

local function animate_notification(notification_frame, container, duration)
    local fade_in_info = TweenInfo.new(fade_duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fade_in_tween = TweenService:Create(notification_frame, fade_in_info, { BackgroundTransparency = 0 })
    fade_in_tween:Play()

    task.delay(duration, function()
        local fade_out_info = TweenInfo.new(fade_duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local fade_out_tween = TweenService:Create(notification_frame, fade_out_info, { BackgroundTransparency = 1 })
        fade_out_tween:Play()

        fade_out_tween.Completed:Connect(function()
            notification_frame:Destroy()
            local layout_tween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {})
            layout_tween:Play()
        end)
    end)
end

function Notification.Notify(title, description, duration)
    local notification_type = "info"
    local lower_title = title:lower()
    local lower_description = description:lower()

    if lower_title:find("error") or lower_description:find("error") then
        notification_type = "error"
    elseif lower_title:find("success") or lower_description:find("success") then
        notification_type = "success"
    elseif lower_title:find("warn") or lower_description:find("warn") then
        notification_type = "warning"
    end

    local player = Players.LocalPlayer
    if not player then return end

    local player_gui = player:WaitForChild("PlayerGui")
    local screen_gui = player_gui:FindFirstChild("NotificationGui")

    if not screen_gui then
        screen_gui = create_screen_gui()
        screen_gui.Parent = player_gui
    end

    local container = screen_gui.NotificationContainer

    local viewport_size = workspace.CurrentCamera.ViewportSize
    local notification_width = is_mobile() and math.min(viewport_size.X * 0.8, 300) or math.min(viewport_size.X * 0.5, 300)

    local notification_frame = create_notification(notification_type, title, description, notification_width)
    notification_frame.Parent = container

    animate_notification(notification_frame, container, duration)

    notification_frame.TextButton.MouseButton1Click:Connect(function()
        local fade_out_info = TweenInfo.new(fade_duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local fade_out_tween = TweenService:Create(notification_frame, fade_out_info, { BackgroundTransparency = 1 })
        fade_out_tween:Play()

        fade_out_tween.Completed:Connect(function()
            notification_frame:Destroy()
            local layout_tween = TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {})
            layout_tween:Play()
        end)
    end)
end

local function start_error_logger()
    LogService.MessageOut:Connect(function(message, messageType)
        if messageType == Enum.MessageType.MessageError then
            Notification.Notify("Error:", tostring(message), 5)
        end
    end)
end

start_error_logger()

return Notification