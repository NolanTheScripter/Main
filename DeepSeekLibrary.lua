local UILibrary = {}
UILibrary.__index = UILibrary

--[[
    ====== CONSTANTS & THEME SYSTEM ======
]]
local IS_MOBILE = game:GetService("UserInputService").TouchEnabled
local INPUT_SERVICE = game:GetService("UserInputService")
local TWEEN_SERVICE = game:GetService("TweenService")

local Theme = {
    -- Color Schemes
    Dark = {
        Primary = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 240),
        Subtext = Color3.fromRGB(180, 180, 180),
        Error = Color3.fromRGB(255, 85, 85),
        Success = Color3.fromRGB(85, 255, 85)
    },
    Light = {
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(220, 220, 225),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(30, 30, 35),
        Subtext = Color3.fromRGB(100, 100, 105),
        Error = Color3.fromRGB(215, 50, 50),
        Success = Color3.fromRGB(50, 215, 50)
    },
    
    -- Typography
    Font = {
        Title = Enum.Font.GothamBlack,
        Header = Enum.Font.GothamBold,
        Body = Enum.Font.GothamMedium,
        Code = Enum.Font.RobotoMono
    },
    
    -- Sizing
    Sizing = {
        Window = UDim2.new(0, 500, 0, 650),
        MobileWindow = UDim2.new(1, -20, 1, -20),
        CornerRadius = UDim.new(0, 12),
        ElementPadding = 10,
        SectionSpacing = 8,
        ControlHeight = IS_MOBILE and 44 or 36,
        TitleBarHeight = 48,
        TabHeight = 42,
        IconSize = 24
    },
    
    -- Animations
    Animations = {
        HoverSpeed = 0.15,
        ClickSpeed = 0.1,
        ToggleSpeed = 0.2,
        SlideSpeed = 0.25,
        FadeSpeed = 0.15
    },
    
    -- Mobile Specific
    Mobile = {
        TouchAreaSize = 44,
        ScrollBarWidth = 6,
        BackButtonVisible = true
    }
}

-- Current active theme (can be switched)
local CurrentTheme = Theme.Dark

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
            local success = pcall(function()
                instance[prop] = value
            end)
            if not success then
                warn(`[UI Library] Failed to set {prop} on {className}`)
            end
        end
    end
    return instance
end

local function ApplyTheme(instance, themeProps)
    for prop, value in pairs(themeProps) do
        if instance[prop] ~= nil then
            instance[prop] = value
        end
    end
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TWEEN_SERVICE:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RoundCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.Sizing.CornerRadius
    corner.Parent = instance
    return corner
end

local function CreateShadow(instance)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Parent = instance
    return shadow
end

local function CreateScrollFrame(parent)
    local scrollFrame = Create("ScrollingFrame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarImageColor3 = CurrentTheme.Subtext,
        ScrollBarThickness = IS_MOBILE and Theme.Mobile.ScrollBarWidth or 4,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local layout = Create("UIListLayout", {
        Parent = scrollFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Theme.Sizing.SectionSpacing)
    })
    
    Create("UIPadding", {
        Parent = scrollFrame,
        PaddingLeft = UDim.new(0, Theme.Sizing.ElementPadding),
        PaddingRight = UDim.new(0, Theme.Sizing.ElementPadding),
        PaddingTop = UDim.new(0, Theme.Sizing.ElementPadding),
        PaddingBottom = UDim.new(0, Theme.Sizing.ElementPadding)
    })
    
    return scrollFrame
end

