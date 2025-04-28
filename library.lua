local UILibrary = {}

-- Helper functions
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function createRoundedFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Size = size
    frame.Position = position
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    return frame
end

local function animateHover(element, isHovering)
    local targetColor = isHovering and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 40, 40)
    TweenService:Create(element, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end

-- Toggle Component
function UILibrary.Toggle(parent, config)
    local toggleFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 120, 0, 40), config.Position or UDim2.new(0, 0, 0, 0))
    toggleFrame.Name = "Toggle"
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local stateIndicator = Instance.new("Frame")
    stateIndicator.Size = UDim2.new(0, 20, 0, 20)
    stateIndicator.Position = UDim2.new(0, 10, 0.5, -10)
    stateIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    stateIndicator.BorderSizePixel = 0
    stateIndicator.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = stateIndicator
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local isToggled = config.Default or false
    
    local function updateState()
        local targetColor = isToggled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        local targetPos = isToggled and UDim2.new(1, -30, 0.5, -10) or UDim2.new(0, 10, 0.5, -10)
        
        TweenService:Create(stateIndicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(stateIndicator, TweenInfo.new(0.2), {Position = targetPos}):Play()
        
        if config.Callback then
            config.Callback(isToggled)
        end
    end
    
    toggleButton.MouseButton1Click:function()
        isToggled = not isToggled
        updateState()
    end
    
    toggleButton.MouseEnter:Connect(function()
        animateHover(toggleFrame, true)
    end)
    
    toggleButton.MouseLeave:Connect(function()
        animateHover(toggleFrame, false)
    end)
    
    updateState()
    
    return {
        SetState = function(self, state)
            isToggled = state
            updateState()
        end,
        GetState = function(self)
            return isToggled
        end
    }
end

-- Checkbox Component
function UILibrary.Checkbox(parent, config)
    local checkboxFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 120, 0, 40), config.Position or UDim2.new(0, 0, 0, 0))
    checkboxFrame.Name = "Checkbox"
    
    local checkboxButton = Instance.new("TextButton")
    checkboxButton.Size = UDim2.new(1, 0, 1, 0)
    checkboxButton.BackgroundTransparency = 1
    checkboxButton.Text = ""
    checkboxButton.Parent = checkboxFrame
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 10, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BorderSizePixel = 0
    box.Parent = checkboxFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = box
    
    local checkmark = Instance.new("ImageLabel")
    checkmark.Size = UDim2.new(0, 14, 0, 14)
    checkmark.Position = UDim2.new(0.5, -7, 0.5, -7)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://3926305904"
    checkmark.ImageRectOffset = Vector2.new(564, 284)
    checkmark.ImageRectSize = Vector2.new(36, 36)
    checkmark.ImageColor3 = Color3.fromRGB(0, 200, 100)
    checkmark.Visible = false
    checkmark.Parent = box
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Checkbox"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkboxFrame
    
    local isChecked = config.Default or false
    
    local function updateState()
        checkmark.Visible = isChecked
        if config.Callback then
            config.Callback(isChecked)
        end
    end
    
    checkboxButton.MouseButton1Click:function()
        isChecked = not isChecked
        updateState()
    end
    
    checkboxButton.MouseEnter:Connect(function()
        animateHover(checkboxFrame, true)
    end)
    
    checkboxButton.MouseLeave:Connect(function()
        animateHover(checkboxFrame, false)
    end)
    
    updateState()
    
    return {
        SetState = function(self, state)
            isChecked = state
            updateState()
        end,
        GetState = function(self)
            return isChecked
        end
    }
end

-- Slider Component
function UILibrary.Slider(parent, config)
    local sliderFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 200, 0, 60), config.Position or UDim2.new(0, 0, 0, 0))
    sliderFrame.Name = "Slider"
    sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = config.Text or "Slider"
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = sliderFrame
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 40, 0, 20)
    valueText.Position = UDim2.new(1, -50, 0, 5)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(config.Default or config.Min or 0)
    valueText.TextColor3 = Color3.fromRGB(150, 150, 150)
    valueText.Font = Enum.Font.Gotham
    valueText.TextSize = 14
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 35)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = config.FillColor or Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0, -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or min
    local isDragging = false
    
    local function updateSlider()
        local ratio = (value - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -8, 0.5, -8)
        valueText.Text = string.format("%.1f", value)
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    local function calculateValue(x)
        local relativeX = x - track.AbsolutePosition.X
        local ratio = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
        return min + (max - min) * ratio
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            value = calculateValue(input.Position.X)
            updateSlider()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            value = calculateValue(input.Position.X)
            updateSlider()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    updateSlider()
    
    return {
        SetValue = function(self, newValue)
            value = math.clamp(newValue, min, max)
            updateSlider()
        end,
        GetValue = function(self)
            return value
        end
    }
end

