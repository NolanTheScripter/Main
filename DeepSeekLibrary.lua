local UILibrary = {}
UILibrary.__index = UILibrary

-- Theme configuration with more customization options
local Theme = {
    Window = {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(0, 400, 0, 500),
        Name = {
            TextColor = Color3.new(1, 1, 1),
            Height = 40,
            Font = Enum.Font.GothamBold,
            TextSize = 18
        }
    },
    Tab = {
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Height = 40,
        TextColor = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 14
    },
    Section = {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Spacing = 5,
        Padding = 10,
        Name = {
            TextColor = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16
        }
    },
    Button = {
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        HoverColor = Color3.fromRGB(90, 90, 90),
        PressedColor = Color3.fromRGB(50, 50, 50),
        TextColor = Color3.new(1, 1, 1),
        Height = 30,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        CornerRadius = UDim.new(0, 4)
    },
    Dropdown = {
        OptionHeight = 30,
        MaxVisibleOptions = 5,
        Background = Color3.fromRGB(60, 60, 60),
        HoverColor = Color3.fromRGB(80, 80, 80)
    },
    Toggle = {
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        OnColor = Color3.fromRGB(0, 170, 255),
        OffColor = Color3.fromRGB(120, 120, 120),
        Size = UDim2.new(0, 50, 0, 25)
    },
    Slider = {
        TrackHeight = 5,
        TrackColor = Color3.fromRGB(100, 100, 100),
        FillColor = Color3.fromRGB(0, 170, 255),
        HandleColor = Color3.fromRGB(200, 200, 200),
        HandleSize = 15
    },
    TextBox = {
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        TextColor = Color3.new(1, 1, 1),
        PlaceholderColor = Color3.fromRGB(180, 180, 180),
        Height = 30
    },
    Label = {
        TextColor = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 14
    },
    Divider = {
        Color = Color3.fromRGB(100, 100, 100),
        Thickness = 1
    }
}

-- Helper function to create rounded corners
local function ApplyCornerRadius(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 4)
    corner.Parent = instance
    return corner
end

-- Helper function to create instances with theme and custom properties
local function CreateInstance(className, props, theme)
    local instance = Instance.new(className)
    
    -- Apply theme properties first
    if theme then
        for prop, value in pairs(theme) do
            if instance[prop] ~= nil then
                instance[prop] = value
            end
        end
    end
    
    -- Apply custom properties
    if props then
        for prop, value in pairs(props) do
            instance[prop] = value
        end
    end
    
    -- Apply corner radius if it's a Frame or TextButton
    if (className == "Frame" or className == "TextButton") and theme and theme.CornerRadius then
        ApplyCornerRadius(instance, theme.CornerRadius)
    end
    
    return instance
end

-- Layout management with padding and spacing
local function AddListLayout(parent, padding, paddingOffset)
    local layout = Instance.new("UIListLayout")
    layout.Parent = parent
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or Theme.Section.Spacing)
    
    local paddingInst = Instance.new("UIPadding")
    paddingInst.Parent = parent
    paddingInst.PaddingLeft = UDim.new(0, paddingOffset or Theme.Section.Padding)
    paddingInst.PaddingRight = UDim.new(0, paddingOffset or Theme.Section.Padding)
    paddingInst.PaddingTop = UDim.new(0, Theme.Section.Padding)
    paddingInst.PaddingBottom = UDim.new(0, Theme.Section.Padding)
    
    return layout
end

-- Window management
function UILibrary:CreateWindow(options)
    options = options or {}
    local window = setmetatable({}, self)
    
    window.Gui = CreateInstance("ScreenGui", {
        Name = options.Title or "Window",
        Parent = options.Parent or game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = options.ResetOnSpawn or false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    window.MainFrame = CreateInstance("Frame", {
        Name = "MainWindow",
        Parent = window.Gui,
        Size = options.Size or Theme.Window.Size,
        BackgroundColor3 = Theme.Window.Background,
        Position = options.Position or UDim2.new(0.5, -200, 0.5, -250),
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, Theme.Window)
    
    ApplyCornerRadius(window.MainFrame)
    
    window.Title = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = window.MainFrame,
        Text = options.Title or "Window",
        Size = UDim2.new(1, 0, 0, Theme.Window.Title.Height),
        TextColor3 = Theme.Window.Title.TextColor,
        BackgroundTransparency = 1,
        Font = Theme.Window.Title.Font,
        TextSize = Theme.Window.Title.TextSize
    })
    
    window.ContentFrame = CreateInstance("Frame", {
        Name = "Content",
        Parent = window.MainFrame,
        Position = UDim2.new(0, 0, 0, Theme.Window.Title.Height),
        Size = UDim2.new(1, 0, 1, -Theme.Window.Title.Height),
        BackgroundTransparency = 1
    })
    
    AddListLayout(window.ContentFrame)
    
    function window:CreateTab(title)
        return self:CreateTab(title)
    end
    
    return window
end

-- Tab management
function UILibrary:CreateTab(title)
    local tab = setmetatable({}, self)
    
    tab.Frame = CreateInstance("Frame", {
        Name = "Tab_" .. title,
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 0, Theme.Tab.Height),
        BackgroundColor3 = Theme.Tab.Background
    })
    
    tab.Title = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = tab.Frame,
        Text = title,
        Size = UDim2.new(1, 0, 1, 0),
        TextColor3 = Theme.Tab.TextColor,
        BackgroundTransparency = 1,
        Font = Theme.Tab.Font,
        TextSize = Theme.Tab.TextSize
    })
    
    tab.ContentFrame = CreateInstance("Frame", {
        Name = "Content",
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 1, -Theme.Tab.Height),
        BackgroundTransparency = 1
    })
    
    AddListLayout(tab.ContentFrame)
    
    function tab:CreateSection(title)
        return self:CreateSection(title)
    end
    
    return tab
