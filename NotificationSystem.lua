local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

local Theme = {
	Background = Color3.fromRGB(25, 25, 25),
	Text = Color3.fromRGB(240, 240, 240),
	Success = Color3.fromRGB(40, 167, 69),
	Warning = Color3.fromRGB(255, 193, 7),
	Error = Color3.fromRGB(220, 53, 69),
	Info = Color3.fromRGB(0, 120, 215),
	Font = Enum.Font.Gotham,
	Padding = 10
}

local function Create(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		instance[property] = value
	end
	return instance
end

local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
	return setmetatable({_tasks = {}}, Janitor)
end

function Janitor:Add(task)
	table.insert(self._tasks, task)
end

function Janitor:Destroy()
	for _, task in ipairs(self._tasks) do
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		end
	end
	self._tasks = {}
end

function NotificationSystem.new()
	local self = setmetatable({}, NotificationSystem)
	self.janitor = Janitor.new()
	self.notifications = {}
	self.container = self:CreateContainer()
	return self
end

function NotificationSystem:CreateContainer()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local screenGui = Create("ScreenGui", {
		Name = "NotificationSystem",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui
	})
	
	local container = Create("Frame", {
		Name = "Container",
		Size = UDim2.new(0, 300, 1, 0),
		Position = UDim2.new(1, -320, 0, 20),
		BackgroundTransparency = 1,
		Parent = screenGui
	})
	
	local layout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = container
	})
	
	local scale = Create("UIScale", {
		Scale = 0.75,
		Parent = screenGui
	})
	
	self.janitor:Add(screenGui)
	
	return container
end

function NotificationSystem:CreateNotification(title, message, notificationType, duration)
	local typeColor = Theme.Info
	
	if notificationType == "success" then
		typeColor = Theme.Success
	elseif notificationType == "warning" then
		typeColor = Theme.Warning
	elseif notificationType == "error" then
		typeColor = Theme.Error
	end
	
	local notification = Create("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.container
	})
	
	local corner = Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = notification
	})
	
	local stroke = Create("UIStroke", {
		Color = typeColor,
		Thickness = 2,
		Parent = notification
	})
	
	local padding = Create("UIPadding", {
		PaddingTop = UDim.new(0, Theme.Padding),
		PaddingBottom = UDim.new(0, Theme.Padding),
		PaddingLeft = UDim.new(0, Theme.Padding),
		PaddingRight = UDim.new(0, Theme.Padding),
		Parent = notification
	})
	
	local titleLabel = Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = notification
	})
	
	local messageLabel = Create("TextLabel", {
		Name = "Message",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 25),
		BackgroundTransparency = 1,
		Text = message,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Font = Theme.Font,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = notification
	})
	
	local progressBar = Create("Frame", {
		Name = "ProgressBar",
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		BackgroundColor3 = typeColor,
		BorderSizePixel = 0,
		Parent = notification
	})
	
	local closeButton = Create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(1, -20, 0, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 20,
		Parent = notification
	})
	
	local notificationJanitor = Janitor.new()
	
	local closeConnection = closeButton.MouseButton1Click:Connect(function()
		self:RemoveNotification(notification, notificationJanitor)
	end)
	notificationJanitor:Add(closeConnection)
	
	local expandTween = TweenService:Create(
		notification,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(1, 0, 0, 80)}
	)
	expandTween:Play()
	
	local progressTween = TweenService:Create(
		progressBar,
		TweenInfo.new(duration or 5, Enum.EasingStyle.Linear),
		{Size = UDim2.new(0, 0, 0, 3)}
	)
	progressTween:Play()
	
	task.delay(duration or 5, function()
		if notification.Parent then
			self:RemoveNotification(notification, notificationJanitor)
		end
	end)
	
	table.insert(self.notifications, {frame = notification, janitor = notificationJanitor})
end

function NotificationSystem:RemoveNotification(notification, notificationJanitor)
	local shrinkTween = TweenService:Create(
		notification,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size = UDim2.new(1, 0, 0, 0)}
	)
	
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		notificationJanitor:Destroy()
		notification:Destroy()
	end)
	
	for i, data in ipairs(self.notifications) do
		if data.frame == notification then
			table.remove(self.notifications, i)
			break
		end
	end
end

function NotificationSystem:Notify(title, message, notificationType, duration)
	self:CreateNotification(title, message, notificationType or "info", duration or 5)
end

function NotificationSystem:Destroy()
	self.janitor:Destroy()
	self.notifications = {}
end

return NotificationSystem