-- Button Component
function UILibrary.Button(parent, config)
    local buttonFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 120, 0, 40), config.Position or UDim2.new(0, 0, 0, 0))
    buttonFrame.Name = "Button"
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = config.Text or "Button"
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = buttonFrame
    
    local function animateClick()
        TweenService:Create(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0.95, 0)}):Play()
        TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size = config.Size or UDim2.new(0, 120, 0, 40)}):Play()
    end
    
    button.MouseButton1Click:Connect(function()
        animateClick()
        if config.Callback then
            config.Callback()
        end
    end)
    
    button.MouseEnter:Connect(function()
        animateHover(buttonFrame, true)
    end)
    
    button.MouseLeave:Connect(function()
        animateHover(buttonFrame, false)
    end)
    
    return {
        SetText = function(self, text)
            button.Text = text
        end,
        SetCallback = function(self, callback)
            config.Callback = callback
        end
    }
end

-- Label Component
function UILibrary.Label(parent, config)
    local label = Instance.new("TextLabel")
    label.Size = config.Size or UDim2.new(1, 0, 0, 20)
    label.Position = config.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Label"
    label.TextColor3 = config.TextColor or Color3.fromRGB(200, 200, 200)
    label.Font = config.Font or Enum.Font.Gotham
    label.TextSize = config.TextSize or 14
    label.TextXAlignment = config.XAlign or Enum.TextXAlignment.Left
    label.TextYAlignment = config.YAlign or Enum.TextYAlignment.Center
    label.Parent = parent
    
    return {
        SetText = function(self, text)
            label.Text = text
        end,
        SetColor = function(self, color)
            label.TextColor3 = color
        end
    }
end

-- Paragraph Component
function UILibrary.Paragraph(parent, config)
    local paragraph = Instance.new("TextLabel")
    paragraph.Size = config.Size or UDim2.new(1, -20, 0, 60)
    paragraph.Position = config.Position or UDim2.new(0, 10, 0, 0)
    paragraph.BackgroundTransparency = 1
    paragraph.Text = config.Text or "Paragraph text goes here. This component is useful for displaying longer blocks of text."
    paragraph.TextColor3 = config.TextColor or Color3.fromRGB(180, 180, 180)
    paragraph.Font = config.Font or Enum.Font.Gotham
    paragraph.TextSize = config.TextSize or 12
    paragraph.TextXAlignment = Enum.TextXAlignment.Left
    paragraph.TextYAlignment = Enum.TextYAlignment.Top
    paragraph.TextWrapped = true
    paragraph.Parent = parent
    
    return {
        SetText = function(self, text)
            paragraph.Text = text
        end
    }
end

-- Color Picker Component
function UILibrary.ColorPicker(parent, config)
    local colorFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 180, 0, 180), config.Position or UDim2.new(0, 0, 0, 0))
    colorFrame.Name = "ColorPicker"
    colorFrame.ClipsDescendants = true
    
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(0, 20, 1, -10)
    hueSlider.Position = UDim2.new(1, -25, 0, 5)
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel = 0
    hueSlider.Parent = colorFrame
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueSlider
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueSlider
    
    local hueSelector = Instance.new("Frame")
    hueSelector.Size = UDim2.new(1, 0, 0, 4)
    hueSelector.Position = UDim2.new(0, 0, 0, 0)
    hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSelector.BorderSizePixel = 0
    hueSelector.Parent = hueSlider
    
    local hueSelectorCorner = Instance.new("UICorner")
    hueSelectorCorner.CornerRadius = UDim.new(0, 2)
    hueSelectorCorner.Parent = hueSelector
    
    local saturationValueBox = Instance.new("ImageLabel")
    saturationValueBox.Size = UDim2.new(1, -30, 1, -10)
    saturationValueBox.Position = UDim2.new(0, 5, 0, 5)
    saturationValueBox.BackgroundColor3 = Color3.new(1, 0, 0)
    saturationValueBox.BorderSizePixel = 0
    saturationValueBox.Image = "rbxassetid://4155801252"
    saturationValueBox.Parent = colorFrame
    
    local selector = Instance.new("Frame")
    selector.Size = UDim2.new(0, 8, 0, 8)
    selector.Position = UDim2.new(0.5, -4, 0.5, -4)
    selector.BackgroundTransparency = 1
    selector.BackgroundColor3 = Color3.new(1, 1, 1)
    selector.BorderColor3 = Color3.new(0, 0, 0)
    selector.BorderSizePixel = 1
    selector.Parent = saturationValueBox
    
    local selectorCorner = Instance.new("UICorner")
    selectorCorner.CornerRadius = UDim.new(1, 0)
    selectorCorner.Parent = selector
    
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1
    local isDraggingHue = false
    local isDraggingSV = false
    
    local function updateColor()
        local color = Color3.fromHSV(currentHue, currentSat, currentVal)
        saturationValueBox.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        
        if config.Callback then
            config.Callback(color)
        end
    end
    
    local function calculateHue(y)
        local relativeY = y - hueSlider.AbsolutePosition.Y
        return 1 - math.clamp(relativeY / hueSlider.AbsoluteSize.Y, 0, 1)
    end
    
    local function calculateSV(x, y)
        local relativeX = x - saturationValueBox.AbsolutePosition.X
        local relativeY = y - saturationValueBox.AbsolutePosition.Y
        return math.clamp(relativeX / saturationValueBox.AbsoluteSize.X, 0, 1),
              1 - math.clamp(relativeY / saturationValueBox.AbsoluteSize.Y, 0, 1)
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            currentHue = calculateHue(input.Position.Y)
            hueSelector.Position = UDim2.new(0, 0, currentHue, -2)
            updateColor()
        end
    end)
    
    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSV = true
            currentSat, currentVal = calculateSV(input.Position.X, input.Position.Y)
            selector.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
            updateColor()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if isDraggingHue then
                currentHue = calculateHue(input.Position.Y)
                hueSelector.Position = UDim2.new(0, 0, currentHue, -2)
                updateColor()
            elseif isDraggingSV then
                currentSat, currentVal = calculateSV(input.Position.X, input.Position.Y)
                selector.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
                updateColor()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = false
            isDraggingSV = false
        end
    end)
    
    updateColor()
    
    return {
        SetColor = function(self, color)
            currentHue, currentSat, currentVal = Color3.toHSV(color)
            hueSelector.Position = UDim2.new(0, 0, currentHue, -2)
            selector.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
            updateColor()
        end,
        GetColor = function(self)
            return Color3.fromHSV(currentHue, currentSat, currentVal)
        end
    }
