-- AutoGuiScaler.lua
local AutoGuiScaler = {}
local RunService = game:GetService("RunService")
local BASE_RESOLUTION = Vector2.new(1920, 1080)

-- Wait for CurrentCamera safely
local function getCurrentCamera()
	while not workspace.CurrentCamera do
		RunService.RenderStepped:Wait()
	end
	return workspace.CurrentCamera
end

-- Calculate scaling based on viewport size
local function calculateScaleFactor()
	local camera = getCurrentCamera()
	local viewportSize = camera.ViewportSize
	return math.min(viewportSize.X / BASE_RESOLUTION.X, viewportSize.Y / BASE_RESOLUTION.Y)
end

-- Ensure or create child instance
local function ensureChildInstance(parent, className, instanceName)
	local child = parent:FindFirstChild(instanceName)
	if not child then
		child = Instance.new(className)
		child.Name = instanceName
		child.Parent = parent
	end
	return child
end

-- Apply scaling logic to UI element
local function applyScalingToElement(uiElement, scaleFactor)
	local uiScale = ensureChildInstance(uiElement, "UIScale", "AutoUIScale")
	uiScale.Scale = scaleFactor

	local aspectRatio = ensureChildInstance(uiElement, "UIAspectRatioConstraint", "AutoAspectRatio")
	aspectRatio.AspectRatio = math.max(uiElement.AbsoluteSize.X, 1) / math.max(uiElement.AbsoluteSize.Y, 1)

	uiElement.AnchorPoint = Vector2.new(0.5, 0.5)
	uiElement.Position = UDim2.new(0.5, 0, 0.5, 0)

	if uiElement:IsA("TextLabel") or uiElement:IsA("TextButton") or uiElement:IsA("TextBox") then
		uiElement.AutomaticSize = Enum.AutomaticSize.XY
		uiElement.TextScaled = true
	end
end

-- Recursive scaling with duplicate prevention
local function scaleInstanceRecursively(instance, scaleFactor)
	if instance:IsA("GuiObject") and not instance:FindFirstChild("AutoUIScale") then
		applyScalingToElement(instance, scaleFactor)
	end
	for _, child in ipairs(instance:GetChildren()) do
		scaleInstanceRecursively(child, scaleFactor)
	end
end

-- Listen for viewport size changes and rescale
local function setupViewportSizeListener(instance)
	local camera = getCurrentCamera()
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local newScale = calculateScaleFactor()
		scaleInstanceRecursively(instance, newScale)
	end)
end

-- Validate input
local function validateInstance(instance)
	if not instance or not instance:IsA("Instance") then
		error("[AutoGuiScaler] Error: Invalid instance passed to ScaleUI. Expected a valid Instance.")
	end
end

-- Public API
function AutoGuiScaler:ScaleUI(instance)
	validateInstance(instance)
	local scaleFactor = calculateScaleFactor()
	scaleInstanceRecursively(instance, scaleFactor)
	setupViewportSizeListener(instance)
end

return AutoGuiScaler