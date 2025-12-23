--[[
	NOTIFICATION MANAGER - Modern Minimalist Dark Theme
	
	A clean, client-side notification system with:
	- Stack notifications (max 3 visible)
	- Queue system for overflow
	- Auto-dismiss with progress bar countdown
	- Manual close button
	- Smooth slide + scale animations
	- Mobile support
	
	Usage:
		local NotificationManager = require(path.to.NotificationManager)
		
		NotificationManager:Notify({
			Title = "Achievement Unlocked!",
			Message = "You've collected 100 coins!",
			Duration = 5,
			Icon = "rbxassetid://YOUR_IMAGE_ID", -- Optional
			Buttons = { -- Optional
				{Text = "Claim", Callback = function() print("Claimed!") end},
				{Text = "Dismiss", Callback = function() print("Dismissed") end}
			}
		})
]]

local NotificationManager = {}

-- ========================================
-- CONFIGURATION
-- ========================================
local CONFIG = {
	MaxVisible = 3,              -- Maximum notifications on screen at once
	DefaultDuration = 5,         -- Default auto-dismiss time (seconds)
	AnimationSpeed = 0.4,        -- Animation duration (seconds)
	Spacing = 10,                -- Space between notifications
	
	-- Position (bottom-right corner)
	OffsetX = 20,                -- Distance from right edge
	OffsetY = 20,                -- Distance from bottom edge
	
	-- Size
	NotificationWidth = 350,
	NotificationHeight = 120,
	
	-- Colors (Dark Theme)
	BackgroundColor = Color3.fromRGB(25, 25, 30),
	BackgroundTransparency = 0.05,
	
	TitleColor = Color3.fromRGB(255, 255, 255),
	MessageColor = Color3.fromRGB(200, 200, 200),
	
	ProgressBarColor = Color3.fromRGB(100, 150, 255),
	ButtonColor = Color3.fromRGB(50, 50, 60),
	ButtonHoverColor = Color3.fromRGB(70, 70, 80),
	
	CloseButtonColor = Color3.fromRGB(255, 80, 80),
}

-- ========================================
-- VARIABLES
-- ========================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui
local ActiveNotifications = {}  -- Currently visible notifications
local NotificationQueue = {}    -- Waiting notifications

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- Create the main ScreenGui container
local function CreateScreenGui()
	if ScreenGui then return ScreenGui end
	
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NotificationSystem"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui
	
	return ScreenGui
end

-- Calculate position for a notification based on its index
local function GetNotificationPosition(index)
	local yOffset = CONFIG.OffsetY + ((CONFIG.NotificationHeight + CONFIG.Spacing) * (index - 1))
	
	return UDim2.new(
		1, -(CONFIG.OffsetX + CONFIG.NotificationWidth),  -- Right side
		1, -(yOffset + CONFIG.NotificationHeight)         -- Bottom side
	)
end

-- Reposition all active notifications with smooth animation
local function RepositionNotifications()
	for i, notif in ipairs(ActiveNotifications) do
		local newPosition = GetNotificationPosition(i)
		
		local tween = TweenService:Create(
			notif.Frame,
			TweenInfo.new(CONFIG.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Position = newPosition}
		)
		tween:Play()
	end
end

-- ========================================
-- NOTIFICATION CREATION
-- ========================================

local function CreateNotificationFrame(data)
	local frame = Instance.new("Frame")
	frame.Name = "Notification"
	frame.Size = UDim2.new(0, CONFIG.NotificationWidth, 0, CONFIG.NotificationHeight)
	frame.BackgroundColor3 = CONFIG.BackgroundColor
	frame.BackgroundTransparency = CONFIG.BackgroundTransparency
	frame.BorderSizePixel = 0
	
	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	
	-- Subtle shadow effect
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = frame
	
	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = frame
	
	-- Icon (if provided)
	local contentStartX = 0
	if data.Icon then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0, 0, 0, 0)
		icon.Image = data.Icon
		icon.BackgroundTransparency = 1
		icon.Parent = frame
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 8)
		iconCorner.Parent = icon
		
		contentStartX = 50
	end
	
	-- Close Button (X)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 24, 0, 24)
	closeButton.Position = UDim2.new(1, -24, 0, 0)
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.BackgroundColor3 = CONFIG.CloseButtonColor
	closeButton.BackgroundTransparency = 0.3
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = frame
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -(contentStartX + 35), 0, 20)
	title.Position = UDim2.new(0, contentStartX, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = data.Title or "Notification"
	title.TextColor3 = CONFIG.TitleColor
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = frame
	
	-- Message
	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.Size = UDim2.new(1, -contentStartX, 0, 35)
	message.Position = UDim2.new(0, contentStartX, 0, 22)
	message.BackgroundTransparency = 1
	message.Text = data.Message or ""
	message.TextColor3 = CONFIG.MessageColor
	message.TextSize = 13
	message.Font = Enum.Font.Gotham
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.TextWrapped = true
	message.Parent = frame
	
	-- Progress Bar Background
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBackground"
	progressBg.Size = UDim2.new(1, 0, 0, 3)
	progressBg.Position = UDim2.new(0, 0, 1, -3)
	progressBg.AnchorPoint = Vector2.new(0, 1)
	progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = frame
	
	-- Progress Bar Fill
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, 0, 1, 0)
	progressBar.BackgroundColor3 = CONFIG.ProgressBarColor
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBg
	
	-- Buttons (if provided)
	if data.Buttons and #data.Buttons > 0 then
		local buttonContainer = Instance.new("Frame")
		buttonContainer.Name = "ButtonContainer"
		buttonContainer.Size = UDim2.new(1, -contentStartX, 0, 25)
		buttonContainer.Position = UDim2.new(0, contentStartX, 1, -32)
		buttonContainer.BackgroundTransparency = 1
		buttonContainer.Parent = frame
		
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.Padding = UDim.new(0, 8)
		layout.Parent = buttonContainer
		
		for _, buttonData in ipairs(data.Buttons) do
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 70, 1, 0)
			button.BackgroundColor3 = CONFIG.ButtonColor
			button.BorderSizePixel = 0
			button.Text = buttonData.Text or "Button"
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextSize = 12
			button.Font = Enum.Font.GothamMedium
			button.Parent = buttonContainer
			
			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 6)
			btnCorner.Parent = button
			
			-- Button hover effect
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ButtonHoverColor}):Play()
			end)
			
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ButtonColor}):Play()
			end)
			
			-- Button click
			if buttonData.Callback then
				button.MouseButton1Click:Connect(buttonData.Callback)
			end
		end
	end
	
	return frame, closeButton, progressBar
