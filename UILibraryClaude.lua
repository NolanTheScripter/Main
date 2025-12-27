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
		
	 -- Slider knob
		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 18, 0, 18)
		knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
		knob.BackgroundColor3 = self.theme.text
		knob.BorderSizePixel = 0
		knob.Parent = track
		
		local knobCorner = Instance.new("UICorner")
		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob
		
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 1, 0)
		button.BackgroundTransparency = 1
		button.Text = ""
		button.Parent = track
		
		local dragging = false
		local currentValue = default
		
		local function updateSlider(input)
			local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			currentValue = math.floor(min + (max - min) * relativeX)
			
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			knob.Position = UDim2.new(relativeX, -9, 0.5, -9)
			valueLabel.Text = tostring(currentValue)
			
			if callback then
				callback(currentValue)
			end
		end
		
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			   input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateSlider(input)
			end
		end)
		
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			   input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
			   input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)
		
		local element = {
			type = "Slider",
			instance = container,
			getValue = function(self)
				return currentValue
			end,
			setValue = function(self, value)
				currentValue = math.clamp(value, min, max)
				local relativeX = (currentValue - min) / (max - min)
				fill.Size = UDim2.new(relativeX, 0, 1, 0)
				knob.Position = UDim2.new(relativeX, -9, 0.5, -9)
				valueLabel.Text = tostring(currentValue)
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addTextBox(tab, text, placeholder, callback, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 70)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
  container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, 25)
		label.Position = UDim2.new(0, 10, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local textBox = Instance.new("TextBox")
		textBox.Size = UDim2.new(1, -20, 0, 35)
		textBox.Position = UDim2.new(0, 10, 0, 30)
		textBox.BackgroundColor3 = self.theme.background
		textBox.BorderSizePixel = 0
		textBox.PlaceholderText = placeholder or "Enter text..."
		textBox.PlaceholderColor3 = self.theme.textMuted
		textBox.Text = ""
		textBox.TextColor3 = self.theme.text
		textBox.TextSize = self.theme.textSizeBody
		textBox.Font = self.theme.fontRegular
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		textBox.ClearTextOnFocus = false
		textBox.Parent = container
		
		local textBoxCorner = Instance.new("UICorner")
		textBoxCorner.CornerRadius = self.theme.cornerRadius
		textBoxCorner.Parent = textBox
		
		local textBoxPadding = Instance.new("UIPadding")
		textBoxPadding.PaddingLeft = UDim.new(0, 10)
		textBoxPadding.PaddingRight = UDim.new(0, 10)
		textBoxPadding.Parent = textBox
		
		if callback then
			textBox.FocusLost:Connect(function(enterPressed)
				callback(textBox.Text, enterPressed)
			end)
		end
		
		local element = {
			type = "TextBox",
			instance = container,
			textBox = textBox,
			getValue = function(self)
				return textBox.Text
			end,
			setValue = function(self, value)
				textBox.Text = value
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addDropdown(tab, text, options, default, callback, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 70)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.ClipsDescendants = true
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, 25)
		label.Position = UDim2.new(0, 10, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local dropdownButton = Instance.new("TextButton")
		dropdownButton.Size = UDim2.new(1, -20, 0, 35)
		dropdownButton.Position = UDim2.new(0, 10, 0, 30)
		dropdownButton.BackgroundColor3 = self.theme.background
		dropdownButton.BorderSizePixel = 0
		dropdownButton.Text = default or options[1] or "Select..."
		dropdownButton.TextColor3 = self.theme.text
		dropdownButton.TextSize = self.theme.textSizeBody
		dropdownButton.Font = self.theme.fontRegular
		dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
		dropdownButton.AutoButtonColor = false
		dropdownButton.Parent = container
		
		local dropdownCorner = Instance.new("UICorner")
		dropdownCorner.CornerRadius = self.theme.cornerRadius
		dropdownCorner.Parent = dropdownButton
		
		local dropdownPadding = Instance.new("UIPadding")
		dropdownPadding.PaddingLeft = UDim.new(0, 10)
		dropdownPadding.PaddingRight = UDim.new(0, 35)
		dropdownPadding.Parent = dropdownButton
		
		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 30, 1, 0)
		arrow.Position = UDim2.new(1, -30, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "▼"
		arrow.TextColor3 = self.theme.textMuted
		arrow.TextSize = 12
		arrow.Font = self.theme.fontBold
		arrow.Parent = dropdownButton
		
		local optionsFrame = Instance.new("Frame")
		optionsFrame.Size = UDim2.new(1, -20, 0, 0)
		optionsFrame.Position = UDim2.new(0, 10, 0, 70)
		optionsFrame.BackgroundColor3 = self.theme.background
		optionsFrame.BorderSizePixel = 0
		optionsFrame.Visible = false
		optionsFrame.Parent = container
		
		local optionsCorner = Instance.new("UICorner")
		optionsCorner.CornerRadius = self.theme.cornerRadius
		optionsCorner.Parent = optionsFrame
		
		local optionsLayout = Instance.new("UIListLayout")
		optionsLayout.Padding = UDim.new(0, 2)
		optionsLayout.Parent = optionsFrame
		
		local optionsPadding = Instance.new("UIPadding")
		optionsPadding.PaddingTop = UDim.new(0, 5)
		optionsPadding.PaddingBottom = UDim.new(0, 5)
		optionsPadding.PaddingLeft = UDim.new(0, 5)
		optionsPadding.PaddingRight = UDim.new(0, 5)
		optionsPadding.Parent = optionsFrame
		
		local isOpen = false
		local selectedOption = default or options[1]
		
		for _, option in ipairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, 0, 0, 30)
			optionButton.BackgroundColor3 = self.theme.surfaceLight
			optionButton.BorderSizePixel = 0
			optionButton.Text = option
			optionButton.TextColor3 = self.theme.text
			optionButton.TextSize = self.theme.textSizeBody
			optionButton.Font = self.theme.fontRegular
			optionButton.TextXAlignment = Enum.TextXAlignment.Left
			optionButton.AutoButtonColor = false
			optionButton.Parent = optionsFrame
			
			local optionCorner = Instance.new("UICorner")
			optionCorner.CornerRadius = UDim.new(0, 6)
			optionCorner.Parent = optionButton
			
			local optionPadding = Instance.new("UIPadding")
			optionPadding.PaddingLeft = UDim.new(0, 10)
			optionPadding.Parent = optionButton
			
			optionButton.MouseEnter:Connect(function()
				TweenService:Create(optionButton, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.hover
				}):Play()
			end)
			
			optionButton.MouseLeave:Connect(function()
				TweenService:Create(optionButton, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.surfaceLight
				}):Play()
			end)
			
			optionButton.MouseButton1Click:Connect(function()
				selectedOption = option
				dropdownButton.Text = option
				
				-- Close dropdown
				isOpen = false
				arrow.Text = "▼"
				optionsFrame.Visible = false
				TweenService:Create(container, TweenInfo.new(0.2), {
					Size = UDim2.new(1, 0, 0, 70)
				}):Play()
				
				if callback then
					callback(option)
				end
			end)
		end
		
		dropdownButton.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			arrow.Text = isOpen and "▲" or "▼"
			optionsFrame.Visible = isOpen
			
			if isOpen then
				local optionsHeight = optionsLayout.AbsoluteContentSize.Y + 10
				optionsFrame.Size = UDim2.new(1, -20, 0, optionsHeight)
				
				TweenService:Create(container, TweenInfo.new(0.2), {
					Size = UDim2.new(1, 0, 0, 75 + optionsHeight)
				}):Play()
			else
				TweenService:Create(container, TweenInfo.new(0.2), {
					Size = UDim2.new(1, 0, 0, 70)
				}):Play()
			end
		end)
		
		local element = {
			type = "Dropdown",
			instance = container,
			getValue = function(self)
				return selectedOption
			end,
			setValue = function(self, value)
				selectedOption = value
				dropdownButton.Text = value
			end,
			setOptions = function(self, newOptions)
				for _, child in ipairs(optionsFrame:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				
				options = newOptions
				-- Recreate options (code would be similar to above)
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addColorPicker(tab, text, default, callback, config)
		config = config or {}
		default = default or Color3.fromRGB(255, 255, 255)
		
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
		
		local colorButton = Instance.new("TextButton")
		colorButton.Size = UDim2.new(0, 50, 0, 30)
		colorButton.Position = UDim2.new(1, -60, 0.5, -15)
		colorButton.BackgroundColor3 = default
		colorButton.BorderSizePixel = 0
		colorButton.Text = ""
		colorButton.Parent = container
		
		local colorCorner = Instance.new("UICorner")
		colorCorner.CornerRadius = self.theme.cornerRadius
		colorCorner.Parent = colorButton
		
		local currentColor = default
		
		colorButton.MouseButton1Click:Connect(function()
			-- Simple color picker popup (simplified version)
			-- In a full implementation, you'd create a color wheel picker
			local colors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(0, 0, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(255, 0, 255),
				Color3.fromRGB(0, 255, 255),
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(0, 0, 0)
			}
			
			-- Cycle through preset colors for demo
			local currentIndex = 1
			for i, color in ipairs(colors) do
				if color == currentColor then
					currentIndex = i
					break
				end
			end
			
			currentIndex = currentIndex % #colors + 1
			currentColor = colors[currentIndex]
			colorButton.BackgroundColor3 = currentColor
			
			if callback then
				callback(currentColor)
			end
		end)
		
		local element = {
			type = "ColorPicker",
			instance = container,
			getValue = function(self)
				return currentColor
			end,
			setValue = function(self, color)
				currentColor = color
				colorButton.BackgroundColor3 = color
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addKeybind(tab, text, default, callback, config)
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
		label.Size = UDim2.new(1, -110, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local keybindButton = Instance.new("TextButton")
		keybindButton.Size = UDim2.new(0, 100, 0, 30)
		keybindButton.Position = UDim2.new(1, -105, 0.5, -15)
		keybindButton.BackgroundColor3 = self.theme.background
		keybindButton.BorderSizePixel = 0
		keybindButton.Text = default and default.Name or "None"
		keybindButton.TextColor3 = self.theme.text
		keybindButton.TextSize = self.theme.textSizeSmall
		keybindButton.Font = self.theme.fontMono
		keybindButton.AutoButtonColor = false
		keybindButton.Parent = container
		
		local keybindCorner = Instance.new("UICorner")
		keybindCorner.CornerRadius = self.theme.cornerRadius
		keybindCorner.Parent = keybindButton
		
		local currentKey = default
		local listening = false
		
		keybindButton.MouseButton1Click:Connect(function()
			listening = true
			keybindButton.Text = "..."
			keybindButton.BackgroundColor3 = self.theme.warning
		end)
		
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					keybindButton.Text = input.KeyCode.Name
					keybindButton.BackgroundColor3 = self.theme.background
					listening = false
					
					if callback then
						callback(input.KeyCode)
					end
				end
			elseif not listening and currentKey and input.KeyCode == currentKey then
				if callback then
					callback(input.KeyCode)
				end
			end
		end)
		
		local element = {
			type = "Keybind",
			instance = container,
			getValue = function(self)
				return currentKey
			end,
			setValue = function(self, key)
				currentKey = key
				keybindButton.Text = key and key.Name or "None"
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addSection(tab, text, config)
		config = config or {}
		
		local section = Instance.new("Frame")
		section.Size = UDim2.new(1, 0, 0, 35)
		section.BackgroundTransparency = 1
		section.Parent = tab.content
		
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 2)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.BackgroundColor3 = self.theme.border
		line.BorderSizePixel = 0
		line.Parent = section
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundColor3 = self.theme.surface
		label.Text = "  " .. text .. "  "
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeHeading
		label.Font = self.theme.fontBold
		label.Parent = section
		
		local element = {
			type = "Section",
			instance = section
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addParagraph(tab, title, text, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 0)
		container.AutomaticSize = Enum.AutomaticSize.Y
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local containerPadding = Instance.new("UIPadding")
		containerPadding.PaddingTop = UDim.new(0, 10)
		containerPadding.PaddingBottom = UDim.new(0, 10)
		containerPadding.PaddingLeft = UDim.new(0, 10)
		containerPadding.PaddingRight = UDim.new(0, 10)
		containerPadding.Parent = container
		
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, 0)
		titleLabel.AutomaticSize = Enum.AutomaticSize.Y
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = self.theme.text
		titleLabel.TextSize = self.theme.textSizeHeading
		titleLabel.Font = self.theme.fontBold
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Top
		titleLabel.TextWrapped = true
		titleLabel.Parent = container
		
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 0, 0)
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.Position = UDim2.new(0, 0, 0, titleLabel.AbsoluteSize.Y + 5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextColor3 = self.theme.textSecondary
		textLabel.TextSize = self.theme.textSizeBody
		textLabel.Font = self.theme.fontRegular
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.TextWrapped = true
		textLabel.Parent = container
		
		local containerLayout = Instance.new("UIListLayout")
		containerLayout.Padding = UDim.new(0, 5)
		containerLayout.Parent = container
		
		local element = {
			type = "Paragraph",
			instance = container,
			setTitle = function(self, newTitle)
				titleLabel.Text = newTitle
			end,
			setText = function(self, newText)
				textLabel.Text = newText
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addDivider(tab)
		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(1, 0, 0, 2)
		divider.BackgroundColor3 = self.theme.border
		divider.BorderSizePixel = 0
		divider.Parent = tab.content
		
		local element = {
			type = "Divider",
			instance = divider
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addImage(tab, imageId, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, config.height or 200)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local image = Instance.new("ImageLabel")
		image.Size = UDim2.new(1, -10, 1, -10)
		image.Position = UDim2.new(0, 5, 0, 5)
		image.BackgroundTransparency = 1
		image.Image = imageId
		image.ScaleType = config.scaleType or Enum.ScaleType.Fit
		image.Parent = container
		
		local element = {
			type = "Image",
			instance = container,
			setImage = function(self, newImageId)
				image.Image = newImageId
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addProgressBar(tab, text, value, config)
		config = config or {}
		value = math.clamp(value or 0, 0, 100)
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 50)
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -70, 0, 20)
		label.Position = UDim2.new(0, 10, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = self.theme.text
		label.TextSize = self.theme.textSizeBody
		label.Font = self.theme.fontRegular
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container
		
		local percentLabel = Instance.new("TextLabel")
		percentLabel.Size = UDim2.new(0, 60, 0, 20)
		percentLabel.Position = UDim2.new(1, -65, 0, 5)
		percentLabel.BackgroundTransparency = 1
		percentLabel.Text = value .. "%"
		percentLabel.TextColor3 = self.theme.primary
		percentLabel.TextSize = self.theme.textSizeBody
		percentLabel.Font = self.theme.fontBold
		percentLabel.TextXAlignment = Enum.TextXAlignment.Right
		percentLabel.Parent = container
		
		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -20, 0, 8)
		track.Position = UDim2.new(0, 10, 0, 32)
		track.BackgroundColor3 = self.theme.background
		track.BorderSizePixel = 0
		track.Parent = container
		
		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(1, 0)
		trackCorner.Parent = track
		
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(value / 100, 0, 1, 0)
		fill.BackgroundColor3 = config.color or self.theme.primary
		fill.BorderSizePixel = 0
		fill.Parent = track
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill
		
		local element = {
			type = "ProgressBar",
			instance = container,
			setValue = function(self, newValue)
				newValue = math.clamp(newValue, 0, 100)
				percentLabel.Text = newValue .. "%"
				TweenService:Create(fill, TweenInfo.new(0.3), {
					Size = UDim2.new(newValue / 100, 0, 1, 0)
				}):Play()
			end,
			getValue = function(self)
				return value
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addChipGroup(tab, options, callback, config)
		config = config or {}
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 0, 0)
		container.AutomaticSize = Enum.AutomaticSize.Y
		container.BackgroundColor3 = self.theme.surfaceLight
		container.BorderSizePixel = 0
		container.Parent = tab.content
		
		local containerCorner = Instance.new("UICorner")
		containerCorner.CornerRadius = self.theme.cornerRadius
		containerCorner.Parent = container
		
		local containerLayout = Instance.new("UIListLayout")
		containerLayout.FillDirection = Enum.FillDirection.Horizontal
		containerLayout.Padding = UDim.new(0, 8)
		containerLayout.Wraps = true
		containerLayout.Parent = container
		
		local containerPadding = Instance.new("UIPadding")
		containerPadding.PaddingTop = UDim.new(0, 10)
		containerPadding.PaddingBottom = UDim.new(0, 10)
		containerPadding.PaddingLeft = UDim.new(0, 10)
		containerPadding.PaddingRight = UDim.new(0, 10)
		containerPadding.Parent = container
		
		local selectedChips = {}
		
		for _, option in ipairs(options) do
			local chip = Instance.new("TextButton")
			chip.Size = UDim2.new(0, 0, 0, 28)
			chip.AutomaticSize = Enum.AutomaticSize.X
			chip.BackgroundColor3 = self.theme.background
			chip.BorderSizePixel = 0
			chip.Text = option
			chip.TextColor3 = self.theme.text
			chip.TextSize = self.theme.textSizeSmall
			chip.Font = self.theme.fontBold
			chip.AutoButtonColor = false
			chip.Parent = container
			
			local chipCorner = Instance.new("UICorner")
			chipCorner.CornerRadius = UDim.new(1, 0)
			chipCorner.Parent = chip
			
			local chipPadding = Instance.new("UIPadding")
			chipPadding.PaddingLeft = UDim.new(0, 15)
			chipPadding.PaddingRight = UDim.new(0, 15)
			chipPadding.Parent = chip
			
			chip.MouseButton1Click:Connect(function()
				local isSelected = selectedChips[option]
				selectedChips[option] = not isSelected
				
				local color = selectedChips[option] and self.theme.primary or self.theme.background
				TweenService:Create(chip, TweenInfo.new(0.2), {
					BackgroundColor3 = color
				}):Play()
				
				if callback then
					callback(option, selectedChips[option], selectedChips)
				end
			end)
		end
		
		local element = {
			type = "ChipGroup",
			instance = container,
			getSelected = function(self)
				return selectedChips
			end
		}
		
		table.insert(tab.elements, element)
		return element
	end

 function window:_addCard(tab, config)
		config = config or {}
		
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.BackgroundColor3 = self.theme.surfaceLight
		card.BorderSizePixel = 0
		card.Parent = tab.content
		
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 10)
		cardCorner.Parent = card
		
		local cardLayout = Instance.new("UIListLayout")
		cardLayout.Padding = UDim.new(0, 10)
		cardLayout.Parent = card
		
		local cardPadding = Instance.new("UIPadding")
  cardPadding.PaddingTop = UDim.new(0, 15)
		cardPadding.PaddingBottom = UDim.new(0, 15)
		cardPadding.PaddingLeft = UDim.new(0, 15)
		cardPadding.PaddingRight = UDim.new(0, 15)
		cardPadding.Parent = card
		
		-- Card can contain other elements
		local cardElements = {}
		
		local cardObject = {
			type = "Card",
			instance = card,
			elements = cardElements,
			
			AddLabel = function(self, text, labelConfig)
				return window:_addLabel({content = card, elements = cardElements}, text, labelConfig)
			end,
			
			AddButton = function(self, text, callback, btnConfig)
				return window:_addButton({content = card, elements = cardElements}, text, callback, btnConfig)
			end,
			
			AddImage = function(self, imageId, imgConfig)
				return window:_addImage({content = card, elements = cardElements}, imageId, imgConfig)
			end
		}
		
		local element = {
			type = "Card",
			instance = card,
			card = cardObject
		}
		
		table.insert(tab.elements, element)
		return cardObject
	end

 function UILibrary:_createHeaderButton(text, color, parent, xOffset)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 40, 0, 40)
		button.Position = UDim2.new(1, xOffset, 0, 5)
		button.BackgroundColor3 = color
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = self.theme.text
		button.TextSize = 18
		button.Font = self.theme.fontBold
		button.AutoButtonColor = false
		button.Parent = parent
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		
		-- Hover effect
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.new(
					math.min(color.R * 1.2, 1),
					math.min(color.G * 1.2, 1),
					math.min(color.B * 1.2, 1)
				)
			}):Play()
		end)
		
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = color
			}):Play()
		end)
		
		return button
	end

 function UILibrary:_setupDragging(window)
		local dragging = false
		local dragStart = Vector2.new()
		local startPos = UDim2.new()
		
		local function updateDrag(input)
			if dragging then
				local delta = input.Position - dragStart
				window.mainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end
		
		local function onDragStart(actionName, inputState, inputObject)
			if inputState == Enum.UserInputState.Begin then
				dragging = true
				dragStart = inputObject.Position
				startPos = window.mainFrame.Position
			elseif inputState == Enum.UserInputState.End then
				dragging = false
			end
		end
		
		ContextActionService:BindAction(
			"DragWindow_" .. window.title,
			onDragStart,
			false,
			Enum.UserInputType.MouseButton1,
			Enum.UserInputType.Touch
		)
		
		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or
			   input.UserInputType == Enum.UserInputType.Touch then
				updateDrag(input)
			end
		end)
	end
	
	function UILibrary:_setupScaling(window)
		local function updateScale()
			local camera = workspace.CurrentCamera
			local viewport = camera.ViewportSize
			local minDimension = math.min(viewport.X, viewport.Y)
			local scale = math.clamp(minDimension / 900, 0.5, 1.3)
			window.uiScale.Scale = scale
		end
		
		updateScale()-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

