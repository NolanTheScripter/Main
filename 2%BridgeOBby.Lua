local RS = game:GetService("RunService")
local map = game:GetService("Workspace"):FindFirstChild("Map")
local db = map and map:FindFirstChild("daddy bridge")
local bOne = db and db:FindFirstChild("bridge 1")
local bTwo = db and db:FindFirstChild("bridge 2")

local function updatePartColors(bridge)
    if bridge then
        for _, glass in ipairs(bridge:GetDescendants()) do
            if glass:IsA("Folder") and glass.Name == "glass" then
                for _, part in ipairs(glass:GetDescendants()) do
                    if part:IsA("Part") and (part.Name == "Part1" or part.Name == "Part2") then
                        local hasKillScript = part:FindFirstChild("kill") and part:FindFirstChild("kill"):IsA("Script")
                        if hasKillScript then
                            part.BrickColor = BrickColor.new("Bright red")
                        else
                            part.BrickColor = BrickColor.new("Bright green")
                        end
                    end
                end
            end
        end
    end
end

Heartbeat event for both bridges
RS.Heartbeat:Connect(function()
    updatePartColors(bOne)
    updatePartColors(bTwo)
end)