-- NoLagModule.lua

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local NoLagModule = {}

NoLagModule.Config = {
    MaxParticles = 100,
    RenderDistance = 150,
    LowDetailDistance = 200,
    MaxFPS = 60,
    MinFPS = 30,
    NetworkSendRate = 30,
    NetworkReceiveRate = 60,
    FrameTimeThreshold = 1 / 55,
    ParticleAdjustmentFactor = 0.5,
    FPSAdjustmentFactor = 0.75,
    NetworkAdjustmentFactor = 0.75,
}

NoLagModule.Enabled = false
NoLagModule.Connection = nil

function NoLagModule:CalculateAverageFrameTime()
    local totalFrameTime = 0
    local frameCount = 0
    RunService.RenderStepped:Connect(function(deltaTime)
        totalFrameTime = totalFrameTime + deltaTime
        frameCount = frameCount + 1
    end)
    return totalFrameTime / frameCount
end

function NoLagModule:ShouldReduceLoad()
    local averageFrameTime = self:CalculateAverageFrameTime()
    return averageFrameTime > self.Config.FrameTimeThreshold
end

function NoLagModule:AdjustParticleEffects()
    for _, emitter in ipairs(workspace:GetDescendants()) do
        if emitter:IsA("ParticleEmitter") then
            local adjustmentFactor = self:ShouldReduceLoad() and self.Config.ParticleAdjustmentFactor or 1
            emitter.Rate = math.min(emitter.Rate, self.Config.MaxParticles * adjustmentFactor)
        end
    end
end

function NoLagModule:DynamicDistanceRendering()
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= hrp then
            local distance = (part.Position - hrp.Position).Magnitude
            part.Transparency = distance > self.Config.RenderDistance and 1 or (distance > self.Config.LowDetailDistance and 0.5 or 0)
        end
    end
end

function NoLagModule:AdjustFPSCap()
    local currentFPS = 1 / RunService.RenderStepped:Wait()
    local targetFPS = currentFPS < self.Config.MinFPS and self.Config.MaxFPS * self.Config.FPSAdjustmentFactor or self.Config.MaxFPS
    setfpscap(targetFPS)
end

function NoLagModule:DynamicLightingOptimization()
    Lighting.GlobalShadows = not self:ShouldReduceLoad()
end

function NoLagModule:DynamicNetworkTraffic()
    local scaleFactor = self:ShouldReduceLoad() and self.Config.NetworkAdjustmentFactor or 1
    settings().Network.SendRate = self.Config.NetworkSendRate * scaleFactor
    settings().Network.ReceiveRate = self.Config.NetworkReceiveRate * scaleFactor
end

function NoLagModule:ActivateAntiLag()
    if self.Connection then return end
    
    self.Connection = RunService.RenderStepped:Connect(function()
        if self.Enabled then
            self:AdjustParticleEffects()
            self:DynamicDistanceRendering()
            self:AdjustFPSCap()
            self:DynamicLightingOptimization()
            self:DynamicNetworkTraffic()
        end
    end)
end

function NoLagModule:DeactivateAntiLag()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    setfpscap(60)
    Lighting.GlobalShadows = true
end

function NoLagModule:Enable(isEnabled)
    self.Enabled = isEnabled
    if self.Enabled then
        self:ActivateAntiLag()
    else
        self:DeactivateAntiLag()
    end
end

return NoLagModule