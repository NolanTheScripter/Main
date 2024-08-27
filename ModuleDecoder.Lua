-- Made by Nolanz with Perplexity(Better ChatGpt) on August 27, 2024, at 1:41 p.m.

local ModuleDecoder = {}

local function logMessage(message)
    print("[ModuleDecoder] " .. message)
end

local function findModuleByName(moduleName)
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("ModuleScript") and descendant.Name == moduleName then
            return descendant
        end
    end
    return nil
end

local function setClipboard(content)
    logMessage("Setting clipboard content: " .. content)
    -- Implement actual clipboard functionality if needed
end

function ModuleDecoder.DecodeModule(moduleName, setClipBoard)
    if type(moduleName) ~= "string" then
        error("Invalid module name. It must be a string.")
    end

    local targetModule = findModuleByName(moduleName)

    if not targetModule then
        logMessage("Module not found: " .. moduleName)
        return nil, "Module not found"
    end

    local success, sourceContent = pcall(function() return targetModule.Source end)
    if not success then
        logMessage("Failed to retrieve source content for module: " .. moduleName)
        return nil, "Failed to retrieve source content"
    end

    logMessage("Retrieved source content for module: " .. moduleName)

    if setClipBoard then
        setClipboard(sourceContent)
    end

    return sourceContent
end

return ModuleDecoder