function UILibrary:Notify(config)
	config = config or {}
	
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Find or create notification container
	local notifContainer = playerGui:FindFirstChild("UILibrary_Notifications")
	if not notifContainer then
		notifContainer = Instance.new("ScreenGui")
		notifContainer.Name = "UILibrary_Notifications"
		notifContainer.ResetOnSpawn = false
		notifContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		notifContainer.Parent = playerGui
		
		local container = Instance.new("Frame")
		container.Name = "Container"
		container.Size = UDim2.new(0, 350, 1, -20)
		container.Position = UDim2.new(1, -360, 0, 10)
		container.BackgroundTransparency = 1
		container.Parent = notifContainer
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
		layout.Parent = container
	end
	
	local container = notifContainer.Container
	
	-- Create notification
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 80)
	notification.BackgroundColor3 = self.theme.surface
	notification.BorderSizePixel = 0
	notification.Parent = container
	
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notification
	
	-- Color bar based on type
	local colorBar = Instance.new("Frame")
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.BackgroundColor3 = config.type == "success" and self.theme.success or
		config.type == "error" and self.theme.danger or
		config.type == "warning" and self.theme.warning or
		self.theme.info
	colorBar.BorderSizePixel = 0
	colorBar.Parent = notification
	
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 10)
	barCorner.Parent = colorBar
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0, 15, 0, 10)
	icon.BackgroundTransparency = 1
	icon.Text = config.icon or 
		(config.type == "success" and "✓" or
		config.type == "error" and "✕" or
		config.type == "warning" and "⚠" or
		"ℹ")
	icon.TextColor3 = colorBar.BackgroundColor3
	icon.TextSize = 24
	icon.Font = self.theme.fontBold
	icon.Parent = notification
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -70, 0, 25)
	title.Position = UDim2.new(0, 60, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = config.title or "Notification"
	title.TextColor3 = self.theme.text
	title.TextSize = self.theme.textSizeHeading
	title.Font = self.theme.fontBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notification
	
	-- Message
	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, -70, 0, 40)
	message.Position = UDim2.new(0, 60, 0, 35)
	message.BackgroundTransparency = 1
	message.Text = config.message or ""
	message.TextColor3 = self.theme.textSecondary
	message.TextSize = self.theme.textSizeBody
	message.Font = self.theme.fontRegular
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.TextWrapped = true
	message.Parent = notification
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -25, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = self.theme.textMuted
	closeBtn.TextSize = 14
	closeBtn.Font = self.theme.fontBold
	closeBtn.Parent = notification
	
	-- Slide in animation
	notification.Position = UDim2.new(1, 0, 0, 0)
	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	
	-- Auto-dismiss
	local duration = config.duration or 5
	
	local function dismiss()
		TweenService:Create(notification, TweenInfo.new(0.3), {
			Position = UDim2.new(1, 0, 0, 0)
		}):Play()
		
		task.wait(0.3)
		notification:Destroy()
	end
	
	closeBtn.MouseButton1Click:Connect(dismiss)
	
	task.delay(duration, dismiss)
	
	return notification
