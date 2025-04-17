-- ReplayAnalyzer.lua
-- Dragnir Enhanced Replay Analyzer System

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ReplayAnalyzer = {}

--// Storage
local ReplayData = {
	PlayerActions = {},
	Predictions = {},
	BallStates = {}
}

local sessionID = HttpService:GenerateGUID(false)
local startTime = tick()

--// Logging Functions

function ReplayAnalyzer:LogPlayerAction(actionType, data)
	table.insert(ReplayData.PlayerActions, {
		Timestamp = tick() - startTime,
		Action = actionType,
		Data = data
	})
end

function ReplayAnalyzer:LogPrediction(predictInfo)
	table.insert(ReplayData.Predictions, {
		Timestamp = tick() - startTime,
		Position = predictInfo.Position,
		Velocity = predictInfo.Velocity,
		Confidence = predictInfo.Confidence,
		AlternativePaths = predictInfo.Alternatives or {}
	})
end

function ReplayAnalyzer:LogBallState(stateInfo)
	table.insert(ReplayData.BallStates, {
		Timestamp = tick() - startTime,
		Position = stateInfo.Position,
		Velocity = stateInfo.Velocity,
		Rotation = stateInfo.Rotation,
		Behavior = stateInfo.BehaviorTag
	})
end

--// Analysis Functions

function ReplayAnalyzer:AnalyzeMissedParries()
	local missed = {}
	for _, action in ipairs(ReplayData.PlayerActions) do
		if action.Action == "ParryAttempt" then
			local success = action.Data.Success
			if not success then
				table.insert(missed, action)
			end
		end
	end
	return missed
end

function ReplayAnalyzer:FindAlternativePredictionMoments()
	local moments = {}
	for _, prediction in ipairs(ReplayData.Predictions) do
		if #prediction.AlternativePaths > 0 then
			table.insert(moments, prediction)
		end
	end
	return moments
end

function ReplayAnalyzer:ComparePredictionsToActual()
	local comparisons = {}
	for i, prediction in ipairs(ReplayData.Predictions) do
		local actual = ReplayData.BallStates[i]
		if actual then
			local delta = (actual.Position - prediction.Position).Magnitude
			table.insert(comparisons, {
				Timestamp = prediction.Timestamp,
				Error = delta,
				Confidence = prediction.Confidence
			})
		end
	end
	return comparisons
end

--// Export

function ReplayAnalyzer:GetRawData()
	return ReplayData
end

function ReplayAnalyzer:ExportToJSON()
	return HttpService:JSONEncode({
		SessionID = sessionID,
		StartTime = startTime,
		Data = ReplayData
	})
end

function ReplayAnalyzer:Reset()
	ReplayData = {
		PlayerActions = {},
		Predictions = {},
		BallStates = {}
	}
	startTime = tick()
end

return ReplayAnalyzer