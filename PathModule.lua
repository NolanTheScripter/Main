local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService") -- For external module loading

local TacticalPath = {}
TacticalPath.__index = TacticalPath

-- Configuration Module
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
    DangerZones = { -- Heatmap Danger Zones
        { Position = Vector3.new(50, 0, 50), Radius = 10 }, -- Example danger zone
    },

    ObstacleCheck = true,
    MaxRetries = 3,
    ZoneBlacklist = { "Lava", "Water", "FireZone" },

    SafePathMode = true,
    WaitTimeout = 3,
    PredictFuture = true,
    PredictTime = 1.5,

    Debug = false,
    PathRecalculationCooldown = 1,
    SlopeSensitivity = 30, -- Max slope angle the agent can traverse
    PhysicsScale = 1, -- Custom physics scaling (gravity, etc.)
    AnimationStates = { Jump = "JumpAnim", Walk = "WalkAnim", Climb = "ClimbAnim" }, -- Animation triggers
}

-- Helper: Logging Utility
local function Log(message)
    if CONFIG.Debug then
        print("[TacticalPath Debug]:", message)
    end
end

-- Helper: Check if Position is Within a Danger Zone
local function IsInDangerZone(position)
    for _, zone in ipairs(CONFIG.DangerZones) do
        if (zone.Position - position).Magnitude <= zone.Radius then
            return true
        end
    end
    return false
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

-- Helper: Dynamic Risk Assessment
local function AssessRisk(position)
    if IsInDangerZone(position) then
        Log("High risk detected at position: " .. tostring(position))
        return true
    end
    return false
end

-- Helper: Smooth Transition Between States
local function TriggerAnimation(humanoid, animationKey)
    if CONFIG.AnimationStates[animationKey] then
        Log("Triggering animation: " .. animationKey)
        humanoid:LoadAnimation(CONFIG.AnimationStates[animationKey]):Play()
    end
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
    self.CachedPaths = {} -- For memory-efficient path caching

    return self
end

-- Pathfinding Function
function TacticalPath:PathTo(from: BasePart, to: BasePart)
    if not (from and to and from:IsA("BasePart") and to:IsA("BasePart")) then
        Log("Invalid pathfinding parameters.")
        return false
    end

    if self.IsActive then
        Log("Pathfinding already in progress. Cancelling previous task.")
        self:Stop()
    end

    local humanoid = from.Parent and from.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        Log("Humanoid not found in the source part's parent.")
        return false
    end

    -- Check for cached path
    local cacheKey = from.Position .. "-" .. to.Position
    if self.CachedPaths[cacheKey] then
        Log("Using cached path.")
        return self:FollowWaypoints(humanoid, self.CachedPaths[cacheKey])
    end

    -- Compute Path
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
        path:ComputeAsync(from.Position, to.Position)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        local errorText = "PathComputeFailed: " .. tostring(errorMsg)
        Log(errorText)
        self.Events.OnPathFail:Fire(errorText)
        return false
    end

    -- Cache Path
    self.CachedPaths[cacheKey] = path:GetWaypoints()

    return self:FollowWaypoints(humanoid, path:GetWaypoints())
end

-- Follow Waypoints
function TacticalPath:FollowWaypoints(humanoid, waypoints)
    self.IsActive = true
    self.Status = "Walking"

    for _, waypoint in ipairs(waypoints) do
        if not self.IsActive then break end
        self.Events.OnStep:Fire(waypoint)
        VisualizeWaypoint(waypoint.Position)

        if AssessRisk(waypoint.Position) then
            Log("Risk detected. Recalculating path.")
            self:Stop()
            return false
        end

        humanoid:MoveTo(waypoint.Position)
        local reached = humanoid.MoveToFinished:Wait(CONFIG.WaitTimeout)
        if not reached then
            self.Events.OnBlocked:Fire("Blocked by obstacle")
            task.delay(CONFIG.PathRecalculationCooldown, function()
                self:Stop()
            end)
            return false
        end
    end

    self.Status = "Complete"
    self.IsActive = false
    self.Events.OnPathEnd:Fire()
    return true
end

-- Stop Pathfinding
function TacticalPath:Stop()
    if not self.IsActive then return end
    self.IsActive = false
    self.Status = "Canceled"
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    Log("Pathfinding stopped successfully.")
end

return TacticalPath