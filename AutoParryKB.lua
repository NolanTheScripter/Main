-- Dragnir Auto-Parry Enhanced System (Full Logic Version) 

local RunService = game:GetService("RunService") 
local Players = game:GetService("Players") 

local VirtualInput = game:GetService("VirtualInputManager")

local DragnirAutoParry = {} DragnirAutoParry.Settings = { AutoParry = true, AutoPredict = true, AutoVisualize = true, DangerZoneScanner = true, ImpactTimerHUD = true, SmartFocusTargeting = true, ReplayAnalyzer = false, BallMemory = true,

MinParryDistance = 5,
MaxParryDistance = 20,
InterpolationSpeed = 0.15,

}

local LocalPlayer = Players.LocalPlayer local Character, HumanoidRootPart = nil, nil local Ball = workspace:WaitForChild("Ball") local BallMemory = {} local LastPrediction, CurrentThreat = nil, nil local VisualizeParts = {}

local function Magnitude(v1, v2) return (v1 - v2).Magnitude end

local function Lerp(a, b, t) return a + (b - a) * t end

local function Clamp(value, min, max) return math.clamp(value, min, max) end

local function GetParryDistance(speed) return Clamp(Lerp(DragnirAutoParry.Settings.MinParryDistance, DragnirAutoParry.Settings.MaxParryDistance, speed / 100), 5, DragnirAutoParry.Settings.MaxParryDistance) end

function DragnirAutoParry.PredictFuturePosition(delta) local v = Ball.Velocity local a = Ball.AssemblyLinearVelocity - v return Ball.Position + (v * delta) + (0.5 * a * delta ^ 2) end

function DragnirAutoParry.Parry() if not DragnirAutoParry.Settings.AutoParry then return end if not HumanoidRootPart then return end

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

function DragnirAutoParry.Visualize() if not DragnirAutoParry.Settings.AutoVisualize then return end local predicted = DragnirAutoParry.PredictFuturePosition(0.35) if LastPrediction and (LastPrediction - predicted).Magnitude < 0.25 then return end LastPrediction = predicted

for _, p in ipairs(VisualizeParts) do p:Destroy() end
VisualizeParts = {}

local part = Instance.new("Part")
part.Anchored = true
part.CanCollide = false
part.Size = Vector3.new(0.4, 0.4, 0.4)
part.Position = predicted
part.Color = Color3.fromRGB(255, 0, 255)
part.Material = Enum.Material.Neon
part.Parent = workspace
table.insert(VisualizeParts, part)

end

function DragnirAutoParry.ScanDangerZone() if not DragnirAutoParry.Settings.DangerZoneScanner then return end local speed = Ball.Velocity.Magnitude local range = Clamp(speed / 3, 5, 25) local color = speed < 30 and Color3.fromRGB(0, 255, 0) or speed < 60 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)

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

function DragnirAutoParry.UpdateImpactHUD() if not DragnirAutoParry.Settings.ImpactTimerHUD then return end local predicted = DragnirAutoParry.PredictFuturePosition(0.25) local distance = Magnitude(predicted, HumanoidRootPart.Position) local speed = Ball.Velocity.Magnitude local timeToHit = speed > 0 and (distance / speed) or 0

-- Print or use BillboardGui here (placeholder)
print("Impact in: ", math.floor(timeToHit * 1000), "ms")

end

function DragnirAutoParry.UpdateThreat() if not DragnirAutoParry.Settings.SmartFocusTargeting then return end local pos = Ball.Position local dist = Magnitude(HumanoidRootPart.Position, pos) local angle = Ball.Velocity.Unit:Dot((HumanoidRootPart.Position - pos).Unit) local score = (angle * 100) + (100 - dist)

if not CurrentThreat or score > CurrentThreat.Score then
	CurrentThreat = {
		Ball = Ball,
		Score = score
	}
end

end

function DragnirAutoParry.LogReplay(success) if not DragnirAutoParry.Settings.ReplayAnalyzer then return end table.insert(BallMemory, { Time = os.clock(), Position = Ball.Position, Result = success and "Parry" or "Miss" }) end

function DragnirAutoParry.RememberBall() if not DragnirAutoParry.Settings.BallMemory then return end table.insert(BallMemory, { Position = Ball.Position, Velocity = Ball.Velocity, Time = os.clock() }) end

function DragnirAutoParry.Start() task.spawn(function() while true do RunService.Heartbeat:Wait() Character = LocalPlayer.Character HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart") if not Character or not HumanoidRootPart then continue end

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

