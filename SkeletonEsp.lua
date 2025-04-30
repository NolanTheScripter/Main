local taskWait = task.wait
local tableInsert = table.insert
local tableFind = table.find
local tableRemove = table.remove
local Vector2New = Vector2.new
local mathRound = math.round

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local LocalPlayer = game.Players.LocalPlayer

local Library = {}
Library.__index = Library

local function createLine(color, transparency, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color or Color3.fromRGB(0, 255, 0)
    line.Transparency = transparency or 1
    line.Thickness = thickness or 1
    return line
end

local function smoothenPosition(position)
    return Vector2New(mathRound(position.X), mathRound(position.Y))
end

local Skeleton = {
    Removed = false,
    Player = nil,
    Visible = false,
    Lines = {},
    Color = Color3.fromRGB(0, 255, 0),
    Alpha = 1,
    Thickness = 1,
    DoSubsteps = true,
    _updateConnection = nil,
    _characterTracker = nil,
}
Skeleton.__index = Skeleton

function Skeleton:UpdateStructure()
    if self.Removed or not self.Player.Character then return end

    self:RemoveLines()
    local character = self.Player.Character

    local function processPart(part)
        for _, link in ipairs(part:GetChildren()) do
            if link:IsA("Motor6D") and link.Part0 and link.Part1 then
                tableInsert(self.Lines, {
                    createLine(self.Color, self.Alpha, self.Thickness),
                    createLine(self.Color, self.Alpha, self.Thickness),
                    part.Name,
                    link.Name
                })
            end
        end
    end

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            processPart(part)
        end
    end

    if not self._characterTracker then
        self._characterTracker = character.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") then
                processPart(child)
            end
        end)
    end
end

function Skeleton:UpdateProperties()
    for _, linePair in ipairs(self.Lines) do
        linePair[1].Color = self.Color
        linePair[1].Transparency = self.Alpha
        linePair[1].Thickness = self.Thickness
        linePair[2].Color = self.Color
        linePair[2].Transparency = self.Alpha
        linePair[2].Thickness = self.Thickness
    end
end

function Skeleton:Update()
    if self.Removed then return end

    local character = self.Player.Character
    if not character then
        self.Visible = false
        if not self.Player.Parent then
            self:Remove()
        end
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        self.Visible = false
        return
    end

    local needsStructureUpdate = false
    for _, linePair in ipairs(self.Lines) do
        local part = character:FindFirstChild(linePair[3])
        local link = part and part:FindFirstChild(linePair[4])

        if not (part and link and link.Part0 and link.Part1) then
            linePair[1].Visible = false
            linePair[2].Visible = false
            needsStructureUpdate = true
            goto continue
        end

        local part0, part1 = link.Part0, link.Part1
        local successCount = 0

        if self.DoSubsteps then
            local c0Pos = (part0.CFrame * link.C0).Position
            local part0Pos, part0Vis = WorldToViewportPoint(Camera, part0.Position)
            local c0ScreenPos, c0Vis = WorldToViewportPoint(Camera, c0Pos)

            if part0Vis and c0Vis then
                linePair[1].From = smoothenPosition(Vector2New(part0Pos.X, part0Pos.Y))
                linePair[1].To = smoothenPosition(Vector2New(c0ScreenPos.X, c0ScreenPos.Y))
                linePair[1].Visible = self.Visible
                successCount += 1
            else
                linePair[1].Visible = false
            end

            local c1Pos = (part1.CFrame * link.C1).Position
            local part1Pos, part1Vis = WorldToViewportPoint(Camera, part1.Position)
            local c1ScreenPos, c1Vis = WorldToViewportPoint(Camera, c1Pos)

            if part1Vis and c1Vis then
                linePair[2].From = smoothenPosition(Vector2New(part1Pos.X, part1Pos.Y))
                linePair[2].To = smoothenPosition(Vector2New(c1ScreenPos.X, c1ScreenPos.Y))
                linePair[2].Visible = self.Visible
                successCount += 1
            else
                linePair[2].Visible = false
            end
        else
            local part0Pos, part0Vis = WorldToViewportPoint(Camera, part0.Position)
            local part1Pos, part1Vis = WorldToViewportPoint(Camera, part1.Position)

            if part0Vis and part1Vis then
                linePair[1].From = smoothenPosition(Vector2New(part0Pos.X, part0Pos.Y))
                linePair[1].To = smoothenPosition(Vector2New(part1Pos.X, part1Pos.Y))
                linePair[1].Visible = self.Visible
                successCount += 1
            else
                linePair[1].Visible = false
            end
            linePair[2].Visible = false
        end

        ::continue::
    end

    if needsStructureUpdate or #self.Lines == 0 then
        self:UpdateStructure()
    end
end

function Skeleton:Toggle(state)
    state = state == nil and not self.Visible or state
    if self.Visible == state then return end

    self.Visible = state
    if state then
        self:UpdateStructure()
        if self._updateConnection then
            self._updateConnection:Disconnect()
        end
        self._updateConnection = RunService.Heartbeat:Connect(function()
            self:Update()
        end)
    else
        if self._updateConnection then
            self._updateConnection:Disconnect()
            self._updateConnection = nil
        end
        self:SetVisible(false)
    end
end

function Skeleton:SetVisible(state)
    for _, linePair in ipairs(self.Lines) do
        linePair[1].Visible = state
        linePair[2].Visible = state
    end
end

function Skeleton:RemoveLines()
    for _, linePair in ipairs(self.Lines) do
        linePair[1]:Remove()
        linePair[2]:Remove()
    end
    self.Lines = {}
end

function Skeleton:Remove()
    if self.Removed then return end
    self.Removed = true
    self:Toggle(false)
    self:RemoveLines()
    if self._characterTracker then
        self._characterTracker:Disconnect()
    end
end

function Library:NewSkeleton(player, doSubsteps, color, alpha, thickness)
    assert(typeof(player) == "Instance" and player:IsA("Player"), "Invalid player argument")

    local skeleton = setmetatable({}, Skeleton)
    skeleton.Player = player
    skeleton.DoSubsteps = doSubsteps or false
    skeleton.Color = color or Color3.fromRGB(0, 255, 0)
    skeleton.Alpha = alpha or 1
    skeleton.Thickness = thickness or 1

    player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        skeleton.Color = player.TeamColor.Color
        skeleton:UpdateProperties()
    end)

    return skeleton
end

return Library