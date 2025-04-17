-- ObstacleHandler.lua
-- Dragnir Environmental Obstacle Detection System

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local ObstacleHandler = {}

-- Settings
local SCAN_INTERVAL = 0.2
local OBSTACLE_TAGS = { "Wall", "Barrier", "Obstacle" }
local MAX_OBSTACLES = 100

-- Internal state
local trackedObstacles = {}
local lastScan = 0
local listeners = {}

-- Utils
local function isObstacle(part)
	if not part:IsA("BasePart") then return false end
	for _, tag in ipairs(OBSTACLE_TAGS) do
		if part.Name:lower():find(tag:lower()) then
			return true
		end
	end
	return false
end

-- Core scanner
local function scanObstacles()
	local current = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isObstacle(obj) then
			current[obj] = true
			if not trackedObstacles[obj] then
				trackedObstacles[obj] = {
					Size = obj.Size,
					Position = obj.Position,
					Normal = obj.CFrame.LookVector,
				}
				for _, fn in ipairs(listeners) do
					task.spawn(fn, "Added", obj)
				end
			else
				local data = trackedObstacles[obj]
				data.Position = obj.Position
				data.Normal = obj.CFrame.LookVector
			end
		end
	end

	for obstacle, _ in pairs(trackedObstacles) do
		if not current[obstacle] or not obstacle:IsDescendantOf(Workspace) then
			for _, fn in ipairs(listeners) do
				task.spawn(fn, "Removed", obstacle)
			end
			trackedObstacles[obstacle] = nil
		end
	end
end

-- Live update
RunService.Heartbeat:Connect(function()
	if os.clock() - lastScan >= SCAN_INTERVAL then
		lastScan = os.clock()
		scanObstacles()
	end
end)

-- API
function ObstacleHandler:GetAllObstacles()
	local result = {}
	for obj, _ in pairs(trackedObstacles) do
		table.insert(result, obj)
	end
	return result
end

function ObstacleHandler:GetObstacleData(obstacle)
	return trackedObstacles[obstacle]
end

function ObstacleHandler:OnObstacleEvent(callback)
	table.insert(listeners, callback)
end

function ObstacleHandler:IsPathObstructed(origin, direction, distance)
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Whitelist
	ray.FilterDescendantsInstances = self:GetAllObstacles()

	local result = Workspace:Raycast(origin, direction.Unit * distance, ray)
	return result and result.Instance or nil
end

return ObstacleHandler