end

-- ============================================
-- DIALOG SYSTEM
-- ============================================

function UILibrary:CreateDialog(config)
	config = config or {}
	
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local dialogGui = Instance.new("ScreenGui")
	dialogGui.Name = "UILibrary_Dialog"
	dialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	dialogGui.Parent = playerGui
	
	-- Overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = dialogGui
	
	-- Dialog box
	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.new(0, 400, 0, 200)
	dialog.AnchorPoint = Vector2.new(0.5, 0.5)
	dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
	dialog.BackgroundColor3 = self.theme.surface
	dialog.BorderSizePixel = 0
	dialog.Parent = overlay
	
	local dialogCorner = Instance.new("UICorner")
	dialogCorner.CornerRadius = UDim.new(0, 12)
	dialogCorner.Parent = dialog
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 40)
	title.Position = UDim2.new(0, 20, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = config.title or "Dialog"
	title.TextColor3 = self.theme.text
	title.TextSize = self.theme.textSizeHeading
	title.Font = self.theme.fontBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = dialog
	
	-- Message
	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, -40, 0, 80)
	message.Position = UDim2.new(0, 20, 0, 60)
	message.BackgroundTransparency = 1
	message.Text = config.message or ""
	message.TextColor3 = self.theme.textSecondary
	message.TextSize = self.theme.textSizeBody
	message.Font = self.theme.fontRegular
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.TextWrapped = true
	message.Parent = dialog
	
	-- Buttons
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, -40, 0, 40)
	buttonContainer.Position = UDim2.new(0, 20, 1, -50)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = dialog
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.Padding = UDim.new(0, 10)
	buttonLayout.Parent = buttonContainer
	
	local buttons = config.buttons or {
		{text = "OK", callback = function() end}
	}
	
	for _, btnConfig in ipairs(buttons) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 100, 0, 35)
		btn.BackgroundColor3 = btnConfig.color or self.theme.primary
		btn.BorderSizePixel = 0
		btn.Text = btnConfig.text
		btn.TextColor3 = self.theme.text
		btn.TextSize = self.theme.textSizeBody
		btn.Font = self.theme.fontBold
		btn.AutoButtonColor = false
		btn.Parent = buttonContainer
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = self.theme.cornerRadius
		btnCorner.Parent = btn
		
		btn.MouseButton1Click:Connect(function()
			if btnConfig.callback then
				btnConfig.callback()
			end
			dialogGui:Destroy()
		end)
	end
	
	-- Scale animation
	dialog.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 400, 0, 200)
	}):Play()
	
	return dialogGui
