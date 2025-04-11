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
    frame.Size = UDim2.new(0, 400, 0, 150)
    frame.Position = UDim2.new(0.5, -200, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.Parent = screenGui

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0.6, -10)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.Text = errorMessage
    textBox.TextWrapped = true
    textBox.TextEditable = false
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame

    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.4, -10, 0.2, -5)
    copyButton.Position = UDim2.new(0.05, 0, 0.7, 0)
    copyButton.Text = "Copy Error"
    copyButton.Parent = frame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.4, -10, 0.2, -5)
    closeButton.Position = UDim2.new(0.55, 0, 0.7, 0)
    closeButton.Text = "Close"
    closeButton.Parent = frame
    copyButton.MouseButton1Click:Connect(function() 
        textBox:CaptureFocus()
    end)
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

return ErrorLogger