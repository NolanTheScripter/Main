
-- A comprehensive health bar system for Roblox characters

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Default Theme Configuration
local DEFAULT_THEME = {
	BackgroundMuted = Color3.fromRGB(50, 50, 50),
	Accent = Color3.fromRGB(0, 200, 80),
	Text = Color3.fromRGB(255, 255, 255),
	Warning = Color3.fromRGB(255, 100, 0),
	DamageFlash = Color3.fromRGB(255, 50, 50),
	HealFlash = Color3.fromRGB(50, 255, 100),
	ShieldColor = Color3.fromRGB(100, 150, 255),
}

-- Instance Pool for Performance
local BillboardPool = {}
local MAX_POOL_SIZE = 20

-- Main HealthBar Class
local HealthBar = {}
HealthBar.__index = HealthBar

-- Cleanup utility
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
	return setmetatable({
		_items = {},
		_enabled = true
	}, Janitor)
end

function Janitor:Add(item, cleanupMethod)
	if not self._enabled then
		if type(cleanupMethod) == "function" then
			cleanupMethod(item)
		elseif type(item) == "userdata" then
			item:Destroy()
		end
		return
	end
	
	table.insert(self._items, {item, cleanupMethod})
end

function Janitor:Cleanup()
	if not self._enabled then return end
	
	for _, data in ipairs(self._items) do
		local item, cleanupMethod = data[1], data[2]
		
		if type(cleanupMethod) == "function" then
			cleanupMethod(item)
		elseif type(item) == "userdata" then
			item:Destroy()
		end
	end
	
	self._items = {}
	self._enabled = false
end

-- Get BillboardGui from pool or create new
local function getBillboardFromPool()
	if #BillboardPool > 0 then
		return table.remove(BillboardPool)
	end
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBarBillboard"
	billboard.Active = true
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.Size = UDim2.new(0, 120, 0, 24)
	billboard.SizeOffset = Vector2.new(0, 0.1)
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboard.ResetOnSpawn = false
	
	return billboard
end

