local ErrorLogger = {}
ErrorLogger.__index = ErrorLogger

function ErrorLogger.new()
    local self = setmetatable({
        errors = {}
    }, ErrorLogger)
    return self
end

function ErrorLogger:logError(errorMessage)
    table.insert(self.errors, {
        message = errorMessage,
        time = os.clock()
    })
    self:showErrorNotification(errorMessage)
end

function ErrorLogger:showErrorNotification(errorMessage)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ErrorNotification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0.8 * game:GetService("Workspace").CurrentCamera.ViewportSize.X, 0, 0.2 * game:GetService("Workspace").CurrentCamera.ViewportSize.Y)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.15
    frame.ClipsDescendants = true
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 5, 0, 5)
    shadow.Image = "rbxassetid://6235572087"
    shadow.ImageTransparency = 0.5
    shadow.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0.6, -10)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.Text = errorMessage
    textBox.TextWrapped = true
    textBox.TextEditable = false
    textBox.ClearTextOnFocus = false
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Parent = frame

    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.4, -10, 0.2, -5)
    copyButton.Position = UDim2.new(0.05, 0, 0.7, 0)
    copyButton.Text = "Copy Error"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyButton.BorderSizePixel = 0
    copyButton.Font = Enum.Font.SourceSans
    copyButton.TextSize = 14
    copyButton.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.4, -10, 0.2, -5)
    closeButton.Position = UDim2.new(0.55, 0, 0.7, 0)
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 14
    closeButton.Parent = frame

    frame:TweenPosition(UDim2.new(0.5, -frame.Size.X.Offset / 2, 0.5, -frame.Size.Y.Offset / 2), "Out", "Quad", 0.3, true)
    frame.BackgroundTransparency = 0.8
    frame:TweenBackgroundTransparency(0.2, "Out", "Quad", 0.3, true)

    copyButton.MouseEnter:Connect(function()
        copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    copyButton.MouseLeave:Connect(function()
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    copyButton.MouseButton1Click:Connect(function()
        setclipboard(errorMessage)
        copyButton.Text = "Copied!"
        wait(1)
        copyButton.Text = "Copy Error"
    end)

    closeButton.MouseButton1Click:Connect(function()
        frame:TweenPosition(UDim2.new(0.5, -frame.Size.X.Offset / 2, 1, 0), "Out", "Quad", 0.3, true)
        wait(0.3)
        screenGui:Destroy()
    end)

    task.spawn(function()
        wait(5)
        frame:TweenPosition(UDim2.new(0.5, -frame.Size.X.Offset / 2, 1, 0), "Out", "Quad", 0.3, true)
        wait(0.3)
        screenGui:Destroy()
    end)
end

return ErrorLogger