--[[
    ====== CORE WINDOW CLASS ======
]]
function UILibrary.new(options)
    options = options or {}
    local self = setmetatable({}, UILibrary)
    
    -- Create main screen GUI
    self.Gui = Create("ScreenGui", {
        Name = options.Name or "AdvancedUI",
        Parent = options.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = options.ResetOnSpawn or false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10
    })
    
    -- Calculate window size based on platform
    local windowSize = IS_MOBILE and Theme.Sizing.MobileWindow or options.Size or Theme.Sizing.Window
    
    -- Create main window frame
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        Parent = self.Gui,
        Size = windowSize,
        Position = IS_MOBILE and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        ClipsDescendants = true
    })
    
    RoundCorners(self.MainFrame)
    CreateShadow(self.MainFrame)
    
    -- Title bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, Theme.Sizing.TitleBarHeight),
        BackgroundColor3 = CurrentTheme.Primary,
        Children = {
            Create("TextLabel", {
                Name = "Title",
                Text = options.Title or "Advanced UI",
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 50, 0, 0),
                TextColor3 = CurrentTheme.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Title,
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Create("ImageButton", {
                Name = "CloseButton",
                Size = UDim2.new(0, Theme.Sizing.TitleBarHeight, 0, Theme.Sizing.TitleBarHeight),
                Position = UDim2.new(1, -Theme.Sizing.TitleBarHeight, 0, 0),
                BackgroundColor3 = CurrentTheme.Primary,
                Image = "rbxassetid://3926305904",
                ImageRectOffset = Vector2.new(284, 4),
                ImageRectSize = Vector2.new(24, 24),
                ImageColor3 = CurrentTheme.Text
            })
        }
    })
    
    -- Mobile back button
    if IS_MOBILE and Theme.Mobile.BackButtonVisible then
        Create("ImageButton", {
            Name = "BackButton",
            Parent = self.TitleBar,
            Size = UDim2.new(0, Theme.Sizing.TitleBarHeight, 0, Theme.Sizing.TitleBarHeight),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = CurrentTheme.Primary,
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(124, 4),
            ImageRectSize = Vector2.new(24, 24),
            ImageColor3 = CurrentTheme.Text
        })
    end
    
    -- Main content area
    self.ContentFrame = Create("Frame", {
        Name = "Content",
        Parent = self.MainFrame,
        Position = UDim2.new(0, 0, 0, Theme.Sizing.TitleBarHeight),
        Size = UDim2.new(1, 0, 1, -Theme.Sizing.TitleBarHeight),
        BackgroundColor3 = CurrentTheme.Primary,
        ClipsDescendants = true
    })
    
    -- Tab buttons container
    self.TabButtons = Create("Frame", {
        Name = "TabButtons",
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 0, Theme.Sizing.TabHeight),
        BackgroundColor3 = CurrentTheme.Secondary
    })
    
    -- Tab content container
    self.TabContent = Create("Frame", {
        Name = "TabContent",
        Parent = self.ContentFrame,
        Position = UDim2.new(0, 0, 0, Theme.Sizing.TabHeight),
        Size = UDim2.new(1, 0, 1, -Theme.Sizing.TabHeight),
        BackgroundColor3 = CurrentTheme.Primary
    })
    
    -- Initialize tab system
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Close button functionality
    self.TitleBar.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Mobile drag functionality
    if IS_MOBILE then
        local dragStartPos, frameStartPos
        local dragInput, dragConnection
        
        local function UpdatePosition(input)
            local delta = input.Position - dragStartPos
            self.MainFrame.Position = UDim2.new(
                0, frameStartPos.X.Offset + delta.X,
                0, frameStartPos.Y.Offset + delta.Y
            )
        end
        
        self.TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragStartPos = input.Position
                frameStartPos = self.MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        if dragConnection then
                            dragConnection:Disconnect()
                            dragConnection = nil
                        end
                    end
                end)
            end
        end)
        
        self.TitleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragConnection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.Change then
                        UpdatePosition(input)
                    end
                end)
            end
        end)
    end
    
    return self
end