-- Create UI Elements
local function createHealthBarUI(parentFrame, options)
	local theme = options.theme or DEFAULT_THEME
	local style = options.style or "rounded"
	
	-- Main Container
	local container = Instance.new("Frame")
	container.Name = "HealthBarContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Parent = parentFrame
	
	-- Optional Decorative Background
	if style == "glossy" or style == "shield" then
		local decorativeBg = Instance.new("ImageLabel")
		decorativeBg.Name = "DecorativeBackground"
		decorativeBg.Size = UDim2.new(1.2, 0, 1.5, 0)
		decorativeBg.Position = UDim2.new(-0.1, 0, -0.25, 0)
		decorativeBg.BackgroundTransparency = 1
		decorativeBg.Image = "rbxassetid://" .. (options.customImage or "3570695787")
		decorativeBg.ScaleType = Enum.ScaleType.Slice
		decorativeBg.SliceCenter = Rect.new(100, 100, 100, 100)
		decorativeBg.Parent = container
	end
	
	-- Background Bar
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.BackgroundColor3 = theme.BackgroundMuted
	background.BackgroundTransparency = 0.4
	background.Size = UDim2.new(1, 0, 0.4, 0)
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.Position = UDim2.new(0.5, 0, 0.5, 0)
	background.Parent = container
	
	-- Apply rounded corners if specified
	if style == "rounded" or style == "glossy" then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = background
	end
	
	-- Optional Border
	if options.showBorder then
		local border = Instance.new("UIStroke")
		border.Name = "Border"
		border.Color = Color3.fromRGB(100, 100, 100)
		border.Thickness = 1
		border.Parent = background
	end
	
	-- Shield/Overhealth Layer (hidden by default)
	local shieldLayer = Instance.new("Frame")
	shieldLayer.Name = "ShieldLayer"
	shieldLayer.BackgroundColor3 = theme.ShieldColor
	shieldLayer.Size = UDim2.new(1, 0, 1, 0)
	shieldLayer.AnchorPoint = Vector2.new(0, 0)
	shieldLayer.Position = UDim2.new(0, 0, 0, 0)
	shieldLayer.Visible = false
	shieldLayer.Parent = background
	
	if style == "rounded" or style == "glossy" then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = shieldLayer
	end
	
	-- Main Health Foreground
	local foreground = Instance.new("Frame")
	foreground.Name = "Foreground"
	foreground.BackgroundColor3 = options.colors and options.colors.foreground or theme.Accent
	foreground.Size = UDim2.new(1, 0, 1, 0)
	foreground.AnchorPoint = Vector2.new(0, 0)
	foreground.Position = UDim2.new(0, 0, 0, 0)
	foreground.Parent = background
	
	-- Apply rounded corners to foreground too
	if style == "rounded" or style == "glossy" then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = foreground
	end
	
	-- Gradient effect for glossy style
	if style == "glossy" then
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, foreground.BackgroundColor3),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(
				math.min(255, foreground.BackgroundColor3.R * 255 + 40),
				math.min(255, foreground.BackgroundColor3.G * 255 + 40),
				math.min(255, foreground.BackgroundColor3.B * 255 + 40)
			)),
			ColorSequenceKeypoint.new(1, foreground.BackgroundColor3)
		})
		gradient.Rotation = 90
		gradient.Parent = foreground
	end
	
	-- Text Label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "HealthText"
	textLabel.Text = "100/100"
	textLabel.TextColor3 = options.colors and options.colors.text or theme.Text
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, -1.5, 0)
	textLabel.Parent = container
	
	-- Text outline for readability
	local textStroke = Instance.new("UIStroke")
	textStroke.Color = Color3.new(0, 0, 0)
	textStroke.Thickness = 1.5
	textStroke.Transparency = 0.3
	textStroke.Parent = textLabel
	
	-- Status Icons Container
	local statusContainer = Instance.new("Frame")
	statusContainer.Name = "StatusContainer"
	statusContainer.BackgroundTransparency = 1
	statusContainer.Size = UDim2.new(1, 0, 0.8, 0)
	statusContainer.Position = UDim2.new(0, 0, -2.8, 0)
	statusContainer.LayoutOrder = 1
	statusContainer.Parent = container
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = statusContainer
	
	return {
		Container = container,
		Background = background,
		Foreground = foreground,
		ShieldLayer = shieldLayer,
		TextLabel = textLabel,
		StatusContainer = statusContainer
	}
end

-- HealthBar Constructor
function HealthBar.new(target, options)
	options = options or {}
	
	-- Validate target
	if not target then
		warn("HealthBar: Target is nil")
		return nil
	end
	
	-- Create new instance
	local self = setmetatable({}, HealthBar)
	
	self._target = target
	self._options = options
	self._janitor = Janitor.new()
	self._statusIcons = {}
	self._lastHealth = 0
	self._lastMaxHealth = 100
	self._currentShield = 0
	self._maxShield = 0
	self._isLowHealth = false
	self._tweens = {}
	self._updateConnection = nil
	self._distanceCheckConnection = nil
	
	-- Apply options with defaults
	self._offset = options.offset or Vector3.new(0, 3, 0)
	self._style = options.style or "rounded"
	self._showText = options.showText ~= false
	self._maxDistance = options.maxDistance or 100
	self._updateSpeed = options.updateSpeed or 0.3
	self._lowHealthThreshold = options.lowHealthThreshold or 0.25
	self._theme = options.theme or DEFAULT_THEME
	self._customColors = options.colors or {}
	
	-- Initialize
	self:_createBillboard()
	self:_setupHealthTracking()
	
	return self
end

