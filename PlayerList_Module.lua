-- PlayerList Module Script
local PlayerList = {}
PlayerList.__index = PlayerList

-- Configuration
local CONFIG = {
    RefreshRate = 1, -- seconds
    PlayerFrameTemplate = "PlayerFrameTemplate", -- Name of the template in ReplicatedStorage
    MaxPlayersDisplayed = 12, -- Max players shown before scroll
    Animations = {
        Join = {
            Duration = 0.3,
            EasingStyle = Enum.EasingStyle.Quint,
            EasingDirection = Enum.EasingDirection.Out
        },
        Leave = {
            Duration = 0.25,
            EasingStyle = Enum.EasingStyle.Quint,
            EasingDirection = Enum.EasingDirection.In
        }
    }
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function PlayerList.new(parentFrame)
    local self = setmetatable({}, PlayerList)
    
    -- UI Setup
    self.ParentFrame = parentFrame
    self.PlayerFrames = {}
    self.PlayerFrameTemplate = ReplicatedStorage:FindFirstChild(CONFIG.PlayerFrameTemplate)
    
    if not self.PlayerFrameTemplate then
        warn("PlayerFrameTemplate not found in ReplicatedStorage!")
        return nil
    end
    
    -- Create scrolling frame if needed
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Name = "PlayerScrollingFrame"
    self.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.ScrollBarThickness = 4
    self.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    self.ScrollingFrame.Parent = self.ParentFrame
    
    self.UIListLayout = Instance.new("UIListLayout")
    self.UIListLayout.Padding = UDim.new(0, 5)
    self.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.UIListLayout.Parent = self.ScrollingFrame
    
    -- Initialize
    self:InitializePlayerList()
    self:SetupConnections()
    
    -- Start auto-refresh
    self.RefreshConnection = RunService.Heartbeat:Connect(function(dt)
        self.TimeSinceLastRefresh = (self.TimeSinceLastRefresh or 0) + dt
        if self.TimeSinceLastRefresh >= CONFIG.RefreshRate then
            self.TimeSinceLastRefresh = 0
            self:RefreshPlayerList()
        end
    end)
    
    return self
end

function PlayerList:InitializePlayerList()
    -- Clear existing frames
    for _, frame in pairs(self.PlayerFrames) do
        frame:Destroy()
    end
    self.PlayerFrames = {}
    
    -- Create frames for current players
    for _, player in ipairs(Players:GetPlayers()) do
        self:AddPlayerFrame(player)
    end
end

function PlayerList:AddPlayerFrame(player)
    local frame = self.PlayerFrameTemplate:Clone()
    frame.Name = player.Name
    frame.Visible = false
    frame.LayoutOrder = player.UserId
    
    -- Customize frame with player info
    local usernameLabel = frame:FindFirstChild("Username")
    if usernameLabel then
        usernameLabel.Text = player.Name
    end
    
    local displayNameLabel = frame:FindFirstChild("DisplayName")
    if displayNameLabel then
        displayNameLabel.Text = player.DisplayName
    end
    
    local avatarImage = frame:FindFirstChild("Avatar")
    if avatarImage and avatarImage:IsA("ImageLabel") then
        avatarImage.Image = Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end
    
    -- Add to UI
    frame.Parent = self.ScrollingFrame
    self.PlayerFrames[player] = frame
    
    -- Animate in
    self:AnimatePlayerJoin(frame)
end

function PlayerList:RemovePlayerFrame(player)
    local frame = self.PlayerFrames[player]
    if frame then
        self:AnimatePlayerLeave(frame, function()
            frame:Destroy()
            self.PlayerFrames[player] = nil
        end)
    end
end

function PlayerList:AnimatePlayerJoin(frame)
    frame.Visible = true
    frame.Position = UDim2.new(-0.2, 0, 0, 0)
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(
        CONFIG.Animations.Join.Duration,
        CONFIG.Animations.Join.EasingStyle,
        CONFIG.Animations.Join.EasingDirection
    )
    
    local goals = {
        Size = UDim2.new(1, 0, 0, 40), -- Adjust height as needed
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0)
    }
    
    local tween = TweenService:Create(frame, tweenInfo, goals)
    tween:Play()
end

function PlayerList:AnimatePlayerLeave(frame, callback)
    local tweenInfo = TweenInfo.new(
        CONFIG.Animations.Leave.Duration,
        CONFIG.Animations.Leave.EasingStyle,
        CONFIG.Animations.Leave.EasingDirection
    )
    
    local goals = {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }
    
    -- Tween text transparency if needed
    for _, child in ipairs(frame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            goals[child] = {TextTransparency = 1}
        elseif child:IsA("ImageLabel") then
            goals[child] = {ImageTransparency = 1}
        end
    end
    
    local tween = TweenService:Create(frame, tweenInfo, goals)
    tween:Play()
    
    tween.Completed:Connect(function()
        if callback then callback() end
    end)
end

function PlayerList:RefreshPlayerList()
    -- Check for new players
    for _, player in ipairs(Players:GetPlayers()) do
        if not self.PlayerFrames[player] then
            self:AddPlayerFrame(player)
        end
    end
    
    -- Check for left players
    for player, frame in pairs(self.PlayerFrames) do
        if not Players:GetPlayerByUserId(player.UserId) then
            self:RemovePlayerFrame(player)
        end
    end
end

function PlayerList:SetupConnections()
    self.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
        self:AddPlayerFrame(player)
    end)
    
    self.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayerFrame(player)
    end)
end

function PlayerList:Destroy()
    if self.RefreshConnection then
        self.RefreshConnection:Disconnect()
    end
    
    if self.PlayerAddedConnection then
        self.PlayerAddedConnection:Disconnect()
    end
    
    if self.PlayerRemovingConnection then
        self.PlayerRemovingConnection:Disconnect()
    end
    
    for _, frame in pairs(self.PlayerFrames) do
        frame:Destroy()
    end
    
    self.PlayerFrames = {}
    setmetatable(self, nil)
end

return PlayerList