end

-- ========================================
-- ANIMATION FUNCTIONS
-- ========================================

local function AnimateIn(frame)
	-- Start position (off-screen to the right)
	local finalPosition = frame.Position
	frame.Position = UDim2.new(
		finalPosition.X.Scale, finalPosition.X.Offset + 400,
		finalPosition.Y.Scale, finalPosition.Y.Offset
	)
	frame.Size = UDim2.new(0, CONFIG.NotificationWidth * 0.8, 0, CONFIG.NotificationHeight * 0.8)
	
	-- Slide in + Scale up
	local tweenInfo = TweenInfo.new(
		CONFIG.AnimationSpeed,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	
	local positionTween = TweenService:Create(frame, tweenInfo, {Position = finalPosition})
	local sizeTween = TweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(0, CONFIG.NotificationWidth, 0, CONFIG.NotificationHeight)
	})
	
	positionTween:Play()
	sizeTween:Play()
end

local function AnimateOut(frame, callback)
	local tweenInfo = TweenInfo.new(
		CONFIG.AnimationSpeed * 0.8,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)
	
	-- Slide out to right + fade + scale down
	local targetPosition = UDim2.new(
		frame.Position.X.Scale, frame.Position.X.Offset + 400,
		frame.Position.Y.Scale, frame.Position.Y.Offset
	)
	
	local positionTween = TweenService:Create(frame, tweenInfo, {Position = targetPosition})
	local transparencyTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
	local sizeTween = TweenService:Create(frame, tweenInfo, {
		Size = UDim2.new(0, CONFIG.NotificationWidth * 0.8, 0, CONFIG.NotificationHeight * 0.8)
	})
	
	positionTween:Play()
	transparencyTween:Play()
	sizeTween:Play()
	
	positionTween.Completed:Connect(function()
		frame:Destroy()
		if callback then callback() end
	end)
end

-- ========================================
-- NOTIFICATION MANAGEMENT
-- ========================================

local function RemoveNotification(notificationData)
	-- Find and remove from active list
	for i, notif in ipairs(ActiveNotifications) do
		if notif == notificationData then
			table.remove(ActiveNotifications, i)
			break
		end
	end
	
	-- Animate out
	AnimateOut(notificationData.Frame, function()
		-- Reposition remaining notifications
		RepositionNotifications()
		
		-- Show next queued notification
		if #NotificationQueue > 0 then
			local nextNotif = table.remove(NotificationQueue, 1)
			NotificationManager:Notify(nextNotif)
		end
	end)
end

local function StartProgressBar(notificationData, duration)
	local progressBar = notificationData.ProgressBar
	
	-- Animate progress bar from full to empty
	local tween = TweenService:Create(
		progressBar,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{Size = UDim2.new(0, 0, 1, 0)}
	)
	
	notificationData.ProgressTween = tween
	tween:Play()
	
	-- Auto-dismiss after duration
	tween.Completed:Connect(function()
		if notificationData.Frame and notificationData.Frame.Parent then
			RemoveNotification(notificationData)
		end
	end)
end

-- ========================================
-- PUBLIC API
-- ========================================

function NotificationManager:Notify(data)
	-- Validate data
	if not data or type(data) ~= "table" then
		warn("NotificationManager: Invalid notification data")
		return
	end
	
	-- If max notifications reached, add to queue
	if #ActiveNotifications >= CONFIG.MaxVisible then
		table.insert(NotificationQueue, data)
		return
	end
	
	-- Ensure ScreenGui exists
	CreateScreenGui()
	
	-- Create notification
	local frame, closeButton, progressBar = CreateNotificationFrame(data)
	frame.Parent = ScreenGui
	
	-- Create notification data object
	local notificationData = {
		Frame = frame,
		CloseButton = closeButton,
		ProgressBar = progressBar,
		Data = data
	}
	
	-- Add to active notifications
	table.insert(ActiveNotifications, notificationData)
	
	-- Set initial position
	frame.Position = GetNotificationPosition(#ActiveNotifications)
	
	-- Animate in
	AnimateIn(frame)
	
	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		if notificationData.ProgressTween then
			notificationData.ProgressTween:Cancel()
		end
		RemoveNotification(notificationData)
	end)
	
	-- Start progress bar countdown
	local duration = data.Duration or CONFIG.DefaultDuration
	StartProgressBar(notificationData, duration)
end

-- Initialize (wait for game to load)
if not game:IsLoaded() then
	game.Loaded:Wait()
end

return NotificationManager