end

-- ============================================
-- CONTEXT MENU
-- ============================================

function UILibrary:CreateContextMenu(position, options)
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local menuGui = Instance.new("ScreenGui")
	menuGui.Name = "UILibrary_ContextMenu"
	menuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	menuGui.Parent = playerGui
	
	local menu = Instance.new("Frame")
	menu.Size = UDim2.new(0, 200, 0, #options * 35 + 10)
	menu.Position = UDim2.new(0, position.X, 0, position.Y)
	menu.BackgroundColor3 = self.theme.surface
	menu.BorderSizePixel = 0
	menu.Parent = menuGui
	
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = self.theme.cornerRadius
	menuCorner.Parent = menu
	
	local menuLayout = Instance.new("UIListLayout")
	menuLayout.Padding = UDim.new(0, 2)
	menuLayout.Parent = menu
	
	local menuPadding = Instance.new("UIPadding")
	menuPadding.PaddingTop = UDim.new(0, 5)
	menuPadding.PaddingBottom = UDim.new(0, 5)
	menuPadding.PaddingLeft = UDim.new(0, 5)
	menuPadding.PaddingRight = UDim.new(0, 5)
	menuPadding.Parent = menu
	
	for _, option in ipairs(options) do
		if option.type == "divider" then
			local divider = Instance.new("Frame")
			divider.Size = UDim2.new(1, 0, 0, 2)
			divider.BackgroundColor3 = self.theme.border
			divider.BorderSizePixel = 0
			divider.Parent = menu
		else
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 30)
			button.BackgroundColor3 = self.theme.surfaceLight
			button.BorderSizePixel = 0
			button.Text = option.icon and (option.icon .. " " .. option.text) or option.text
			button.TextColor3 = option.color or self.theme.text
			button.TextSize = self.theme.textSizeBody
			button.Font = self.theme.fontRegular
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.AutoButtonColor = false
			button.Parent = menu
			
			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 6)
			btnCorner.Parent = button
			
			local btnPadding = Instance.new("UIPadding")
			btnPadding.PaddingLeft = UDim.new(0, 10)
			btnPadding.Parent = button
			
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.hover
				}):Play()
			end)
			
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(0.2), {
					BackgroundColor3 = self.theme.surfaceLight
				}):Play()
			end)
			
			button.MouseButton1Click:Connect(function()
				if option.callback then
					option.callback()
				end
				menuGui:Destroy()
			end)
		end
	end
	
	-- Close on click outside
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(1, 0, 1, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = ""
	closeButton.ZIndex = -1
	closeButton.Parent = menuGui
	
	closeButton.MouseButton1Click:Connect(function()
		menuGui:Destroy()
	end)
	
	return menuGui
end

-- ============================================
-- LOADING SCREEN
-- ============================================

function UILibrary:CreateLoadingScreen(config)
	config = config or {}
	
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "UILibrary_Loading"
	loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadingGui.Parent = playerGui
	
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = config.backgroundColor or self.theme.background
	overlay.BackgroundTransparency = config.transparency or 0
	overlay.BorderSizePixel = 0
	overlay.Parent = loadingGui
	
	local spinner = Instance.new("Frame")
	spinner.Size = UDim2.new(0, 60, 0, 60)
	spinner.AnchorPoint = Vector2.new(0.5, 0.5)
	spinner.Position = UDim2.new(0.5, 0, 0.5, -30)
	spinner.BackgroundTransparency = 1
	spinner.Parent = overlay
	
	-- Create spinning dots
	for i = 1, 8 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 8, 0, 8)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.new(0.5, 0, 0.5, 0)
		dot.BackgroundColor3 = self.theme.primary
		dot.BorderSizePixel = 0
		dot.Parent = spinner
		
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
		
		local angle = (i - 1) * 45
		local rad = math.rad(angle)
		local x = math.sin(rad) * 25
		local y = -math.cos(rad) * 25
		dot.Position = UDim2.new(0.5, x, 0.5, y)
		
		task.spawn(function()
			while dot and dot.Parent do
				for opacity = 1, 0.2, -0.1 do
					if not dot or not dot.Parent then break end
					dot.BackgroundTransparency = 1 - opacity
					task.wait(0.05)
				end
				task.wait(0.4)
			end
		end)
		
		task.wait(0.1)
	end
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0, 300, 0, 30)
	text.AnchorPoint = Vector2.new(0.5, 0)
	text.Position = UDim2.new(0.5, 0, 0.5, 40)
	text.BackgroundTransparency = 1
	text.Text = config.text or "Loading..."
	text.TextColor3 = self.theme.text
	text.TextSize = self.theme.textSizeBody
	text.Font = self.theme.fontRegular
	text.Parent = overlay
	
	local loading = {
		gui = loadingGui,
		setText = function(self, newText)
			text.Text = newText
		end,
		close = function(self)
			loadingGui:Destroy()
		end
	}
	
	return loading
end

return UILibrary
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end
	
	table.insert(self.windows, window)
	return window
end

