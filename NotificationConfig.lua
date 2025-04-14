return {
    Fonts = {
        Title = Enum.Font.GothamBold,
        Message = Enum.Font.Gotham,
    },
    Colors = {
        Success = Color3.fromRGB(40, 200, 100),
        Error = Color3.fromRGB(255, 80, 80),
        Warning = Color3.fromRGB(255, 200, 80),
        Fail = Color3.fromRGB(150, 150, 150),
        Info = Color3.fromRGB(100, 180, 255),
        Custom = Color3.fromRGB(255, 255, 255),
    },
    Icons = {
        Success = "rbxassetid://icon_success",
        Error = "rbxassetid://icon_error",
        Warning = "rbxassetid://icon_warning",
        Info = "rbxassetid://icon_info",
    },
    Sounds = {
        Success = "rbxassetid://sound_success",
        Error = "rbxassetid://sound_error",
    },
    CornerRadius = UDim.new(0, 8),
    ShadowEnabled = true,
    MaxVisible = 6,   -- The maximum number of notifications visible at once
    DefaultDuration = 5,  -- Default time for notifications to remain before closing
    BlurEffect = false,   -- Option to enable background blur effect
}