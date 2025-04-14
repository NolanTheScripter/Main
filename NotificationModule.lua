local NotificationModule = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function calculateSize(Content)
    local baseWidth = 300
    local baseHeight = 100
    local extraWidthPerChar = 5
    local extraHeightPerLine = 20
    local lineWidth = 50 

    local lines = math.ceil(#Content / lineWidth)
    local width = math.min(baseWidth + (#Content * extraWidthPerChar), 500)
    local height = baseHeight + ((lines - 1) * extraHeightPerLine)

    return width, height
end

local function CreateNotification(Title, Content, Duration, Image)
    local ScreenGui = CoreGui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui")
    ScreenGui.Name = "NotificationGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local width, height = calculateSize(Content)

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, width, 0, height)
    NotificationFrame.Position = UDim2.new(0.5, -width / 2, 0.85, 0)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.AnchorPoint = Vector2.new(0.5, 1)
    NotificationFrame.BackgroundTransparency = 0.2
    NotificationFrame.Visible = true
    NotificationFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = NotificationFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.7
    UIStroke.Parent = NotificationFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 0.35, 0)
    TitleLabel.Position = UDim2.new(0, 50, 0, 10)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotificationFrame

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -50, 0.55, -15)
    ContentLabel.Position = UDim2.new(0, 50, 0.35, 5)
    ContentLabel.Text = Content
    ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.TextScaled = true
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextWrapped = true
    ContentLabel.Parent = NotificationFrame

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 10, 0.5, -20)
    Icon.Image = Image
    Icon.BackgroundTransparency = 1
    Icon.Parent = NotificationFrame

    local function FadeOutNotification()
        local tween = TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1, Position = NotificationFrame.Position + UDim2.new(0, 0, 0.1, 0)})
        tween:Play()
        tween.Completed:Wait()
        NotificationFrame:Destroy()
    end

    local function AutoCloseNotification()
        task.delay(Duration, function()
            FadeOutNotification()
        end)
    end

    TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = NotificationFrame.Position - UDim2.new(0, 0, 0.05, 0)}):Play()
    AutoCloseNotification()
end

function NotificationModule:Notify(Title, Content, Duration, Image)
    CreateNotification(Title, Content, Duration, Image)
end

return NotificationModule