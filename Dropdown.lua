local DropdownCategories = {}
local module = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Dropdown class
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(title, options, defaultOption, callback)
    local self = setmetatable({}, Dropdown)
    
    self.title = title
    self.options = options or {}
    self.defaultOption = defaultOption or options[1] or "None"
    self.callback = callback
    self.isOpen = false
    self.refreshConnection = nil
    self.playerAddedConn = nil
    self.playerRemovedConn = nil
    
    self:CreateUI()
    
    return self
end

function Dropdown:Refresh(newOptions, autoRefresh)
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
        self.refreshConnection = nil
    end

    if newOptions then
        self.options = newOptions
    end

    if autoRefresh then
        self.refreshConnection = RunService.Heartbeat:Connect(function()
            self:UpdateOptions(self.options)
        end)
    else
        self:UpdateOptions(self.options)
    end
end

function Dropdown:UpdateOptions(options)
    for _, child in ipairs(self.scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    self.options = options or self.options

    for i, opt in ipairs(self.options) do
        local btn = Instance.new("TextButton")
        btn.Name = opt
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Text = opt
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        btn.Parent = self.scrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
        
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
        end)

        btn.MouseButton1Click:Connect(function()
            self.selected = opt
            self.mainButton.Text = self.selected
            
            local tween = TweenService:Create(
                self.listFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, -10, 0, 0)}
            )
            tween:Play()
            self.isOpen = false
            
            if self.callback then
                self.callback(opt)
            end
        end)
    end

    local totalHeight = #self.options * 28 + (#self.options-1)*2
    self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    self.openSize = UDim2.new(1, -10, 0, math.min(totalHeight, 150))
end

function Dropdown:CreateUI()
    if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("MobileDropdownUI") then
        game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui").MobileDropdownUI:Destroy()
    end

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "MobileDropdownUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")

    self.dropdown = Instance.new("Frame")
    self.dropdown.Name = "Dropdown"
    self.dropdown.Size = UDim2.new(0.25, 0, 0, 50)
    self.dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
    self.dropdown.Position = UDim2.new(0.5, 0, 0.3, 0)
    self.dropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    self.dropdown.BorderSizePixel = 0
    self.dropdown.Parent = self.screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.dropdown

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.title
    titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.dropdown

    self.mainButton = Instance.new("TextButton")
    self.mainButton.Size = UDim2.new(1, -10, 0.5, 0)
    self.mainButton.Position = UDim2.new(0, 5, 0.45, 0)
    self.mainButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    self.mainButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    self.mainButton.Font = Enum.Font.Gotham
    self.mainButton.TextSize = 14
    self.mainButton.Text = self.defaultOption
    self.mainButton.TextTruncate = Enum.TextTruncate.AtEnd
    self.mainButton.BorderSizePixel = 0
    self.mainButton.AutoButtonColor = false
    self.mainButton.Parent = self.dropdown
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 4)
    mainCorner.Parent = self.mainButton

    self.mainButton.MouseEnter:Connect(function()
        self.mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
    
    self.mainButton.MouseLeave:Connect(function()
        self.mainButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    end)

    self.listFrame = Instance.new("Frame")
    self.listFrame.Position = UDim2.new(0, 5, 1, 2)
    self.listFrame.Size = UDim2.new(1, -10, 0, 0)
    self.listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.listFrame.BorderSizePixel = 0
    self.listFrame.ClipsDescendants = true
    self.listFrame.Parent = self.dropdown
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = self.listFrame

    self.scrollFrame = Instance.new("ScrollingFrame")
    self.scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.scrollFrame.BackgroundTransparency = 1
    self.scrollFrame.ScrollBarThickness = 4
    self.scrollFrame.Parent = self.listFrame

    local layout = Instance.new("UIListLayout", self.scrollFrame)
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    self:UpdateOptions(self.options)

    self.mainButton.MouseButton1Click:Connect(function()
        if self.isOpen then
            local tween = TweenService:Create(
                self.listFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, -10, 0, 0)}
            )
            tween:Play()
        else
            local tween = TweenService:Create(
                self.listFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = self.openSize}
            )
            tween:Play()
        end
        self.isOpen = not self.isOpen
    end)

    self.inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local absolutePos = self.dropdown.AbsolutePosition
            local absoluteSize = self.dropdown.AbsoluteSize
            
            local isOutside = not (
                input.Position.X >= absolutePos.X and
                input.Position.X <= absolutePos.X + absoluteSize.X and
                input.Position.Y >= absolutePos.Y and
                input.Position.Y <= absolutePos.Y + absoluteSize.Y + self.openSize.Y.Offset
            )
            
            if isOutside and self.isOpen then
                self.isOpen = false
                local tween = TweenService:Create(
                    self.listFrame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(1, -10, 0, 0)}
                )
                tween:Play()
            end
        end
    end)
end

function Dropdown:Destroy()
    if self.refreshConnection then
        self.refreshConnection:Disconnect()
    end
    if self.inputBeganConnection then
        self.inputBeganConnection:Disconnect()
    end
    if self.playerAddedConn then
        self.playerAddedConn:Disconnect()
    end
    if self.playerRemovedConn then
        self.playerRemovedConn:Disconnect()
    end
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- PlayerList dropdown creator
function DropdownCategories.PlayerList(callback)
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    
    local dropdown = Dropdown.new("Players", playerNames, playerNames[1], callback)
    
    -- Auto-update when players join/leave
    dropdown.playerAddedConn = Players.PlayerAdded:Connect(function(player)
        table.insert(playerNames, player.Name)
        dropdown:Refresh(playerNames, false)
    end)
    
    dropdown.playerRemovedConn = Players.PlayerRemoving:Connect(function(player)
        for i, name in ipairs(playerNames) do
            if name == player.Name then
                table.remove(playerNames, i)
                break
            end
        end
        dropdown:Refresh(playerNames, false)
    end)
    
    return dropdown
end

-- Main module functions
function module.new(title, options, defaultOption, callback)
    return Dropdown.new(title, options, defaultOption, callback)
end

function module.PlayerList(callback)
    return DropdownCategories.PlayerList(callback)
end

return module