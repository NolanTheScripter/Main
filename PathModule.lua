local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local TacticalPath = {}
TacticalPath.__index = TacticalPath

-- Configuration Module (Dynamic Loading)
local CONFIG = {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    AgentJumpHeight = 10,
    AgentCanClimb = true,
    AgentCanSwim = false,

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

    Debug = false,
}

-- Helper: Logging Utility
local function Log(message)
    if CONFIG.Debug then
        print("[TacticalPath Debug]:", message)
    end
end

-- Helper: Visualize Waypoints
local function VisualizeWaypoint(position, color)
    if not CONFIG.Visualize then return end
    local dot = Instance.new("Part")
    dot.Size = Vector3.new(0.5, 0.5, 0.5)
    dot.Anchored = true
    dot.CanCollide = false
    dot.BrickColor = BrickColor.new(color or CONFIG.WaypointColor)
    dot.Position = position
    dot.Parent = workspace
    Debris:AddItem(dot, CONFIG.WaypointTime)
end

-- Helper: Check if Part is Blacklisted
local function IsBlacklisted(part)
    for _, tag in pairs(CONFIG.ZoneBlacklist) do
        if part.Name:lower():find(tag:lower()) then
            return true
        end
    end
    return false
end

-- Helper: Check Path Clearance
local function IsPathClear(startPos, endPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { workspace.Terrain }
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(startPos, (endPos - startPos).Unit * (startPos - endPos).Magnitude, rayParams)
    return not result or not IsBlacklisted(result.Instance)
end

-- Helper: Predict Future Position
local function PredictPosition(target)
    if not CONFIG.PredictFuture then return target.Position end
    local root = target:FindFirstChild("HumanoidRootPart")
    if not root then return target.Position end
    return root.Position + (root.AssemblyLinearVelocity * CONFIG.PredictTime)
end

-- Initialize TacticalPath
function TacticalPath.new()
    local self = setmetatable({}, TacticalPath)

    -- Define Events for Callbacks
    self.Events = {
        OnPathStart = Instance.new("BindableEvent"),
        OnStep = Instance.new("BindableEvent"),
        OnJump = Instance.new("BindableEvent"),
        OnClimb = Instance.new("BindableEvent"),
        OnBlocked = Instance.new("BindableEvent"),
        OnPathFail = Instance.new("BindableEvent"),
        OnPathEnd = Instance.new("BindableEvent"),
    }

    self.Status = "Idle"
    self.Target = nil
    self.IsActive = false
    self._connection = nil

    return self
end

-- Pathfinding Function
function TacticalPath:PathTo(from: BasePart, to: BasePart)
    if not (from and to and from:IsA("BasePart") and to:IsA("BasePart")) then
        return false
    end

    local humanoid = from.Parent and from.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local function ComputePath()
        local destination = CONFIG.PredictFuture and PredictPosition(to.Parent) or to.Position
        local path = PathfindingService:CreatePath({
            AgentRadius = CONFIG.AgentRadius,
            AgentHeight = CONFIG.AgentHeight,
            AgentCanJump = CONFIG.AgentCanJump,
            AgentJumpHeight = CONFIG.AgentJumpHeight,
            AgentCanClimb = CONFIG.AgentCanClimb,
            AgentCanSwim = CONFIG.AgentCanSwim,
            WaypointSpacing = CONFIG.SafePathMode and 1 or 2,
        })

        local success, errorMsg = pcall(function()
            path:ComputeAsync(from.Position, destination)
        end)

        if not success or path.Status ~= Enum.PathStatus.Success then
            self.Events.OnPathFail:Fire("PathComputeFailed: " .. tostring(errorMsg))
            return nil
        end
        return path
    end

    local path = ComputePath()
    if not path then return false end

    self.IsActive = true
    self.Status = "Walking"
    self.Target = to
    self.Events.OnPathStart:Fire(to)

    self._connection = RunService.Heartbeat:Connect(function()
        if (to.Position - PredictPosition(to.Parent)).Magnitude > CONFIG.RecalculateDistance then
            self:Stop()
            self:PathTo(from, to)
        end
    end)

    for _, waypoint in ipairs(path:GetWaypoints()) do
        if not self.IsActive then break end
        self.Events.OnStep:Fire(waypoint)
        VisualizeWaypoint(waypoint.Position)

        if CONFIG.SmartJump and waypoint.Action == Enum.PathWaypointAction.Jump then
            self.Events.OnJump:Fire()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif waypoint.Action == Enum.PathWaypointAction.Climb then
            self.Events.OnClimb:Fire()
        end

        local retries = 0
        repeat
            if IsPathClear(from.Position, waypoint.Position) then
                humanoid:MoveTo(waypoint.Position)
                local reached = humanoid.MoveToFinished:Wait(CONFIG.WaitTimeout)
                if reached then break else retries += 1 end
            else
                self.Events.OnBlocked:Fire("BlockedRay")
                task.wait(CONFIG.WaitTimeout)
                retries += 1
            end
        until retries >= CONFIG.MaxRetries

        if retries >= CONFIG.MaxRetries then
            self.Events.OnPathFail:Fire("MaxRetriesReached")
            self:Stop()
            return false
        end
    end

    self.Status = "Complete"
    self.Events.OnPathEnd:Fire()
    self.IsActive = false
    return true
end

-- Stop Pathfinding
function TacticalPath:Stop()
    self.IsActive = false
    self.Status = "Canceled"
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
end

return TacticalPath