--[[
    ====== WINDOW METHODS ======
]]
function UILibrary:CreateTab(title, icon)
    local tab = {
        Window = self,
        Name = title or "Tab",
        Icon = icon
    }
    
    -- Create tab button
    tab.Button = Create("TextButton", {
        Name = "Tab_"..tab.Name,
        Parent = self.TabButtons,
        Text = tab.Name,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = CurrentTheme.Secondary,
        TextColor3 = CurrentTheme.Text,
        Font = Theme.Font.Header,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    if tab.Icon then
        tab.Button.TextXAlignment = Enum.TextXAlignment.Left
        Create("ImageLabel", {
            Name = "Icon",
            Parent = tab.Button,
            Image = tab.Icon,
            Size = UDim2.new(0, Theme.Sizing.IconSize, 0, Theme.Sizing.IconSize),
            Position = UDim2.new(0, 10, 0.5, -Theme.Sizing.IconSize/2),
            BackgroundTransparency = 1,
            ImageColor3 = CurrentTheme.Text
        })
        tab.Button.Text = "   "..tab.Button.Text
    end
    
    -- Create tab content
    tab.Content = Create("Frame", {
        Name = "Content_"..tab.Name,
        Parent = self.TabContent,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Primary,
        Visible = false
    })
    
    -- Scroll frame for content
    tab.ScrollFrame = CreateScrollFrame(tab.Content)
    
    -- Add to tabs list
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Tab button interactivity
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Hover effects
    tab.Button.MouseEnter:Connect(function()
        Tween(tab.Button, {BackgroundColor3 = Color3.fromRGB(
            CurrentTheme.Secondary.R * 255 + 20,
            CurrentTheme.Secondary.G * 255 + 20,
            CurrentTheme.Secondary.B * 255 + 20
        )}, Theme.Animations.HoverSpeed)
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(tab.Button, {BackgroundColor3 = CurrentTheme.Secondary}, Theme.Animations.HoverSpeed)
        end
    end)
    
    function tab:CreateSection(title, collapsible)
        local section = {
            Tab = self,
            Title = title or "",
            Collapsible = collapsible or false,
            Expanded = true
        }
        
        -- Section container
        section.Frame = Create("Frame", {
            Name = "Section_"..section.Title,
            Parent = self.ScrollFrame,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = CurrentTheme.Secondary,
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true
        })
        
        RoundCorners(section.Frame)
        
        -- Section layout
        local layout = Create("UIListLayout", {
            Parent = section.Frame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, Theme.Sizing.SectionSpacing)
        })
        
        Create("UIPadding", {
            Parent = section.Frame,
            PaddingLeft = UDim.new(0, Theme.Sizing.ElementPadding),
            PaddingRight = UDim.new(0, Theme.Sizing.ElementPadding),
            PaddingTop = UDim.new(0, Theme.Sizing.ElementPadding),
            PaddingBottom = UDim.new(0, Theme.Sizing.ElementPadding)
        })
        
        -- Section header
        if section.Title ~= "" then
            section.Header = Create("Frame", {
                Name = "Header",
                Parent = section.Frame,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ControlHeight),
                BackgroundTransparency = 1,
                LayoutOrder = 0
            })
            
            section.TitleLabel = Create("TextLabel", {
                Name = "Title",
                Parent = section.Header,
                Text = section.Title,
                Size = UDim2.new(1, -30, 1, 0),
                TextColor3 = CurrentTheme.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font.Header,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if section.Collapsible then
                section.ToggleButton = Create("ImageButton", {
                    Name = "Toggle",
                    Parent = section.Header,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -24, 0.5, -12),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(364, 284),
                    ImageRectSize = Vector2.new(24, 24),
                    ImageColor3 = CurrentTheme.Subtext
                })
                
                section.ToggleButton.MouseButton1Click:Connect(function()
                    section.Expanded = not section.Expanded
                    Tween(section.ToggleButton, {
                        Rotation = section.Expanded and 0 or 180
                    }, Theme.Animations.ToggleSpeed)
                    
                    for _, child in ipairs(section.Frame:GetChildren()) do
                        if child:IsA("GuiObject") and child ~= section.Header and child ~= section.ToggleButton then
                            child.Visible = section.Expanded
                        end
                    end
                end)
            end
        end
        
        --[[
            ====== SECTION ELEMENT CREATION METHODS ======
        ]]
        function section:CreateLabel(text, style)
            style = style or "Body"
            
            local label = Create("TextLabel", {
                Name = "Label_"..text,
                Parent = self.Frame,
                Text = text,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ControlHeight),
                TextColor3 = style == "Subtext" and CurrentTheme.Subtext or CurrentTheme.Text,
                BackgroundTransparency = 1,
                Font = Theme.Font[style] or Theme.Font.Body,
                TextSize = style == "Header" and 16 or 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #self.Frame:GetChildren()
            })
            
            return label
        end
        
        function section:CreateButton(text, callback, options)
            options = options or {}
            
            local button = Create("TextButton", {
                Name = "Button_"..text,
                Parent = self.Frame,
                Text = text,
                Size = UDim2.new(1, 0, 0, Theme.Sizing.ControlHeight),
                BackgroundColor3 = CurrentTheme.Accent,
                TextColor3 = CurrentTheme.Text,
                Font = Theme.Font.Header,
                TextSize = 14,
                AutoButtonColor = false,
                LayoutOrder = #self.Frame:GetChildren()
            })
            
            RoundCorners(button)
            
            -- Icon support
            if options.Icon then
                button.TextXAlignment = Enum.TextXAlignment.Left
                Create("ImageLabel", {
                    Name = "Icon",
                    Parent = button,
                    Image = options.Icon,
                    Size = UDim2.new(0, Theme.Sizing.IconSize, 0, Theme.Sizing.IconSize),
                    Position = UDim2.new(0, 10, 0.5, -Theme.Sizing.IconSize/2),
                    BackgroundTransparency = 1,
                    ImageColor3 = CurrentTheme.Text
                })
                button.Text = "   "..button.Text
            end
            
            -- Interactive states
            button.MouseEnter:Connect(function()
                Tween(button, {
                    BackgroundColor3 = Color3.fromRGB(
                        math.min(CurrentTheme.Accent.R * 255 + 20, 255),
                        math.min(CurrentTheme.Accent.G * 255 + 20, 255),
                        math.min(CurrentTheme.Accent.B * 255 + 20, 255)
                    )
                }, Theme.Animations.HoverSpeed)
            end)
            
            button.MouseLeave:Connect(function()
                Tween(button, {BackgroundColor3 = CurrentTheme.Accent}, Theme.Animations.HoverSpeed)
            end)
            
            button.MouseButton1Down:Connect(function()
                Tween(button, {BackgroundColor3 = Color3.fromRGB(
                    math.max(CurrentTheme.Accent.R * 255 - 20, 0),
                    math.max(CurrentTheme.Accent.G * 255 - 20, 0),
                    math.max(CurrentTheme.Accent.B * 255 - 20, 0)
                )}, Theme.Animations.ClickSpeed)
            end)
            
            button.MouseButton1Up:Connect(function()
                Tween(button, {
                    BackgroundColor3 = Color3.fromRGB(
                        math.min(CurrentTheme.Accent.R * 255 + 20, 255),
                        math.min(CurrentTheme.Accent.G * 255 + 20, 255),
                        math.min(CurrentTheme.Accent.B * 255 + 20, 255)
                    )
                }, Theme.Animations.ClickSpeed)
            end)
            
            if callback then
                button.MouseButton1Click:Connect(function()
                    -- Pulse effect
                    Tween(button, {Size = UDim2.new(0.98, 0, 0.95, 0)}, 0.1):andThen(function()
                        Tween(button, {Size = UDim2.new(1, 0, 1, 0)}, 0.1)
                    end)
                    
                    callback()
                end)
            end
            
            return button
        end
        
        -- ... (Other component creation methods would follow the same pattern)
        
        return section
    end
    
    return tab
