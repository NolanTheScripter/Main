-- AutoGuiScaler.lua
local AutoGuiScaler = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Base resolution used as a scaling reference
local BASE_RESOLUTION = Vector2.new(1920, 1080)

-- Utility function to calculate the scale factor based on the current viewport size
local function calculateScaleFactor()
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then
        warn("[AutoGuiScaler] Warning: CurrentCamera is not available. Defaulting scale factor to 1.")
        return 1 -- Return default scale factor
    end

    local viewportSize = currentCamera.ViewportSize
    return math.min(viewportSize.X / BASE_RESOLUTION.X, viewportSize.Y / BASE_RESOLUTION.Y)
end

-- Safely create or reuse an existing instance by name and class
local function ensureChildInstance(parent, className, instanceName)
    local child = parent:FindFirstChild(instanceName)
    if not child then
        child = Instance.new(className)
        child.Name = instanceName
        child.Parent = parent
    end
    return child
end

-- Function to apply scaling components to a UI element
local function applyScalingToElement(uiElement, scaleFactor)
    -- Apply UIScale
    local uiScale = ensureChildInstance(uiElement, "UIScale", "AutoUIScale")
    uiScale.Scale = scaleFactor

    -- Apply UIAspectRatioConstraint
    local aspectRatioConstraint = ensureChildInstance(uiElement, "UIAspectRatioConstraint", "AutoAspectRatio")
    aspectRatioConstraint.AspectRatio = math.max(uiElement.AbsoluteSize.X, 1) / math.max(uiElement.AbsoluteSize.Y, 1) -- Prevent divide-by-zero

    -- Center UI element
    uiElement.AnchorPoint = Vector2.new(0.5, 0.5)
    uiElement.Position = UDim2.new(0.5, 0, 0.5, 0)

    -- Configure text-specific properties
    if uiElement:IsA("TextLabel") or uiElement:IsA("TextButton") or uiElement:IsA("TextBox") then
        uiElement.AutomaticSize = Enum.AutomaticSize.XY
        uiElement.TextScaled = true
    end
end

-- Recursive function to scale an instance and all its descendants
local function scaleInstanceRecursively(instance, scaleFactor)
    -- Apply scaling to the current instance if it is a GuiObject
    if instance:IsA("GuiObject") then
        applyScalingToElement(instance, scaleFactor)
    end

    -- Recursively scale all children
    for _, child in ipairs(instance:GetChildren()) do
        scaleInstanceRecursively(child, scaleFactor)
    end
end

-- Function to dynamically update scaling when the viewport size changes
local function setupViewportSizeListener(instance)
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then
        warn("[AutoGuiScaler] Warning: CurrentCamera is not available for viewport size updates.")
        return
    end

    -- Connect to the `ViewportSize` change signal
    currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local updatedScaleFactor = calculateScaleFactor()
        scaleInstanceRecursively(instance, updatedScaleFactor)
    end)
end

-- Function to validate the input instance
local function validateInstance(instance)
    if not instance or not instance:IsA("Instance") then
        error("[AutoGuiScaler] Error: Invalid instance passed to ScaleUI. Expected a valid Instance.")
    end
end

-- Public function to initiate and maintain scaling across the UI hierarchy
function AutoGuiScaler:ScaleUI(instance)
    validateInstance(instance)

    -- Calculate the initial scale factor
    local initialScaleFactor = calculateScaleFactor()

    -- Apply scaling to the instance and all its descendants
    scaleInstanceRecursively(instance, initialScaleFactor)

    -- Set up dynamic updates for scaling on viewport size changes
    setupViewportSizeListener(instance)
end

return AutoGuiScaler