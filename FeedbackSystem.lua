-- FeedbackSystem.lua
-- Dragnir Customizable Alerts & Feedback Core

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local FeedbackSystem = {}

--// Configuration
local settings = {
	EnableAudio = true,
	EnableVisual = true,
	LowConfidenceThreshold = 0.3,
	ImpactWarningThreshold = 0.6,
	AudioAssets = {
		ImpactWarning = "rbxassetid://123456789",  -- Replace with real ID
		SuccessfulParry = "rbxassetid://987654321"
	},
	HUD = {
		Enabled = true,
		ShowPredictionConfidence = true,
		ShowBallType = true,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Position = UDim2.new(0.01, 0, 0.85, 0)
	}
}

--// Internal HUD UI
local screenGui, confidenceLabel

local function createHUD()
	if not settings.HUD.Enabled then return end

	screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
	screenGui.Name = "DragnirFeedbackHUD"
	screenGui.ResetOnSpawn = false

	confidenceLabel = Instance.new("TextLabel", screenGui)
	confidenceLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
	confidenceLabel.Position = settings.HUD.Position
	confidenceLabel.BackgroundTransparency = 0.3
	confidenceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	confidenceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	confidenceLabel.Font = settings.HUD.Font
	confidenceLabel.TextSize = settings.HUD.TextSize
	confidenceLabel.Text = "Awaiting Prediction..."
	confidenceLabel.ZIndex = 10
end

--// Play audio feedback
function FeedbackSystem:PlaySound(type)
	if not settings.EnableAudio then return end

	local soundId = settings.AudioAssets[type]
	if not soundId then return end

	local sound = Instance.new("Sound", SoundService)
	sound.SoundId = soundId
	sound.Volume = 0.8
	sound.PlayOnRemove = true
	sound:Destroy()
end

--// Update visual feedback
function FeedbackSystem:UpdateVisual(confidence, ballType)
	if not settings.EnableVisual or not confidenceLabel then return end

	local confidenceText = string.format("Confidence: %.2f", confidence)
	if ballType and settings.HUD.ShowBallType then
		confidenceText = confidenceText .. " | Type: " .. tostring(ballType)
	end

	if confidence < settings.LowConfidenceThreshold then
		confidenceLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	elseif confidence > 0.8 then
		confidenceLabel.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		confidenceLabel.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
	end

	confidenceLabel.Text = confidenceText
end

--// Feedback for successful parry
function FeedbackSystem:ParrySuccess()
	self:PlaySound("SuccessfulParry")
end

--// Feedback for imminent danger
function FeedbackSystem:ThreatWarning(confidence)
	if confidence >= settings.ImpactWarningThreshold then
		self:PlaySound("ImpactWarning")
	end
end

--// Cleanup
function FeedbackSystem:Destroy()
	if screenGui then
		screenGui:Destroy()
	end
end

--// Initialize
createHUD()

return FeedbackSystem