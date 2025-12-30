local ScalingManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/ScalingManager.lua"))()
local FlexLayout = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/FlexLayout.lua"))()
local SpringSolver = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/SpringSolver.lua"))()
local PreniumEffects = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/PreniumEffects.lua"))()

local ProfessionalUI = {
    themes = {},
    components = {},
    activeModals = {}
}

-- Thème centralisé
ProfessionalUI.themes.Primary = {
    Background = Color3.fromRGB(25, 25, 35),
    Surface = Color3.fromRGB(40, 40, 50),
    Primary = Color3.fromRGB(0, 162, 255),
    Secondary = Color3.fromRGB(140, 110, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 90, 90)
}

ProfessionalUI.themes.Rounded = {
    None = UDim.new(0, 0),
    Small = UDim.new(0, 4),
    Medium = UDim.new(0, 8),
    Large = UDim.new(0, 12),
    Full = UDim.new(1, 0)
}

-- Factory Pattern
function ProfessionalUI.createComponent(type, config, parent)
    local component = {}
    local instance
    
    if type == "Button" then
        instance = ProfessionalUI.createButton(config, parent)
    elseif type == "Card" then
        instance = ProfessionalUI.createCard(config, parent)
    elseif type == "Modal" then
        instance = ProfessionalUI.createModal(config, parent)
    elseif type == "Input" then
        instance = ProfessionalUI.createInput(config, parent)
    end
    
    -- Application automatique du thème
    ProfessionalUI.applyTheme(instance, config.theme or "Primary")
    
    -- Ajout aux composants gérés
    local id = #ProfessionalUI.components + 1
    ProfessionalUI.components[id] = {
        instance = instance,
        type = type,
        config = config
    }
    
    component.instance = instance
    component.destroy = function()
        ProfessionalUI.components[id] = nil
        instance:Destroy()
    end
    
    return component
end

function ProfessionalUI.createButton(config, parent)
    local button = Instance.new("TextButton")
    button.Name = config.name or "Button"
    button.Text = config.text or "Button"
    button.TextColor3 = ProfessionalUI.themes.Primary.Text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = ScalingManager.adaptiveFontSize(18)
    button.BackgroundColor3 = ProfessionalUI.themes.Primary.Primary
    button.AutoButtonColor = false
    button.Size = config.size or ScalingManager.normalizeSize(Vector2.new(120, 40))
    button.Position = config.position or UDim2.new(0.5, 0, 0.5, 0)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Arrondis
    local corner = Instance.new("UICorner")
    corner.CornerRadius = ProfessionalUI.themes.Rounded.Medium
    corner.Parent = button
    
    -- Effets visuels
    PremiumEffects.applyStroke(button, "SCALED", {
        type = "BEVEL",
        rotation = 90
    })
    
    -- Animation d'interaction
    local originalSize = button.Size
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        SpringSolver.animateUI(button, "Size", 
            UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 4,
                     originalSize.Y.Scale, originalSize.Y.Offset + 4),
            SpringSolver.Presets.BOUNCY)
        
        SpringSolver.animateUI(button, "BackgroundColor3",
            originalColor:Lerp(Color3.fromRGB(255, 255, 255), 0.1),
            SpringSolver.Presets.SNAPPY)
    end)
    
    button.MouseLeave:Connect(function()
        SpringSolver.animateUI(button, "Size", originalSize,
            SpringSolver.Presets.CRITICAL)
        
        SpringSolver.animateUI(button, "BackgroundColor3", originalColor,
            SpringSolver.Presets.CRITICAL)
    end)
    
    button.MouseButton1Down:Connect(function()
        SpringSolver.animateUI(button, "BackgroundColor3",
            originalColor:Lerp(Color3.fromRGB(0, 0, 0), 0.2),
            SpringSolver.Presets.SNAPPY)
    end)
    
    button.MouseButton1Up:Connect(function()
        SpringSolver.animateUI(button, "BackgroundColor3", originalColor,
            SpringSolver.Presets.BOUNCY)
        
        if config.onClick then
            config.onClick()
        end
    end)
    
    button.Parent = parent or ProfessionalUI.screenGui
    return button
end

function ProfessionalUI.createModal(config, parent)
    local modalId = #ProfessionalUI.activeModals + 1
    
    -- Overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "ModalOverlay_" .. modalId
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 10
    
    local canvasGroup = Instance.new("CanvasGroup")
    canvasGroup.GroupTransparency = 1
    canvasGroup.Parent = overlay
    
    -- Contenu modal
    local modalContainer = ScalingManager.createContainer(overlay,
        UDim2.new(0.8, 0, 0.7, 0),
        UDim2.new(0.5, 0, 0.5, 0))
    modalContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    modalContainer.BackgroundColor3 = ProfessionalUI.themes.Primary.Surface
    modalContainer.ZIndex = 11
    
    PremiumEffects.applyStroke(modalContainer, "SCALED")
    
    -- Animation d'entrée
    PremiumEffects.setGroupTransparency(canvasGroup, 0, 0.3)
    
    SpringSolver.animateUI(modalContainer, "Position",
        UDim2.new(0.5, 0, 0.48, 0),
        SpringSolver.Presets.BOUNCY)
    
    -- Fermeture
    local closeFunction = function()
        PremiumEffects.setGroupTransparency(canvasGroup, 1, 0.2)
        SpringSolver.animateUI(modalContainer, "Position",
            UDim2.new(0.5, 0, 0.6, 0),
            SpringSolver.Presets.CRITICAL,
            function()
                overlay:Destroy()
                ProfessionalUI.activeModals[modalId] = nil
            end)
    end
    
    overlay.Parent = parent or ProfessionalUI.screenGui
    ProfessionalUI.activeModals[modalId] = overlay
    
    return {
        container = modalContainer,
        close = closeFunction
    }
end

-- Initialisation
function ProfessionalUI.init(player)
    -- Création ScreenGui
    ProfessionalUI.screenGui = Instance.new("ScreenGui")
    ProfessionalUI.screenGui.Name = "ProfessionalUI"
    ProfessionalUI.screenGui.ResetOnSpawn = false
    ProfessionalUI.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ProfessionalUI.screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Démarrer les systèmes
    SpringSolver.start()
    
    -- Responsive listener
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        for _, component in pairs(ProfessionalUI.components) do
            if component.type == "Container" then
                FlexLayout.adjustForViewport(component.instance)
            end
        end
    end)
end

-- Nettoyage
function ProfessionalUI.cleanup()
    for _, connection in pairs(SpringSolver.connections) do
        connection:Disconnect()
    end
    
    for _, component in pairs(ProfessionalUI.components) do
        component.instance:Destroy()
    end
    
    ProfessionalUI.screenGui:Destroy()
end

return ProfessionalUI