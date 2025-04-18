local UILibrary = {}
UILibrary.__index = UILibrary

--[[
    ====== THEME SYSTEM ======
]]
local Theme = {
    Primary = {
        Background = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Highlight = Color3.fromRGB(0, 120, 215)
    },
    Secondary = {
        Background = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(220, 220, 220)
    },
    Accent = {
        Background = Color3.fromRGB(70, 70, 70),
        Hover = Color3.fromRGB(90, 90, 90),
        Pressed = Color3.fromRGB(50, 50, 50)
    },
    Font = {
        Header = Enum.Font.GothamBold,
        Body = Enum.Font.Gotham,
        Size = {
            Title = 18,
            Header = 16,
            Body = 14
        }
    },
    Sizing = {
        Window = UDim2.new(0, 450, 0, 600),
        TabHeight = 40,
        SectionSpacing = 5,
        SectionPadding = 10,
        ElementHeight = 30,
        CornerRadius = 4
    }
}

--[[
    ====== UTILITY FUNCTIONS ======
]]
local function Create(className, props)
    local instance = Instance.new(className)
    for prop, value in pairs(props) do
        if prop == "Children" then
            for _, child in ipairs(value) do
                child.Parent = instance
            end
        else
            local success, _ = pcall(function()
                instance[prop] = value
            end)
            if not success then
                warn(`Failed to set property {prop} on {className}`)
            end
        end
    end
    return instance
end

local function ApplyTheme(instance, theme)
    for prop, value in pairs(theme) do
        if instance[prop] ~= nil then
            instance[prop] = value
        end
    end
end

local function RoundCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Theme.Sizing.CornerRadius)
    corner.Parent = instance
    return corner
end

local function CreateLayout(parent, padding)
    local layout = Create("UIListLayout", {
        Parent = parent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or Theme.Sizing.SectionSpacing)
    })

    Create("UIPadding", {
        Parent = parent,
        PaddingLeft = UDim.new(0, Theme.Sizing.SectionPadding),
        PaddingRight = UDim.new(0, Theme.Sizing.SectionPadding),
        PaddingTop = UDim.new(0, Theme.Sizing.SectionPadding),
        PaddingBottom = UDim.new(0, Theme.Sizing.SectionPadding)
    })

    return layout
end

--[[
    ====== CORE COMPONENTS ======
]]
function UILibrary.new(options)
    options = options or {}
    local self = setmetatable({}, UILibrary)
    
    -- Create main screen GUI
    self.Gui = Create("ScreenGui", {
        Name = options.Name or "UILibrary",
        Parent = options.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = options.ResetOnSpawn or false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Create main window frame
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        Parent = self.Gui,
        Size = options.Size or Theme.Sizing.Window,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Primary.Background,
        Children = {
            Create("TextLabel", {
                Name = "Title",
                Text = options.Title or "UI Window",
                Size = UDim2.new(1, 0, 0, Theme.Sizing.TabHeight),
                TextColor3 = Theme.Primary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Header,
                TextSize = Theme.Font.Size.Title
            }),
            Create("Frame", {
                Name = "Content",
                Position = UDim2.new(0, 0, 0, Theme.Sizing.TabHeight),
                Size = UDim2.new(1, 0, 1, -Theme.Sizing.TabHeight),
                BackgroundTransparency = 1
            })
        }
    })

    RoundCorners(self.MainFrame)
    CreateLayout(self.MainFrame.Content)

    return self
end

