-- Trainer.lua
-- Dragnir AI Training System for Ball Trajectories and Parry Accuracy

local Trainer = {}

-- Configurations
local trainingSettings = {
	TrainingDuration = 10,  -- Time in seconds for each training session
	TrainingModes = {
		Basic = {speed = 30, variation = 0.1}, -- Default speed and slight variation
		Advanced = {speed = 60, variation = 0.3}, -- Increased speed and more randomization
		Random = {speed = math.random(30, 70), variation = math.random(0.1, 0.5)} -- Random mode
	}
}

local activeTrainingSession = nil
local trainingLog = {}

-- Start a training session with a specified mode
function Trainer:StartSession(mode)
	local modeSettings = trainingSettings.TrainingModes[mode] or trainingSettings.TrainingModes.Basic
	local duration = trainingSettings.TrainingDuration

	activeTrainingSession = {
		Mode = mode,
		Speed = modeSettings.speed,
		Variation = modeSettings.variation,
		StartTime = tick(),
		EndTime = tick() + duration
	}

	warn("[Trainer] Training session started in", mode, "mode.")

	-- Generate and simulate ball trajectories
	self:SimulateBallTrajectories(activeTrainingSession)

	-- Training session time limit
	task.spawn(function()
		while tick() < activeTrainingSession.EndTime do
			task.wait(0.1)
		end
		self:EndSession()
	end)
end

-- Simulate ball trajectories based on selected training mode
function Trainer:SimulateBallTrajectories(session)
	-- Simulate multiple balls with varying speed and variation
	local ballCount = 5  -- Number of balls per session
	for i = 1, ballCount do
		local ball = Instance.new("Part")
		ball.Shape = Enum.PartType.Ball
		ball.Size = Vector3.new(1, 1, 1)
		ball.Position = Vector3.new(math.random(-20, 20), 50, math.random(-20, 20))
		ball.Anchored = false
		ball.Parent = workspace

		local velocity = Vector3.new(math.random(-session.Speed, session.Speed), math.random(-session.Speed, session.Speed), math.random(-session.Speed, session.Speed))
		ball.Velocity = velocity

		-- Apply random trajectory variation
		local variation = session.Variation
		local randomAngle = math.random(-variation, variation)
		ball.CFrame = ball.CFrame * CFrame.Angles(randomAngle, randomAngle, randomAngle)

		-- Log ball trajectory
		table.insert(trainingLog, {
			Ball = ball,
			Velocity = velocity,
			Variation = randomAngle
		})

		-- Destroy ball after training duration
		task.delay(trainingSettings.TrainingDuration, function()
			if ball and ball.Parent then
				ball:Destroy()
			end
		end)
	end
end

-- End the current training session and evaluate performance
function Trainer:EndSession()
	if not activeTrainingSession then return end

	-- Log end time and calculate session duration
	local sessionDuration = tick() - activeTrainingSession.StartTime
	print("[Trainer] Training session ended. Duration:", sessionDuration, "seconds.")

	-- Evaluate performance (simple example: track ball catches or missed parries)
	local performance = self:EvaluatePerformance()

	-- Provide feedback
	self:ProvideFeedback(performance)

	-- Clear training session and log
	activeTrainingSession = nil
	trainingLog = {}
end

-- Evaluate performance based on ball parry accuracy (dummy calculation)
function Trainer:EvaluatePerformance()
	local successfulParries = 0
	local totalParries = #trainingLog

	-- Dummy logic: assuming 70% of the balls are successfully parried
	successfulParries = math.floor(totalParries * 0.7)
	local accuracy = successfulParries / totalParries

	return {
		Accuracy = accuracy,
		SuccessfulParries = successfulParries,
		TotalParries = totalParries
	}
end

-- Provide feedback on performance (simple text-based feedback)
function Trainer:ProvideFeedback(performance)
	if performance.Accuracy >= 0.9 then
		print("[Trainer] Excellent! Keep up the great work.")
	elseif performance.Accuracy >= 0.7 then
		print("[Trainer] Good job, but there's room for improvement.")
	else
		print("[Trainer] Keep practicing! You'll improve over time.")
	end
end

-- Retrieve the training log for post-training analysis
function Trainer:GetTrainingLog()
	return trainingLog
end

return Trainer