local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local DragnirAutoParry = {}

-- Configuration Settings
DragnirAutoParry.Settings = {
    AutoParry = true,
    AutoPredict = true,
    AutoVisualize = true,
    DangerZoneScanner = true,
    ImpactTimerHUD = true,
    SmartFocusTargeting = true,
    ReplayAnalyzer = false,
    BallMemory = true,

    MinParryDistance = 5,
    MaxParryDistance = 20,
    InterpolationSpeed = 0.15,
}

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local Character, HumanoidRootPart = nil, nil
local Ball = workspace:WaitForChild("Ball")
local BallMemory = {}
local LastPrediction, CurrentThreat = nil, nil
local VisualizeParts = {}

-- Utility Functions
local function Magnitude(v1, v2)
    return (v1 - v2).Magnitude
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Clamp(value, min, max)
    return math.clamp(value, min, max)
end

local function GetParryDistance(speed)
    return Clamp(
        Lerp(DragnirAutoParry.Settings.MinParryDistance, DragnirAutoParry.Settings.MaxParryDistance, speed / 100),
        DragnirAutoParry.Settings.MinParryDistance,
        DragnirAutoParry.Settings.MaxParryDistance
    )
end

-- Core Functions
function DragnirAutoParry.PredictFuturePosition(delta)
    local velocity = Ball.Velocity
    local acceleration = Ball.AssemblyLinearVelocity - velocity
    return Ball.Position + (velocity * delta) + (0.5 * acceleration * delta ^ 2)
end

function DragnirAutoParry.Parry()
    if not DragnirAutoParry.Settings.AutoParry or not HumanoidRootPart then return end

    local distance = Magnitude(HumanoidRootPart.Position, Ball.Position)
    local speed = Ball.Velocity.Magnitude
    local triggerDistance = GetParryDistance(speed)

    if distance <= triggerDistance then
        task.delay(DragnirAutoParry.Settings.InterpolationSpeed, function()
            local updatedDist = Magnitude(HumanoidRootPart.Position, Ball.Position)
            if updatedDist <= triggerDistance then
                VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                DragnirAutoParry.LogReplay(true)
            else
                DragnirAutoParry.LogReplay(false)
            end
        end)
    end
end

function DragnirAutoParry.Visualize()
    if not DragnirAutoParry.Settings.AutoVisualize then return end

    local predicted = DragnirAutoParry.PredictFuturePosition(0.35)
    if LastPrediction and (LastPrediction - predicted).Magnitude < 0.25 then return end
    LastPrediction = predicted

    -- Clear previous visualizations
    for _, part in ipairs(VisualizeParts) do
        part:Destroy()
    end
    VisualizeParts = {}

    -- Create new visualization - Main Prediction Sphere
    local mainPart = Instance.new("Part")
    mainPart.Anchored = true
    mainPart.CanCollide = false
    mainPart.Size = Vector3.new(0.5, 0.5, 0.5)
    mainPart.Position = predicted
    mainPart.Color = Color3.fromRGB(0, 255, 0) -- Green for base visualization
    mainPart.Material = Enum.Material.Neon
    mainPart.Parent = workspace
    table.insert(VisualizeParts, mainPart)

    -- Add a velocity-based trail for dynamic feedback
    local trailPart = Instance.new("Part")
    trailPart.Anchored = true
    trailPart.CanCollide = false
    trailPart.Size = Vector3.new(0.3, 0.3, 0.3)
    trailPart.Position = Ball.Position
    trailPart.Color = Color3.fromRGB(255, math.clamp(255 - Ball.Velocity.Magnitude * 4, 0, 255), 0) -- Gradient from red to green
    trailPart.Material = Enum.Material.Neon
    trailPart.Transparency = 0.5
    trailPart.Parent = workspace
    table.insert(VisualizeParts, trailPart)

    -- Add a connecting line between the Ball and the predicted position
    local beam = Instance.new("Beam")
    local attachment0 = Instance.new("Attachment", Ball)
    local attachment1 = Instance.new("Attachment", mainPart)
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    }
    beam.Width0 = 0.2
    beam.Width1 = 0.1
    beam.FaceCamera = true
    beam.Parent = workspace
    table.insert(VisualizeParts, beam)
end

function DragnirAutoParry.ScanDangerZone()
    if not DragnirAutoParry.Settings.DangerZoneScanner or not HumanoidRootPart then return end

    local speed = Ball.Velocity.Magnitude
    local range = Clamp(speed / 3, 5, 25)
    local color = speed < 30 and Color3.fromRGB(0, 255, 0)
                or speed < 60 and Color3.fromRGB(255, 255, 0)
                or Color3.fromRGB(255, 0, 0)

    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(range * 2, range * 2, range * 2)
    part.Position = HumanoidRootPart.Position
    part.Transparency = 0.75
    part.Color = color
    part.Material = Enum.Material.ForceField
    part.Parent = workspace
    table.insert(VisualizeParts, part)
end

function DragnirAutoParry.UpdateImpactHUD()
    if not DragnirAutoParry.Settings.ImpactTimerHUD or not HumanoidRootPart then return end

    local predicted = DragnirAutoParry.PredictFuturePosition(0.25)
    local distance = Magnitude(predicted, HumanoidRootPart.Position)
    local speed = Ball.Velocity.Magnitude
    local timeToHit = speed > 0 and (distance / speed) or 0

    print(string.format("Impact in: %d ms", math.floor(timeToHit * 1000)))
end

function DragnirAutoParry.UpdateThreat()
    if not DragnirAutoParry.Settings.SmartFocusTargeting or not HumanoidRootPart then return end

    local pos = Ball.Position
    local dist = Magnitude(HumanoidRootPart.Position, pos)
    local angle = Ball.Velocity.Unit:Dot((HumanoidRootPart.Position - pos).Unit)
    local score = (angle * 100) + (100 - dist)

    if not CurrentThreat or score > CurrentThreat.Score then
        CurrentThreat = {
            Ball = Ball,
            Score = score,
        }
    end
end

function DragnirAutoParry.LogReplay(success)
    if not DragnirAutoParry.Settings.ReplayAnalyzer then return end

    table.insert(BallMemory, {
        Time = os.clock(),
        Position = Ball.Position,
        Result = success and "Parry" or "Miss",
    })
end

function DragnirAutoParry.RememberBall()
    if not DragnirAutoParry.Settings.BallMemory then return end

    table.insert(BallMemory, {
        Position = Ball.Position,
        Velocity = Ball.Velocity,
        Time = os.clock(),
    })
end

function DragnirAutoParry.Start()
    task.spawn(function()
        while true do
            RunService.Heartbeat:Wait()

            Character = LocalPlayer.Character
            HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            if not Character or not HumanoidRootPart then continue end

            DragnirAutoParry.RememberBall()
            DragnirAutoParry.UpdateThreat()
            DragnirAutoParry.Parry()
            DragnirAutoParry.Visualize()
            DragnirAutoParry.ScanDangerZone()
            DragnirAutoParry.UpdateImpactHUD()
        end
    end)
end

return DragnirAutoParry