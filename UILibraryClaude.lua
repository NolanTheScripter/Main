--!strict
-- UILibrary - Complete Roblox UI Library
-- Mobile-optimized with all UI elements needed for any project

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local UILibrary = {}
UILibrary.__index = UILibrary

-- Default theme
local DEFAULT_THEME = {
	-- Colors
	background = Color3.fromRGB(20, 20, 25),
	surface = Color3.fromRGB(30, 30, 36),
	surfaceLight = Color3.fromRGB(40, 40, 48),
	primary = Color3.fromRGB(0, 162, 255),
	secondary = Color3.fromRGB(100, 100, 255),
	success = Color3.fromRGB(2, 183, 87),
	danger = Color3.fromRGB(220, 60, 60),
	warning = Color3.fromRGB(255, 178, 41),
	info = Color3.fromRGB(66, 165, 245),
	text = Color3.fromRGB(255, 255, 255),
	textSecondary = Color3.fromRGB(200, 200, 200),
	textMuted = Color3.fromRGB(150, 150, 150),
	border = Color3.fromRGB(60, 60, 70),
	hover = Color3.fromRGB(50, 50, 58),
	
	-- Sizes
	cornerRadius = UDim.new(0, 8),
	padding = 10,
	buttonHeight = 35,
	inputHeight = 40,
	
	-- Fonts
	fontBold = Enum.Font.GothamBold,
	fontRegular = Enum.Font.Gotham,
	fontMono = Enum.Font.Code,
	
	-- Text sizes
	textSizeTitle = 20,
	textSizeHeading = 16,
	textSizeBody = 14,
	textSizeSmall = 12,
	textSizeTiny = 10,
	
	-- Animation
	animationSpeed = 0.2,
	hoverScale = 1.05
}

-- Create new UI instance
function UILibrary.new(title, theme)
	local self = setmetatable({}, UILibrary)
	
	self.theme = theme or DEFAULT_THEME
	self.title = title or "UI Library"
	self.windows = {}
	self.notifications = {}
	
	return self
end

-- ============================================
-- WINDOW CREATION
-- ============================================

