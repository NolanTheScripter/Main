-- SkillAdapter.lua
-- Dragnir Adaptive Parry System Based on Player Skill Level

local SkillAdapter = {}

-- Skill Tiers (can be dynamically expanded)
local SkillLevels = {
	Beginner = {
		ParryRadius = 8,
		ReactionTime = 0.35,
		ThreatSensitivity = 0.5
	},
	Intermediate = {
		ParryRadius = 6,
		ReactionTime = 0.25,
		ThreatSensitivity = 0.7
	},
	Advanced = {
		ParryRadius = 4,
		ReactionTime = 0.15,
		ThreatSensitivity = 0.9
	},
	Elite = {
		ParryRadius = 2.5,
		ReactionTime = 0.075,
		ThreatSensitivity = 1.0
	}
}

-- Current active settings
local currentSettings = SkillLevels.Intermediate

-- Get current parameters
function SkillAdapter:GetSettings()
	return currentSettings
end

-- Set skill level manually or by detected profile
function SkillAdapter:SetLevel(level)
	if SkillLevels[level] then
		currentSettings = SkillLevels[level]
		warn("[SkillAdapter] Skill level set to:", level)
	else
		warn("[SkillAdapter] Invalid skill level:", level)
	end
end

-- Auto-detect based on performance metrics
function SkillAdapter:AutoDetect(stats)
	-- Example metrics: avgParryAccuracy, avgResponseTime
	local accuracy = stats.avgParryAccuracy or 0
	local response = stats.avgResponseTime or 0.3

	if accuracy >= 0.95 and response <= 0.1 then
		self:SetLevel("Elite")
	elseif accuracy >= 0.85 then
		self:SetLevel("Advanced")
	elseif accuracy >= 0.65 then
		self:SetLevel("Intermediate")
	else
		self:SetLevel("Beginner")
	end
end

-- Modify external values with skill-adapted ones
function SkillAdapter:ApplyTo(parrySystem)
	if not parrySystem then return end
	parrySystem:SetParryRadius(currentSettings.ParryRadius)
	parrySystem:SetReactionDelay(currentSettings.ReactionTime)
	parrySystem:SetThreatSensitivity(currentSettings.ThreatSensitivity)
end

return SkillAdapter