-- Create and position the BillboardGui
function HealthBar:_createBillboard()
	-- Get or create BillboardGui
	self._billboard = getBillboardFromPool()
	self._billboard.MaxDistance = self._maxDistance
	self._billboard.Enabled = true
	self._billboard.Adornee = self._target
	
	-- Create attachment point
	local attachment = Instance.new("Attachment")
	attachment.Name = "HealthBarAttachment"
	attachment.Parent = self._target
	attachment.Position = self._offset
	
	self._billboard.Adornee = self._target
	self._billboard.StudsOffset = Vector3.new(0, 0, 0)
	
	-- Create UI elements
	local uiElements = createHealthBarUI(self._billboard, {
		theme = self._theme,
		style = self._style,
		colors = self._customColors,
		showBorder = self._options.showBorder,
		customImage = self._options.customImage
	})
	
	self._container = uiElements.Container
	self._background = uiElements.Background
	self._foreground = uiElements.Foreground
	self._shieldLayer = uiElements.ShieldLayer
	self._textLabel = uiElements.TextLabel
	self._statusContainer = uiElements.StatusContainer
	
	-- Hide text if disabled
	if not self._showText then
		self._textLabel.Visible = false
	end
	
	-- Add to janitor for cleanup
	self._janitor:Add(self._billboard)
	self._janitor:Add(attachment)
	
	-- Parent to appropriate location
	if self._target:IsA("Model") then
		local player = Players:GetPlayerFromCharacter(self._target)
		if player then
			self._billboard.Parent = player:FindFirstChildOfClass("PlayerGui") or Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
		else
			-- NPC or object
			self._billboard.Parent = game:GetService("CoreGui")
		end
	else
		self._billboard.Parent = game:GetService("CoreGui")
	end
	
	-- Setup distance-based updates
	self:_setupDistanceUpdates()
end

-- Setup health tracking based on target type
function HealthBar:_setupHealthTracking()
	if self._target:IsA("Model") then
		-- Character with Humanoid
		local humanoid = self._target:FindFirstChildOfClass("Humanoid")
		if humanoid then
			self:_trackHumanoid(humanoid)
		else
			-- Wait for humanoid
			self._janitor:Add(self._target.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") then
					self:_trackHumanoid(child)
				end
			end))
		end
	elseif self._target:IsA("BasePart") then
		-- Part with custom health values
		self:_trackCustomHealth()
	end
end

-- Track Humanoid health
function HealthBar:_trackHumanoid(humanoid)
	-- Initial values
	self._lastHealth = humanoid.Health
	self._lastMaxHealth = humanoid.MaxHealth
	self:_updateHealthDisplay(humanoid.Health, humanoid.MaxHealth)
	
	-- Health changed signal
	local healthChangedConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		local newHealth = humanoid.Health
		local maxHealth = humanoid.MaxHealth
		
		if newHealth ~= self._lastHealth or maxHealth ~= self._lastMaxHealth then
			self:_updateHealthDisplay(newHealth, maxHealth)
			self._lastHealth = newHealth
			self._lastMaxHealth = maxHealth
		end
	end)
	
	self._janitor:Add(healthChangedConn)
	
	-- Max health changed signal
	local maxHealthChangedConn = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		self:_updateHealthDisplay(humanoid.Health, humanoid.MaxHealth)
	end)
	
	self._janitor:Add(maxHealthChangedConn)
	
	-- Handle character death/removal
	local diedConn = humanoid.Died:Connect(function()
		self:Destroy()
	end)
	
	self._janitor:Add(diedConn)
	
	-- Cleanup if humanoid is removed
	self._janitor:Add(humanoid.AncestryChanged:Connect(function()
		if not humanoid:IsDescendantOf(game) then
			self:Destroy()
		end
	end))
end

-- Track custom health values (for objects, vehicles, etc.)
function HealthBar:_trackCustomHealth()
	-- This would be implemented based on custom health system
	-- For now, we'll provide manual update methods
end

