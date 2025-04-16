--// Main UI Library - Mobile and Desktop Supported
local Uilib = {}
Uilib.__index = Uilib

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Create the Main Window
function Uilib:CreateWindow(config)
    local self = setmetatable({}, Uilib)

    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "DragnirUILib"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, config.Width or 400, 0, config.Height or 300)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    -- Tab Holder
    local tabHolder = Instance.new("Frame")
    tabHolder.Name = "TabHolder"
    tabHolder.Size = UDim2.new(1, 0, 0, 35)
    tabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabHolder.BorderSizePixel = 0
    tabHolder.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabHolder

    -- Content Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Position = UDim2.new(0, 0, 0, 35)
    container.Size = UDim2.new(1, 0, 1, -35)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = main

    local tabs = {}

    -- Create a Tab
    function self:CreateTab(name)
        -- Tab Button
        local button = Instance.new("TextButton")
        button.Name = name .. "_Button"
        button.Size = UDim2.new(0, 100, 1, 0)
        button.Text = name
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.BorderSizePixel = 0
        button.Parent = tabHolder

        -- Tab Content Frame
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = name .. "_Tab"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = container

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = tabFrame

        -- Tab Switching
        button.MouseButton1Click:Connect(function()
            for _, t in pairs(container:GetChildren()) do
                if t:IsA("Frame") then
                    t.Visible = false
                end
            end
            tabFrame.Visible = true
        end)

        tabs[name] = tabFrame

        -- Components for the Tab
        local components = {}

        function components:Label(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 25)
            lbl.Text = text
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = tabFrame
        end

        function components:Button(name, callback)
            local btn = Instance.new("TextButton")
            btn.Text = name
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            btn.Parent = tabFrame

            btn.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        function components:Slider(name, min, max, default, callback)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 25)
            lbl.Text = name .. ": " .. tostring(default)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = tabFrame

            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1, -10, 0, 20)
            slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            slider.BorderSizePixel = 0
            slider.Parent = tabFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(120, 120, 255)
            fill.BorderSizePixel = 0
            fill.Parent = slider

            local dragging = false
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)

            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
                    pos = math.clamp(pos, 0, 1)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    lbl.Text = name .. ": " .. tostring(val)
                    callback(val)
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        return components
    end

    -- Notification System
    function self:Notify(text, duration)
        local notify = Instance.new("TextLabel")
        notify.Size = UDim2.new(0, 300, 0, 30)
        notify.Position = UDim2.new(0.5, 0, 0.1, 0)
        notify.AnchorPoint = Vector2.new(0.5, 0)
        notify.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.Text = text
        notify.Parent = screenGui

        task.delay(duration or 3, function()
            notify:Destroy()
        end)
    end

    return self
end

return Uilib