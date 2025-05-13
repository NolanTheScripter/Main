local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Cache system to prevent duplicate requests
local cache = {
    universeIds = {},
    productInfo = {}
}

-- Secure API request with error handling
local function apiRequest(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    return success and response or nil
end

-- Get Universe ID from Place ID
local function getUniverseId(placeId)
    if cache.universeIds[placeId] then
        return cache.universeIds[placeId]
    end

    local url = string.format("https://apis.roblox.com/universes/v1/places/%d/universe", placeId)
    local response = apiRequest(url)
    
    if response then
        local data = HttpService:JSONDecode(response)
        cache.universeIds[placeId] = data.universeId
        return data.universeId
    end
    
    return nil
end

-- Enhanced product info fetcher
local function getProductInfo(assetId, assetType)
    assetType = assetType or Enum.InfoType.GamePass
    local cacheKey = assetType.Name..assetId
    
    if cache.productInfo[cacheKey] then
        return cache.productInfo[cacheKey]
    end

    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(assetId, assetType)
    end)

    if success then
        cache.productInfo[cacheKey] = result
        return result
    end
    
    return nil
end

-- Get all gamepasses for a universe
local function getGamepasses(universeId)
    local url = string.format("https://games.roblox.com/v1/games/%d/game-passes?limit=100", universeId)
    local response = apiRequest(url)
    
    if not response then return {} end
    
    local data = HttpService:JSONDecode(response)
    local results = {}
    
    for _, gamepass in ipairs(data.data) do
        local info = getProductInfo(gamepass.id)
        if info then
            table.insert(results, {
                id = gamepass.id,
                name = gamepass.name,
                price = info.PriceInRobux or 0,
                sales = info.Sales or 0,
                creator = info.Creator and info.Creator.Name or "Unknown"
            })
        end
    end
    
    return results
end

-- Main function to print all gamepasses
local function printGamepasses(placeId)
    placeId = placeId or game.PlaceId
    local universeId = getUniverseId(placeId)
    
    if not universeId then
        warn("Failed to get universe ID for place", placeId)
        return
    end
    
    local gamepasses = getGamepasses(universeId)
    
    if #gamepasses == 0 then
        print("No gamepasses found for this game")
        return
    end
    
    print(string.format("\nGamepasses for place %d (universe %d):", placeId, universeId))
    for _, gp in ipairs(gamepasses) do
        print(string.format(
            "%s (ID: %d) - %d R$ | Sales: %d | By: %s",
            gp.name, gp.id, gp.price, gp.sales, gp.creator
        ))
    end
end

-- Export functions without auto-executing
return {
    GetUniverseId = getUniverseId,
    GetProductInfo = getProductInfo,
    GetGamepasses = getGamepasses,
    PrintGamepasses = printGamepasses
}