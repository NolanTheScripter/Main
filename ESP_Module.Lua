local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    
    -- ESP Settings
    self.Enabled = true
    self.BoxColor = Color3.fromRGB(255, 0, 0) -- Red
    self.HealthBarColor = Color3.fromRGB(0, 255, 0)  -- Green
    self.HealthBarBGColor = Color3.fromRGB(50, 50, 50) -- Dark gray
    self.TracerColor = Color3.fromRGB(0, 0, 255) -- Blue
    self.NameColor = Color3.fromRGB(255, 255, 255) -- White
    self.Transparency = 0.5
    self.Thickness = 2
    self.BoxSize = Vector2.new(50, 100)
    self.MaxRenderDistance = 500 -- Max distance for rendering ESP elements

    -- Options
    self.TeamCheck = true
    self.Tracers = true
    self.HealthBars = true
    self.Names = true

    -- Services
    self.Players = game:GetService("Players")
    self.LocalPlayer = self.Players.LocalPlayer
    self.RunService = game:GetService("RunService")
    self.Camera = workspace.CurrentCamera
    
    -- Store ESP Items
    self.ESPItems = {}

    -- Initialize ESP
    self:Init()
    return self
end

function ESP:Init()
    -- Interval update for better performance
    local updateInterval = 0.1
    local timeElapsed = 0

    self.RunService.RenderStepped:Connect(function(deltaTime)
        if not self.Enabled then
            self:HideAll()
        else
            timeElapsed = timeElapsed + deltaTime
            if timeElapsed >= updateInterval then
                self:UpdateAll()
                timeElapsed = 0
            end
        end
    end)

    -- Add existing players
    for _, player in ipairs(self.Players:GetPlayers()) do
        if player ~= self.LocalPlayer then
            self:AddPlayer(player)
        end
    end

    -- Listen for new players
    self.Players.PlayerAdded:Connect(function(player)
        if player ~= self.LocalPlayer then
            self:AddPlayer(player)
        end
    end)

    -- Handle player removal
    self.Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)
end

function ESP:UpdateAll()
    for _, espItem in pairs(self.ESPItems) do
        espItem:Update()
    end
end

function ESP:HideAll()
    for _, espItem in pairs(self.ESPItems) do
        espItem:Hide()
    end
end

function ESP:AddPlayer(player)
    if self.ESPItems[player] then return end
    local espItem = ESPItem.new(player, self)
    self.ESPItems[player] = espItem
end

function ESP:RemovePlayer(player)
    if self.ESPItems[player] then
        self.ESPItems[player]:Remove()
        self.ESPItems[player] = nil
    end
end

function ESP:Toggle(state)
    self.Enabled = state
end

-- ESPItem Class
local ESPItem = {}
ESPItem.__index = ESPItem

function ESPItem.new(player, esp)
    local self = setmetatable({}, ESPItem)
    self.Player = player
    self.esp = esp

    -- Box Drawing
    self.Box = Drawing.new("Square")
    self.Box.Visible = false
    self.Box.Color = esp.BoxColor
    self.Box.Thickness = esp.Thickness
    self.Box.Transparency = esp.Transparency
    self.Box.Filled = false
    self.Box.Size = esp.BoxSize
    
    -- Health Bar (Background and Fill)
    if esp.HealthBars then
        self.HealthBarBG = Drawing.new("Line")
        self.HealthBarBG.Visible = false
        self.HealthBarBG.Color = esp.HealthBarBGColor
        self.HealthBarBG.Thickness = esp.Thickness
        self.HealthBarBG.Transparency = esp.Transparency
        
        self.HealthBar = Drawing.new("Line")
        self.HealthBar.Visible = false
        self.HealthBar.Color = esp.HealthBarColor
        self.HealthBar.Thickness = esp.Thickness
        self.HealthBar.Transparency = esp.Transparency
    end
    
    -- Tracer Drawing
    if esp.Tracers then
        self.Tracer = Drawing.new("Line")
        self.Tracer.Visible = false
        self.Tracer.Color = esp.TracerColor
        self.Tracer.Thickness = esp.Thickness
        self.Tracer.Transparency = esp.Transparency
    end
    
    -- Name Display
    if esp.Names then
        self.Name = Drawing.new("Text")
        self.Name.Visible = false
        self.Name.Color = esp.NameColor
        self.Name.Size = 13
        self.Name.Center = true
        self.Name.Outline = true
        self.Name.Font = 2
        self.Name.Transparency = esp.Transparency
    end
    
    return self
end

function ESPItem:Update()
    local character = self.Player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not rootPart then
        self:Hide()
        return
    end

    -- Respect team check
    if self.esp.TeamCheck and self.Player.Team == self.esp.LocalPlayer.Team then
        self:Hide()
        return
    end

    -- Calculate screen position and distance
    local pos, onScreen = self.esp.Camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - self.esp.Camera.CFrame.Position).Magnitude

    -- Only show ESP if on screen and within render distance
    if not onScreen or distance > self.esp.MaxRenderDistance then
        self:Hide()
        return
    end

    -- Update Box
    self.Box.Size = self.esp.BoxSize
    self.Box.Position = Vector2.new(pos.X - self.esp.BoxSize.X / 2, pos.Y - self.esp.BoxSize.Y / 2)
    self.Box.Visible = true

    -- Update Health Bar
    if self.esp.HealthBars and humanoid.MaxHealth > 0 then
        local healthPerc = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local barHeight = self.esp.BoxSize.Y
        local offset = 10 -- horizontal offset from the box
        local barX = pos.X - self.esp.BoxSize.X / 2 - offset
        local barYBottom = pos.Y + self.esp.BoxSize.Y / 2
        local barYTop = barYBottom - barHeight
        
        if self.HealthBarBG then
            self.HealthBarBG.From = Vector2.new(barX, barYBottom)
            self.HealthBarBG.To = Vector2.new(barX, barYTop)
            self.HealthBarBG.Visible = true
        end
        
        if self.HealthBar then
            local filledY = barYBottom - barHeight * healthPerc
            self.HealthBar.From = Vector2.new(barX, barYBottom)
            self.HealthBar.To = Vector2.new(barX, filledY)
            self.HealthBar.Visible = true
        end
    end
    
    -- Update Tracer (from bottom center of the screen)
    if self.esp.Tracers and self.Tracer then
        self.Tracer.From = Vector2.new(self.esp.Camera.ViewportSize.X / 2, self.esp.Camera.ViewportSize.Y)
        self.Tracer.To = Vector2.new(pos.X, pos.Y)
        self.Tracer.Visible = true
    end
    
    -- Update Name Display (above the box)
    if self.esp.Names and self.Name then
        self.Name.Text = self.Player.DisplayName or self.Player.Name
        self.Name.Position = Vector2.new(pos.X, pos.Y - self.esp.BoxSize.Y / 2 - 15)
        self.Name.Visible = true
    end
end 

function ESPItem:Hide()
    if self.Box then self.Box.Visible = false end
    if self.HealthBar then self.HealthBar.Visible = false end
    if self.HealthBarBG then self.HealthBarBG.Visible = false end
    if self.Tracer then self.Tracer.Visible = false end
    if self.Name then self.Name.Visible = false end
end

function ESPItem:Remove()
    if self.Box then self.Box:Remove() end
    if self.HealthBar then self.HealthBar:Remove() end
    if self.HealthBarBG then self.HealthBarBG:Remove() end
    if self.Tracer then self.Tracer:Remove() end
    if self.Name then self.Name:Remove() end
end

-- Create an instance of ESP
local espInstance = ESP.new()
return espInstance