-- Setup distance-based update throttling
function HealthBar:_setupDistanceUpdates()
	local camera = workspace.CurrentCamera
	local lastUpdate = 0
	local UPDATE_INTERVAL = 0.1 -- 10Hz
	
	self._distanceCheckConnection = RunService.Heartbeat:Connect(function()
		local now = tick()
		if now - lastUpdate < UPDATE_INTERVAL then return end
		lastUpdate = now
		
		if not camera or not self._target or not self._target.Parent then
			return
		end
		
		-- Calculate distance
		local targetPos = self._target.Position
		local cameraPos = camera.CameraFrame.Position
		local distance = (targetPos - cameraPos).Magnitude
		
		-- Enable/disable based on distance
		if distance > self._maxDistance then
			if self._billboard.Enabled then
				self._billboard.Enabled = false
			end
		else
			if not self._billboard.Enabled then
				self._billboard.Enabled = true
			end
			
			-- Adjust opacity based on distance (optional)
			local alpha = 1 - math.clamp((distance - (self._maxDistance * 0.7)) / (self._maxDistance * 0.3), 0, 0.5)
			self._container.BackgroundTransparency = 1 - alpha
		end
	end)
	
	self._janitor:Add(self._distanceCheckConnection)
end

-- Update health display with animations
function HealthBar:_updateHealthDisplay(currentHealth, maxHealth)
	-- Validate values
	currentHealth = math.max(0, currentHealth or 0)
	maxHealth = math.max(1, maxHealth or 100)
	
	-- Calculate fill percentage
	local fill = math.clamp(currentHealth / maxHealth, 0, 1)
	
	-- Cancel previous tweens
	for _, tween in ipairs(self._tweens) do
		tween:Cancel()
	end
	self._tweens = {}
	
	-- Animate foreground width
	local tweenInfo = TweenInfo.new(
		self._updateSpeed,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	
	local foregroundTween = TweenService:Create(
		self._foreground,
		tweenInfo,
		{Size = UDim2.new(fill, 0, 1, 0)}
	)
	
	foregroundTween:Play()
	table.insert(self._tweens, foregroundTween)
	
	-- Update text
	if self._showText then
		self._textLabel.Text = string.format("%d/%d", math.floor(currentHealth), math.floor(maxHealth))
		
		-- Animate text color change
		local textColor = self._customColors.text or self._theme.Text
		
		if currentHealth < self._lastHealth then
			-- Damage flash
			local damageTween = TweenService:Create(
				self._textLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{TextColor3 = self._theme.DamageFlash}
			)
			damageTween:Play()
			table.insert(self._tweens, damageTween)
			
			-- Return to normal color
			task.delay(0.1, function()
				if self._textLabel then
					local returnTween = TweenService:Create(
						self._textLabel,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{TextColor3 = textColor}
					)
					returnTween:Play()
					table.insert(self._tweens, returnTween)
				end
			end)
			
			-- Shake effect for significant damage
			local damageAmount = self._lastHealth - currentHealth
			if damageAmount > maxHealth * 0.1 then
				self:_applyShakeEffect(0.2, 3)
			end
		elseif currentHealth > self._lastHealth then
			-- Heal flash
			local healTween = TweenService:Create(
				self._textLabel,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{TextColor3 = self._theme.HealFlash}
			)
			healTween:Play()
			table.insert(self._tweens, healTween)
			
			task.delay(0.1, function()
				if self._textLabel then
					local returnTween = TweenService:Create(
						self._textLabel,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{TextColor3 = textColor}
					)
					returnTween:Play()
					table.insert(self._tweens, returnTween)
				end
			end)
		end
	end
	
	-- Check for low health
	local wasLowHealth = self._isLowHealth
	self._isLowHealth = fill <= self._lowHealthThreshold
	
	if self._isLowHealth and not wasLowHealth then
		self:_startLowHealthPulse()
	elseif not self._isLowHealth and wasLowHealth then
		self:_stopLowHealthPulse()
	end
	
	-- Update bar color based on health percentage
	self:_updateBarColor(fill)
end

-- Update bar color based on health percentage
function HealthBar:_updateBarColor(fill)
	local targetColor
	
	if self._isLowHealth then
		targetColor = self._customColors.lowHealth or self._theme.Warning
	else
		targetColor = self._customColors.foreground or self._theme.Accent
		
		-- Optional: Color interpolation from green to red
		if self._options.useHealthGradient then
			local r = math.clamp(2 * (1 - fill), 0, 1)
			local g = math.clamp(2 * fill, 0, 1)
			targetColor = Color3.new(r, g, 0)
		end
	end
	
	local colorTween = TweenService:Create(
		self._foreground,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = targetColor}
	)
	
	colorTween:Play()
	table.insert(self._tweens, colorTween)
