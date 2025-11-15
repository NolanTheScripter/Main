-- NotificationModule.lua
-- Place this script in ReplicatedStorage or StarterPlayerScripts

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local NotificationModule = {}
NotificationModule.Queue = {}
NotificationModule.ActiveNotification = nil

-- Settings for notifications
NotificationModule.Settings = {
    WidthScale = 0.3,                -- Width is 30% of screen
    AspectRatio = 4,                 -- Aspect ratio width:height
    AnimationTime = 0.4,             -- Seconds for in/out animation
    Padding = UDim.new(0, 10),       -- Padding (unused but reserved)
    DefaultDuration = 3,             -- Notification display time (seconds)
    BackgroundColor = Color3.fromRGB(50, 50, 50),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Creates a notification UI frame
function NotificationModule:CreateNotificationFrame(text, duration, color)
    duration = duration or self.Settings.DefaultDuration
    color = color or self.Settings.BackgroundColor

    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, -0.2, 0)
    frame.Size = UDim2.new(self.Settings.WidthScale, 0, 0, 100)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = self.Settings.AspectRatio
    aspect.DominantAxis = Enum.DominantAxis.Width
    aspect.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = self.Settings.TextColor
    textLabel.TextScaled = true
    textLabel.TextWrapped = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = frame

    local notifObj = {}
    function notifObj:Play()
        screenGui.Parent = PlayerGui

        -- Tween in
        local tweenIn = TweenService:Create(frame, TweenInfo.new(self.Settings.AnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.1, 0)
        })
        tweenIn:Play()

        -- Tween out after duration expires
        delay(duration, function()
            local tweenOut = TweenService:Create(frame, TweenInfo.new(self.Settings.AnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, -0.2, 0),
                BackgroundTransparency = 1
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                screenGui:Destroy()
                NotificationModule.ActiveNotification = nil
                NotificationModule:ShowNext()
            end)
        end)
    end

    return notifObj
end

-- Shows the next notification in queue
function NotificationModule:ShowNext()
    if #self.Queue == 0 then return end
    self.ActiveNotification = table.remove(self.Queue, 1)
    self.ActiveNotification:Play()
end

-- Main public function to send a notification
function NotificationModule:SendNotification(text, duration, color)
    local notif = self:CreateNotificationFrame(text, duration, color)
    table.insert(self.Queue, notif)
    if not self.ActiveNotification then
        self:ShowNext()
    end
end

return NotificationModule