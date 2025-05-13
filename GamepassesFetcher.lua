local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Configuration
local MAX_RETRIES = 3
local DELAY_BETWEEN_REQUESTS = 1
local RESULTS_PER_PAGE = 100

-- Enhanced secure request function with retries and delays
local function secureRequest(url)
    local retries = 0
    local lastError = ""
    
    while retries < MAX_RETRIES do
        local success, result = pcall(function()
            if retries > 0 then
                task.wait(DELAY_BETWEEN_REQUESTS * retries)
            end
            return HttpService:GetAsync(url, true)
        end)
        
        if success then
            return result
        else
            lastError = result
            retries = retries + 1
            warn(string.format("Request failed (attempt %d/%d): %s", retries, MAX_RETRIES, result))
        end
    end
    
    error(string.format("Failed after %d attempts. Last error: %s", MAX_RETRIES, lastError))
end

-- Get universe ID with better caching
local universeIdCache = {}
local function getUniverseId(placeId)
    placeId = placeId or game.PlaceId
    
    if universeIdCache[placeId] then
        return universeIdCache[placeId]
    end
    
    local url = string.format("https://apis.roblox.com/universes/v1/places/%d/universe", placeId)
    local result = secureRequest(url)
    local data = HttpService:JSONDecode(result)
    
    universeIdCache[placeId] = data.universeId
    return data.universeId
end

-- Fetch all gamepasses with pagination
local function fetchAllGamepasses(universeId)
    local gamepasses = {}
    local cursor = ""
    local hasMore = true
    local page = 1
    
    while hasMore do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/game-passes?limit=%d&sortOrder=Asc",
            universeId,
            RESULTS_PER_PAGE
        )
        
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local result = secureRequest(url)
        local data = HttpService:JSONDecode(result)
        
        for _, gamepass in ipairs(data.data) do
            table.insert(gamepasses, {
                id = gamepass.id,
                name = gamepass.name,
                price = gamepass.price or 0,
                displayName = gamepass.displayName or gamepass.name
            })
        end
        
        hasMore = data.nextPageCursor ~= nil
        cursor = data.nextPageCursor or ""
        page = page + 1
        
        if hasMore then
            task.wait(DELAY_BETWEEN_REQUESTS)
        end
    end
    
    return gamepasses
end

-- Main function with protection against duplicate runs
local executionLock = false
local function printAllGamepasses(placeId)
    if executionLock then
        warn("Script is already running. Please wait.")
        return
    end
    
    executionLock = true
    
    local success, err = pcall(function()
        local universeId = getUniverseId(placeId)
        if not universeId then
            error("Could not determine universe ID")
        end
        
        print("\nFetching gamepasses... (This may take a moment)")
        local gamepasses = fetchAllGamepasses(universeId)
        
        if #gamepasses == 0 then
            print("No gamepasses found for this game")
            return
        end
        
        print(string.format("\nFound %d gamepasses:", #gamepasses))
        for _, gamepass in ipairs(gamepasses) do
            print(string.format("Gamepass: %-30s | ID: %-10d | Price: %d R$", 
                gamepass.displayName, 
                gamepass.id, 
                gamepass.price
            ))
        end
    end)
    
    if not success then
        warn("Error:", err)
    end
    
    executionLock = false
end

-- Export the function but don't auto-run
return {
    GetGamepasses = printAllGamepasses
}