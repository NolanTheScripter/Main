-- CooldownHandler.lua
-- Dragnir Smart Cooldown Management System

local RunService = game:GetService("RunService")

local CooldownHandler = {}

--// Settings
local defaultCooldown = 0.35 -- Seconds between valid parry attempts
local cooldownMap = {}

--// Internal
local lastUpdate = os.clock()

--// Utility
local function getPlayerID(player)
	return tostring(player.UserId or player.Name)
end

--// API

function CooldownHandler:CanParry(player)
	local id = getPlayerID(player)
	local current = os.clock()

	if cooldownMap[id] == nil or current >= cooldownMap[id] then
		return true
	end

	return false
end

function CooldownHandler:SetCooldown(player, duration)
	local id = getPlayerID(player)
	cooldownMap[id] = os.clock() + (duration or defaultCooldown)
end

function CooldownHandler:GetCooldownRemaining(player)
	local id = getPlayerID(player)
	local remaining = (cooldownMap[id] or 0) - os.clock()
	return math.max(0, remaining)
end

function CooldownHandler:GetCooldownPercent(player)
	local id = getPlayerID(player)
	local start = (cooldownMap[id] or 0) - defaultCooldown
	local elapsed = os.clock() - start
	return math.clamp(elapsed / defaultCooldown, 0, 1)
end

function CooldownHandler:Clear(player)
	cooldownMap[getPlayerID(player)] = nil
end

function CooldownHandler:ClearAll()
	cooldownMap = {}
end

--// HUD Visualizer Support (Optional)
function CooldownHandler:GetHUDData(player)
	return {
		Percent = self:GetCooldownPercent(player),
		Remaining = self:GetCooldownRemaining(player),
		IsReady = self:CanParry(player)
	}
end

-- Optional automatic cleanup (if needed in the future)
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for id, time in pairs(cooldownMap) do
		if now >= time then
			cooldownMap[id] = nil
		end
	end
end)

return CooldownHandler