-- TacticalPathfindingModule.lua - Dragnir Pathfinder v6 -- Now with Predictive Player Movement, Safe Pathing Mode, Smart Waiting, and Comprehensive Waypoint Callbacks

local PathfindingService = game:GetService("PathfindingService") local Players = game:GetService("Players") local Debris = game:GetService("Debris") local RunService = game:GetService("RunService") local Workspace = game:GetService("Workspace")

local TacticalPath = {} TacticalPath.__index = TacticalPath

-- Configuration local CONFIG = { AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentJumpHeight = 10, AgentCanClimb = true, AgentCanSwim = false,

RecalculateDistance = 10,
SmartJump = true,
Visualize = true,
WaypointColor = Color3.fromRGB(255, 0, 0),
WaypointTime = 3,

ObstacleCheck = true,
MaxRetries = 3,
ZoneBlacklist = { "Lava", "Water", "FireZone" },

SafePathMode = true,
WaitTimeout = 3,
PredictFuture = true,
PredictTime = 1.5,

Debug = false

}

local function Visualize(position, color) if not CONFIG.Visualize then return end local dot = Instance.new("Part") dot.Size = Vector3.new(0.5, 0.5, 0.5) dot.Anchored = true dot.CanCollide = false dot.Shape = Enum.PartType.Ball dot.Material = Enum.Material.Neon dot.Color = color or CONFIG.WaypointColor dot.Position = position dot.Parent = workspace Debris:AddItem(dot, CONFIG.WaypointTime) end

local function IsBlacklisted(part) for _, tag in pairs(CONFIG.ZoneBlacklist) do if part.Name:lower():find(tag:lower()) then return true end end return false end

local function IsPathClear(startPos, endPos) local ray = RaycastParams.new() ray.FilterDescendantsInstances = { workspace.Terrain } ray.FilterType = Enum.RaycastFilterType.Blacklist ray.IgnoreWater = true

local result = workspace:Raycast(startPos, (endPos - startPos).Unit * (startPos - endPos).Magnitude, ray)
return not result or not IsBlacklisted(result.Instance)

end

local function PredictPosition(target) if not CONFIG.PredictFuture then return target.Position end local root = target:FindFirstChild("HumanoidRootPart") if not root then return target.Position end local vel = root.Velocity return root.Position + (vel * CONFIG.PredictTime) end

function TacticalPath.new() local self = setmetatable({}, TacticalPath)

self.OnPathStart = function(target) end
self.OnStep = function(waypoint) end
self.OnJump = function() end
self.OnClimb = function() end
self.OnFall = function() end
self.OnBlocked = function(blocker) end
self.OnPathFail = function(status) end
self.OnPathEnd = function() end

self.Status = "Idle"
self.Target = nil
self.IsActive = false
self._connection = nil

return self

end

function TacticalPath:PathTo(from: BasePart, to: BasePart) if not (from and to and from:IsA("BasePart") and to:IsA("BasePart")) then return false end local humanoid = from.Parent and from.Parent:FindFirstChildOfClass("Humanoid") if not humanoid then return false end

local function Compute()
	local destination = CONFIG.PredictFuture and PredictPosition(to.Parent) or to.Position
	local path = PathfindingService:CreatePath({
		AgentRadius = CONFIG.AgentRadius,
		AgentHeight = CONFIG.AgentHeight,
		AgentCanJump = CONFIG.AgentCanJump,
		AgentJumpHeight = CONFIG.AgentJumpHeight,
		AgentCanClimb = CONFIG.AgentCanClimb,
		AgentCanSwim = CONFIG.AgentCanSwim,
		WaypointSpacing = CONFIG.SafePathMode and 1 or 2
	})

	local success = pcall(function()
		path:ComputeAsync(from.Position, destination)
	end)
	if not success or path.Status ~= Enum.PathStatus.Complete then
		self.OnPathFail("PathComputeFailed")
		return nil
	end
	return path
end

local path = Compute()
if not path then return false end
self.IsActive = true
self.Status = "Walking"
self.Target = to
self.OnPathStart(to)

self._connection = RunService.Heartbeat:Connect(function()
	if (to.Position - PredictPosition(to.Parent)).Magnitude > CONFIG.RecalculateDistance then
		self._connection:Disconnect()
		self:PathTo(from, to)
	end
end)

for _, waypoint in ipairs(path:GetWaypoints()) do
	if not self.IsActive then break end
	self.OnStep(waypoint)
	Visualize(waypoint.Position)

	if CONFIG.SmartJump and waypoint.Action == Enum.PathWaypointAction.Jump then
		self.OnJump()
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	elseif waypoint.Action == Enum.PathWaypointAction.Climb then
		self.OnClimb()
	elseif waypoint.Action == Enum.PathWaypointAction.Custom then
		-- Placeholder for OnLedgeGrab etc.
	end

	local retries = 0
	repeat
		if IsPathClear(from.Position, waypoint.Position) then
			humanoid:MoveTo(waypoint.Position)
			local reached = humanoid.MoveToFinished:Wait(CONFIG.WaitTimeout)
			if reached then break else retries += 1 end
		else
			self.OnBlocked("BlockedRay")
			wait(CONFIG.WaitTimeout)
			retries += 1
		end
	until retries >= CONFIG.MaxRetries

	if retries >= CONFIG.MaxRetries then
		self.OnPathFail("MaxRetriesReached")
		self:Stop()
		return false
	end
end

self.Status = "Complete"
self.OnPathEnd()
self.IsActive = false
return true

end

function TacticalPath:PathToPlayer(player: Player) if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local localChar = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait() self:PathTo(localChar:WaitForChild("HumanoidRootPart"), player.Character.HumanoidRootPart) end end

function TacticalPath:Stop() self.IsActive = false self.Status = "Canceled" if self._connection then self._connection:Disconnect() end end

return TacticalPath

