-- Core/ScalingManager.lua
local ScalingManager = {}

function ScalingManager.createContainer(parent, sizeScale, positionScale)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = sizeScale
    frame.Position = positionScale
    
    -- Normalisation des tailles fixes
    local fixedSize = Instance.new("UISizeConstraint")
    fixedSize.MinSize = Vector2.new(50, 50) -- Minimum lisible
    fixedSize.MaxSize = Vector2.new(500, 800) -- Maximum ergonomique
    fixedSize.Parent = frame
    
    -- Conservation des proportions
    local aspectRatio = Instance.new("UIAspectRatioConstraint")
    aspectRatio.AspectRatio = sizeScale.X.Scale / sizeScale.Y.Scale
    aspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
    aspectRatio.DominantAxis = Enum.DominantAxis.Width
    aspectRatio.Parent = frame
    
    frame.Parent = parent
    return frame
end

function ScalingManager.normalizeSize(baseSize)
    -- Convertit les pixels en offsets normalisés
    -- Roblox: 1 pixel = 1/96 inch ≈ 0.264mm
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local scaleFactor = math.min(viewportSize.X, viewportSize.Y) / 1080
    
    return UDim2.new(0, baseSize.X * scaleFactor, 0, baseSize.Y * scaleFactor)
end

function ScalingManager.adaptiveFontSize(baseSize)
    -- Taille de texte physiquement constante
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local diagonal = math.sqrt(viewportSize.X^2 + viewportSize.Y^2)
    local normalizedSize = (baseSize * diagonal) / 2200 -- Réglage empirique
    
    return math.clamp(normalizedSize, 14, 36)
end

return ScalingManager