local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Enhanced cache with TTL (Time-To-Live)
local cache = {
    universeIds = {},
    productInfo = {},
    lastUpdated = {}
}

-- Safe API request with retries
local function apiRequest(url, retries)
    retries = retries or 3
    for i = 1, retries do
        local success, response = pcall(function()
            return HttpService:GetAsync(url, true)
        end)
        if success then return response end
        if i < retries then task.wait(1) end
    end
    warn("API request failed after "..retries.." attempts: "..url)
    return nil
end

-- Get Universe ID with validation
local function getUniverseId(placeId)
    placeId = tonumber(placeId)
    if not placeId or placeId <= 0 then return nil end
    
    if cache.universeIds[placeId] then
        return cache.universeIds[placeId]
    end

    local url = string.format("https://apis.roblox.com/universes/v1/places/%d/universe", placeId)
    local response = apiRequest(url)
    
    if response then
        local success, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if success and data.universeId then
            cache.universeIds[placeId] = data.universeId
            cache.lastUpdated[placeId] = os.time()
            return data.universeId
        end
    end
    return nil
end

-- Safe product info fetcher
local function getProductInfo(assetId, assetType)
    assetType = assetType or Enum.InfoType.GamePass
    assetId = tonumber(assetId)
    if not assetId or assetId <= 0 then return nil end
    
    local cacheKey = assetType.Name..tostring(assetId)
    
    -- Return cached data if fresh (less than 5 minutes old)
    if cache.productInfo[cacheKey] and (os.time() - (cache.lastUpdated[cacheKey] or 0)) < 300 then
        return cache.productInfo[cacheKey]
    end

    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(assetId, assetType)
    end)

    if success and result then
        cache.productInfo[cacheKey] = result
        cache.lastUpdated[cacheKey] = os.time()
        return result
    end
    
    return nil
end

-- Get gamepasses with pagination
local function getGamepasses(universeId)
    universeId = tonumber(universeId)
    if not universeId or universeId <= 0 then return {} end
    
    local gamepasses = {}
    local cursor = ""
    local hasMore = true
    local attempts = 0
    
    while hasMore and attempts < 10 do -- Prevent infinite loops
        attempts = attempts + 1
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/game-passes?limit=100%s",
            universeId,
            cursor ~= "" and "&cursor="..cursor or ""
        )
        
        local response = apiRequest(url)
        if not response then break end
        
        local success, data = pcall(HttpService.JSONDecode, HttpService, response)
        if not success then break end
        
        for _, gp in ipairs(data.data or {}) do
            if gp.id and gp.name then
                table.insert(gamepasses, {
                    id = tonumber(gp.id) or 0,
                    name = tostring(gp.name) or "Unknown",
                    raw = gp -- Keep raw data for debugging
                })
            end
        end
        
        cursor = data.nextPageCursor or ""
        hasMore = cursor ~= "" and #data.data == 100
        if hasMore then task.wait(0.5) end -- Rate limiting
    end
    
    return gamepasses
end

-- Safe print function
local function printGamepasses(placeId)
    placeId = tonumber(placeId) or game.PlaceId
    local universeId = getUniverseId(placeId)
    
    if not universeId then
        warn("Failed to get universe ID for place "..tostring(placeId))
        return false
    end
    
    local gamepasses = getGamepasses(universeId)
    
    print(string.format("\nFound %d gamepasses for place %d (universe %d):", 
        #gamepasses, placeId, universeId))
    
    for i, gp in ipairs(gamepasses) do
        local info = getProductInfo(gp.id)
        local price = info and info.PriceInRobux or 0
        local sales = info and info.Sales or 0
        local creator = info and info.Creator and info.Creator.Name or "Unknown"
        
        print(string.format("%3d. %-40s ID: %-10d Price: %-5d Sales: %-7d Creator: %s",
            i,
            gp.name:sub(1, 40),
            gp.id,
            price,
            sales,
            creator
        ))
    end
    
    return true
end

-- Module export with initialization check
local initialized = false
local function init()
    if initialized then return end
    initialized = true
    -- Any initialization code here
end

return {
    Init = init,
    GetUniverseId = getUniverseId,
    GetProductInfo = getProductInfo,
    GetGamepasses = getGamepasses,
    PrintGamepasses = printGamepasses,
    _VERSION = "1.2.0"
}