-- NotificationModule.lua
-- Improved modular notification system with glow, stacking, sounds, queue, click-to-dismiss, and onClick callbacks.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NotificationModule = {}

-- Notification sound effects (soft UI chimes)
local function createSound(id)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = 0.5
    sound.Parent = SoundService
    return sound
end

local appearSound = createSound(6026984224) -- Soft UI ping
local disappearSound = createSound(6026985440) -- Soft UI fade

-- Notification container GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotificationGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "NotificationContainer"
container.Size = UDim2.new(0.3, 0, 0.6, 0)
container.Position = UDim2.new(1, -20, 1, -20)
container.AnchorPoint = Vector2.new(1, 1)
container.BackgroundTransparency = 1
container.Parent = screenGui

local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder
list.VerticalAlignment = Enum.VerticalAlignment.Bottom
list.Padding = UDim.new(0, 10)
list.Parent = container

local padding = Instance.new("UIPadding")
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = container

-- Color schemes
local notificationColors = {
    Info = {bg = Color3.fromRGB(45, 125, 255), text = Color3.new(1, 1, 1)},
    Success = {bg = Color3.fromRGB(40, 167, 69), text = Color3.new(1, 1, 1)},
    Warning = {bg = Color3.fromRGB(255, 193, 7), text = Color3.new(0, 0, 0)},
    Error = {bg = Color3.fromRGB(220, 53, 69), text = Color3.new(1, 1, 1)},
    Neutral = {bg = Color3.fromRGB(108, 117, 125), text = Color3.new(1, 1, 1)},
    Achievement = {bg = Color3.fromRGB(255, 215, 0), text = Color3.new(0, 0, 0)},
    Update = {bg = Color3.fromRGB(0, 123, 255), text = Color3.new(1, 1, 1)},
    Reminder = {bg = Color3.fromRGB(255, 87, 34), text = Color3.new(1, 1, 1)},
    Dark = {bg = Color3.fromRGB(60, 60, 60), text = Color3.new(1, 1, 1)}
}

-- Queue system
local queue = {}
local activeCount = 0
local maxVisible = 5

local function createNotification(title, description, notificationType, duration, priority, onClick)
    description = description or ""
    duration = duration or 5
    priority = priority or 1

    local colors = notificationColors[notificationType] or notificationColors["Info"]

    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = colors.bg
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = priority
    frame.ClipsDescendants = true
    frame.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = colors.bg
    stroke.Transparency = 0.6
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = colors.text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 8, 0, 5)
    titleLabel.Size = UDim2.new(1, -16, 0.4, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Text = description
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 13
    descLabel.TextColor3 = colors.text
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, 8, 0.4, 2)
    descLabel.Size = UDim2.new(1, -16, 0.6, -7)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextTransparency = 1
    descLabel.TextWrapped = true
    descLabel.TextScaled = false
    descLabel.Parent = frame

    -- Glow pulse effect
    local glow = true
    task.spawn(function()
        while glow and stroke do
            TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0.3}):Play()
            task.wait(0.8)
            TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0.6}):Play()
            task.wait(0.8)
        end
    end)

    -- Appear animation
    frame.Position = UDim2.new(1.5, 0, 0, 0)
    appearSound:Play()
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(descLabel, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

    local function dismiss()
        if not frame or not frame.Parent then return end
        disappearSound:Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(descLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1.5, 0, 0, 0), BackgroundTransparency = 1}):Play()
            .Completed:Once(function()
                glow = false
                frame:Destroy()
                activeCount -= 1
                if #queue > 0 then
                    local next = table.remove(queue, 1)
                    NotificationModule:Notify(unpack(next))
                end
            end)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if onClick then onClick() end
            dismiss()
        end
    end)

    task.delay(duration, dismiss)
end

function NotificationModule:Notify(title, description, notificationType, duration, priority, onClick)
    if activeCount >= maxVisible then
        table.insert(queue, {title, description, notificationType, duration, priority, onClick})
        return
    end
    activeCount += 1
    createNotification(title, description, notificationType, duration, priority, onClick)
end

return NotificationModule
