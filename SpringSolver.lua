-- Core/SpringSolver.lua
local SpringSolver = {}

SpringSolver.springs = {}
SpringSolver.connections = {}

-- Paramètres prédéfinis
SpringSolver.Presets = {
    CRITICAL = {mass = 1, stiffness = 170, damping = 24}, -- ζ ≈ 1
    BOUNCY = {mass = 1, stiffness = 120, damping = 14},   -- ζ ≈ 0.64
    SNAPPY = {mass = 1, stiffness = 210, damping = 28},   -- ζ ≈ 1.2
    GENTLE = {mass = 1, stiffness = 80, damping = 16},    -- ζ ≈ 1
}

function SpringSolver.createSpring(initialValue, targetValue, preset)
    local spring = {
        position = initialValue,
        velocity = 0,
        target = targetValue,
        mass = preset.mass or 1,
        stiffness = preset.stiffness or 100,
        damping = preset.damping or 20,
        active = true,
        onUpdate = nil
    }
    
    local id = #SpringSolver.springs + 1
    SpringSolver.springs[id] = spring
    
    return {
        id = id,
        setTarget = function(value)
            spring.target = value
            spring.active = true
        end,
        setPosition = function(value)
            spring.position = value
        end,
        setCallback = function(callback)
            spring.onUpdate = callback
        end,
        destroy = function()
            spring.active = false
            SpringSolver.springs[id] = nil
        end
    }
end

-- Boucle de simulation principale
function SpringSolver.start()
    if SpringSolver.connections.update then return end
    
    local lastTime = tick()
    
    SpringSolver.connections.update = game:GetService("RunService").Heartbeat:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        if deltaTime > 0.1 then deltaTime = 0.1 end
        
        for id, spring in pairs(SpringSolver.springs) do
            if spring.active then
                -- Équation: a = -(k/m)x - (b/m)v
                local x = spring.position - spring.target
                local acceleration = -(spring.stiffness / spring.mass) * x - 
                                   (spring.damping / spring.mass) * spring.velocity
                
                -- Intégration Verlet
                spring.velocity = spring.velocity + acceleration * deltaTime
                spring.position = spring.position + spring.velocity * deltaTime
                
                -- Arrêt conditionnel
                local speed = math.abs(spring.velocity) + math.abs(x)
                if speed < 0.001 and math.abs(x) < 0.001 then
                    spring.position = spring.target
                    spring.velocity = 0
                    spring.active = false
                end
                
                if spring.onUpdate then
                    spring.onUpdate(spring.position)
                end
            end
        end
    end)
end

-- Animateur d'interface
function SpringSolver.animateUI(guiObject, property, targetValue, preset, callback)
    local currentValue = guiObject[property]
    local valueType = typeof(currentValue)
    
    local spring = SpringSolver.createSpring(0, 1, preset or SpringSolver.Presets.CRITICAL)
    
    spring.setCallback(function(t)
        local animatedValue
        
        if valueType == "number" then
            animatedValue = currentValue + (targetValue - currentValue) * t
        elseif valueType == "UDim2" then
            animatedValue = UDim2.new(
                currentValue.X.Scale + (targetValue.X.Scale - currentValue.X.Scale) * t,
                currentValue.X.Offset + (targetValue.X.Offset - currentValue.X.Offset) * t,
                currentValue.Y.Scale + (targetValue.Y.Scale - currentValue.Y.Scale) * t,
                currentValue.Y.Offset + (targetValue.Y.Offset - currentValue.Y.Offset) * t
            )
        elseif valueType == "Vector2" then
            animatedValue = Vector2.new(
                currentValue.X + (targetValue.X - currentValue.X) * t,
                currentValue.Y + (targetValue.Y - currentValue.Y) * t
            )
        elseif valueType == "Color3" then
            animatedValue = Color3.new(
                currentValue.R + (targetValue.R - currentValue.R) * t,
                currentValue.G + (targetValue.G - currentValue.G) * t,
                currentValue.B + (targetValue.B - currentValue.B) * t
            )
        end
        
        guiObject[property] = animatedValue
        
        if t == 1 and callback then
            callback()
        end
    end)
    
    spring.setTarget(1)
    return spring
end

return SpringSolver