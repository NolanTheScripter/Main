local ESP = {}

-- Dependencies
local taskWait = task.wait
local Vector2New = Vector2.new
local Vector3New = Vector3.new
local mathRound = math.round
local mathSin = math.sin
local mathCos = math.cos
local mathPi = math.pi
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Animation Constants
local ANIMATION_SPEED = 1.5
local PULSE_SPEED = 2
local FADE_DURATION = 0.3

-- Utility Functions
local function createText(color, size, center)
    local text = Drawing.new("Text")
    text.Color = color
    text.Size = size
    text.Center = center or false
    text.Outline = true
    text.Visible = false
    text.Transparency = 0
    return text
end

local function createRectangle(size, color)
    local rect = Drawing.new("Rectangle")
    rect.Size = size
    rect.Color = color
    rect.Filled = true
    rect.Visible = false
    rect.Transparency = 0
    return rect
end

local function createLine(color, thickness)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = thickness
    line.Visible = false
    line.Transparency = 0
    return line
end

local function smoothenPosition(Vector2)
    return Vector2New(mathRound(Vector2.X), mathRound(Vector2.Y))
end

local function getHealth(target)
    if target:FindFirstChild("Humanoid") then
        return target.Humanoid.Health, target.Humanoid.MaxHealth
    end
    return nil, nil
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function pulseValue(t, speed)
    return 0.5 + 0.5 * mathSin(t * speed * mathPi * 2)
end

-- Animation Controller
local AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new()
    local self = setmetatable({}, AnimationController)
    self.animations = {}
    self.time = 0
    return self
end

function AnimationController:update(dt)
    self.time = self.time + dt
    for _, anim in pairs(self.animations) do
        if anim.active then
            anim:update(dt)
        end
    end
end

function AnimationController:addAnimation(anim)
    table.insert(self.animations, anim)
    return anim
end

-- Base Animation Class
local BaseAnimation = {}
BaseAnimation.__index = BaseAnimation

function BaseAnimation.new(target, duration, easingStyle, easingDirection)
    local self = setmetatable({}, BaseAnimation)
    self.target = target
    self.duration = duration or 1
    self.time = 0
    self.active = true
    self.easingStyle = easingStyle or Enum.EasingStyle.Linear
    self.easingDirection = easingDirection or Enum.EasingDirection.InOut
    return self
end

function BaseAnimation:update(dt)
    self.time = self.time + dt
    if self.time >= self.duration then
        self.time = self.duration
        self.active = false
    end
    self:applyAnimation()
end

function BaseAnimation:applyAnimation()
    -- To be overridden by specific animations
end

-- Fade Animation
local FadeAnimation = setmetatable({}, BaseAnimation)
FadeAnimation.__index = FadeAnimation

