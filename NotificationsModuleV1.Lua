local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")

local NotificationModule = {}
local MAX_NOTIFICATIONS = 5 local notifications = {}

local function createScreenGui() local screenGui = Instance.new("ScreenGui") screenGui.Name = "NotificationGui" screenGui.ResetOnSpawn = false screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") return screenGui end

local screenGui = createScreenGui()

local function createNotificationFrame(parent) local notificationFrame = Instance.new("Frame") notificationFrame.Name = "NotificationFrame" notificationFrame.Size = UDim2.new(0.3, 0, 0.5, 0) notificationFrame.Position = UDim2.new(1, -20, 1, -20) notificationFrame.AnchorPoint = Vector2.new(1, 1) notificationFrame.BackgroundTransparency = 1 notificationFrame.Parent = parent

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = notificationFrame

return notificationFrame

end

local notificationFrame = createNotificationFrame(screenGui)

local notificationColors = { Info = {bg = Color3.fromRGB(45, 125, 255), text = Color3.new(1, 1, 1)}, Success = {bg = Color3.fromRGB(40, 167, 69), text = Color3.new(1, 1, 1)}, Warning = {bg = Color3.fromRGB(255, 193, 7), text = Color3.new(0, 0, 0)}, Error = {bg = Color3.fromRGB(220, 53, 69), text = Color3.new(1, 1, 1)} }

local function createNotificationTemplate(notificationType) local template = Instance.new("Frame") template.Size = UDim2.new(1, 0, 0.2, 0) template.BackgroundTransparency = 1 template.BorderSizePixel = 0 template.ClipsDescendants = true template.BackgroundColor3 = notificationColors[notificationType].bg

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = template

local shadow = Instance.new("UIStroke")
shadow.Thickness = 2
shadow.Transparency = 0.5
shadow.Parent = template

return template

end

local function createTextLabel(parent, position, size, text, textColor) local label = Instance.new("TextLabel") label.Size = size label.Position = position label.BackgroundTransparency = 1 label.Font = Enum.Font.Gotham label.TextScaled = true label.TextColor3 = textColor label.Text = text label.TextXAlignment = Enum.TextXAlignment.Left label.Parent = parent return label end

local function playSound() local sound = Instance.new("Sound") sound.SoundId = "rbxassetid://12345678" -- Replace with a valid sound ID sound.Volume = 0.5 sound.Parent = SoundService sound:Play() game:GetService("Debris"):AddItem(sound, 2) end

local function animateNotification(notificationTemplate, titleLabel, descriptionLabel, duration) notificationTemplate.Position = UDim2.new(1.5, 0, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset) local appearTween = TweenService:Create(notificationTemplate, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset), BackgroundTransparency = 0}) appearTween:Play()

coroutine.wrap(function()
    wait(duration)
    local disappearTween = TweenService:Create(notificationTemplate, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, notificationTemplate.Position.Y.Scale, notificationTemplate.Position.Y.Offset), BackgroundTransparency = 1})
    disappearTween:Play()
    disappearTween.Completed:Connect(function()
        notificationTemplate:Destroy()
    end)
end)()

end

function NotificationModule.Notify(title, description, notificationType, duration) description = description or "" duration = duration or 5 notificationType = notificationColors[notificationType] and notificationType or "Info"

if #notifications >= MAX_NOTIFICATIONS then
    notifications[1]:Destroy()
    table.remove(notifications, 1)
end

local notificationTemplate = createNotificationTemplate(notificationType)
local titleLabel = createTextLabel(notificationTemplate, UDim2.new(0, 5, 0, 5), UDim2.new(1, -10, 0.5, -10), title, notificationColors[notificationType].text)
titleLabel.Font = Enum.Font.GothamBold
local descriptionLabel = createTextLabel(notificationTemplate, UDim2.new(0, 5, 0.5, 5), UDim2.new(1, -10, 0.5, -10), description, notificationColors[notificationType].text)

notificationTemplate.Parent = notificationFrame
table.insert(notifications, notificationTemplate)

animateNotification(notificationTemplate, titleLabel, descriptionLabel, duration)
playSound()

notificationTemplate.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        notificationTemplate:Destroy()
    end
end)

end

return NotificationModule

