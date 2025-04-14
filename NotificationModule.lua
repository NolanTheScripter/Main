-- Dragnir Ultra Notification System v3.1 (Auto-Detect Localization)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

-- Configuration
local Config = {
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8),
    Colors = {
        Success = Color3.fromRGB(60, 220, 130),
        Error = Color3.fromRGB(255, 75, 75),
        Warning = Color3.fromRGB(255, 200, 80),
        Info = Color3.fromRGB(85, 170, 255),
        Fail = Color3.fromRGB(120, 120, 120),
    },
    Sounds = {
        Success = "rbxassetid://123456789",
        Error = "rbxassetid://987654321",
        Warning = "rbxassetid://456789123",
    },
    DefaultDuration = 7,
    MaxVisibleNotifications = 5,
    StackingDirection = "Vertical", -- Options: "Vertical", "Horizontal"
    DebugMode = false, -- Developer mode for testing notifications
    Localization = {
        en = { -- English
            Success = "Success",
            Error = "Error",
            Warning = "Warning",
            Info = "Info",
            Fail = "Fail",
        },
        es = { -- Spanish
            Success = "Éxito",
            Error = "Error",
            Warning = "Advertencia",
            Info = "Información",
            Fail = "Fallo",
        },
        fr = { -- French
            Success = "Succès",
            Error = "Erreur",
            Warning = "Avertissement",
            Info = "Info",
            Fail = "Échec",
        },
        de = { -- German
            Success = "Erfolg",
            Error = "Fehler",
            Warning = "Warnung",
            Info = "Info",
            Fail = "Fehlschlag",
        },
        zh = { -- Chinese (Simplified)
            Success = "成功",
            Error = "错误",
            Warning = "警告",
            Info = "信息",
            Fail = "失败",
        },
        ru = { -- Russian
            Success = "Успех",
            Error = "Ошибка",
            Warning = "Предупреждение",
            Info = "Информация",
            Fail = "Неудача",
        },
        pt = { -- Portuguese
            Success = "Sucesso",
            Error = "Erro",
            Warning = "Aviso",
            Info = "Informação",
            Fail = "Falha",
        },
        ar = { -- Arabic
            Success = "نجاح",
            Error = "خطأ",
            Warning = "تحذير",
            Info = "معلومة",
            Fail = "فشل",
        },
        hi = { -- Hindi
            Success = "सफलता",
            Error = "त्रुटि",
            Warning = "चेतावनी",
            Info = "जानकारी",
            Fail = "विफल",
        },
        ja = { -- Japanese
            Success = "成功",
            Error = "エラー",
            Warning = "警告",
            Info = "情報",
            Fail = "失敗",
        },
    },
    DefaultLanguage = "en", -- Fallback language
    Language = nil -- Detected language will be stored here
}

-- Helper Functions
local function DetectLanguage()
    local detectedLanguage
    pcall(function()
        detectedLanguage = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
    end)

    if detectedLanguage and Config.Localization[detectedLanguage] then
        return detectedLanguage
    else
        return Config.DefaultLanguage -- Fallback to default language
    end
end

local function Localize(key)
    local language = Config.Language or Config.DefaultLanguage
    return Config.Localization[language][key] or key
end

local function PlayAnimation(object, properties, duration, easingStyle)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[easingStyle] or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function PlaySound(soundId)
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 1
        sound.Parent = workspace
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

local function TriggerHapticFeedback()
    if UserInputService.TouchEnabled and HapticService:IsMotorSupported(Enum.UserInputType.Touch) then
        HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0.5)
    end
end

-- Initialize Language
Config.Language = DetectLanguage()

-- UI Initialization
local DragnirNotificationGui = Instance.new("ScreenGui")
DragnirNotificationGui.Name = "DragnirNotificationGui"
DragnirNotificationGui.IgnoreGuiInset = true
DragnirNotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DragnirNotificationGui.ResetOnSpawn = false
DragnirNotificationGui.DisplayOrder = 1000
DragnirNotificationGui.Parent = PlayerGui

local NotificationContainer = Instance.new("ScrollingFrame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0.3, 0, 0.8, 0)
NotificationContainer.Position = UDim2.new(0.7, 0, 0.1, 0)
NotificationContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
NotificationContainer.ScrollBarThickness = 6
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = DragnirNotificationGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Config.StackingDirection == "Horizontal" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
UIListLayout.Parent = NotificationContainer

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = NotificationContainer

-- Notification System
local Notification = {}

function Notification:Create(config)
    -- Create Notification Frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = Config.CompactMode and UDim2.new(1, 0, 0, 50) or UDim2.new(1, 0, 0, 100)
    NotificationFrame.BackgroundColor3 = config.Color or Config.Colors[config.Type] or Config.Colors.Info
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationContainer

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = Config.CornerRadius
    UICorner.Parent = NotificationFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Parent = NotificationFrame

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -40, 0.3, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Font = Config.Font
    TitleLabel.Text = config.Title or Localize(config.Type) or "Notification"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = NotificationFrame

    -- Message Label
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "MessageLabel"
    MessageLabel.Size = UDim2.new(1, -20, 0.6, 0)
    MessageLabel.Position = UDim2.new(0, 10, 0.35, 0)
    MessageLabel.Text = config.Message or ""
    MessageLabel.TextWrapped = true
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Parent = NotificationFrame

    -- Entry Animation
    NotificationFrame.Position = UDim2.new(1, 0, 0, 0)
    PlayAnimation(NotificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)

    -- Auto-Dismiss
    if not config.Sticky then
        task.delay(config.Duration or Config.DefaultDuration, function()
            Notification:Dismiss(NotificationFrame)
        end)
    end
end

function Notification:Dismiss(frame)
    -- Exit Animation
    local tween = PlayAnimation(frame, {BackgroundTransparency = 1}, 0.5)
    tween.Completed:Connect(function()
        frame:Destroy()
    end)
end

return Notification