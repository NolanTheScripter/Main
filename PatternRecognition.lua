-- PatternRecognition.lua
-- Dragnir Advanced Ball Behavior Pattern Analyzer
-- Tracks recurring patterns, detects anomalies, and boosts prediction accuracy

local PatternRecognition = {}

-- Configuration
local config = {
	historyLimit = 30,
	confidenceDecay = 0.97,
	signatureThreshold = 0.75,
	alertOnAnomaly = true,
}

-- Internal pattern definitions
local knownPatterns = {
	ZigZag = function(history)
		local changes = 0
		for i = 2, #history - 1 do
			local a = history[i - 1].Velocity.Unit
			local b = history[i].Velocity.Unit
			local dot = a:Dot(b)
			if dot < 0.25 then changes += 1 end
		end
		return changes / #history
	end,

	Spin = function(history)
		local rotations = 0
		for i = 2, #history do
			local cross = history[i - 1].Velocity:Cross(history[i].Velocity).Magnitude
			if cross > 0.5 then rotations += 1 end
		end
		return rotations / #history
	end,

	StallThenAccelerate = function(history)
		if #history < 4 then return 0 end
		local slowed = 0
		for i = 1, #history // 2 do
			if history[i].Velocity.Magnitude < 10 then slowed += 1 end
		end
		local spedUp = history[#history].Velocity.Magnitude > 50
		return slowed / (#history / 2) > 0.6 and spedUp and 1 or 0
	end,

	Curve = function(history)
		local deviation = 0
		for i = 2, #history do
			local offset = (history[i].Position - history[i - 1].Position).Unit
			local expected = (history[#history].Position - history[1].Position).Unit
			local dot = offset:Dot(expected)
			deviation += (1 - dot)
		end
		return deviation / #history
	end
}

-- Ball memory system
local ballMemory = {}

function PatternRecognition:Track(ballId, position, velocity)
	local memory = ballMemory[ballId] or {
		history = {},
		confidence = 0.5,
		signature = nil,
		anomaly = false,
	}
	table.insert(memory.history, {
		Position = position,
		Velocity = velocity,
		Timestamp = os.clock()
	})
	if #memory.history > config.historyLimit then
		table.remove(memory.history, 1)
	end

	-- Analyze for known patterns
	local bestMatch, bestScore = nil, 0
	for pattern, func in pairs(knownPatterns) do
		local score = func(memory.history)
		if score > bestScore then
			bestScore = score
			bestMatch = pattern
		end
	end

	-- Assign signature if strong enough
	if bestScore >= config.signatureThreshold then
		memory.signature = bestMatch
		memory.confidence = math.min(1.0, memory.confidence + 0.1)
	else
		memory.confidence *= config.confidenceDecay
		if memory.confidence < 0.3 and config.alertOnAnomaly then
			memory.anomaly = true
		end
	end

	ballMemory[ballId] = memory
end

function PatternRecognition:GetSignature(ballId)
	local memory = ballMemory[ballId]
	return memory and memory.signature or nil
end

function PatternRecognition:GetConfidence(ballId)
	local memory = ballMemory[ballId]
	return memory and memory.confidence or 0.5
end

function PatternRecognition:IsAnomalous(ballId)
	local memory = ballMemory[ballId]
	return memory and memory.anomaly or false
end

return PatternRecognition