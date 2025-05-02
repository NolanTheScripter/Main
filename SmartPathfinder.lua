--[[
    Advanced Intelligent Pathfinding System
    Features:
    - Dynamic environmental awareness
    - Adaptive behavior modes
    - Smooth human-like movement
    - Real-time obstacle avoidance
    - Predictive path optimization
    - Modular plugin system
]]

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- Constants
local PATH_CACHE_TTL = 30 -- seconds
local THREAT_SCAN_INTERVAL = 0.2
local NAV_UPDATE_THROTTLE = 0.1
local DEFAULT_AGENT_RADIUS = 2
local MAX_FALL_HEIGHT = 10

-- Main module with proper OOP structure
local SmartPathfinder = {}
SmartPathfinder.__index = SmartPathfinder

-- Behavior mode configurations
local BEHAVIOR_MODES = {
    Cautious = {
        speedMultiplier = 0.7,
        threatTolerance = 0.2,
        pathPreference = "Safest",
        scanRadius = 30,
        recalculateInterval = 0.5
    },
    Aggressive = {
        speedMultiplier = 1.3,
        threatTolerance = 0.8,
        pathPreference = "Shortest",
        scanRadius = 20,
        recalculateInterval = 0.3
    },
    Stealth = {
        speedMultiplier = 0.9,
        threatTolerance = 0.4,
        pathPreference = "Concealed",
        scanRadius = 40,
        recalculateInterval = 0.7
    }
}

-- Constructor
function SmartPathfinder.new(character)
    local self = setmetatable({}, SmartPathfinder)
    
    -- Entity references
    self.character = character
    self.humanoid = character:WaitForChild("Humanoid")
    self.rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Configuration
    self.config = {
        baseSpeed = self.humanoid.WalkSpeed,
        agentRadius = DEFAULT_AGENT_RADIUS,
        maxFallHeight = MAX_FALL_HEIGHT,
        updateInterval = NAV_UPDATE_THROTTLE
    }
    
    -- State management
    self._active = false
    self._currentBehavior = "Stealth"
    self._currentPath = nil
    self._pathHistory = {}
    self._threatMap = {}
    self._plugins = {}
    self._cache = {
        paths = {},
        timestamps = {}
    }
    
    -- Initialize systems
    self:_initPerception()
    self:_initNavigation()
    self:_initLocomotion()
    
    return self
end

--[[ Perception System ]]
function SmartPathfinder:_initPerception()
    self._lastScan = 0
    self._scanConnections = {}
    
    -- Continuous environmental scanning
    table.insert(self._scanConnections, RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - self._lastScan > THREAT_SCAN_INTERVAL then
            self:_updateThreatMap()
            self._lastScan = now
        end
    end))
end

