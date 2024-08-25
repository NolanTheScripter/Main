-- AdvancedErrorHandling.lua
-- Made by [Your Name], at time: August 25, 2024
-- 
-- Description:
-- This module provides a comprehensive error handling system for Lua applications.
-- It allows you to log errors with varying levels of severity (debug, info, warning, error, critical),
-- store logs in memory, and optionally log them to a file or the console.
-- 
-- Benefits:
-- 1. **Centralized Error Management**: Easily manage and log errors from different parts of your application.
-- 2. **Configurable Logging**: Choose where to log errors (console or file) based on your needs.
-- 3. **Detailed Error Information**: Each log entry includes a timestamp, error level, category, message, and stack trace for easy debugging.
-- 4. **Safe Function Execution**: Use `safeExecute` to run functions safely and handle any errors that occur without crashing your application.
-- 5. **Customizable**: Modify the configuration to fit your specific requirements (e.g., enabling/disabling logging, changing log destinations).

local AdvancedErrorHandling = {}

AdvancedErrorHandling.Levels = {
    debug = "debug",
    info = "info",
    warning = "warning",
    error = "error",
    critical = "critical"
}

AdvancedErrorHandling.errorLogs = {}

AdvancedErrorHandling.config = {
    logToFile = true,
    logToConsole = true,
    emailOnCritical = false,
    emailRecipients = {"admin@example.com"}
}

local function logErrorToFile(logEntry)
    if not AdvancedErrorHandling.config.logToFile then return end
    local file, err = io.open("error_log.txt", "a")
    if not file then
        print("Error opening log file: " .. err)
        return
    end
    file:write("Timestamp: " .. logEntry.timestamp .. "\n")
    file:write("Level: " .. logEntry.level .. "\n")
    file:write("Category: " .. logEntry.category .. "\n")
    file:write("Message: " .. logEntry.message .. "\n")
    file:write("Stack Trace: " .. logEntry.stackTrace .. "\n")
    file:write("------\n")
    file:close()
end

local function logErrorToConsole(logEntry)
    if not AdvancedErrorHandling.config.logToConsole then return end
    print("[" .. logEntry.level .. "] " .. logEntry.message)
end

function AdvancedErrorHandling.logError(errorMessage, level, category)
    level = level or AdvancedErrorHandling.Levels.error
    category = category or "General"
    local logEntry = {
        message = errorMessage,
        level = level,
        category = category,
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        stackTrace = debug.traceback()
    }
    table.insert(AdvancedErrorHandling.errorLogs, logEntry)

    logErrorToConsole(logEntry)
    logErrorToFile(logEntry)
end

function AdvancedErrorHandling.handleError(err, level, category)
    local customMessage = "An error occurred: " .. tostring(err)
    AdvancedErrorHandling.logError(customMessage, level, category)
    return customMessage
end

function AdvancedErrorHandling.safeExecute(func, level, category, ...)
    local status, result = xpcall(func, function(err) return AdvancedErrorHandling.handleError(err, level, category) end, ...)
    if not status then
        print("Execution failed: " .. result)
    else
        print("Execution succeeded.")
    end
    return status, result
end

function AdvancedErrorHandling.printErrorLogs()
    for i, log in ipairs(AdvancedErrorHandling.errorLogs) do
        print("Log #" .. i)
        print("Timestamp: " .. log.timestamp)
        print("Level: " .. log.level)
        print("Category: " .. log.category)
        print("Message: " .. log.message)
        print("Stack Trace: " .. log.stackTrace)
        print("------")
    end
end

return AdvancedErrorHandling