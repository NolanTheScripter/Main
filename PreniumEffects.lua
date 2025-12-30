-- Core/PremiumEffects.lua
local PremiumEffects = {}

function PremiumEffects.applyStroke(element, thicknessMode, gradientConfig)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    
    -- Stroke adaptatif
    if thicknessMode == "SCALED" then
        stroke.Thickness = 0.1 -- 10% de l'axe le plus court
        stroke.SizingMode = Enum.StrokeSizingMode.Scale
    elseif thicknessMode == "FIXED" then
        stroke.SizingMode = Enum.StrokeSizingMode.Absolute
    end
    
    -- Gradient avancé
    if gradientConfig then
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = gradientConfig.rotation or 0
        
        if gradientConfig.type == "BEVEL" then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
            })
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.7),
                NumberSequenceKeypoint.new(0.5, 0.3),
                NumberSequenceKeypoint.new(1, 0.7)
            })
        elseif gradientConfig.type == "HALO" then
            gradient.Color = ColorSequence.new(gradientConfig.color or Color3.fromRGB(255, 255, 255))
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.9),
                NumberSequenceKeypoint.new(0.5, 0.2),
                NumberSequenceKeypoint.new(1, 0.9)
            })
        end
        
        gradient.Parent = stroke
    end
    
    stroke.Parent = element
    return stroke
end

function PremiumEffects.applyDepth(frame, depthLevel)
    -- Ombre portée
    local shadow = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Transparency = 0.8
    stroke.Thickness = 4 * (depthLevel or 1)
    stroke.Parent = frame
    
    -- Légère élévation
    local elevation = Instance.new("UIGradient")
    elevation.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    elevation.Parent = frame
    
    return shadow
end

function PremiumEffects.createGlassEffect(parent)
    local glass = Instance.new("Frame")
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = 0.9
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = glass
    
    -- Flou simulé via transparence gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.92),
        NumberSequenceKeypoint.new(1, 0.85)
    })
    gradient.Rotation = 90
    gradient.Parent = glass
    
    -- Bordure subtile
    PremiumEffects.applyStroke(glass, "SCALED", {
        type = "BEVEL",
        rotation = 90
    })
    
    glass.Parent = parent
    return glass
end

-- Gestionnaire CanvasGroup optimisé
PremiumEffects.activeCanvasGroups = {}

function PremiumEffects.setGroupTransparency(group, transparency, duration, springPreset)
    if not group:IsA("CanvasGroup") then
        local canvasGroup = Instance.new("CanvasGroup")
        canvasGroup.GroupTransparency = group.GroupTransparency or 0
        canvasGroup.Parent = group
        group = canvasGroup
    end
    
    -- Animation spring
    local spring = SpringSolver.createSpring(
        group.GroupTransparency,
        transparency,
        springPreset or SpringSolver.Presets.CRITICAL
    )
    
    spring.setCallback(function(value)
        group.GroupTransparency = value
    end)
    
    spring.setTarget(transparency)
    
    -- Nettoyage automatique
    if transparency == 1 then
        delay(duration + 0.5, function()
            if group.GroupTransparency == 1 then
                group:Destroy()
            end
        end)
    end
    
    return spring
end

return PremiumEffects