end

-- Section management
function UILibrary:CreateSection(title)
    local section = setmetatable({}, self)
    
    section.Frame = CreateInstance("Frame", {
        Name = "Section_" .. (title or "Untitled"),
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Section.Background,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    AddListLayout(section.Frame)
    
    if title then
        section.Title = CreateInstance("TextLabel", {
            Name = "Title",
            Parent = section.Frame,
            Text = title,
            Size = UDim2.new(1, 0, 0, Theme.Window.Title.Height),
            TextColor3 = Theme.Section.Title.TextColor,
            BackgroundTransparency = 1,
            Font = Theme.Section.Title.Font,
            TextSize = Theme.Section.Title.TextSize
        })
    end
    
    -- Button component
    function section:CreateButton(text, callback)
        local button = CreateInstance("TextButton", {
            Name = "Button_" .. text,
            Text = text,
            Size = UDim2.new(1, 0, 0, Theme.Button.Height),
            BackgroundColor3 = Theme.Button.Background,
            TextColor3 = Theme.Button.TextColor,
            Font = Theme.Button.Font,
            TextSize = Theme.Button.TextSize,
            AutoButtonColor = false
        }, Theme.Button)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Theme.Button.HoverColor
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = Theme.Button.Background
        end)
        
        button.MouseButton1Down:Connect(function()
            button.BackgroundColor3 = Theme.Button.PressedColor
        end)
        
        button.MouseButton1Up:Connect(function()
            button.BackgroundColor3 = Theme.Button.HoverColor
        end)
        
        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        button.Parent = self.Frame
        return button
    end
    
    -- Label component
    function section:CreateLabel(text)
        local label = CreateInstance("TextLabel", {
            Name = "Label_" .. text,
            Text = text,
            Size = UDim2.new(1, 0, 0, Theme.Button.Height),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Label.TextColor,
            Font = Theme.Label.Font,
            TextSize = Theme.Label.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        label.Parent = self.Frame
        return label
    end
    
    -- Toggle component
    function section:CreateToggle(text, default, callback)
        local toggle = CreateInstance("Frame", {
            Name = "Toggle_" .. text,
            Size = UDim2.new(1, 0, 0, Theme.Button.Height),
            BackgroundTransparency = 1
        })
        
        local label = CreateInstance("TextLabel", {
            Name = "Label",
            Text = text,
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Label.TextColor,
            Font = Theme.Label.Font,
            TextSize = Theme.Label.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left
        }, toggle)
        
        local toggleFrame = CreateInstance("Frame", {
            Name = "ToggleFrame",
            Size = Theme.Toggle.Size,
            Position = UDim2.new(1, -Theme.Toggle.Size.X.Offset, 0.5, -Theme.Toggle.Size.Y.Offset/2),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = default and Theme.Toggle.OnColor or Theme.Toggle.OffColor
        }, toggle)
        
        ApplyCornerRadius(toggleFrame, UDim.new(0, Theme.Toggle.Size.Y.Offset/2))
        
        local toggleButton = CreateInstance("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, toggleFrame)
        
        local state = default or false
        
        local function updateToggle()
            toggleFrame.BackgroundColor3 = state and Theme.Toggle.OnColor or Theme.Toggle.OffColor
            if callback then callback(state) end
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
        
        toggle.Parent = self.Frame
        return {
            Set = function(value)
                state = value
                updateToggle()
            end,
            Get = function()
                return state
            end
        }
    end
    
    -- Slider component
    function section:CreateSlider(options)
        options = options or {}
        options.Min = options.Min or 0
        options.Max = options.Max or 100
        options.Default = options.Default or options.Min
        options.Precision = options.Precision or 0
        options.Suffix = options.Suffix or ""
        
        local slider = CreateInstance("Frame", {
            Name = "Slider",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1
        })
        
        local track = CreateInstance("Frame", {
            Name = "Track",
            Size = UDim2.new(1, 0, 0, Theme.Slider.TrackHeight),
            Position = UDim2.new(0, 0, 0.5, -Theme.Slider.TrackHeight/2),
            BackgroundColor3 = Theme.Slider.TrackColor
        }, slider)
        
        ApplyCornerRadius(track, UDim.new(0, Theme.Slider.TrackHeight/2))
        
        local fill = CreateInstance("Frame", {
            Name = "Fill",
            Size = UDim2.new((options.Default - options.Min)/(options.Max - options.Min), 0, 1, 0),
            BackgroundColor3 = Theme.Slider.FillColor
        }, track)
        
        ApplyCornerRadius(fill, UDim.new(0, Theme.Slider.TrackHeight/2))
        
        local handle = CreateInstance("Frame", {
            Name = "Handle",
            Size = UDim2.new(0, Theme.Slider.HandleSize, 0, Theme.Slider.HandleSize),
            Position = UDim2.new((options.Default - options.Min)/(options.Max - options.Min), -Theme.Slider.HandleSize/2, 0.5, -Theme.Slider.HandleSize/2),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Slider.HandleColor
        }, slider)
        
        ApplyCornerRadius(handle, UDim.new(0, Theme.Slider.HandleSize/2))
        
        local valueLabel = CreateInstance("TextLabel", {
            Name = "Value",
            Text = string.format("%."..options.Precision.."f", options.Default) .. options.Suffix,
            Size = UDim2.new(0, 80, 0, Theme.Button.Height),
            Position = UDim2.new(1, -80, 0, 0),
            TextColor3 = Theme.Label.TextColor,
            BackgroundTransparency = 1,
            Font = Theme.Label.Font,
            TextSize = Theme.Label.TextSize,
            TextXAlignment = Enum.TextXAlignment.Right
        }, slider)
        
        local isDragging = false
        
        local function updateValue(percent)
            percent = math.clamp(percent, 0, 1)
            local value = options.Min + (options.Max - options.Min) * percent
            local formattedValue = string.format("%."..options.Precision.."f", value) .. options.Suffix
            valueLabel.Text = formattedValue
            fill.Size = UDim2.new(percent, 0, 1, 0)
            handle.Position = UDim2.new(percent, -Theme.Slider.HandleSize/2, 0.5, -Theme.Slider.HandleSize/2)
            if options.Callback then options.Callback(value) end
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                local percent = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                updateValue(percent)
            end
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                local relativeX = mousePos.X - track.AbsolutePosition.X
                local percent = relativeX / track.AbsoluteSize.X
                updateValue(percent)
            end
        end)
        
        slider.Parent = self.Frame
        return {
            Set = function(value)
                local percent = (value - options.Min)/(options.Max - options.Min)
                updateValue(percent)
            end,
            Get = function()
                return tonumber(string.match(valueLabel.Text, "[%d%.]+"))
            end
        }
    end
    
    -- Dropdown component
    function section:CreateDropdown(options)
        options = options or {}
        options.Options = options.Options or {}
        options.Default = options.Default or (options.Options[1] or "Select")
        
        local dropdown = CreateInstance("Frame", {
            Name = "Dropdown",
            Size = UDim2.new(1, 0, 0, Theme.Button.Height),
            BackgroundTransparency = 1
        })
        
        local mainButton = CreateInstance("TextButton", {
            Name = "MainButton",
            Size = UDim2.new(1, 0, 1, 0),
            Text = options.Default,
            BackgroundColor3 = Theme.Button.Background,
            TextColor3 = Theme.Button.TextColor,
            Font = Theme.Button.Font,
            TextSize = Theme.Button.TextSize
        }, dropdown)
        
        ApplyCornerRadius(mainButton)
        
        local optionsFrame = CreateInstance("Frame", {
            Name = "Options",
            Position = UDim2.new(0, 0, 1, 5),
            Size = UDim2.new(1, 0, 0, math.min(#options.Options, Theme.Dropdown.MaxVisibleOptions) * Theme.Dropdown.OptionHeight),
            BackgroundColor3 = Theme.Dropdown.Background,
            Visible = false,
            ClipsDescendants = true
        }, dropdown)
        
        ApplyCornerRadius(optionsFrame)
        
        local optionsListLayout = Instance.new("UIListLayout")
        optionsListLayout.Parent = optionsFrame
        optionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function toggleOptions()
            optionsFrame.Visible = not optionsFrame.Visible
        end
        
        mainButton.MouseButton1Click:Connect(toggleOptions)
        
        for _, option in ipairs(options.Options) do
            local optionButton = CreateInstance("TextButton", {
                Name = option,
                Size = UDim2.new(1, 0, 0, Theme.Dropdown.OptionHeight),
                Text = option,
                BackgroundColor3 = Theme.Dropdown.Background,
                TextColor3 = Theme.Button.TextColor,
                Font = Theme.Button.Font,
                TextSize = Theme.Button.TextSize,
                AutoButtonColor = false
            })
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Theme.Dropdown.HoverColor
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Theme.Dropdown.Background
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                mainButton.Text = option
                optionsFrame.Visible = false
                if options.Callback then options.Callback(option) end
            end)
            
            optionButton.Parent = optionsFrame
        end
        
        -- Close dropdown when clicking outside
        local dropdownConnection
        dropdownConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and optionsFrame.Visible then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                if not optionsFrame.AbsoluteRect:Contains(mousePos) and not mainButton.AbsoluteRect:Contains(mousePos) then
                    optionsFrame.Visible = false
                end
            end
        end)
        
        dropdown.Parent = self.Frame
        return {
            Set = function(option)
                if table.find(options.Options, option) then
                    mainButton.Text = option
                    if options.Callback then options.Callback(option) end
                end
            end,
            Get = function()
                return mainButton.Text
            end,
            Destroy = function()
                dropdownConnection:Disconnect()
                dropdown:Destroy()
            end
        }
    end
    
    -- TextBox component
    function section:CreateTextBox(options)
        options = options or {}
        
        local textBoxFrame = CreateInstance("Frame", {
            Name = "TextBox",
            Size = UDim2.new(1, 0, 0, Theme.TextBox.Height),
            BackgroundTransparency = 1
        })
        
        local textBox = CreateInstance("TextBox", {
            Name = "Input",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.TextBox.Background,
            TextColor3 = Theme.TextBox.TextColor,
            PlaceholderColor3 = Theme.TextBox.PlaceholderColor,
            PlaceholderText = options.Placeholder or "Enter text...",
            Text = options.Text or "",
            ClearTextOnFocus = options.ClearTextOnFocus or false,
            Font = Theme.Label.Font,
            TextSize = Theme.Label.TextSize
        }, textBoxFrame)
        
        ApplyCornerRadius(textBox)
        
        if options.Callback then
            textBox.FocusLost:Connect(function(enterPressed)
                options.Callback(textBox.Text, enterPressed)
            end)
        end
        
        textBoxFrame.Parent = self.Frame
        return {
            Set = function(text)
                textBox.Text = text
            end,
            Get = function()
                return textBox.Text
            end
        }
    end
    
    -- Divider component
    function section:CreateDivider()
        local divider = CreateInstance("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, Theme.Divider.Thickness),
            BackgroundColor3 = Theme.Divider.Color,
            BorderSizePixel = 0
        })
        
        divider.Parent = self.Frame
        return divider
    end
    
    -- Keybind component
    function section:CreateKeybind(options)
        options = options or {}
        options.Default = options.Default or Enum.KeyCode.Unknown
        
        local keybind = CreateInstance("Frame", {
            Name = "Keybind",
            Size = UDim2.new(1, 0, 0, Theme.Button.Height),
            BackgroundTransparency = 1
        })
        
        local label = CreateInstance("TextLabel", {
            Name = "Label",
            Text = options.Text or "Keybind",
            Size = UDim2.new(0.7, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Label.TextColor,
            Font = Theme.Label.Font,
            TextSize = Theme.Label.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left
        }, keybind)
        
        local button = CreateInstance("TextButton", {
            Name = "Button",
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            Text = options.Default.Name,
            BackgroundColor3 = Theme.Button.Background,
            TextColor3 = Theme.Button.TextColor,
            Font = Theme.Button.Font,
            TextSize = Theme.Button.TextSize
        }, keybind)
        
        ApplyCornerRadius(button)
        
        local currentKey = options.Default
        local listening = false
        
        local function setKey(key)
            currentKey = key
            button.Text = key.Name
            if options.Callback then options.Callback(key) end
        end
        
        button.MouseButton1Click:Connect(function()
            listening = true
            button.Text = "..."
        end)
        
        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if listening and not gameProcessed then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    setKey(input.KeyCode)
                    listening = false
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setKey(Enum.KeyCode.Unknown)
                    listening = false
                end
            end
        end)
        
        keybind.Parent = self.Frame
        return {
            Set = function(key)
                setKey(key)
            end,
            Get = function()
                return currentKey
            end,
            Destroy = function()
                connection:Disconnect()
                keybind:Destroy()
            end
        }
    end
    
    return section
end

return UILibrary