end

-- Dropdown Component
function UILibrary.Dropdown(parent, config)
    local dropdownFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 160, 0, 40), config.Position or UDim2.new(0, 0, 0, 0))
    dropdownFrame.Name = "Dropdown"
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = config.Text or "Select..."
    dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 14
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.Parent = dropdownFrame
    
    local dropdownIcon = Instance.new("ImageLabel")
    dropdownIcon.Size = UDim2.new(0, 16, 0, 16)
    dropdownIcon.Position = UDim2.new(1, -25, 0.5, -8)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Image = "rbxassetid://3926305904"
    dropdownIcon.ImageRectOffset = Vector2.new(324, 364)
    dropdownIcon.ImageRectSize = Vector2.new(36, 36)
    dropdownIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    dropdownIcon.Parent = dropdownFrame
    
    local optionsFrame = createRoundedFrame(parent, UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0), UDim2.new(0, dropdownFrame.AbsolutePosition.X, 0, dropdownFrame.AbsolutePosition.Y + dropdownFrame.AbsoluteSize.Y + 5))
    optionsFrame.Name = "DropdownOptions"
    optionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    optionsFrame.Visible = false
    optionsFrame.ClipsDescendants = true
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.Padding = UDim.new(0, 2)
    optionsList.Parent = optionsFrame
    
    local isOpen = false
    local selectedIndex = 0
    
    local function toggleDropdown()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        
        if isOpen then
            TweenService:Create(optionsFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, #config.Options * 32 + 4)}):Play()
            TweenService:Create(dropdownIcon, TweenInfo.new(0.2), {Rotation = 180}):Play()
        else
            TweenService:Create(optionsFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0)}):Play()
            TweenService:Create(dropdownIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
        end
    end
    
    local function createOption(index, option)
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -10, 0, 30)
        optionButton.Position = UDim2.new(0, 5, 0, index * 32 - 28)
        optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Parent = optionsFrame
        
        optionButton.MouseButton1Click:Connect(function()
            selectedIndex = index
            dropdownButton.Text = option
            toggleDropdown()
            if config.Callback then
                config.Callback(option, index)
            end
        end)
        
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
    end
    
    for i, option in ipairs(config.Options or {}) do
        createOption(i, option)
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    dropdownButton.MouseEnter:Connect(function()
        animateHover(dropdownFrame, true)
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        animateHover(dropdownFrame, false)
    end)
    
    return {
        SetOptions = function(self, newOptions)
            config.Options = newOptions
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for i, option in ipairs(newOptions) do
                createOption(i, option)
            end
        end,
        Select = function(self, index)
            if index > 0 and index <= #config.Options then
                selectedIndex = index
                dropdownButton.Text = config.Options[index]
                if config.Callback then
                    config.Callback(config.Options[index], index)
                end
            end
        end,
        GetSelected = function(self)
            return selectedIndex > 0 and config.Options[selectedIndex] or nil, selectedIndex
        end
    }
end

-- Input Component
function UILibrary.Input(parent, config)
    local inputFrame = createRoundedFrame(parent, config.Size or UDim2.new(0, 200, 0, 40), config.Position or UDim2.new(0, 0, 0, 0))
    inputFrame.Name = "Input"
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = config.Text or ""
    textBox.PlaceholderText = config.Placeholder or "Enter text..."
    textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = config.ClearOnFocus or false
    textBox.Parent = inputFrame
    
    local function onFocus()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end
    
    local function onFocusLost()
        TweenService:Create(inputFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        if config.Callback then
            config.Callback(textBox.Text)
        end
    end
    
    textBox.Focused:Connect(onFocus)
    textBox.FocusLost:Connect(onFocusLost)
    
    return {
        SetText = function(self, text)
            textBox.Text = text
        end,
        GetText = function(self)
            return textBox.Text
        end
    }
end

return UILibrary