function UILibrary:CreateTab(title)
    local tab = {
        Window = self,
        Name = title or "Tab"
    }

    -- Create tab button
    tab.Button = Create("TextButton", {
        Name = "Tab_"..tab.Name,
        Parent = self.MainFrame.Content,
        Text = tab.Name,
        Size = UDim2.new(1, 0, 0, Theme.Sizing.TabHeight),
        BackgroundColor3 = Theme.Secondary.Background,
        TextColor3 = Theme.Secondary.Text,
        Font = Theme.Font.Body,
        TextSize = Theme.Font.Size.Header
    })

    -- Create tab content frame
    tab.Content = Create("Frame", {
        Name = "Content",
        Parent = self.MainFrame.Content,
        Size = UDim2.new(1, 0, 1, -Theme.Sizing.TabHeight),
        BackgroundTransparency = 1
    })

    CreateLayout(tab.Content)

    -- Tab selection functionality
    local function ShowTab()
        for _, child in ipairs(self.MainFrame.Content:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Content" then
                child.Visible = false
            end
        end
        tab.Content.Visible = true
    end

    tab.Button.MouseButton1Click:Connect(ShowTab)
    ShowTab() -- Show this tab by default

    function tab:CreateSection(title)
        local section = {
            Tab = self,
            Title = title or ""
        }

        section.Frame = Create("Frame", {
            Name = "Section_"..section.Title,
            Parent = self.Content,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Secondary.Background,
            AutomaticSize = Enum.AutomaticSize.Y
        })

        RoundCorners(section.Frame)
        CreateLayout(section.Frame)

        if section.Title ~= "" then
            section.TitleLabel = Create("TextLabel", {
                Name = "Title",
                Parent = section.Frame,
                Text = section.Title,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.TabHeight),
                TextColor3 = Theme.Primary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Header,
                TextSize = Theme.Font.Size.Header
            })
        end

        --[[
            ====== SECTION ELEMENT CREATION METHODS ======
        ]]
        function section:CreateLabel(text)
            local label = Create("TextLabel", {
                Name = "Label_"..text,
                Parent = self.Frame,
                Text = text,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                TextColor3 = Theme.Secondary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return label
        end

        function section:CreateButton(text, callback)
            local button = Create("TextButton", {
                Name = "Button_"..text,
                Parent = self.Frame,
                Text = text,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                BackgroundColor3 = Theme.Accent.Background,
                TextColor3 = Theme.Primary.Text,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body,
                AutoButtonColor = false
            })

            RoundCorners(button)

            -- Interactive states
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Theme.Accent.Hover
            end)

            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Theme.Accent.Background
            end)

            button.MouseButton1Down:Connect(function()
                button.BackgroundColor3 = Theme.Accent.Pressed
            end)

            button.MouseButton1Up:Connect(function()
                button.BackgroundColor3 = Theme.Accent.Hover
            end)

            if callback then
                button.MouseButton1Click:Connect(callback)
            end

            return button
        end

        function section:CreateToggle(text, default, callback)
            local toggle = {
                Value = default or false,
                Callback = callback
            }

            local container = Create("Frame", {
                Name = "Toggle_"..text,
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                BackgroundTransparency = 1
            })

            local label = Create("TextLabel", {
                Name = "Label",
                Parent = container,
                Text = text,
                Size = UDim2.new(0.7, 0, 1, 0),
                TextColor3 = Theme.Secondary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local toggleFrame = Create("Frame", {
                Name = "ToggleFrame",
                Parent = container,
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -50, 0.5, -12.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = toggle.Value and Theme.Primary.Highlight or Color3.fromRGB(120, 120, 120)
            })

            RoundCorners(toggleFrame, 12)

            local toggleButton = Create("TextButton", {
                Name = "ToggleButton",
                Parent = toggleFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ""
            })

            local function UpdateToggle()
                toggleFrame.BackgroundColor3 = toggle.Value and Theme.Primary.Highlight or Color3.fromRGB(120, 120, 120)
                if toggle.Callback then
                    toggle.Callback(toggle.Value)
                end
            end

            toggleButton.MouseButton1Click:Connect(function()
                toggle.Value = not toggle.Value
                UpdateToggle()
            end)

            function toggle:Set(value)
                if type(value) == "boolean" then
                    self.Value = value
                    UpdateToggle()
                end
            end

            function toggle:Get()
                return self.Value
            end

            return toggle
        end

        function section:CreateSlider(options)
            options = options or {}
            local slider = {
                Min = options.Min or 0,
                Max = options.Max or 100,
                Value = options.Default or options.Min or 0,
                Callback = options.Callback,
                Step = options.Step or 1,
                Suffix = options.Suffix or ""
            }

            local container = Create("Frame", {
                Name = "Slider",
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1
            })

            local track = Create("Frame", {
                Name = "Track",
                Parent = container,
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 0.5, -2.5),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            })

            RoundCorners(track, 2)

            local fill = Create("Frame", {
                Name = "Fill",
                Parent = track,
                Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
                BackgroundColor3 = Theme.Primary.Highlight
            })

            RoundCorners(fill, 2)

            local handle = Create("Frame", {
                Name = "Handle",
                Parent = container,
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -7.5, 0.5, -7.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            })

            RoundCorners(handle, 7)

            local valueLabel = Create("TextLabel", {
                Name = "Value",
                Parent = container,
                Text = slider.Value..slider.Suffix,
                Size = UDim2.new(0, 80, 0, Theme.Sizing.ElementHeight),
                Position = UDim2.new(1, -80, 0, 0),
                TextColor3 = Theme.Secondary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local isDragging = false

            local function UpdateValue(percent)
                percent = math.clamp(percent, 0, 1)
                local value = slider.Min + (slider.Max - slider.Min) * percent
                value = math.floor(value / slider.Step + 0.5) * slider.Step -- Apply step
                slider.Value = value
                valueLabel.Text = value..slider.Suffix
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
                if slider.Callback then
                    slider.Callback(value)
                end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    local percent = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    UpdateValue(percent)
                end
            end)

            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)

            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position
                    local relativeX = mousePos.X - track.AbsolutePosition.X
                    local percent = relativeX / track.AbsoluteSize.X
                    UpdateValue(percent)
                end
            end)

            function slider:Set(value)
                local percent = (value - slider.Min) / (slider.Max - slider.Min)
                UpdateValue(percent)
            end

            function slider:Get()
                return slider.Value
            end

            return slider
        end

        function section:CreateDropdown(options)
            options = options or {}
            local dropdown = {
                Options = options.Options or {},
                Selected = options.Default or options.Options[1],
                Callback = options.Callback
            }

            local container = Create("Frame", {
                Name = "Dropdown",
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                BackgroundTransparency = 1
            })

            local mainButton = Create("TextButton", {
                Name = "MainButton",
                Parent = container,
                Size = UDim2.new(1, 0, 1, 0),
                Text = dropdown.Selected or "Select...",
                BackgroundColor3 = Theme.Accent.Background,
                TextColor3 = Theme.Primary.Text,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body
            })

            RoundCorners(mainButton)

            local optionsFrame = Create("Frame", {
                Name = "Options",
                Parent = container,
                Position = UDim2.new(0, 0, 1, 5),
                Size = UDim2.new(1, 0, 0, math.min(#dropdown.Options, 5) * Theme.Sizing.ElementHeight),
                BackgroundColor3 = Theme.Secondary.Background,
                Visible = false,
                ClipsDescendants = true
            })

            RoundCorners(optionsFrame)
            CreateLayout(optionsFrame, 2)

            local function ToggleOptions()
                optionsFrame.Visible = not optionsFrame.Visible
            end

            mainButton.MouseButton1Click:Connect(ToggleOptions)

            for _, option in ipairs(dropdown.Options) do
                local optionButton = Create("TextButton", {
                    Name = option,
                    Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                    Text = option,
                    BackgroundColor3 = Theme.Secondary.Background,
                    TextColor3 = Theme.Secondary.Text,
                    Font = Theme.Font.Body,
                    TextSize = Theme.Font.Size.Body,
                    AutoButtonColor = false
                })

                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = Theme.Accent.Background
                end)

                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = Theme.Secondary.Background
                end)

                optionButton.MouseButton1Click:Connect(function()
                    dropdown.Selected = option
                    mainButton.Text = option
                    optionsFrame.Visible = false
                    if dropdown.Callback then
                        dropdown.Callback(option)
                    end
                end)

                optionButton.Parent = optionsFrame
            end

            local dropdownConnection
            dropdownConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and optionsFrame.Visible then
                    local mousePos = input.Position
                    if not optionsFrame.AbsoluteRect:Contains(mousePos) and not mainButton.AbsoluteRect:Contains(mousePos) then
                        optionsFrame.Visible = false
                    end
                end
            end)

            function dropdown:Set(option)
                if table.find(dropdown.Options, option) then
                    dropdown.Selected = option
                    mainButton.Text = option
                    if dropdown.Callback then
                        dropdown.Callback(option)
                    end
                end
            end

            function dropdown:Get()
                return dropdown.Selected
            end

            function dropdown:Destroy()
                dropdownConnection:Disconnect()
                container:Destroy()
            end

            return dropdown
        end

        function section:CreateTextBox(options)
            options = options or {}
            local textBox = {
                Callback = options.Callback,
                Placeholder = options.Placeholder or "Enter text..."
            }

            local container = Create("Frame", {
                Name = "TextBox",
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                BackgroundTransparency = 1
            })

            local input = Create("TextBox", {
                Name = "Input",
                Parent = container,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Accent.Background,
                TextColor3 = Theme.Primary.Text,
                PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                PlaceholderText = textBox.Placeholder,
                Text = options.Text or "",
                ClearTextOnFocus = options.ClearTextOnFocus or false,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body
            })

            RoundCorners(input)

            if textBox.Callback then
                input.FocusLost:Connect(function(enterPressed)
                    textBox.Callback(input.Text, enterPressed)
                end)
            end

            function textBox:Set(text)
                input.Text = text
            end

            function textBox:Get()
                return input.Text
            end

            return textBox
        end

        function section:CreateKeybind(options)
            options = options or {}
            local keybind = {
                Key = options.Default or Enum.KeyCode.Unknown,
                Callback = options.Callback
            }

            local container = Create("Frame", {
                Name = "Keybind",
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ElementHeight),
                BackgroundTransparency = 1
            })

            local label = Create("TextLabel", {
                Name = "Label",
                Parent = container,
                Text = options.Text or "Keybind",
                Size = UDim2.new(0.7, 0, 1, 0),
                TextColor3 = Theme.Secondary.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local button = Create("TextButton", {
                Name = "Button",
                Parent = container,
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                Text = keybind.Key.Name,
                BackgroundColor3 = Theme.Accent.Background,
                TextColor3 = Theme.Primary.Text,
                Font = Theme.Font.Body,
                TextSize = Theme.Font.Size.Body
            })

            RoundCorners(button)

            local listening = false

            local function SetKey(key)
                keybind.Key = key
                button.Text = key.Name
                if keybind.Callback then
                    keybind.Callback(key)
                end
            end

            button.MouseButton1Click:Connect(function()
                listening = true
                button.Text = "..."
            end)

            local connection
            connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        SetKey(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SetKey(Enum.KeyCode.Unknown)
                    end
                    listening = false
                end
            end)

            function keybind:Set(key)
                SetKey(key)
            end

            function keybind:Get()
                return keybind.Key
            end

            function keybind:Destroy()
                connection:Disconnect()
                container:Destroy()
            end

            return keybind
        end

        function section:CreateDivider()
            local divider = Create("Frame", {
                Name = "Divider",
                Parent = self.Frame,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Color3.fromRGB(100, 100, 100),
                BorderSizePixel = 0
            })
            return divider
        end

        return section
    end

    return tab
end

return UILibrary