-- Visualizer.lua
-- Dragnir Adaptable Threat Visualizer System

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Visualizer = {}

--// Configurable Visual Layers
local layers = {
	Primary = Color3.fromRGB(255, 0, 0),
	Secondary = Color3.fromRGB(255, 165, 0),
	Low = Color3.fromRGB(255, 255, 0)
}

local activeVisuals = {}

--// Drawing Utility
local function createBillboard(name, color, size)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = name
	billboard.Size = UDim2.new(0, size, 0, size)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 2, 0)

	local frame = Instance.new("Frame", billboard)
	frame.BackgroundColor3 = color
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.25

	return billboard
end

--// Public API

-- Show a threat visualization on a target instance
function Visualizer:ShowThreat(target, layer, label)
	if not target:IsA("BasePart") then return end
	local name = "Threat_" .. (label or "Generic")
	if activeVisuals[target] then
		activeVisuals[target]:Destroy()
	end

	local color = layers[layer] or Color3.fromRGB(200, 200, 200)
	local billboard = createBillboard(name, color, 12)
	billboard.Parent = target
	activeVisuals[target] = billboard
end

-- Remove visual indicator from a part
function Visualizer:RemoveThreat(target)
	if activeVisuals[target] then
		activeVisuals[target]:Destroy()
		activeVisuals[target] = nil
	end
end

-- Clear all visual elements
function Visualizer:ClearAll()
	for _, visual in pairs(activeVisuals) do
		if visual then
			visual:Destroy()
		end
	end
	table.clear(activeVisuals)
end

-- Render heatmap zones (optional expansion)
function Visualizer:ShowHeatZone(position, radius, color)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(radius, 0.2, radius)
	part.Position = position
	part.Color = color or Color3.fromRGB(255, 50, 50)
	part.Material = Enum.Material.Neon
	part.Transparency = 0.6
	part.Shape = Enum.PartType.Cylinder
	part.Orientation = Vector3.new(90, 0, 0)
	part.Name = "HeatZone"
	part.Parent = workspace

	task.delay(2, function()
		if part and part.Parent then part:Destroy() end
	end)
end

-- Dynamic resizing of visuals
function Visualizer:ResizeThreat(target, scale)
	if activeVisuals[target] then
		activeVisuals[target].Size = UDim2.new(0, scale, 0, scale)
	end
end

return Visualizer