--// Advanced Server Browser - Modular Edition --// Module: UIHandler.lua

local UIHandler = {}

local Players = game:GetService("Players") local TweenService = game:GetService("TweenService") local LocalPlayer = Players.LocalPlayer local Settings = { MaxPing = 250, MaxPlayers = 15, AutoScan = false, AutoJoin = false, ScanDelay = 5, }

local ScreenGui, MainFrame, ServerListFrame, StatusLabel = nil, nil, nil, nil

function UIHandler:CreateUI() ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "ServerBrowserUI" ScreenGui.ResetOnSpawn = false ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Blur = Instance.new("BlurEffect", game.Lighting)
Blur.Size = 12

MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Advanced Server Browser"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local function CreateButton(text, callback)
    local button = Instance.new("TextButton", MainFrame)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, #MainFrame:GetChildren() * 35)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.MouseButton1Click:Connect(callback)
    return button
end

CreateButton("Manual Scan", function()
    UIHandler.OnManualScan()
end)

CreateButton("Toggle Auto Scan", function()
    Settings.AutoScan = not Settings.AutoScan
end)

CreateButton("Toggle Auto Join", function()
    Settings.AutoJoin = not Settings.AutoJoin
end)

CreateButton("Increase Max Ping (Now: " .. Settings.MaxPing .. ")", function()
    Settings.MaxPing += 50
end)

CreateButton("Decrease Max Players (Now: " .. Settings.MaxPlayers .. ")", function()
    Settings.MaxPlayers -= 1
end)

ServerListFrame = Instance.new("ScrollingFrame", MainFrame)
ServerListFrame.Position = UDim2.new(0, 10, 1, -180)
ServerListFrame.Size = UDim2.new(1, -20, 0, 120)
ServerListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ServerListFrame.BorderSizePixel = 0
ServerListFrame.ScrollBarThickness = 6

StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Text = "Status: Ready"

end

function UIHandler:UpdateServerList(serverData, teleportFunction) ServerListFrame:ClearAllChildren() ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, #serverData * 30)

for i, server in ipairs(serverData) do
    local entry = Instance.new("Frame", ServerListFrame)
    entry.Size = UDim2.new(1, 0, 0, 30)
    entry.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    local label = Instance.new("TextLabel", entry)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.format("%d Players | %dms", server.Playing, server.Ping)

    local join = Instance.new("TextButton", entry)
    join.Size = UDim2.new(0.25, -10, 0.8, 0)
    join.Position = UDim2.new(0.75, 5, 0.1, 0)
    join.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
    join.TextColor3 = Color3.new(1, 1, 1)
    join.Font = Enum.Font.GothamBold
    join.TextSize = 13
    join.Text = "Join"
    join.MouseButton1Click:Connect(function()
        teleportFunction(server.ID)
    end)
end

end

function UIHandler:SetStatus(text) if StatusLabel then StatusLabel.Text = "Status: " .. text end end

function UIHandler:GetSettings() return Settings end

return UIHandler