end

-- Apply shake effect
function HealthBar:_applyShakeEffect(duration, intensity)
	if not self._container then return end
	
	local startTime = tick()
	local startPosition = self._container.Position
	
	local connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		if elapsed > duration then
			self._container.Position = startPosition
			connection:Disconnect()
			return
		end
		
		local progress = elapsed / duration
		local shakeFactor = (1 - progress) * intensity
		
		local offsetX = (math.random() * 2 - 1) * shakeFactor
		local offsetY = (math.random() * 2 - 1) * shakeFactor * 0.5
		
		self._container.Position = startPosition + UDim2.new(0, offsetX, 0, offsetY)
	end)
	
	self._janitor:Add(connection)
end

-- Low health pulse effect
function HealthBar:_startLowHealthPulse()
	if self._lowHealthPulseConnection then
		self._lowHealthPulseConnection:Disconnect()
	end
	
	local pulseSpeed = 2 -- Pulses per second
	local minAlpha = 0.3
	local maxAlpha = 0.7
	
	self._lowHealthPulseConnection = RunService.Heartbeat:Connect(function()
		if not self._foreground then
			self._lowHealthPulseConnection:Disconnect()
			return
		end
		
		local time = tick() * math.pi * 2 * pulseSpeed
		local alpha = (math.sin(time) + 1) / 2 -- 0 to 1
		alpha = minAlpha + (maxAlpha - minAlpha) * alpha
		
		self._foreground.BackgroundTransparency = 1 - alpha
	end)
	
	self._janitor:Add(self._lowHealthPulseConnection)
end

function HealthBar:_stopLowHealthPulse()
	if self._lowHealthPulseConnection then
		self._lowHealthPulseConnection:Disconnect()
		self._lowHealthPulseConnection = nil
	end
	
	if self._foreground then
		self._foreground.BackgroundTransparency = 0
	end
end

-- Public API Methods

-- Update health manually (for custom health systems)
function HealthBar:UpdateHealth(current, max)
	self:_updateHealthDisplay(current, max)
end

-- Set shield/overhealth
function HealthBar:SetShield(shield, maxShield)
	self._currentShield = math.max(0, shield or 0)
	self._maxShield = math.max(0, maxShield or 0)
	
	if self._shieldLayer then
		if self._maxShield > 0 then
			self._shieldLayer.Visible = true
			local shieldFill = math.clamp(self._currentShield / self._maxShield, 0, 1)
			
			local tweenInfo = TweenInfo.new(
				0.3,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)
			
			local shieldTween = TweenService:Create(
				self._shieldLayer,
				tweenInfo,
				{Size = UDim2.new(shieldFill, 0, 1, 0)}
			)
			
			shieldTween:Play()
			table.insert(self._tweens, shieldTween)
		else
			self._shieldLayer.Visible = false
		end
	end
end

-- Add status icon
function HealthBar:AddStatusIcon(imageId, tooltipText, duration)
	local icon = Instance.new("ImageLabel")
	icon.Name = "StatusIcon"
	icon.Size = UDim2.new(0, 16, 0, 16)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://" .. imageId
	icon.LayoutOrder = #self._statusIcons + 1
	icon.Parent = self._statusContainer
	
	-- Tooltip
	if tooltipText then
		local tooltip = Instance.new("TextLabel")
		tooltip.Name = "Tooltip"
		tooltip.Text = tooltipText
		tooltip.TextSize = 12
		tooltip.BackgroundColor3 = Color3.new(0, 0, 0)
		tooltip.BackgroundTransparency = 0.5
		tooltip.TextColor3 = Color3.new(1, 1, 1)
		tooltip.Size = UDim2.new(0, 0, 0, 0)
		tooltip.Position = UDim2.new(0.5, 0, -1, 0)
		tooltip.Visible = false
		tooltip.Parent = icon
		
		-- Auto-size
		tooltip.AutomaticSize = Enum.AutomaticSize.XY
		
		-- Show/hide on hover
		local isMouseOver = false
		
		local enterConn = icon.MouseEnter:Connect(function()
			isMouseOver = true
			task.wait(0.3) -- Delay before showing
			if isMouseOver then
				tooltip.Visible = true
			end
		end)
		
		local leaveConn = icon.MouseLeave:Connect(function()
			isMouseOver = false
			tooltip.Visible = false
		end)
		
		self._janitor:Add(enterConn)
		self._janitor:Add(leaveConn)
	end
	
	table.insert(self._statusIcons, {
		Icon = icon,
		EndTime = duration and (tick() + duration) or nil
	})
	
	-- Auto-remove if duration specified
	if duration then
		task.delay(duration, function()
			self:RemoveStatusIcon(imageId)
		end)
	end
	
	return imageId