function SmartPathfinder:_updateThreatMap()
    local position = self.rootPart.Position
    local radius = BEHAVIOR_MODES[self._currentBehavior].scanRadius
    
    -- Use OverlapParams for better performance
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = {self.character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    -- Spatial query
    local parts = Workspace:GetPartBoundsInRadius(position, radius, params)
    
    -- Analyze objects
    local newThreatMap = {}
    for _, part in ipairs(parts) do
        local assembly = part:GetRootPart()
        if assembly then
            newThreatMap[assembly] = {
                type = part:GetAttribute("ObjectType") or "Unknown",
                position = assembly.Position,
                velocity = assembly.AssemblyLinearVelocity,
                threat = part:GetAttribute("ThreatLevel") or 0,
                lastSeen = tick()
            }
        end
    end
    
    -- Merge with existing threats
    for threat, data in pairs(self._threatMap) do
        if not newThreatMap[threat] and tick() - data.lastSeen < 5 then
            newThreatMap[threat] = data
        end
    end
    
    self._threatMap = newThreatMap
end

function SmartPathfinder:_isPositionSafe(position)
    -- Check for immediate dangers
    for threat, data in pairs(self._threatMap) do
        if (position - data.position).Magnitude < self.config.agentRadius * 3 then
            if data.threat > BEHAVIOR_MODES[self._currentBehavior].threatTolerance then
                return false
            end
        end
    end
    
    -- Terrain safety check
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {self.character}
    
    -- Ground stability check
    local groundRay = Workspace:Raycast(
        position + Vector3.new(0, 2, 0),
        Vector3.new(0, -5, 0),
        params
    )
    
    if not groundRay or not groundRay.Instance then
        return false -- No ground below
    end
    
    -- Ledge check
    local ledgeRay = Workspace:Raycast(
        position,
        (self.rootPart.CFrame.LookVector * self.config.agentRadius * 2) + Vector3.new(0, -2, 0),
        params
    )
    
    return ledgeRay ~= nil
end

--[[ Navigation System ]]
function SmartPathfinder:_initNavigation()
    self._pathQueue = {}
    self._isComputingPath = false
end

function SmartPathfinder:GeneratePathAsync(target)
    -- Check cache first
    local cacheKey = tostring(target)
    if self._cache.paths[cacheKey] and tick() - self._cache.timestamps[cacheKey] < PATH_CACHE_TTL then
        return self._cache.paths[cacheKey]
    end
    
    -- Queue system for path computation
    local promise = Promise.new()
    table.insert(self._pathQueue, {target = target, promise = promise})
    
    if not self._isComputingPath then
        self:_processPathQueue()
    end
    
    return promise
end

function SmartPathfinder:_processPathQueue()
    if #self._pathQueue == 0 or self._isComputingPath then return end
    self._isComputingPath = true
    
    local nextPath = table.remove(self._pathQueue, 1)
    local target = nextPath.target
    local promise = nextPath.promise
    
    -- Create path with current behavior settings
    local path = PathfindingService:CreatePath({
        AgentRadius = self.config.agentRadius,
        AgentHeight = self.humanoid.HipHeight * 1.5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 2,
        Costs = {
            Water = BEHAVIOR_MODES[self._currentBehavior].waterCost or 10
        }
    })
    
    -- Async computation
    task.spawn(function()
        local success, err = pcall(function()
            path:ComputeAsync(self.rootPart.Position, target)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            
            -- Apply behavior-specific modifications
            if BEHAVIOR_MODES[self._currentBehavior].pathPreference == "Safest" then
                waypoints = self:_optimizeForSafety(waypoints)
            end
            
            -- Cache the result
            local cacheKey = tostring(target)
            self._cache.paths[cacheKey] = waypoints
            self._cache.timestamps[cacheKey] = tick()
            
            promise:Resolve(waypoints)
        else
            promise:Reject(err or "Path computation failed")
        end
        
        self._isComputingPath = false
        self:_processPathQueue()
    end)
end

function SmartPathfinder:_optimizeForSafety(waypoints)
    local safeWaypoints = {}
    
    for i, wp in ipairs(waypoints) do
        if self:_isPositionSafe(wp.Position) then
            table.insert(safeWaypoints, wp)
        else
            -- Find safer alternative
            local alternative = self:_findSafeAlternative(wp.Position)
            if alternative then
                table.insert(safeWaypoints, alternative)
            end
        end
    end
    
    return safeWaypoints
end

--[[ Locomotion System ]]
function SmartPathfinder:_initLocomotion()
    self._movementActive = false
    self._currentSpline = nil
    self._splineInterpolation = 0
end

function SmartPathfinder:FollowPath(waypoints)
    if self._movementActive then
        self:StopMovement()
    end
    
    self._movementActive = true
    self._currentPath = waypoints
    
    -- Generate smooth path
    local spline = self:_createCatmullRomSpline(waypoints)
    self._currentSpline = spline
    
    -- Movement loop
    coroutine.wrap(function()
        local step = 0
        local maxSteps = #spline
        
        while self._movementActive and step < maxSteps do
            step += 1
            local point = spline[step]
            
            -- Adaptive speed control
            local speedMultiplier = self:_calculateSpeedMultiplier(point)
            self.humanoid.WalkSpeed = self.config.baseSpeed * speedMultiplier
            
            -- Move to point
            self.humanoid:MoveTo(point)
            
            -- Wait for arrival or interruption
            local arrived = self.humanoid.MoveToFinished:Wait()
            
            -- Dynamic obstacle check
            if not self:_isPositionSafe(point) then
                self:RecalculatePath()
                break
            end
        end
        
        self._movementActive = false
    end)()
end

function SmartPathfinder:_createCatmullRomSpline(waypoints)
    local splinePoints = {}
    
    for i = 1, #waypoints - 3 do
        local p0, p1, p2, p3 = waypoints[i], waypoints[i+1], waypoints[i+2], waypoints[i+3]
        
        for t = 0, 1, 0.1 do
            local point = p1 + (
                (-p0 + p2) * t +
                (2*p0 - 5*p1 + 4*p2 - p3) * t^2 +
                (-p0 + 3*p1 - 3*p2 + p3) * t^3
            ) * 0.5
            
            table.insert(splinePoints, point)
        end
    end
    
    return splinePoints
end

function SmartPathfinder:_calculateSpeedMultiplier(position)
    -- Terrain adaptation
    local slope = self:_getTerrainSlope(position)
    local slopeFactor = math.clamp(1 - slope/30, 0.7, 1.3)
    
    -- Threat proximity
    local threatFactor = 1
    for _, data in pairs(self._threatMap) do
        local distance = (position - data.position).Magnitude
        if distance < 10 then
            threatFactor = math.min(threatFactor, 1 - (data.threat * (10 - distance)/10)
        end
    end
    
    return BEHAVIOR_MODES[self._currentBehavior].speedMultiplier * slopeFactor * threatFactor
end

--[[ Public API ]]
function SmartPathfinder:SetBehaviorMode(mode)
    if BEHAVIOR_MODES[mode] then
        self._currentBehavior = mode
        self.config.updateInterval = BEHAVIOR_MODES[mode].recalculateInterval
        self:RecalculatePath()
        return true
    end
    return false
end

function SmartPathfinder:RecalculatePath()
    if self._currentPath and #self._currentPath > 0 then
        local target = self._currentPath[#self._currentPath].Position
        self:GeneratePathAsync(target):andThen(function(newPath)
            self:FollowPath(newPath)
        end)
    end
end

function SmartPathfinder:StopMovement()
    self._movementActive = false
    self.humanoid:MoveTo(self.rootPart.Position)
end

function SmartPathfinder:RegisterPlugin(name, plugin)
    self._plugins[name] = plugin
    plugin:Initialize(self)
end

function SmartPathfinder:Destroy()
    -- Clean up all connections and resources
    for _, conn in ipairs(self._scanConnections) do
        conn:Disconnect()
    end
    
    self:StopMovement()
    setmetatable(self, nil)
end

return SmartPathfinder