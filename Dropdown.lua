local TweenService = game:GetService("TweenService")

local SmoothDropdown = {}
SmoothDropdown.__index = SmoothDropdown

function SmoothDropdown.new(parent, options)
	local self = setmetatable({}, SmoothDropdown)
	
	self.options = options or {"Option 1", "Option 2", "Option 3"}
	self.isOpen = false
	self.selectedIndex = 1
	self.onSelect = nil
	
	-- Main container
	self.container = Instance.new("Frame")
	self.container.Size = UDim2.new(0, 200, 0, 40)
	self.container.Position = UDim2.new(0.5, -100, 0.5, -20)
	self.container.BackgroundTransparency = 1
	self.container.Parent = parent
	
	-- Dropdown header
	self.header = Instance.new("TextButton")
	self.header.Size = UDim2.new(1, 0, 0, 40)
	self.header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	self.header.BorderSizePixel = 0
	self.header.Font = Enum.Font.GothamBold
	self.header.TextSize = 14
	self.header.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.header.Text = self.options[self.selectedIndex]
	self.header.TextXAlignment = Enum.TextXAlignment.Left
	self.header.TextTruncate = Enum.TextTruncate.AtEnd
	self.header.Parent = self.container
	
	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, 15)
	headerPadding.PaddingRight = UDim.new(0, 35)
	headerPadding.Parent = self.header
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 8)
	headerCorner.Parent = self.header
	
	-- Arrow icon
	self.arrow = Instance.new("TextLabel")
	self.arrow.Size = UDim2.new(0, 20, 0, 20)
	self.arrow.Position = UDim2.new(1, -30, 0.5, -10)
	self.arrow.BackgroundTransparency = 1
	self.arrow.Text = "â–¼"
	self.arrow.TextSize = 12
	self.arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.arrow.Font = Enum.Font.GothamBold
	self.arrow.Parent = self.header
	
	-- Dropdown list container
	self.listContainer = Instance.new("Frame")
	self.listContainer.Size = UDim2.new(1, 0, 0, 0)
	self.listContainer.Position = UDim2.new(0, 0, 0, 45)
	self.listContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	self.listContainer.BorderSizePixel = 0
	self.listContainer.ClipsDescendants = true
	self.listContainer.Visible = false
	self.listContainer.Parent = self.container
	
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 8)
	listCorner.Parent = self.listContainer
	
	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = self.listContainer
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 5)
	listPadding.PaddingBottom = UDim.new(0, 5)
	listPadding.Parent = self.listContainer
	
	-- Create option buttons
	self.optionButtons = {}
	for i, option in ipairs(self.options) do
		local optionBtn = Instance.new("TextButton")
		optionBtn.Size = UDim2.new(1, 0, 0, 35)
		optionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		optionBtn.BorderSizePixel = 0
		optionBtn.Font = Enum.Font.Gotham
		optionBtn.TextSize = 13
		optionBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		optionBtn.Text = option
		optionBtn.TextXAlignment = Enum.TextXAlignment.Left
		optionBtn.AutoButtonColor = false
		optionBtn.LayoutOrder = i
		optionBtn.Parent = self.listContainer
		
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 15)
		btnPadding.PaddingRight = UDim.new(0, 15)
		btnPadding.Parent = optionBtn
		
		-- Hover effect
		optionBtn.MouseEnter:Connect(function()
			TweenService:Create(optionBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(55, 55, 65)
			}):Play()
		end)
		
		optionBtn.MouseLeave:Connect(function()
			TweenService:Create(optionBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			}):Play()
		end)
		
		-- Selection
		optionBtn.MouseButton1Click:Connect(function()
			self:selectOption(i)
		end)
		
		table.insert(self.optionButtons, optionBtn)
	end
	
	-- Header click to toggle
	self.header.MouseButton1Click:Connect(function()
		self:toggle()
	end)
	
	-- Header hover effect
	self.header.MouseEnter:Connect(function()
		TweenService:Create(self.header, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		}):Play()
	end)
	
	self.header.MouseLeave:Connect(function()
		TweenService:Create(self.header, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		}):Play()
	end)
	
	return self
end

function SmoothDropdown:toggle()
	if self.isOpen then
		self:close()
	else
		self:open()
	end
end

function SmoothDropdown:open()
	if self.isOpen then return end
	self.isOpen = true
	
	local targetHeight = #self.options * 35 + 12
	
	self.listContainer.Visible = true
	
	-- Animate dropdown open
	TweenService:Create(self.listContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, targetHeight)
	}):Play()
	
	-- Rotate arrow
	TweenService:Create(self.arrow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Rotation = 180
	}):Play()
	
	-- Fade in options
	for i, btn in ipairs(self.optionButtons) do
		btn.BackgroundTransparency = 1
		btn.TextTransparency = 1
		
		task.wait(0.03)
		
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundTransparency = 0,
			TextTransparency = 0
		}):Play()
	end
end

function SmoothDropdown:close()
	if not self.isOpen then return end
	self.isOpen = false
	
	-- Animate dropdown close
	TweenService:Create(self.listContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(1, 0, 0, 0)
	}):Play()
	
	-- Rotate arrow back
	TweenService:Create(self.arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Rotation = 0
	}):Play()
	
	task.wait(0.2)
	self.listContainer.Visible = false
end

function SmoothDropdown:selectOption(index)
	if index < 1 or index > #self.options then return end
	
	self.selectedIndex = index
	self.header.Text = self.options[index]
	
	-- Flash effect on selection
	TweenService:Create(self.header, TweenInfo.new(0.1), {
		BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	}):Play()
	
	task.wait(0.1)
	
	TweenService:Create(self.header, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	}):Play()
	
	self:close()
	
	if self.onSelect then
		self.onSelect(index, self.options[index])
	end
end

function SmoothDropdown:setOptions(newOptions)
	self.options = newOptions
	
	-- Clear existing buttons
	for _, btn in ipairs(self.optionButtons) do
		btn:Destroy()
	end
	self.optionButtons = {}
	
	-- Recreate buttons
	for i, option in ipairs(self.options) do
		local optionBtn = Instance.new("TextButton")
		optionBtn.Size = UDim2.new(1, 0, 0, 35)
		optionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		optionBtn.BorderSizePixel = 0
		optionBtn.Font = Enum.Font.Gotham
		optionBtn.TextSize = 13
		optionBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		optionBtn.Text = option
		optionBtn.TextXAlignment = Enum.TextXAlignment.Left
		optionBtn.AutoButtonColor = false
		optionBtn.LayoutOrder = i
		optionBtn.Parent = self.listContainer
		
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 15)
		btnPadding.PaddingRight = UDim.new(0, 15)
		btnPadding.Parent = optionBtn
		
		optionBtn.MouseEnter:Connect(function()
			TweenService:Create(optionBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(55, 55, 65)
			}):Play()
		end)
		
		optionBtn.MouseLeave:Connect(function()
			TweenService:Create(optionBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			}):Play()
		end)
		
		optionBtn.MouseButton1Click:Connect(function()
			self:selectOption(i)
		end)
		
		table.insert(self.optionButtons, optionBtn)
	end
	
	self.selectedIndex = 1
	self.header.Text = self.options[1]
end

function SmoothDropdown:destroy()
	self.container:Destroy()
end

return SmoothDropdown