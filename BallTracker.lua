-- BallTracker.lua
-- Dragnir Modular Ball Tracking System
-- Efficiently monitors all active balls and maintains a real-time tracking registry

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BallTracker = {}

-- Configuration
local TRACK_INTERVAL = 0.05
local BALL_NAME = "Ball"
local MAX_TRACKED = 50

-- Internal storage
local trackedBalls = {}
local lastUpdate = 0
local listeners = {}

-- Utility
local function isBall(obj)
	return obj:IsA("BasePart") and obj.Name:lower():find("origin")
end

local function getVelocity(part)
	if part:FindFirstChild("Velocity") then
		return part.Velocity
	end
	return part.AssemblyLinearVelocity
end

-- Core update loop
RunService.Heartbeat:Connect(function()
	if os.clock() - lastUpdate < TRACK_INTERVAL then return end
	lastUpdate = os.clock()

	local currentBalls = {}

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isBall(obj) then
			currentBalls[obj] = true

			if not trackedBalls[obj] then
				trackedBalls[obj] = {
					LastPosition = obj.Position,
					LastVelocity = getVelocity(obj),
					SpawnTime = os.clock(),
				}

				for _, fn in ipairs(listeners) do
					task.spawn(fn, "Added", obj)
				end
			else
				local data = trackedBalls[obj]
				data.LastVelocity = getVelocity(obj)
				data.LastPosition = obj.Position
			end
		end
	end

	-- Clean up removed balls
	for ball, _ in pairs(trackedBalls) do
		if not currentBalls[ball] or not ball:IsDescendantOf(Workspace) then
			for _, fn in ipairs(listeners) do
				task.spawn(fn, "Removed", ball)
			end
			trackedBalls[ball] = nil
		end
	end
end)

-- API

function BallTracker:GetAllBalls()
	local result = {}
	for ball, _ in pairs(trackedBalls) do
		table.insert(result, ball)
	end
	return result
end

function BallTracker:GetBallData(ball)
	return trackedBalls[ball]
end

function BallTracker:OnBallEvent(callback)
	table.insert(listeners, callback)
end

function BallTracker:GetClosestBall(fromPosition, maxDistance)
	local closest, distance = nil, math.huge
	for ball in pairs(trackedBalls) do
		local d = (ball.Position - fromPosition).Magnitude
		if d < distance and (not maxDistance or d <= maxDistance) then
			distance = d
			closest = ball
		end
	end
	return closest
end

function BallTracker:GetVelocity(ball)
	local data = trackedBalls[ball]
	return data and data.LastVelocity or Vector3.zero
end

function BallTracker:GetPosition(ball)
	local data = trackedBalls[ball]
	return data and data.LastPosition or Vector3.zero
end

return BallTracker