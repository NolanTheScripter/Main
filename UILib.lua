local UI = {}
local WindowFunctions = {}
local TabFunctions = {}
local SectionFunctions = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

---------------------------------------------------------------------
-- UI:CreateWindow
---------------------------------------------------------------------
function UI:CreateWindow(Name, Icon)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Name .. "_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = Name .. "_Frame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12)
    ContentCorner.Parent = ContentContainer

    local window = {
        Frame = MainFrame,
        TabBar = TabBar,
        ContentContainer = ContentContainer,
        Tabs = {}
    }

    setmetatable(window, { __index = WindowFunctions })
    return window
end

---------------------------------------------------------------------
-- WindowFunctions:CreateTab
---------------------------------------------------------------------
function WindowFunctions:CreateTab(TabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = TabName .. "_Button"
    TabButton.Size = UDim2.new(0, 100, 1, 0)
    TabButton.Text = TabName
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = self.TabBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    local TabContent = Instance.new("Frame")
    TabContent.Name = TabName .. "_Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer

    -- Automatically select the first tab if no tab is selected yet
    if #self.Tabs == 0 then
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    end

    -- Handle tab switching
    TabButton.MouseButton1Click:Connect(function()
        -- Hide all other tabs
        for _, tab in pairs(self.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end

        -- Show the selected tab
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    end)

    local tab = {
        Name = TabName,
        Button = TabButton,
        Content = TabContent
    }
    setmetatable(tab, { __index = TabFunctions })

    -- Store tab in the Tabs list
    table.insert(self.Tabs, tab)

    return tab
end

---------------------------------------------------------------------
-- TabFunctions:CreateSection
---------------------------------------------------------------------
function TabFunctions:CreateSection(SectionName)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section_" .. SectionName
    SectionFrame.Size = UDim2.new(1, -10, 0, 0)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = self.Content

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 5)
    SectionLayout.Parent = SectionFrame

    local Header = Instance.new("TextLabel")
    Header.Name = SectionName .. "_Header"
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.Text = SectionName
    Header.BackgroundTransparency = 1
    Header.Font = Enum.Font.GothamBold
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 16
    Header.Parent = SectionFrame

    local section = {
        Frame = SectionFrame
    }
    setmetatable(section, { __index = SectionFunctions })
    return section
end

---------------------------------------------------------------------
-- SectionFunctions
---------------------------------------------------------------------

function SectionFunctions:Input(Name, CurrentValue, PlaceholderText, RemoveTextAfterFocusLost, Callback)
    RemoveTextAfterFocusLost = RemoveTextAfterFocusLost or false

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, 0, 0, 30)
    InputBox.Text = CurrentValue or ""
    InputBox.PlaceholderText = PlaceholderText or Name
    InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 14
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = self.Frame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = InputBox

    InputBox.FocusLost:Connect(function(entered)
        local inputText = InputBox.Text
        if RemoveTextAfterFocusLost then
            InputBox.Text = ""
        end

        if Callback and type(Callback) == "function" then
            Callback(inputText)
        end
    end)

    InputBox.MouseEnter:Connect(function()
        InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)

    InputBox.MouseLeave:Connect(function()
        InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)

    return InputBox
end

function SectionFunctions:Dropdown(Name, Options, Callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(1, 0, 0, 30)
    Dropdown.Text = Name .. " (Click to Select)"
    Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    Dropdown.Font = Enum.Font.Gotham
    Dropdown.TextSize = 14
    Dropdown.Parent = self.Frame

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    DropdownFrame.Position = UDim2.new(0, 0, 0, 30)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = Dropdown

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Dropdown.MouseButton1Click:Connect(function()
        -- Toggle the dropdown list visibility
        if DropdownFrame.Visible then
            DropdownFrame.Visible = false
        else
            DropdownFrame.Visible = true
        end
    end)

    for _, option in ipairs(Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = option
        OptionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.Parent = DropdownFrame

        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Text = Name .. ": " .. option
            if Callback then Callback(option) end
            DropdownFrame.Visible = false
        end)
    end

    return Dropdown
end

function SectionFunctions:Slider(Name, Min, Max, Increment, Suffix, CurrentValue, Callback)
    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 30)
    Slider.Text = Name .. ": " .. tostring(CurrentValue) .. (Suffix or "")
    Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    Slider.Font = Enum.Font.Gotham
    Slider.TextSize = 14
    Slider.Parent = self.Frame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Slider

    Slider.MouseButton1Click:Connect(function()
        CurrentValue = math.clamp(CurrentValue + Increment, Min, Max)
        Slider.Text = Name .. ": " .. tostring(CurrentValue) .. (Suffix or "")
        if Callback then Callback(CurrentValue) end
    end)

    return Slider
end

function SectionFunctions:Paragraph(Title, Content)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
    TitleLabel.Text = Title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.Parent = self.Frame

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, 0, 0, 50)
    ContentLabel.Text = Content
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.TextWrapped = true
    ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextSize = 12
    ContentLabel.Parent = self.Frame

    ContentLabel:GetPropertyChangedSignal("Text"):Connect(function()
        ContentLabel.Size = UDim2.new(1, 0, 0, ContentLabel.TextBounds.Y)
    end)

    return { Title = TitleLabel, Content = ContentLabel }
end

---------------------------------------------------------------------
-- Return the UI table
---------------------------------------------------------------------
return UI