function FadeAnimation.new(target, targetAlpha, duration)
    local self = BaseAnimation.new(target, duration or FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    setmetatable(self, FadeAnimation)
    self.startAlpha = target.Transparency
    self.targetAlpha = targetAlpha
    return self
end

function FadeAnimation:applyAnimation()
    local progress = TweenService:GetValue(self.time/self.duration, self.easingStyle, self.easingDirection)
    self.target.Transparency = lerp(self.startAlpha, self.targetAlpha, progress)
end

-- Pulse Animation
local PulseAnimation = setmetatable({}, BaseAnimation)
PulseAnimation.__index = PulseAnimation

function PulseAnimation.new(target, speed, minSize, maxSize)
    local self = BaseAnimation.new(target)
    setmetatable(self, PulseAnimation)
    self.speed = speed or PULSE_SPEED
    self.minSize = minSize or target.Size
    self.maxSize = maxSize or target.Size * 1.2
    return self
end

function PulseAnimation:applyAnimation()
    local pulse = pulseValue(self.time, self.speed)
    self.target.Size = self.minSize:Lerp(self.maxSize, pulse)
end

-- ESP Class
local ESPClass = {}
ESPClass.__index = ESPClass

function ESPClass.new(targetInstance)
    local self = setmetatable({}, ESPClass)
    
    self.Target = targetInstance
    self.Color = Color3.fromRGB(255, 255, 255)
    self._connection = nil
    self.animationController = AnimationController.new()
    
    -- Initialize drawing objects
    self.Text = createText(self.Color, 14, true)
    self.DistanceText = createText(self.Color, 12, true)
    self.HealthBar = createRectangle(Vector2New(50, 3), Color3.fromRGB(0, 255, 0))
    self.BoundingBox = nil
    self.NameText = createText(self.Color, 16, true)
    self.TagText = createText(Color3.fromRGB(255, 215, 0), 14, true)
    self.TracerLine = createLine(self.Color, 1)
    
    -- Set team color if applicable
    if targetInstance:IsA("Player") then
        self.TeamColor = targetInstance.TeamColor.Color
        self.Color = self.TeamColor
    end
    
    -- Initial animations
    self:playSpawnAnimation()
    
    return self
end

function ESPClass:playSpawnAnimation()
    -- Fade in all elements
    for _, drawing in pairs({self.Text, self.DistanceText, self.HealthBar, self.NameText, self.TagText, self.TracerLine}) do
        drawing.Transparency = 1
        self.animationController:addAnimation(FadeAnimation.new(drawing, 0))
    end
    
    -- Pulse animation for name
    self.animationController:addAnimation(PulseAnimation.new(self.NameText, PULSE_SPEED * 0.7))
end

function ESPClass:playDamageAnimation()
    -- Flash red when damaged
    local originalColor = self.Text.Color
    self.Text.Color = Color3.fromRGB(255, 50, 50)
    self.HealthBar.Color = Color3.fromRGB(255, 50, 50)
    
    delay(0.3, function()
        self.Text.Color = originalColor
        self:UpdateHealthBar() -- Restore health bar color based on health
    end)
end

function ESPClass:Update(dt)
    if not self.Target or not self.Target:IsDescendantOf(workspace) then
        self:Remove()
        return
    end
    
    -- Update animations
    self.animationController:update(dt)
    
    local targetPosition = self.Target:GetPivot().Position
    local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPosition)
    
    if onScreen then
        local smoothedPosition = smoothenPosition(Vector2New(screenPosition.X, screenPosition.Y))
        
        -- Animate position changes smoothly
        self.Text.Position = self.Text.Position:Lerp(smoothedPosition + Vector2New(0, 20), dt * ANIMATION_SPEED)
        self.DistanceText.Position = self.DistanceText.Position:Lerp(smoothedPosition + Vector2New(0, 35), dt * ANIMATION_SPEED)
        self.NameText.Position = self.NameText.Position:Lerp(smoothedPosition + Vector2New(0, -20), dt * ANIMATION_SPEED)
        
        -- Update tracer line
        local screenBottom = Vector2New(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        self.TracerLine.From = screenBottom
        self.TracerLine.To = smoothedPosition
        self.TracerLine.Visible = true
        
        -- Update visibility with fade
        for _, drawing in pairs({self.Text, self.DistanceText, self.NameText, self.TracerLine}) do
            if drawing.Transparency < 0.5 then
                drawing.Visible = true
            end
        end
        
        self:UpdateHealthBar()
        self:UpdateDistance()
        
        if self.BoundingBox then
            -- Bounding box update logic here
        end
    else
        -- Smooth fade out when off screen
        for _, drawing in pairs({self.Text, self.DistanceText, self.NameText, self.TracerLine}) do
            if drawing.Visible and drawing.Transparency < 1 then
                drawing.Visible = false
            end
        end
    end
end

function ESPClass:UpdateHealthBar()
    local health, maxHealth = getHealth(self.Target)
    if health and maxHealth then
        local healthPercentage = health / maxHealth
        
        -- Animate health bar changes
        local targetSize = Vector2New(50 * healthPercentage, 3)
        self.HealthBar.Size = self.HealthBar.Size:Lerp(targetSize, 0.3)
        
        -- Change color based on health with smooth transition
        local targetColor
        if healthPercentage > 0.5 then
            targetColor = Color3.fromRGB(0, 255, 0)
        elseif healthPercentage > 0.25 then
            targetColor = Color3.fromRGB(255, 255, 0)
        else
            targetColor = Color3.fromRGB(255, 0, 0)
            -- Pulse animation when health is low
            if not self.lowHealthPulse then
                self.lowHealthPulse = self.animationController:addAnimation(PulseAnimation.new(self.HealthBar, PULSE_SPEED * 1.5))
            end
        end
        
        if healthPercentage > 0.25 and self.lowHealthPulse then
            self.lowHealthPulse.active = false
            self.lowHealthPulse = nil
        end
        
        self.HealthBar.Color = self.HealthBar.Color:Lerp(targetColor, 0.2)
        self.HealthBar.Position = self.Text.Position + Vector2New(-25, 40)
        self.HealthBar.Visible = true
    else
        self.HealthBar.Visible = false
    end
end

function ESPClass:UpdateDistance()
    if self.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = self.Target:GetPivot().Position
        local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
        local distance = (targetPosition - playerPosition).Magnitude
        self.DistanceText.Text = string.format("%.1f studs", distance)
    end
end

function ESPClass:Toggle(state, instant)
    if instant then
        for _, drawing in pairs({self.Text, self.DistanceText, self.NameText, self.HealthBar, self.TracerLine}) do
            drawing.Visible = state
            drawing.Transparency = state and 0 or 1
        end
    else
        local targetAlpha = state and 0 or 1
        for _, drawing in pairs({self.Text, self.DistanceText, self.NameText, self.HealthBar, self.TracerLine}) do
            self.animationController:addAnimation(FadeAnimation.new(drawing, targetAlpha))
            drawing.Visible = true
        end
    end
end

function ESPClass:Remove()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    
    -- Fade out before removing
    for _, drawing in pairs({self.Text, self.DistanceText, self.NameText, self.HealthBar, self.TracerLine, self.TagText}) do
        if drawing then
            coroutine.wrap(function()
                self.animationController:addAnimation(FadeAnimation.new(drawing, 1))
                task.wait(FADE_DURATION)
                drawing:Remove()
            end)()
        end
    end
end

-- Rest of the ESPClass methods remain the same...

-- Library Table
local ESPLibrary = {
    ActiveESPs = {}
}

function ESPLibrary:NewESP(target)
    if not target then return end
    if self.ActiveESPs[target] then return self.ActiveESPs[target] end
    
    local newESP = ESPClass.new(target)
    self.ActiveESPs[target] = newESP
    
    -- Create update loop with delta time
    newESP._connection = RunService.Heartbeat:Connect(function(dt)
        newESP:Update(dt)
    end)
    
    -- Monitor health changes for damage animation
    if target:FindFirstChild("Humanoid") then
        target.Humanoid.HealthChanged:Connect(function()
            newESP:playDamageAnimation()
        end)
    end
    
    return newESP
end

-- Rest of the library functions remain the same...

-- Initialize
ESP.Library = ESPLibrary

return ESP