end

-- Remove status icon
function HealthBar:RemoveStatusIcon(imageId)
	for i, statusData in ipairs(self._statusIcons) do
		if statusData.Icon.Image:find(imageId) then
			statusData.Icon:Destroy()
			table.remove(self._statusIcons, i)
			break
		end
	end
end

-- Set visibility
function HealthBar:SetVisible(visible)
	if self._billboard then
		self._billboard.Enabled = visible
	end
end

-- Update position offset
function HealthBar:SetOffset(newOffset)
	self._offset = newOffset
	if self._billboard and self._billboard.Adornee then
		-- Find and update attachment
		for _, child in ipairs(self._billboard.Adornee:GetChildren()) do
			if child.Name == "HealthBarAttachment" then
				child.Position = newOffset
				break
			end
		end
	end
end

-- Change style dynamically
function HealthBar:SetStyle(newStyle)
	-- This would require recreating UI elements
	-- For simplicity, we'll just change colors
	self._style = newStyle
	-- Implementation depends on desired complexity
end

-- Destroy and cleanup
function HealthBar:Destroy()
	-- Stop effects
	self:_stopLowHealthPulse()
	
	-- Cancel tweens
	for _, tween in ipairs(self._tweens) do
		tween:Cancel()
	end
	
	-- Cleanup janitor
	self._janitor:Cleanup()
	
	-- Return billboard to pool
	if self._billboard and #BillboardPool < MAX_POOL_SIZE then
		-- Clear and disable
		for _, child in ipairs(self._billboard:GetChildren()) do
			child:Destroy()
		end
		self._billboard.Enabled = false
		self._billboard.Adornee = nil
		
		-- Add to pool
		table.insert(BillboardPool, self._billboard)
	end
	
	-- Clear references
	setmetatable(self, nil)
	for k in pairs(self) do
		self[k] = nil
	end
end

-- Module return
local HealthBarModule = {}

-- Public constructor
function HealthBarModule.new(target, options)
	return HealthBar.new(target, options)
end

-- Batch creation for teams
function HealthBarModule.CreateForTeam(team, options)
	local healthBars = {}
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team then
			local character = player.Character or player.CharacterAdded:Wait()
			healthBars[player] = HealthBar.new(character, options)
		end
	end
	
	-- Listen for new players joining team
	local conn = Players.PlayerAdded:Connect(function(player)
		player:GetPropertyChangedSignal("Team"):Connect(function()
			if player.Team == team then
				local character = player.Character or player.CharacterAdded:Wait()
				healthBars[player] = HealthBar.new(character, options)
			elseif healthBars[player] then
				healthBars[player]:Destroy()
				healthBars[player] = nil
			end
		end)
	end)
	
	return healthBars, conn
end

-- Set global theme
function HealthBarModule.SetGlobalTheme(customTheme)
	for key, value in pairs(customTheme) do
		DEFAULT_THEME[key] = value
	end
end

-- Get default theme
function HealthBarModule.GetDefaultTheme()
	return DEFAULT_THEME
end

-- Cleanup all health bars
function HealthBarModule.CleanupPool()
	for _, billboard in ipairs(BillboardPool) do
		billboard:Destroy()
	end
	BillboardPool = {}
end

return HealthBarModule