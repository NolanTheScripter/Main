local Notification = {}

local GUI = game:GetService("CoreGui"):FindFirstChild("STX_Notification")

function Notification:Notify(nofdebug, middledebug, all)
    local SelectedType = string.lower(tostring(middledebug.Type))
    
    local ambientShadow = self:createAmbientShadow()
    local Window = self:createWindow(ambientShadow)
    local Outline_A = self:createOutline(Window, middledebug.OutlineColor)
    local WindowTitle = self:createWindowTitle(Window, nofdebug.Title)
    local WindowDescription = self:createWindowDescription(Window, nofdebug.Description)
    
    if SelectedType == "default" then
        self:handleDefaultType(ambientShadow, Outline_A, middledebug.Time)
    elseif SelectedType == "image" then
        self:handleImageType(ambientShadow, Window, WindowTitle, Outline_A, middledebug.Time, all.Image, all.ImageColor)
    elseif SelectedType == "option" then
        self:handleOptionType(ambientShadow, Window, Outline_A, middledebug.Time, all.Callback)
    end
end

function Notification:createAmbientShadow()
    local ambientShadow = Instance.new("ImageLabel")
    ambientShadow.Name = "ambientShadow"
    ambientShadow.Parent = GUI
    ambientShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientShadow.BackgroundTransparency = 1.000
    ambientShadow.BorderSizePixel = 0
    ambientShadow.Position = UDim2.new(0.91525954, 0, 0.936809778, 0)
    ambientShadow.Size = UDim2.new(0, 0, 0, 0)
    ambientShadow.Image = "rbxassetid://1316045217"
    ambientShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ambientShadow.ImageTransparency = 0.400
    ambientShadow.ScaleType = Enum.ScaleType.Slice
    ambientShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    return ambientShadow
end

function Notification:createWindow(ambientShadow)
    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = ambientShadow
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, 5, 0, 5)
    Window.Size = UDim2.new(0, 230, 0, 80)
    Window.ZIndex = 2
    return Window
end

function Notification:createOutline(Window, OutlineColor)
    local Outline_A = Instance.new("Frame")
    Outline_A.Name = "Outline_A"
    Outline_A.Parent = Window
    Outline_A.BackgroundColor3 = OutlineColor
    Outline_A.BorderSizePixel = 0
    Outline_A.Position = UDim2.new(0, 0, 0, 25)
    Outline_A.Size = UDim2.new(0, 230, 0, 2)
    Outline_A.ZIndex = 5
    return Outline_A
end

function Notification:createWindowTitle(Window, Title)
    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = Window
    WindowTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.BackgroundTransparency = 1.000
    WindowTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Position = UDim2.new(0, 8, 0, 2)
    WindowTitle.Size = UDim2.new(0, 222, 0, 22)
    WindowTitle.ZIndex = 4
    WindowTitle.Font = Enum.Font.GothamSemibold
    WindowTitle.Text = Title
    WindowTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    WindowTitle.TextSize = 12.000
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    return WindowTitle
end

function Notification:createWindowDescription(Window, Description)
    local WindowDescription = Instance.new("TextLabel")
    WindowDescription.Name = "WindowDescription"
    WindowDescription.Parent = Window
    WindowDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowDescription.BackgroundTransparency = 1.000
    WindowDescription.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowDescription.BorderSizePixel = 0
    WindowDescription.Position = UDim2.new(0, 8, 0, 34)
    WindowDescription.Size = UDim2.new(0, 216, 0, 40)
    WindowDescription.ZIndex = 4
    WindowDescription.Font = Enum.Font.GothamSemibold
    WindowDescription.Text = Description
    WindowDescription.TextColor3 = Color3.fromRGB(180, 180, 180)
    WindowDescription.TextSize = 12.000
    WindowDescription.TextWrapped = true
    WindowDescription.TextXAlignment = Enum.TextXAlignment.Left
    WindowDescription.TextYAlignment = Enum.TextYAlignment.Top
    return WindowDescription
end

function Notification:handleDefaultType(ambientShadow, Outline_A, Time)
    ambientShadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
    Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Time)

    wait(Time)
    ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
    wait(0.2)
    ambientShadow:Destroy()
end

function Notification:handleImageType(ambientShadow, Window, WindowTitle, Outline_A, Time, Image, ImageColor)
    ambientShadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
    WindowTitle.Position = UDim2.new(0, 24, 0, 2)
    local ImageButton = Instance.new("ImageButton")
    ImageButton.Parent = Window
    ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageButton.BackgroundTransparency = 1.000
    ImageButton.BorderSizePixel = 0
    ImageButton.Position = UDim2.new(0, 4, 0, 4)
    ImageButton.Size = UDim2.new(0, 18, 0, 18)
    ImageButton.ZIndex = 5
    ImageButton.AutoButtonColor = false
    ImageButton.Image = Image
    ImageButton.ImageColor3 = ImageColor

    Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Time)
    wait(Time)
    ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
    wait(0.2)
    ambientShadow:Destroy()
end

function Notification:handleOptionType(ambientShadow, Window, Outline_A, Time, Callback)
    ambientShadow:TweenSize(UDim2.new(0, 240, 0, 110), "Out", "Linear", 0.2)
    Window.Size = UDim2.new(0, 230, 0, 100)
    local Uncheck = self:createOptionButton(Window, "Uncheck", UDim2.new(0, 7, 0, 76), "http://www.roblox.com/asset/?id=6031094678", Color3.fromRGB(255, 84, 84))
    local Check = self:createOptionButton(Window, "Check", UDim2.new(0, 28, 0, 76), "http://www.roblox.com/asset/?id=6031094667", Color3.fromRGB(83, 230, 50))

    local function handleOptionClick(isChecked)
        pcall(function()
            Callback(isChecked)
        end)
        ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
        wait(0.2)
        ambientShadow:Destroy()
    end

    Uncheck.MouseButton1Click:Connect(function() handleOptionClick(false) end)
    Check.MouseButton1Click:Connect(function() handleOptionClick(true) end)

    Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Time)
    wait(Time)
    ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
    wait(0.2)
    ambientShadow:Destroy()
end

function Notification:createOptionButton(Window, Name, Position, Image, ImageColor)
    local Button = Instance.new("ImageButton")
    Button.Name = Name
    Button.Parent = Window
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 1.000
    Button.BorderSizePixel = 0
    Button.Position = Position
    Button.Size = UDim2.new(0, 18, 0, 18)
    Button.ZIndex = 5
    Button.AutoButtonColor = false
    Button.Image = Image
    Button.ImageColor3 = ImageColor
    return Button
end

return Notification