end

function UILibrary:SelectTab(tab)
    if self.CurrentTab then
        -- Deselect current tab
        Tween(self.CurrentTab.Button, {
            BackgroundColor3 = CurrentTheme.Secondary
        }, Theme.Animations.HoverSpeed)
        
        self.CurrentTab.Content.Visible = false
    end
    
    -- Select new tab
    self.CurrentTab = tab
    tab.Content.Visible = true
    
    Tween(tab.Button, {
        BackgroundColor3 = Color3.fromRGB(
            CurrentTheme.Secondary.R * 255 + 30,
            CurrentTheme.Secondary.G * 255 + 30,
            CurrentTheme.Secondary.B * 255 + 30
        )
    }, Theme.Animations.HoverSpeed)
    
    -- Scroll to top
    if tab.ScrollFrame then
        tab.ScrollFrame.CanvasPosition = Vector2.new(0, 0)
    end
end

function UILibrary:Destroy()
    self.Gui:Destroy()
    setmetatable(self, nil)
end

--[[
    ====== THEME MANAGEMENT ======
]]
function UILibrary:SetTheme(themeName)
    CurrentTheme = Theme[themeName] or Theme.Dark
    -- Implement theme propagation to all elements
end

function UILibrary:ToggleDarkMode()
    self:SetTheme(CurrentTheme == Theme.Dark and "Light" or "Dark")
end

return UILibrary