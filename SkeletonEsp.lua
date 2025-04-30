--// Aliases
local taskWait = task.wait
local tableInsert = table.insert
local tableFind = table.find
local tableRemove = table.remove

local Vector2New = Vector2.new
local mathRound = math.round

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local WorldToViewportPoint = Camera.WorldToViewportPoint

--// Utility Functions
local function createLine(color, alpha, thickness)
    local line = Drawing.new("Line")
    line.Color = color
    line.Transparency = alpha
    line.Thickness = thickness
    line.Visible = false
    return line
end

local function smoothenPosition(vec)
    return Vector2New(mathRound(vec.X), mathRound(vec.Y))
end

--// Skeleton Class
local Skeleton = {}
Skeleton.__index = Skeleton

function Skeleton:UpdateStructure()
    if not self.Player or not self.Player.Character then
        self:RemoveLines()
        return
    end

    local character = self.Player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Clear existing lines if character changed
    if self.LastCharacter ~= character then
        self:RemoveLines()
        self.LastCharacter = character
    end

    -- Define bone connections (R15 and R6 compatible)
    local connections = {
        -- Torso connections
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        
        -- Left arm
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        
        -- Right arm
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        
        -- Left leg
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        
        -- Right leg
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }

    -- Create lines for each connection if they don't exist
    for i, connection in ipairs(connections) do
        if not self.Lines[i] then
            self.Lines[i] = createLine(self.Color, self.Alpha, self.Thickness)
            self.Lines[i].StartPart = connection[1]  -- Store part names
            self.Lines[i].EndPart = connection[2]
        end
    end

    -- Remove extra lines if connections decreased
    while #self.Lines > #connections do
        tableRemove(self.Lines):Remove()
    end
end

function Skeleton:UpdateProperties()
    for _, line in ipairs(self.Lines) do
        line.Color = self.Color
        line.Transparency = self.Alpha
        line.Thickness = self.Thickness
    end
end

function Skeleton:Update()
    if self.Removed or not self.Visible then
        self:SetVisible(false)
        return
    end

    -- Check if player is valid
    if not self.Player or not self.Player.Character then
        self:SetVisible(false)
        return
    end

    local character = self.Player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        self:SetVisible(false)
        return
    end

    -- Update structure if needed
    self:UpdateStructure()

    -- Update line positions
    for _, line in ipairs(self.Lines) do
        local startPart = character:FindFirstChild(line.StartPart)
        local endPart = character:FindFirstChild(line.EndPart)

        if startPart and endPart then
            local startPos, startVisible = WorldToViewportPoint(Camera, startPart.Position)
            local endPos, endVisible = WorldToViewportPoint(Camera, endPart.Position)

            if startVisible and endVisible then
                line.From = smoothenPosition(startPos)
                line.To = smoothenPosition(endPos)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

function Skeleton:Toggle(state)
    if state then
        if not self._updateConnection then
            self._updateConnection = RunService.Heartbeat:Connect(function()
                self:Update()
            end)
        end
    else
        if self._updateConnection then
            self._updateConnection:Disconnect()
            self._updateConnection = nil
        end
        self:SetVisible(false)
    end
end

function Skeleton:SetVisible(state)
    for _, line in ipairs(self.Lines) do
        line.Visible = state and self.Visible
    end
end

function Skeleton:RemoveLines()
    for _, line in ipairs(self.Lines) do
        line:Remove()
    end
    self.Lines = {}
end

function Skeleton:Remove()
    self.Removed = true
    if self._updateConnection then
        self._updateConnection:Disconnect()
    end
    self:RemoveLines()
end

--// Constructor
function Skeleton.new(player)
    local self = setmetatable({}, Skeleton)

    self.Player = player
    self.Removed = false
    self.Visible = true
    self.Lines = {}

    self.Color = Color3.new(1, 1, 1)
    self.Alpha = 1
    self.Thickness = 1
    self.DoSubsteps = false

    self._updateConnection = nil
    self._characterTracker = nil

    return self
end

--// Library Table
local Library = {}

function Library:NewSkeleton(player)
    local skel = Skeleton.new(player)

    -- Set team color if available
    if player.Team then
        skel.Color = player.TeamColor.Color
    end

    -- Bind team color change
    player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        skel.Color = player.TeamColor.Color
        skel:UpdateProperties()
    end)

    -- Auto-remove when player leaves
    player.CharacterRemoving:Connect(function()
        skel:Remove()
    end)

    -- Start updating
    skel:Toggle(true)

    return skel
end

return Library