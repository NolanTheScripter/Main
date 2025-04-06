--// Module: ServerScanner.lua

local HttpService = game:GetService("HttpService") local TeleportService = game:GetService("TeleportService") local Players = game:GetService("Players")

local ServerScanner = {}

local GameId = game.PlaceId local Cursor = nil local Scanning = false local AutoThread = nil local UI = nil

local function FetchServers() local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s", GameId, Cursor and ("&cursor=" .. Cursor) or "") local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end) if success and result and result.data then Cursor = result.nextPageCursor return result.data end return {} end

function ServerScanner:Start(uiModule) UI = uiModule Scanning = true UI:SetStatus("Scanning...") task.spawn(function() local collected = {} local settings = UI:GetSettings()

while Scanning and Cursor do
        local servers = FetchServers()
        for _, s in ipairs(servers) do
            if s.playing < settings.MaxPlayers then
                table.insert(collected, {
                    ID = s.id,
                    Playing = s.playing,
                    Ping = math.random(40, settings.MaxPing) -- Fake ping estimate
                })
            end
        end
        task.wait(0.1)
    end

    table.sort(collected, function(a, b)
        return a.Ping < b.Ping
    end)

    UI:UpdateServerList(collected, function(serverId)
        TeleportService:TeleportToPlaceInstance(GameId, serverId, Players.LocalPlayer)
    end)

    if settings.AutoJoin and collected[1] then
        TeleportService:TeleportToPlaceInstance(GameId, collected[1].ID, Players.LocalPlayer)
    end

    UI:SetStatus("Scan Complete")
end)

end

function ServerScanner:AutoLoop(uiModule) if AutoThread then return end AutoThread = task.spawn(function() while true do local settings = uiModule:GetSettings() if settings.AutoScan then Cursor = nil ServerScanner:Start(uiModule) end task.wait(settings.ScanDelay or 10) end end) end

function ServerScanner:Stop() Scanning = false end

return ServerScanner
