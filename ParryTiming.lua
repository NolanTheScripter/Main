-- ParryTiming.lua
-- Dragnir Adaptive Parry Timing Engine

local RunService = game:GetService("RunService")

local ParryTiming = {}

-- Settings
local BASE_REACTION_TIME = 0.12 -- seconds
local MIN_REACTION_TIME = 0.045
local MAX_REACTION_TIME = 0.25
local SPEED_SCALE = 0.00075
local THREAT_BONUS = 0.08
local SLOW_BALL_DELAY = 0.1

-- Ball data override (optional tuning per type)
local BallTypeDelays = {
	["Heavy"] = 0.04,
	["Light"] = 0.1,
	["Curved"] = 0.075,
	["Zigzag"] = 0.09,
}

-- Internal state
local lastParryTime = 0
local currentCooldown = 0

-- Calculate adaptive parry timing
function ParryTiming:Calculate(ballData)
	if not ballData or not ballData.Speed then return BASE_REACTION_TIME end

	local baseTime = BASE_REACTION_TIME
	local speed = ballData.Speed
	local threat = ballData.Threat or 0
	local typeName = ballData.Type or "Default"

	-- Apply custom ball type delay
	local typeBonus = BallTypeDelays[typeName] or 0

	-- Adjust base time based on speed
	local dynamicAdjustment = math.clamp(baseTime - (speed * SPEED_SCALE), MIN_REACTION_TIME, MAX_REACTION_TIME)

	-- Threat level urgency
	if threat >= 0.75 then
		dynamicAdjustment -= THREAT_BONUS
	elseif threat <= 0.25 then
		dynamicAdjustment += SLOW_BALL_DELAY
	end

	local finalTiming = math.clamp(dynamicAdjustment + typeBonus, MIN_REACTION_TIME, MAX_REACTION_TIME)
	return finalTiming
end

-- Cooldown management
function ParryTiming:StartCooldown()
	lastParryTime = os.clock()
end

function ParryTiming:IsOnCooldown()
	return (os.clock() - lastParryTime) < currentCooldown
end

function ParryTiming:SetCooldown(duration)
	currentCooldown = duration or 0
end

-- API: For logging/debugging
function ParryTiming:GetLastParryTime()
	return lastParryTime
end

function ParryTiming:GetCurrentCooldown()
	return currentCooldown
end

return ParryTiming