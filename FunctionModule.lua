local FunctionModule = {}

-- =======================
-- Utility Functions
-- =======================

function FunctionModule.safeCall(func, retries, initialDelay, maxDelay, ...)
    retries = retries or 3
    initialDelay = initialDelay or 0.5
    maxDelay = maxDelay or 5
    local delay = initialDelay
    local attempt = 0
    local success, result

    while attempt < retries do
        attempt = attempt + 1
        success, result = pcall(func, ...)
        if success then
            return result
        end
        warn(string.format("Attempt %d failed: %s", attempt, result))
        wait(delay)
        delay = math.min(delay * 2, maxDelay)
    end
    return nil
end

function FunctionModule.timeExecution(func, ...)
    local startTime = tick()
    local result = func(...)
    local endTime = tick()
    local execTime = endTime - startTime
    print(string.format("Execution time: %.6f seconds", execTime))
    return result, execTime
end

function FunctionModule.deepClone(tbl)
    local result = {}
    for key, value in next, tbl, nil do
        if type(value) == "table" then
            result[key] = FunctionModule.deepClone(value)
        elseif type(value) == "userdata" then
            result[key] = value
        else
            result[key] = value
        end
    end
    setmetatable(result, getmetatable(tbl))
    return result
end

-- =======================
-- Caching System
-- =======================

local cache = {}
function FunctionModule.memoize(func, ttl)
    ttl = ttl or 60
    return function(...)
        local key = table.concat({...}, ",")
        local currentTime = tick()

        if cache[key] and (currentTime - cache[key].timestamp < ttl) then
            return cache[key].value
        end

        local result = func(...)
        cache[key] = { value = result, timestamp = currentTime }
        return result
    end
end

-- =======================
-- Functional Programming Enhancements
-- =======================

function FunctionModule.compose(...)
    local funcs = {...}
    return function(initialValue)
        local result = initialValue
        for _, func in ipairs(funcs) do
            result = func(result)
        end
        return result
    end
end

function FunctionModule.chain(func)
    local result = func()
    local chain = {
        thenDo = function(self, nextFunc)
            result = nextFunc(result)
            return self
        end,
        catchError = function(self, errorFunc)
            if not result then
                errorFunc("Error encountered")
            end
            return self
        end,
        getResult = function()
            return result
        end,
        logResult = function(self, tag)
            print(string.format("[%s] Result: %s", tag or "INFO", tostring(result)))
            return self
        end,
        transformResult = function(self, transformer)
            result = transformer(result)
            return self
        end
    }
    return chain
end

-- =======================
-- Advanced Event Handlers
-- =======================

function FunctionModule.dynamicDebounce(func, initialDelay, decayRate, maxDelay)
    local lastCallTime = 0
    local lastDelay = initialDelay or 0.5
    local maxDelay = maxDelay or 5
    return function(...)
        local currentTime = tick()
        if currentTime - lastCallTime >= lastDelay then
            lastCallTime = currentTime
            func(...)
            lastDelay = math.min(lastDelay * decayRate, maxDelay)
        end
    end
end

function FunctionModule.throttle(func, windowTime)
    local lastCallTime = 0
    return function(...)
        local currentTime = tick()
        if currentTime - lastCallTime >= windowTime then
            lastCallTime = currentTime
            func(...)
        end
    end
end

-- =======================
-- Asynchronous Helpers
-- =======================

function FunctionModule.asyncBatch(funcs, maxConcurrency, ...)
    maxConcurrency = maxConcurrency or 5
    local results = {}
    local semaphore = 0

    local function executeAsync(func, index)
        if semaphore < maxConcurrency then
            semaphore = semaphore + 1
            task.spawn(function()
                local success, result = pcall(func, ...)
                results[index] = { success = success, result = result }
                semaphore = semaphore - 1
            end)
        end
    end

    for i, func in ipairs(funcs) do
        executeAsync(func, i)
    end

    return results
end

-- =======================
-- Task-based Execution
-- =======================
function FunctionModule.taskSpawn(func, ...)
    task.spawn(function()
        local success, result = pcall(func, ...)
        if not success then
            warn("Error in task.spawn: " .. result)
        end
    end)
end

function FunctionModule.taskDelay(delay, func, ...)
    task.delay(delay, function()
        local success, result = pcall(func, ...)
        if not success then
            warn("Error in task.delay: " .. result)
        end
    end)
end

function FunctionModule.taskWait(waitTime)
    task.wait(waitTime)
end

-- =======================
-- Custom Error Handling
-- =======================

function FunctionModule.retryWithBackoff(func, retries, initialDelay, maxDelay, ...)
    retries = retries or 3
    initialDelay = initialDelay or 1
    maxDelay = maxDelay or 5

    return FunctionModule.safeCall(func, retries, initialDelay, maxDelay, ...)
end

-- =======================
-- Data Manipulation and Transformation
-- =======================

function FunctionModule.find(tbl, condition)
    for _, value in ipairs(tbl) do
        if condition(value) then
            return value
        end
    end
    return nil
end

-- =======================
-- Debugging & Logging Tools
-- =======================

local verbosityLevel = 1
function FunctionModule.setVerbosity(level)
    verbosityLevel = level
end

function FunctionModule.log(message, tag, level)
    level = level or 1
    if level >= verbosityLevel then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        print(string.format("[%s] [%s] %s", timestamp, tag or "INFO", message))
    end
end

-- =======================
-- Private Helper
-- =======================
local function privateHelper()
    return "This is private!"
end

return FunctionModule