function UILibrary:CreateWindow(config)
	config = config or {}
	
	local window = {}
	window.title = config.title or self.title
	window.size = config.size or UDim2.new(0, 600, 0, 400)
	window.position = config.position or UDim2.new(0.5, 0, 0.5, 0)
	window.draggable = config.draggable ~= false
	window.resizable = config.resizable or false
	window.closable = config.closable ~= false
	window.minimizable = config.minimizable or true
	window.tabs = {}
	window.currentTab = nil
	
	-- Create ScreenGui
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	window.screenGui = Instance.new("ScreenGui")
	window.screenGui.Name = "UILibrary_" .. window.title
	window.screenGui.ResetOnSpawn = false
	window.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	window.screenGui.Parent = playerGui
	
	-- Main frame
	window.mainFrame = Instance.new("Frame")
	window.mainFrame.Name = "MainFrame"
	window.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	window.mainFrame.Position = window.position
	window.mainFrame.Size = window.size
	window.mainFrame.BackgroundColor3 = self.theme.background
	window.mainFrame.BorderSizePixel = 0
	window.mainFrame.ClipsDescendants = true
	window.mainFrame.Parent = window.screenGui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = window.mainFrame
	
	-- Shadow effect
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ZIndex = 0
	shadow.Parent = window.mainFrame
	
	-- UIScale for responsive design
	window.uiScale = Instance.new("UIScale")
	window.uiScale.Parent = window.mainFrame
	
	-- Header
	window.header = Instance.new("Frame")
	window.header.Name = "Header"
	window.header.Size = UDim2.new(1, 0, 0, 50)
	window.header.BackgroundColor3 = self.theme.surface
	window.header.BorderSizePixel = 0
	window.header.Parent = window.mainFrame
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = window.header
	
	local headerBottom = Instance.new("Frame")
	headerBottom.Size = UDim2.new(1, 0, 0, 12)
	headerBottom.Position = UDim2.new(0, 0, 1, -12)
	headerBottom.BackgroundColor3 = self.theme.surface
	headerBottom.BorderSizePixel = 0
	headerBottom.Parent = window.header
	
	-- Title
	window.titleLabel = Instance.new("TextLabel")
	window.titleLabel.Size = UDim2.new(1, -100, 1, 0)
	window.titleLabel.Position = UDim2.new(0, 15, 0, 0)
	window.titleLabel.BackgroundTransparency = 1
	window.titleLabel.Text = window.title
	window.titleLabel.TextColor3 = self.theme.text
	window.titleLabel.TextSize = self.theme.textSizeTitle
	window.titleLabel.Font = self.theme.fontBold
	window.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	window.titleLabel.Parent = window.header
	
	-- Control buttons
	local buttonX = -15
	
	if window.closable then
		window.closeButton = self:_createHeaderButton("✕", self.theme.danger, window.header, buttonX)
		window.closeButton.MouseButton1Click:Connect(function()
			window:Destroy()
		end)
		buttonX = buttonX - 45
	end
	
	if window.minimizable then
		window.minimizeButton = self:_createHeaderButton("—", self.theme.warning, window.header, buttonX)
		window.minimizeButton.MouseButton1Click:Connect(function()
			window:ToggleMinimize()
		end)
		buttonX = buttonX - 45
	end
	
	-- Tab container
	window.tabContainer = Instance.new("Frame")
	window.tabContainer.Name = "TabContainer"
	window.tabContainer.Size = UDim2.new(0, 150, 1, -60)
	window.tabContainer.Position = UDim2.new(0, 10, 0, 55)
	window.tabContainer.BackgroundColor3 = self.theme.surface
	window.tabContainer.BorderSizePixel = 0
	window.tabContainer.Parent = window.mainFrame
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = self.theme.cornerRadius
	tabCorner.Parent = window.tabContainer
	
	window.tabLayout = Instance.new("UIListLayout")
	window.tabLayout.Padding = UDim.new(0, 5)
	window.tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	window.tabLayout.Parent = window.tabContainer
	
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 10)
	tabPadding.PaddingBottom = UDim.new(0, 10)
	tabPadding.PaddingLeft = UDim.new(0, 10)
	tabPadding.PaddingRight = UDim.new(0, 10)
	tabPadding.Parent = window.tabContainer
	
	-- Content container
	window.contentContainer = Instance.new("Frame")
	window.contentContainer.Name = "ContentContainer"
	window.contentContainer.Size = UDim2.new(1, -180, 1, -60)
	window.contentContainer.Position = UDim2.new(0, 170, 0, 55)
	window.contentContainer.BackgroundColor3 = self.theme.surface
	window.contentContainer.BorderSizePixel = 0
	window.contentContainer.Parent = window.mainFrame
	
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = self.theme.cornerRadius
	contentCorner.Parent = window.contentContainer
	
	-- Setup dragging
	if window.draggable then
		self:_setupDragging(window)
	end
	
	-- Setup responsive scaling
	self:_setupScaling(window)
	
	-- Window methods
	function window:Destroy()
		self.screenGui:Destroy()
	end
	
	function window:ToggleMinimize()
		local isMinimized = self.mainFrame.Size.Y.Offset == 50
		local newSize = isMinimized and window.size or UDim2.new(window.size.X.Scale, window.size.X.Offset, 0, 50)
		
		TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = newSize
		}):Play()
		
		self.tabContainer.Visible = isMinimized
		self.contentContainer.Visible = isMinimized
	end
	
	function window:CreateTab(name, icon)
		return self:_createTab(name, icon)
	end
	
	function window:_createTab(name, icon)
		local tab = {}
		tab.name = name
		tab.icon = icon or "📄"
		tab.elements = {}
		
		-- Tab button
		tab.button = Instance.new("TextButton")
		tab.button.Name = "Tab_" .. name
		tab.button.Size = UDim2.new(1, 0, 0, 40)
		tab.button.BackgroundColor3 = self.theme.surfaceLight
		tab.button.BorderSizePixel = 0
		tab.button.Text = tab.icon .. " " .. name
		tab.button.TextColor3 = self.theme.text
		tab.button.TextSize = self.theme.textSizeBody
		tab.button.Font = self.theme.fontBold
		tab.button.AutoButtonColor = false
		tab.button.Parent = window.tabContainer
		
		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = self.theme.cornerRadius
		tabCorner.Parent = tab.button
		
		-- Tab content
		tab.content = Instance.new("ScrollingFrame")
		tab.content.Name = "Content_" .. name
		tab.content.Size = UDim2.new(1, -20, 1, -20)
		tab.content.Position = UDim2.new(0, 10, 0, 10)
		tab.content.BackgroundTransparency = 1
		tab.content.BorderSizePixel = 0
		tab.content.ScrollBarThickness = 6
		tab.content.ScrollBarImageColor3 = self.theme.border
		tab.content.CanvasSize = UDim2.new(0, 0, 0, 0)
		tab.content.Visible = false
		tab.content.Parent = window.contentContainer
		
		tab.layout = Instance.new("UIListLayout")
		tab.layout.Padding = UDim.new(0, 10)
		tab.layout.SortOrder = Enum.SortOrder.LayoutOrder
		tab.layout.Parent = tab.content
		
		tab.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tab.content.CanvasSize = UDim2.new(0, 0, 0, tab.layout.AbsoluteContentSize.Y + 20)
		end)
		
		-- Tab button click
		tab.button.MouseButton1Click:Connect(function()
			window:SwitchTab(tab)
		end)
		
		-- Hover effect
		tab.button.MouseEnter:Connect(function()
			if tab ~= window.currentTab then
				TweenService:Create(tab.button, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.hover
				}):Play()
			end
		end)
		
		tab.button.MouseLeave:Connect(function()
			if tab ~= window.currentTab then
				TweenService:Create(tab.button, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.surfaceLight
				}):Play()
			end
		end)
		
		table.insert(window.tabs, tab)
		
		-- Auto-select first tab
		if #window.tabs == 1 then
			window:SwitchTab(tab)
		end
		
		-- Tab element creation methods
		function tab:AddLabel(text, config)
			return window:_addLabel(tab, text, config)
		end
		
		function tab:AddButton(text, callback, config)
			return window:_addButton(tab, text, callback, config)
		end
		
		function tab:AddToggle(text, default, callback, config)
			return window:_addToggle(tab, text, default, callback, config)
		end
		
		function tab:AddSlider(text, min, max, default, callback, config)
			return window:_addSlider(tab, text, min, max, default, callback, config)
		end
		
		function tab:AddTextBox(text, placeholder, callback, config)
			return window:_addTextBox(tab, text, placeholder, callback, config)
		end
		
		function tab:AddDropdown(text, options, default, callback, config)
			return window:_addDropdown(tab, text, options, default, callback, config)
		end
		
		function tab:AddColorPicker(text, default, callback, config)
			return window:_addColorPicker(tab, text, default, callback, config)
		end
		
		function tab:AddKeybind(text, default, callback, config)
			return window:_addKeybind(tab, text, default, callback, config)
		end
		
		function tab:AddSection(text, config)
			return window:_addSection(tab, text, config)
		end
		
		function tab:AddParagraph(title, text, config)
			return window:_addParagraph(tab, title, text, config)
		end
		
		function tab:AddDivider()
			return window:_addDivider(tab)
		end
		
		function tab:AddImage(imageId, config)
			return window:_addImage(tab, imageId, config)
		end
		
		function tab:AddProgressBar(text, value, config)
			return window:_addProgressBar(tab, text, value, config)
		end
		
		function tab:AddChipGroup(options, callback, config)
			return window:_addChipGroup(tab, options, callback, config)
		end
		
		function tab:AddCard(config)
			return window:_addCard(tab, config)
		end
		
		return tab
	end
	
	function window:SwitchTab(tab)
		-- Hide all tabs
		for _, t in ipairs(self.tabs) do
			t.content.Visible = false
			t.button.BackgroundColor3 = self.theme.surfaceLight
		end
		
		-- Show selected tab
		tab.content.Visible = true
		tab.button.BackgroundColor3 = self.theme.primary
		self.currentTab = tab
	end
	
	-- Element creation methods
	function window:_addLabel(tab, text, config)
		config = config or {}
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, config.height or 30)
		label.BackgroundTransparency = config.backgroundTransparency or 1
		label.BackgroundColor3 = config.backgroundColor or self.theme.surfaceLight
		label.Text = text
		label.TextColor3 = config.textColor or self.theme.text
		label.TextSize = config.textSize or self.theme.textSizeBody
		label.Font = config.font or self.theme.fontRegular
		label.TextXAlignment = config.textXAlignment or Enum.TextXAlignment.Left
		label.TextWrapped = config.textWrapped ~= false
		label.Parent = tab.content
		
		if config.backgroundTransparency ~= 1 then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = self.theme.cornerRadius
			corner.Parent = label
			
			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 10)
			padding.PaddingRight = UDim.new(0, 10)
			padding.Parent = label
		end
		
		local element = {
			type = "Label",
			instance = label,
			setText = function(self, newText)
				label.Text = newText
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end
	
	function window:_addButton(tab, text, callback, config)
		config = config or {}
		
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, config.height or self.theme.buttonHeight)
		button.BackgroundColor3 = config.color or self.theme.primary
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = self.theme.text
		button.TextSize = self.theme.textSizeBody
		button.Font = self.theme.fontBold
		button.AutoButtonColor = false
		button.Parent = tab.content
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = self.theme.cornerRadius
		corner.Parent = button
		
		-- Hover and click effects
		local originalColor = button.BackgroundColor3
		
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.new(
					math.min(originalColor.R * 1.2, 1),
					math.min(originalColor.G * 1.2, 1),
					math.min(originalColor.B * 1.2, 1)
				)
			}):Play()
		end)
		
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = originalColor
			}):Play()
		end)
		
		button.MouseButton1Click:Connect(function()
			-- Click animation
			TweenService:Create(button, TweenInfo.new(0.1), {
				Size = UDim2.new(1, -10, 0, config.height or self.theme.buttonHeight)
			}):Play()
			
			task.wait(0.1)
			
			TweenService:Create(button, TweenInfo.new(0.1), {
				Size = UDim2.new(1, 0, 0, config.height or self.theme.buttonHeight)
			}):Play()
			
			if callback then
				callback()
			end
		end)
		
		local element = {
			type = "Button",
			instance = button,
			setText = function(self, newText)
				button.Text = newText
			end,
			setColor = function(self, color)
				originalColor = color
				button.BackgroundColor3 = color
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end
	
	function window:_addToggle(tab, text, default, callback, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 40)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -70, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		-- Toggle switch
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 50, 0, 26)
		toggleFrame.Position = UDim2.new(1, -60, 0.5, -13)
		toggleFrame.BackgroundColor3 = default and self.theme.success or self.theme.textMuted
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = container
		
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(1, 0)
		toggleCorner.Parent = toggleFrame
		
		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 22, 0, 22)
		knob.Position = default and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
		knob.BackgroundColor3 = self.theme.text
		knob.BorderSizePixel = 0
		knob.Parent = toggleFrame
		
		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob
		
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 1, 0)
		button.BackgroundTransparency = 1
		button.Text = ""
		button.Parent = toggleFrame
		
		local isOn = default
		
		button.MouseButton1Click:Connect(function()
			isOn = not isOn
			
			local pos = isOn and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
			local color = isOn and self.theme.success or self.theme.textMuted
			
			TweenService:Create(knob, TweenInfo.new(0.2), {Position = pos}):Play()
			TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
			
			if callback then
				callback(isOn)
			end
		end)
		
		local element = {
			type = "Toggle",
			instance = container,
			getValue = function(self)
				return isOn
			end,
			setValue = function(self, value)
				isOn = value
				knob.Position = isOn and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
				toggleFrame.BackgroundColor3 = isOn and self.theme.success or self.theme.textMuted
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end
	
	function window:_addSlider(tab, text, min, max, default, callback, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 60)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -70, 0, 25)
		label.Position = UDim2.new(0, 10, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local valueLabel = Instance.new("TextLabel")
		valueLabel.Size = UDim2.new(0, 60, 0, 25)
		valueLabel.Position = UDim2.new(1, -65, 0, 5)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = tostring(default)
		valueLabel.TextColor3 = self.theme.primary
		valueLabel.TextSize = self.theme.textSizeBody
		valueLabel.Font = self.theme.fontBold
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.Parent = container
		
		-- Slider track
		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -20, 0, 6)
		track.Position = UDim2.new(0, 10, 0, 35)
		track.BackgroundColor3 = self.theme.background
		track.BorderSizePixel = 0
		track.Parent = container
		
		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(1, 0)
		trackCorner.Parent = track
		
		-- Slider fill
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = self.theme.primary
		fill.BorderSizePixel = 0
		fill.Parent = track
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill
		
	 