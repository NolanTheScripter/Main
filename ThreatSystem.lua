-- ThreatSystem.lua
-- Enhanced Adaptive Threat Prioritization System
-- by Nolan Dragnir

local ThreatSystem = {}

-- Dynamic weight configuration
local weights = {
	health = 1.75,
	proximity = 2.25,
	velocity = 1.6,
	trajectory = 2.0,
	countPressure = 1.3,
	environment = 1.6,
	predictionConfidence = 1.5,
	threatSignature = 2.2,
	zoneWeighting = 1.8,
}

-- Signature patterns for known threats
local threatSignatures = {
	ZigZag = 2.0,
	Spin = 1.5,
	StallThenAccelerate = 2.2,
	Curve = 1.8,
	RandomBounce = 2.4,
}

-- Heatmapped danger zones (e.g. near goal, tight corners)
local function getZoneWeight(ball)
	if ball.InDangerZone then
		return 1.5
	elseif ball.InNeutralZone then
		return 1.0
	elseif ball.InSafeZone then
		return 0.75
	end
	return 1.0
end

-- Prediction confidence booster
local function predictionScore(confidence)
	return math.clamp(confidence or 0.5, 0.1, 1.0)
end

-- Distance calculator
local function getDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

-- Main evaluator
function ThreatSystem:Evaluate(context)
	local player = context.player
	local balls = context.balls
	local threats = {}
	local ballCount = #balls

	for _, ball in ipairs(balls) do
		local score = 0

		-- Proximity
		local distance = getDistance(player.Position, ball.Position)
		score += (1 / math.max(distance, 1)) * weights.proximity

		-- Velocity
		score += (ball.Velocity.Magnitude / 100) * weights.velocity

		-- Trajectory
		local dirToPlayer = (player.Position - ball.Position).Unit
		local trajectoryDot = ball.Velocity.Unit:Dot(dirToPlayer)
		score += math.clamp(trajectoryDot, 0, 1) * weights.trajectory

		-- Health-based amplification
		local healthMod = 1 + ((1 - player.HealthPercent) * weights.health)
		score *= healthMod

		-- Ball pressure
		score *= (1 + (ballCount - 1) * weights.countPressure)

		-- Prediction confidence
		score += predictionScore(ball.Confidence) * weights.predictionConfidence

		-- Environment factor
		if ball.HasObstacles then
			score *= weights.environment
		end

		-- Threat signature boost
		if ball.Signature and threatSignatures[ball.Signature] then
			score += threatSignatures[ball.Signature] * weights.threatSignature
		end

		-- Zone danger factor
		score *= getZoneWeight(ball) * weights.zoneWeighting

		table.insert(threats, {
			Ball = ball,
			Score = score,
			Priority = score > 5 and "CRITICAL" or score > 3 and "HIGH" or "NORMAL"
		})
	end

	table.sort(threats, function(a, b)
		return a.Score > b.Score
	end)

	return threats[1] or nil, threats
end

return ThreatSystem