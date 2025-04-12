local RemoteViewer = {}
RemoteViewer.__index = RemoteViewer

function RemoteViewer.new()
    local self = setmetatable({}, RemoteViewer)
    self.eventListeners = {}
    self.functionCache = {}
    self.eventUsage = {}
    self.functionUsage = {}
    self.cacheExpiryTime = 30
    self.learningRate = 0.1
    self.retryCount = 3
    self.retryDelay = 1
    self.lastUpdateTime = os.clock()
    self.settings = self:LoadSettings()
    self.uiInitialized = false
    self.usageHistory = {} -- Stores historical usage data for predictions
    self.anomalyThreshold = 5 -- Threshold for detecting anomalies
    return self
end

function RemoteViewer:Initialize()
    self:MonitorReplicatedStorage()
    self:InitializeUI()
end

function RemoteViewer:InitializeUI()
    if not self.uiInitialized then
        print("Initializing UI...")
        self.uiInitialized = true
    else
        warn("UI has already been initialized. Skipping re-initialization.")
    end
end

function RemoteViewer:MonitorReplicatedStorage()
    game.ReplicatedStorage.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then
            self:RegisterRemoteEvent(child)
        elseif child:IsA("RemoteFunction") then
            self:RegisterRemoteFunction(child)
        end
    end)

    for _, child in pairs(game.ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then
            self:RegisterRemoteEvent(child)
        elseif child:IsA("RemoteFunction") then
            self:RegisterRemoteFunction(child)
        end
    end
end

function RemoteViewer:RegisterRemoteEvent(remoteEvent)
    if not self.eventListeners[remoteEvent.Name] then
        self.eventListeners[remoteEvent.Name] = remoteEvent.OnClientEvent:Connect(function(...)
            self:HandleEventUsage(remoteEvent.Name)
        end)
    end
end

function RemoteViewer:RegisterRemoteFunction(remoteFunction)
    if not self.functionCache[remoteFunction.Name] then
        self.functionCache[remoteFunction.Name] = remoteFunction
    end
end

function RemoteViewer:HandleEventUsage(eventName)
    self:UpdateUsage(self.eventUsage, eventName)
    self:DetectAnomalies(self.eventUsage, eventName)
end

function RemoteViewer:HandleFunctionUsage(functionName)
    self:UpdateUsage(self.functionUsage, functionName)
    self:DetectAnomalies(self.functionUsage, functionName)
end

function RemoteViewer:UpdateUsage(usageTable, name)
    local currentTime = os.clock()
    if not usageTable[name] then
        usageTable[name] = { frequency = 0, lastAccess = currentTime }
    end
    local data = usageTable[name]
    data.frequency = data.frequency + 1
    data.lastAccess = currentTime

    -- Update historical usage for predictions
    if not self.usageHistory[name] then
        self.usageHistory[name] = {}
    end
    table.insert(self.usageHistory[name], data.frequency)

    -- Limit history size to prevent memory overflow
    if #self.usageHistory[name] > 100 then
        table.remove(self.usageHistory[name], 1)
    end

    self:DecayOldData(usageTable, currentTime)
end

function RemoteViewer:DecayOldData(usageTable, currentTime)
    for name, data in pairs(usageTable) do
        if currentTime - data.lastAccess > self.cacheExpiryTime then
            -- Dynamic learning rate adjustment
            local adjustedLearningRate = self:AdjustLearningRate(data.frequency)
            data.frequency = data.frequency * (1 - adjustedLearningRate)
        end
    end
end

function RemoteViewer:AdjustLearningRate(frequency)
    -- Increase learning rate for low-frequency events and decrease for high-frequency
    if frequency < 10 then
        return math.min(self.learningRate * 2, 0.5)
    elseif frequency > 100 then
        return math.max(self.learningRate * 0.5, 0.01)
    else
        return self.learningRate
    end
end

function RemoteViewer:PredictFutureUsage(name)
    -- Predict future usage based on a simple moving average
    if not self.usageHistory[name] or #self.usageHistory[name] < 5 then
        return nil
    end
    local sum = 0
    for i = #self.usageHistory[name] - 4, #self.usageHistory[name] do
        sum = sum + self.usageHistory[name][i]
    end
    return sum / 5
end

function RemoteViewer:DetectAnomalies(usageTable, name)
    local currentFrequency = usageTable[name] and usageTable[name].frequency or 0
    local predictedFrequency = self:PredictFutureUsage(name)
    if predictedFrequency and math.abs(currentFrequency - predictedFrequency) > self.anomalyThreshold then
        warn("Anomaly detected in usage of " .. name .. ": Current = " .. currentFrequency .. ", Predicted = " .. predictedFrequency)
    end
end

function RemoteViewer:CallRemoteFunction(functionName, ...)
    local remoteFunction = self.functionCache[functionName]
    if remoteFunction then
        local success, result = pcall(function()
            return remoteFunction:InvokeServer(...)
        end)
        if success then
            self:HandleFunctionUsage(functionName)
            return result
        else
            warn("Error invoking remote function: " .. tostring(result))
            self:RetryFunction(functionName, ...)
        end
    else
        warn("Remote function '" .. functionName .. "' not found in the function cache.")
    end
end

function RemoteViewer:RetryFunction(functionName, ...)
    for attempt = 1, self.retryCount do
        task.wait(self.retryDelay * attempt)
        local success, result = pcall(function()
            return self:CallRemoteFunction(functionName, ...)
        end)
        if success then
            return result
        else
            warn("Retrying function '" .. functionName .. "': Attempt " .. attempt .. " failed.")
        end
    end
    warn("All retry attempts for function '" .. functionName .. "' failed.")
end

function RemoteViewer:Update()
    self:AutoDetectRemotes()
    local currentTime = os.clock()
    self:DecayOldData(self.eventUsage, currentTime)
    self:DecayOldData(self.functionUsage, currentTime)

    if self.uiInitialized then
        self:UpdateUI()
    end
end

function RemoteViewer:UpdateUI()
    -- Update the graphical UI, displaying the usage statistics, logs, and graphs
end

local viewer = RemoteViewer.new()
viewer:Initialize()

while true do
    viewer:Update()
    task.wait(1)
end

return RemoteViewer