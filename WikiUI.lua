--!strict
-- Wikipedia UI Module - Complete Interface with All Features
-- Production-ready UI module with full mobile support and all API features

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WikiModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/NolanTheScripter/Main/main/WikipediaModule.lua"))()

local WikiUI = {}
WikiUI.__index = WikiUI

-- Configuration
local COLORS = {
	background = Color3.fromRGB(20, 20, 25),
	surface = Color3.fromRGB(30, 30, 36),
	surfaceLight = Color3.fromRGB(40, 40, 48),
	primary = Color3.fromRGB(60, 120, 220),
	primaryHover = Color3.fromRGB(70, 135, 235),
	success = Color3.fromRGB(80, 180, 100),
	danger = Color3.fromRGB(220, 60, 60),
	warning = Color3.fromRGB(220, 160, 40),
	text = Color3.fromRGB(255, 255, 255),
	textSecondary = Color3.fromRGB(200, 200, 200),
	textMuted = Color3.fromRGB(150, 150, 150),
	border = Color3.fromRGB(60, 60, 70),
	accent = Color3.fromRGB(100, 180, 255)
}

local ICONS = {
	search = "🔍",
	close = "✕",
	back = "←",
	forward = "→",
	menu = "☰",
	star = "⭐",
	bookmark = "🔖",
	share = "↗",
	random = "🎲",
	trending = "📈",
	history = "🕐",
	category = "📁",
	image = "🖼️",
	link = "🔗",
	location = "📍",
	language = "🌐",
	info = "ℹ️",
	book = "📖",
	edit = "✏️",
	refresh = "🔄",
	filter = "⚙️"
}

-- Create new UI instance
function WikiUI.new()
	local self = setmetatable({}, WikiUI)
	
	self.wiki = WikiModule.new()
	self.currentLanguage = "en"
	self.searchHistory = {}
	self.bookmarks = {}
	self.currentPage = nil
	self.currentView = "search"
	
	self:_createUI()
	self:_setupEvents()
	
	return self
end

-- Create main UI structure
function WikiUI:_createUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Main ScreenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "WikipediaUI"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Parent = playerGui
	
	-- Main Container
	self.mainFrame = Instance.new("Frame")
	self.mainFrame.Name = "MainFrame"
	self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.mainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
	self.mainFrame.BackgroundColor3 = COLORS.background
	self.mainFrame.BorderSizePixel = 0
	self.mainFrame.Parent = self.screenGui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 15)
	mainCorner.Parent = self.mainFrame
	
	-- UIScale for responsive design
	self.uiScale = Instance.new("UIScale")
	self.uiScale.Parent = self.mainFrame
	
	-- Setup dragging
	self:_setupDragging()
	
	-- Create UI components
	self:_createHeader()
	self:_createSidebar()
	self:_createContentArea()
	self:_createSearchView()
	self:_createArticleView()
	self:_createCategoryView()
	self:_createImageView()
	self:_createHistoryView()
	self:_createSettingsView()
	self:_createLoadingOverlay()
	
	-- Update scale
	self:_updateScale()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self:_updateScale()
	end)
end

-- Setup dragging functionality
function WikiUI:_setupDragging()
	local dragging = false
	local dragStart = Vector2.new()
	local startPos = UDim2.new()
	
	local function updateDrag(input)
		if dragging then
			local delta = input.Position - dragStart
			self.mainFrame.Position = UDim2.new(
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
			startPos = self.mainFrame.Position
		elseif inputState == Enum.UserInputState.End then
			dragging = false
		end
	end
	
	ContextActionService:BindAction("DragWikiWindow", onDragStart, false, 
		Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch then
			updateDrag(input)
		end
	end)
end

-- Create header
function WikiUI:_createHeader()
	self.header = Instance.new("Frame")
	self.header.Name = "Header"
	self.header.Size = UDim2.new(1, 0, 0, 60)
	self.header.BackgroundColor3 = COLORS.surface
	self.header.BorderSizePixel = 0
	self.header.Parent = self.mainFrame
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 15)
	headerCorner.Parent = self.header
	
	local headerBottom = Instance.new("Frame")
	headerBottom.Size = UDim2.new(1, 0, 0, 15)
	headerBottom.Position = UDim2.new(0, 0, 1, -15)
	headerBottom.BackgroundColor3 = COLORS.surface
	headerBottom.BorderSizePixel = 0
	headerBottom.Parent = self.header
	
	-- Logo/Title
	local logo = self:_createTextLabel({
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		Text = "📚 Wikipedia",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.header
	})
	
	-- Search bar in header
	self.headerSearchContainer = Instance.new("Frame")
	self.headerSearchContainer.Size = UDim2.new(0, 350, 0, 40)
	self.headerSearchContainer.Position = UDim2.new(0, 220, 0, 10)
	self.headerSearchContainer.BackgroundColor3 = COLORS.surfaceLight
	self.headerSearchContainer.BorderSizePixel = 0
	self.headerSearchContainer.Parent = self.header
	
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = self.headerSearchContainer
	
	self.headerSearchBox = Instance.new("TextBox")
	self.headerSearchBox.Size = UDim2.new(1, -50, 1, 0)
	self.headerSearchBox.Position = UDim2.new(0, 10, 0, 0)
	self.headerSearchBox.BackgroundTransparency = 1
	self.headerSearchBox.PlaceholderText = "Quick search..."
	self.headerSearchBox.PlaceholderColor3 = COLORS.textMuted
	self.headerSearchBox.Text = ""
	self.headerSearchBox.TextColor3 = COLORS.text
	self.headerSearchBox.TextSize = 14
	self.headerSearchBox.Font = Enum.Font.Gotham
	self.headerSearchBox.TextXAlignment = Enum.TextXAlignment.Left
	self.headerSearchBox.ClearTextOnFocus = false
	self.headerSearchBox.Parent = self.headerSearchContainer
	
	local quickSearchBtn = self:_createButton({
		Size = UDim2.new(0, 35, 0, 30),
		Position = UDim2.new(1, -40, 0, 5),
		Text = ICONS.search,
		TextSize = 16,
		BackgroundColor3 = COLORS.primary,
		Parent = self.headerSearchContainer
	})
	
	-- Language selector
	self.langButton = self:_createButton({
		Size = UDim2.new(0, 45, 0, 40),
		Position = UDim2.new(1, -160, 0, 10),
		Text = ICONS.language,
		TextSize = 18,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = self.header
	})
	
	-- Random page button
	self.randomButton = self:_createButton({
		Size = UDim2.new(0, 45, 0, 40),
		Position = UDim2.new(1, -110, 0, 10),
		Text = ICONS.random,
		TextSize = 18,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = self.header
	})
	
	-- Settings button
	self.settingsButton = self:_createButton({
		Size = UDim2.new(0, 45, 0, 40),
		Position = UDim2.new(1, -60, 0, 10),
		Text = ICONS.filter,
		TextSize = 18,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = self.header
	})
	
	-- Close button
	self.closeButton = self:_createButton({
		Size = UDim2.new(0, 45, 0, 40),
		Position = UDim2.new(1, -10, 0, 10),
		Text = ICONS.close,
		TextSize = 20,
		BackgroundColor3 = COLORS.danger,
		Parent = self.header
	})
end

-- Create sidebar
function WikiUI:_createSidebar()
	self.sidebar = Instance.new("Frame")
	self.sidebar.Name = "Sidebar"
	self.sidebar.Size = UDim2.new(0, 80, 1, -70)
	self.sidebar.Position = UDim2.new(0, 10, 0, 65)
	self.sidebar.BackgroundColor3 = COLORS.surface
	self.sidebar.BorderSizePixel = 0
	self.sidebar.Parent = self.mainFrame
	
	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 10)
	sidebarCorner.Parent = self.sidebar
	
	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 8)
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.Parent = self.sidebar
	
	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 10)
	sidebarPadding.PaddingBottom = UDim.new(0, 10)
	sidebarPadding.Parent = self.sidebar
	
	-- Sidebar buttons
	local menuItems = {
		{icon = ICONS.search, name = "Search", view = "search"},
		{icon = ICONS.trending, name = "Trending", view = "trending"},
		{icon = ICONS.category, name = "Categories", view = "category"},
		{icon = ICONS.image, name = "Images", view = "images"},
		{icon = ICONS.history, name = "History", view = "history"},
		{icon = ICONS.bookmark, name = "Saved", view = "saved"},
		{icon = ICONS.location, name = "Nearby", view = "nearby"}
	}
	
	self.menuButtons = {}
	for _, item in ipairs(menuItems) do
		local btn = self:_createMenuButton(item.icon, item.name, item.view)
		self.menuButtons[item.view] = btn
	end
end

-- Create menu button
function WikiUI:_createMenuButton(icon, name, view)
	local btn = self:_createButton({
		Size = UDim2.new(0, 60, 0, 60),
		Text = icon,
		TextSize = 24,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = self.sidebar
	})
	
	btn.Name = view .. "Button"
	
	local label = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 1, -18),
		Text = name,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		Parent = btn
	})
	
	btn.MouseButton1Click:Connect(function()
		self:switchView(view)
	end)
	
	return btn
end

-- Create content area
function WikiUI:_createContentArea()
	self.contentArea = Instance.new("Frame")
	self.contentArea.Name = "ContentArea"
	self.contentArea.Size = UDim2.new(1, -110, 1, -70)
	self.contentArea.Position = UDim2.new(0, 100, 0, 65)
	self.contentArea.BackgroundColor3 = COLORS.surface
	self.contentArea.BorderSizePixel = 0
	self.contentArea.Parent = self.mainFrame
	
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 10)
	contentCorner.Parent = self.contentArea
	
	-- Container for different views
	self.viewContainer = Instance.new("Frame")
	self.viewContainer.Size = UDim2.new(1, 0, 1, 0)
	self.viewContainer.BackgroundTransparency = 1
	self.viewContainer.Parent = self.contentArea
end

-- Create search view
function WikiUI:_createSearchView()
	self.searchView = Instance.new("Frame")
	self.searchView.Name = "SearchView"
	self.searchView.Size = UDim2.new(1, 0, 1, 0)
	self.searchView.BackgroundTransparency = 1
	self.searchView.Visible = true
	self.searchView.Parent = self.viewContainer
	
	-- Search input section
	local searchSection = Instance.new("Frame")
	searchSection.Size = UDim2.new(1, -40, 0, 140)
	searchSection.Position = UDim2.new(0, 20, 0, 20)
	searchSection.BackgroundTransparency = 1
	searchSection.Parent = self.searchView
	
	local title = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 30),
		Text = "Search Wikipedia",
		TextSize = 22,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchSection
	})
	
	local subtitle = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 35),
		Text = "Explore millions of articles",
		TextSize = 13,
		TextColor3 = COLORS.textSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchSection
	})
	
	-- Main search box
	local searchBoxContainer = Instance.new("Frame")
	searchBoxContainer.Size = UDim2.new(1, 0, 0, 50)
	searchBoxContainer.Position = UDim2.new(0, 0, 0, 65)
	searchBoxContainer.BackgroundColor3 = COLORS.surfaceLight
	searchBoxContainer.BorderSizePixel = 0
	searchBoxContainer.Parent = searchSection
	
	local searchBoxCorner = Instance.new("UICorner")
	searchBoxCorner.CornerRadius = UDim.new(0, 10)
	searchBoxCorner.Parent = searchBoxContainer
	
	self.mainSearchBox = Instance.new("TextBox")
	self.mainSearchBox.Size = UDim2.new(1, -120, 1, -10)
	self.mainSearchBox.Position = UDim2.new(0, 15, 0, 5)
	self.mainSearchBox.BackgroundTransparency = 1
	self.mainSearchBox.PlaceholderText = "Search for anything..."
	self.mainSearchBox.PlaceholderColor3 = COLORS.textMuted
	self.mainSearchBox.Text = ""
	self.mainSearchBox.TextColor3 = COLORS.text
	self.mainSearchBox.TextSize = 16
	self.mainSearchBox.Font = Enum.Font.Gotham
	self.mainSearchBox.TextXAlignment = Enum.TextXAlignment.Left
	self.mainSearchBox.ClearTextOnFocus = false
	self.mainSearchBox.Parent = searchBoxContainer
	
	self.mainSearchButton = self:_createButton({
		Size = UDim2.new(0, 100, 0, 40),
		Position = UDim2.new(1, -105, 0, 5),
		Text = ICONS.search .. " Search",
		TextSize = 14,
		BackgroundColor3 = COLORS.primary,
		Parent = searchBoxContainer
	})
	
	-- Search options
	local optionsFrame = Instance.new("Frame")
	optionsFrame.Size = UDim2.new(1, 0, 0, 30)
	optionsFrame.Position = UDim2.new(0, 0, 0, 120)
	optionsFrame.BackgroundTransparency = 1
	optionsFrame.Parent = searchSection
	
	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.FillDirection = Enum.FillDirection.Horizontal
	optionsLayout.Padding = UDim.new(0, 10)
	optionsLayout.Parent = optionsFrame
	
	local searchTypes = {
		{text = "Articles", value = "articles"},
		{text = "Images", value = "images"},
		{text = "Categories", value = "categories"}
	}
	
	self.searchTypeButtons = {}
	for _, type in ipairs(searchTypes) do
		local btn = self:_createButton({
			Size = UDim2.new(0, 90, 0, 28),
			Text = type.text,
			TextSize = 12,
			BackgroundColor3 = COLORS.surfaceLight,
			Parent = optionsFrame
		})
		btn.Name = type.value
		self.searchTypeButtons[type.value] = btn
	end
	
	-- Results area
	self.searchResults = Instance.new("ScrollingFrame")
	self.searchResults.Size = UDim2.new(1, -40, 1, -180)
	self.searchResults.Position = UDim2.new(0, 20, 0, 170)
	self.searchResults.BackgroundColor3 = COLORS.background
	self.searchResults.BorderSizePixel = 0
	self.searchResults.ScrollBarThickness = 6
	self.searchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.searchResults.ScrollBarImageColor3 = COLORS.border
	self.searchResults.Parent = self.searchView
	
	local resultsCorner = Instance.new("UICorner")
	resultsCorner.CornerRadius = UDim.new(0, 10)
	resultsCorner.Parent = self.searchResults
	
	self.searchResultsLayout = Instance.new("UIListLayout")
	self.searchResultsLayout.Padding = UDim.new(0, 12)
	self.searchResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.searchResultsLayout.Parent = self.searchResults
	
	local resultsPadding = Instance.new("UIPadding")
	resultsPadding.PaddingTop = UDim.new(0, 15)
	resultsPadding.PaddingBottom = UDim.new(0, 15)
	resultsPadding.PaddingLeft = UDim.new(0, 15)
	resultsPadding.PaddingRight = UDim.new(0, 15)
	resultsPadding.Parent = self.searchResults
	
	-- Empty state
	self.searchEmptyState = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.new(0, 0, 0.4, 0),
		Text = "🔍\n\nSearch for articles, images, or topics",
		TextSize = 16,
		TextColor3 = COLORS.textMuted,
		Parent = self.searchResults
	})
end

-- Create article view
function WikiUI:_createArticleView()
	self.articleView = Instance.new("Frame")
	self.articleView.Name = "ArticleView"
	self.articleView.Size = UDim2.new(1, 0, 1, 0)
	self.articleView.BackgroundTransparency = 1
	self.articleView.Visible = false
	self.articleView.Parent = self.viewContainer
	
	-- Article toolbar
	self.articleToolbar = Instance.new("Frame")
	self.articleToolbar.Size = UDim2.new(1, -40, 0, 45)
	self.articleToolbar.Position = UDim2.new(0, 20, 0, 15)
	self.articleToolbar.BackgroundColor3 = COLORS.surfaceLight
	self.articleToolbar.BorderSizePixel = 0
	self.articleToolbar.Parent = self.articleView
	
	local toolbarCorner = Instance.new("UICorner")
	toolbarCorner.CornerRadius = UDim.new(0, 8)
	toolbarCorner.Parent = self.articleToolbar
	
	local toolbarLayout = Instance.new("UIListLayout")
	toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
	toolbarLayout.Padding = UDim.new(0, 8)
	toolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	toolbarLayout.Parent = self.articleToolbar
	
	local toolbarPadding = Instance.new("UIPadding")
	toolbarPadding.PaddingLeft = UDim.new(0, 10)
	toolbarPadding.PaddingRight = UDim.new(0, 10)
	toolbarPadding.Parent = self.articleToolbar
	
	-- Toolbar buttons
	self.backButton = self:_createButton({
		Size = UDim2.new(0, 70, 0, 35),
		Text = ICONS.back .. " Back",
		TextSize = 12,
		BackgroundColor3 = COLORS.surface,
		Parent = self.articleToolbar
	})
	
	self.bookmarkButton = self:_createButton({
		Size = UDim2.new(0, 35, 0, 35),
		Text = ICONS.bookmark,
		TextSize = 16,
		BackgroundColor3 = COLORS.surface,
		Parent = self.articleToolbar
	})
	
	self.shareButton = self:_createButton({
		Size = UDim2.new(0, 35, 0, 35),
		Text = ICONS.share,
		TextSize = 16,
		BackgroundColor3 = COLORS.surface,
		Parent = self.articleToolbar
	})
	
	self.articleInfoButton = self:_createButton({
		Size = UDim2.new(0, 35, 0, 35),
		Text = ICONS.info,
		TextSize = 16,
		BackgroundColor3 = COLORS.surface,
		Parent = self.articleToolbar
	})
	
	-- Article content scroll
	self.articleScroll = Instance.new("ScrollingFrame")
	self.articleScroll.Size = UDim2.new(1, -40, 1, -75)
	self.articleScroll.Position = UDim2.new(0, 20, 0, 70)
	self.articleScroll.BackgroundColor3 = COLORS.background
	self.articleScroll.BorderSizePixel = 0
	self.articleScroll.ScrollBarThickness = 6
	self.articleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.articleScroll.ScrollBarImageColor3 = COLORS.border
	self.articleScroll.Parent = self.articleView
	
	local articleScrollCorner = Instance.new("UICorner")
	articleScrollCorner.CornerRadius = UDim.new(0, 10)
	articleScrollCorner.Parent = self.articleScroll
	
	-- Article content container
	self.articleContent = Instance.new("Frame")
	self.articleContent.Size = UDim2.new(1, -30, 0, 0)
	self.articleContent.AutomaticSize = Enum.AutomaticSize.Y
	self.articleContent.Position = UDim2.new(0, 15, 0, 15)
	self.articleContent.BackgroundTransparency = 1
	self.articleContent.Parent = self.articleScroll
	
	local articleLayout = Instance.new("UIListLayout")
	articleLayout.Padding = UDim.new(0, 15)
	articleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	articleLayout.Parent = self.articleContent
end

-- Create category view
function WikiUI:_createCategoryView()
	self.categoryView = Instance.new("Frame")
	self.categoryView.Name = "CategoryView"
	self.categoryView.Size = UDim2.new(1, 0, 1, 0)
	self.categoryView.BackgroundTransparency = 1
	self.categoryView.Visible = false
	self.categoryView.Parent = self.viewContainer
	
	local title = self:_createTextLabel({
		Size = UDim2.new(1, -40, 0, 35),
		Position = UDim2.new(0, 20, 0, 20),
		Text = ICONS.category .. " Browse Categories",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.categoryView
	})
	
	-- Category search
	local catSearchContainer = Instance.new("Frame")
	catSearchContainer.Size = UDim2.new(1, -40, 0, 40)
	catSearchContainer.Position = UDim2.new(0, 20, 0, 65)
	catSearchContainer.BackgroundColor3 = COLORS.surfaceLight
	catSearchContainer.BorderSizePixel = 0
	catSearchContainer.Parent = self.categoryView
	
	local catSearchCorner = Instance.new("UICorner")
	catSearchCorner.CornerRadius = UDim.new(0, 8)
	catSearchCorner.Parent = catSearchContainer
	
	self.categorySearchBox = Instance.new("TextBox")
	self.categorySearchBox.Size = UDim2.new(1, -100, 1, 0)
	self.categorySearchBox.Position = UDim2.new(0, 10, 0, 0)
	self.categorySearchBox.BackgroundTransparency = 1
	self.categorySearchBox.PlaceholderText = "Search categories..."
	self.categorySearchBox.PlaceholderColor3 = COLORS.textMuted
	self.categorySearchBox.Text = ""
	self.categorySearchBox.TextColor3 = COLORS.text
	self.categorySearchBox.TextSize = 14
	self.categorySearchBox.Font = Enum.Font.Gotham
	self.categorySearchBox.TextXAlignment = Enum.TextXAlignment.Left
	self.categorySearchBox.Parent = catSearchContainer
	
	local catSearchBtn = self:_createButton({
		Size = UDim2.new(0, 85, 0, 32),
		Position = UDim2.new(1, -90, 0, 4),
		Text = ICONS.search,
		TextSize = 14,
		BackgroundColor3 = COLORS.primary,
		Parent = catSearchContainer
	})
	
	-- Category results
	self.categoryResults = Instance.new("ScrollingFrame")
	self.categoryResults.Size = UDim2.new(1, -40, 1, -125)
	self.categoryResults.Position = UDim2.new(0, 20, 0, 115)
	self.categoryResults.BackgroundColor3 = COLORS.background
	self.categoryResults.BorderSizePixel = 0
	self.categoryResults.ScrollBarThickness = 6
	self.categoryResults.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.categoryResults.ScrollBarImageColor3 = COLORS.border
	self.categoryResults.Parent = self.categoryView
	
	local catResultsCorner = Instance.new("UICorner")
	catResultsCorner.CornerRadius = UDim.new(0, 10)
	catResultsCorner.Parent = self.categoryResults
	
	self.categoryResultsLayout = Instance.new("UIListLayout")
	self.categoryResultsLayout.Padding = UDim.new(0, 10)
	self.categoryResultsLayout.Parent = self.categoryResults
	
	local catResultsPadding = Instance.new("UIPadding")
	catResultsPadding.PaddingTop = UDim.new(0, 15)
	catResultsPadding.PaddingBottom = UDim.new(0, 15)
	catResultsPadding.PaddingLeft = UDim.new(0, 15)
	catResultsPadding.PaddingRight = UDim.new(0, 15)
	catResultsPadding.Parent = self.categoryResults
end

-- Create image view
function WikiUI:_createImageView()
	self.imageView = Instance.new("Frame")
	self.imageView.Name = "ImageView"
	self.imageView.Size = UDim2.new(1, 0, 1, 0)
	self.imageView.BackgroundTransparency = 1
	self.imageView.Visible = false
	self.imageView.Parent = self.viewContainer
	
	local title = self:_createTextLabel({
		Size = UDim2.new(1, -40, 0, 35),
		Position = UDim2.new(0, 20, 0, 20),
		Text = ICONS.image .. " Image Gallery",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.imageView
	})
	
	-- Image search
	local imgSearchContainer = Instance.new("Frame")
	imgSearchContainer.Size = UDim2.new(1, -40, 0, 40)
	imgSearchContainer.Position = UDim2.new(0, 20, 0, 65)
	imgSearchContainer.BackgroundColor3 = COLORS.surfaceLight
	imgSearchContainer.BorderSizePixel = 0
	imgSearchContainer.Parent = self.imageView
	
	local imgSearchCorner = Instance.new("UICorner")
	imgSearchCorner.CornerRadius = UDim.new(0, 8)
	imgSearchCorner.Parent = imgSearchContainer
	
	self.imageSearchBox = Instance.new("TextBox")
	self.imageSearchBox.Size = UDim2.new(1, -100, 1, 0)
	self.imageSearchBox.Position = UDim2.new(0, 10, 0, 0)
	self.imageSearchBox.BackgroundTransparency = 1
	self.imageSearchBox.PlaceholderText = "Search for images..."
	self.imageSearchBox.PlaceholderColor3 = COLORS.textMuted
	self.imageSearchBox.Text = ""
	self.imageSearchBox.TextColor3 = COLORS.text
	self.imageSearchBox.TextSize = 14
	self.imageSearchBox.Font = Enum.Font.Gotham
	self.imageSearchBox.TextXAlignment = Enum.TextXAlignment.Left
	self.imageSearchBox.Parent = imgSearchContainer
	
	local imgSearchBtn = self:_createButton({
		Size = UDim2.new(0, 85, 0, 32),
		Position = UDim2.new(1, -90, 0, 4),
		Text = ICONS.search,
		TextSize = 14,
		BackgroundColor3 = COLORS.primary,
		Parent = imgSearchContainer
	})
	
	-- Image grid
	self.imageGrid = Instance.new("ScrollingFrame")
	self.imageGrid.Size = UDim2.new(1, -40, 1, -125)
	self.imageGrid.Position = UDim2.new(0, 20, 0, 115)
	self.imageGrid.BackgroundColor3 = COLORS.background
	self.imageGrid.BorderSizePixel = 0
	self.imageGrid.ScrollBarThickness = 6
	self.imageGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.imageGrid.ScrollBarImageColor3 = COLORS.border
	self.imageGrid.Parent = self.imageView
	
	local imgGridCorner = Instance.new("UICorner")
	imgGridCorner.CornerRadius = UDim.new(0, 10)
	imgGridCorner.Parent = self.imageGrid
	
	self.imageGridLayout = Instance.new("UIGridLayout")
	self.imageGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	self.imageGridLayout.CellSize = UDim2.new(0, 150, 0, 150)
	self.imageGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.imageGridLayout.Parent = self.imageGrid
	
	local imgGridPadding = Instance.new("UIPadding")
	imgGridPadding.PaddingTop = UDim.new(0, 15)
	imgGridPadding.PaddingBottom = UDim.new(0, 15)
	imgGridPadding.PaddingLeft = UDim.new(0, 15)
	imgGridPadding.PaddingRight = UDim.new(0, 15)
	imgGridPadding.Parent = self.imageGrid
end

-- Create history view
function WikiUI:_createHistoryView()
	self.historyView = Instance.new("Frame")
	self.historyView.Name = "HistoryView"
	self.historyView.Size = UDim2.new(1, 0, 1, 0)
	self.historyView.BackgroundTransparency = 1
	self.historyView.Visible = false
	self.historyView.Parent = self.viewContainer
	
	local title = self:_createTextLabel({
		Size = UDim2.new(1, -40, 0, 35),
		Position = UDim2.new(0, 20, 0, 20),
		Text = ICONS.history .. " Search History",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.historyView
	})
	
	-- Clear history button
	self.clearHistoryButton = self:_createButton({
		Size = UDim2.new(0, 120, 0, 35),
		Position = UDim2.new(1, -160, 0, 20),
		Text = "Clear All",
		TextSize = 13,
		BackgroundColor3 = COLORS.danger,
		Parent = self.historyView
	})
	
	-- History list
	self.historyList = Instance.new("ScrollingFrame")
	self.historyList.Size = UDim2.new(1, -40, 1, -75)
	self.historyList.Position = UDim2.new(0, 20, 0, 65)
	self.historyList.BackgroundColor3 = COLORS.background
	self.historyList.BorderSizePixel = 0
	self.historyList.ScrollBarThickness = 6
	self.historyList.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.historyList.ScrollBarImageColor3 = COLORS.border
	self.historyList.Parent = self.historyView
	
	local historyListCorner = Instance.new("UICorner")
	historyListCorner.CornerRadius = UDim.new(0, 10)
	historyListCorner.Parent = self.historyList
	
	self.historyListLayout = Instance.new("UIListLayout")
	self.historyListLayout.Padding = UDim.new(0, 10)
	self.historyListLayout.Parent = self.historyList
	
	local historyListPadding = Instance.new("UIPadding")
	historyListPadding.PaddingTop = UDim.new(0, 15)
	historyListPadding.PaddingBottom = UDim.new(0, 15)
	historyListPadding.PaddingLeft = UDim.new(0, 15)
	historyListPadding.PaddingRight = UDim.new(0, 15)
	historyListPadding.Parent = self.historyList
	
	-- Empty state
	self.historyEmptyState = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.new(0, 0, 0.4, 0),
		Text = "🕐\n\nNo search history yet",
		TextSize = 16,
		TextColor3 = COLORS.textMuted,
		Parent = self.historyList
	})
end

-- Create settings view
function WikiUI:_createSettingsView()
	self.settingsView = Instance.new("Frame")
	self.settingsView.Name = "SettingsView"
	self.settingsView.Size = UDim2.new(1, 0, 1, 0)
	self.settingsView.BackgroundTransparency = 1
	self.settingsView.Visible = false
	self.settingsView.Parent = self.viewContainer
	
	local title = self:_createTextLabel({
		Size = UDim2.new(1, -40, 0, 35),
		Position = UDim2.new(0, 20, 0, 20),
		Text = ICONS.filter .. " Settings",
		TextSize = 20,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.settingsView
	})
	
	-- Settings scroll
	local settingsScroll = Instance.new("ScrollingFrame")
	settingsScroll.Size = UDim2.new(1, -40, 1, -75)
	settingsScroll.Position = UDim2.new(0, 20, 0, 65)
	settingsScroll.BackgroundColor3 = COLORS.background
	settingsScroll.BorderSizePixel = 0
	settingsScroll.ScrollBarThickness = 6
	settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	settingsScroll.ScrollBarImageColor3 = COLORS.border
	settingsScroll.Parent = self.settingsView
	
	local settingsCorner = Instance.new("UICorner")
	settingsCorner.CornerRadius = UDim.new(0, 10)
	settingsCorner.Parent = settingsScroll
	
	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.Padding = UDim.new(0, 15)
	settingsLayout.Parent = settingsScroll
	
	local settingsPadding = Instance.new("UIPadding")
	settingsPadding.PaddingTop = UDim.new(0, 15)
	settingsPadding.PaddingBottom = UDim.new(0, 15)
	settingsPadding.PaddingLeft = UDim.new(0, 15)
	settingsPadding.PaddingRight = UDim.new(0, 15)
	settingsPadding.Parent = settingsScroll
	
	-- Language selector
	local langSection = self:_createSettingSection("Language", settingsScroll)
	local languages = {
		{code = "en", name = "English"},
		{code = "es", name = "Español"},
		{code = "fr", name = "Français"},
		{code = "de", name = "Deutsch"},
		{code = "it", name = "Italiano"},
		{code = "pt", name = "Português"},
		{code = "ja", name = "日本語"},
		{code = "zh", name = "中文"},
		{code = "ru", name = "Русский"},
		{code = "ar", name = "العربية"}
	}
	
	self.languageButtons = {}
	for _, lang in ipairs(languages) do
		local btn = self:_createButton({
			Size = UDim2.new(0, 120, 0, 35),
			Text = lang.name,
			TextSize = 13,
			BackgroundColor3 = COLORS.surfaceLight,
			Parent = langSection
		})
		btn.Name = lang.code
		self.languageButtons[lang.code] = btn
		
		btn.MouseButton1Click:Connect(function()
			self:setLanguage(lang.code)
		end)
	end
	
	-- Result limit
	local limitSection = self:_createSettingSection("Results Per Page", settingsScroll)
	self.resultLimitBox = Instance.new("TextBox")
	self.resultLimitBox.Size = UDim2.new(0, 100, 0, 35)
	self.resultLimitBox.BackgroundColor3 = COLORS.surfaceLight
	self.resultLimitBox.BorderSizePixel = 0
	self.resultLimitBox.Text = "10"
	self.resultLimitBox.TextColor3 = COLORS.text
	self.resultLimitBox.TextSize = 14
	self.resultLimitBox.Font = Enum.Font.Gotham
	self.resultLimitBox.Parent = limitSection
	
	local limitCorner = Instance.new("UICorner")
	limitCorner.CornerRadius = UDim.new(0, 8)
	limitCorner.Parent = self.resultLimitBox
	
	-- Auto-save history
	local historySection = self:_createSettingSection("Save Search History", settingsScroll)
	self.historyToggle = self:_createToggle(historySection)
	
	-- Theme section
	local themeSection = self:_createSettingSection("Theme", settingsScroll)
	local themeBtn = self:_createButton({
		Size = UDim2.new(0, 150, 0, 35),
		Text = "Dark Mode (Active)",
		TextSize = 13,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = themeSection
	})
end

-- Create setting section
function WikiUI:_createSettingSection(title, parent)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = COLORS.surfaceLight
	section.BorderSizePixel = 0
	section.Parent = parent
	
	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 8)
	sectionCorner.Parent = section
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.Parent = section
	
	local sectionPadding = Instance.new("UIPadding")
	sectionPadding.PaddingTop = UDim.new(0, 12)
	sectionPadding.PaddingBottom = UDim.new(0, 12)
	sectionPadding.PaddingLeft = UDim.new(0, 12)
	sectionPadding.PaddingRight = UDim.new(0, 12)
	sectionPadding.Parent = section
	
	local titleLabel = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 20),
		Text = title,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = section
	})
	
	return section
end

-- Create toggle switch
function WikiUI:_createToggle(parent)
	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.new(0, 50, 0, 26)
	toggle.BackgroundColor3 = COLORS.success
	toggle.BorderSizePixel = 0
	toggle.Parent = parent
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggle
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new(0, 26, 0, 2)
	knob.BackgroundColor3 = COLORS.text
	knob.BorderSizePixel = 0
	knob.Parent = toggle
	
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = toggle
	
	local isOn = true
	button.MouseButton1Click:Connect(function()
		isOn = not isOn
		local pos = isOn and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 2, 0, 2)
		local color = isOn and COLORS.success or COLORS.textMuted
		
		TweenService:Create(knob, TweenInfo.new(0.2), {Position = pos}):Play()
		TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end)
	
	return toggle
end

-- Create loading overlay
function WikiUI:_createLoadingOverlay()
	self.loadingOverlay = Instance.new("Frame")
	self.loadingOverlay.Name = "LoadingOverlay"
	self.loadingOverlay.Size = UDim2.new(1, 0, 1, 0)
	self.loadingOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.loadingOverlay.BackgroundTransparency = 0.7
	self.loadingOverlay.BorderSizePixel = 0
	self.loadingOverlay.Visible = false
	self.loadingOverlay.ZIndex = 100
	self.loadingOverlay.Parent = self.mainFrame
	
	local loadingBox = Instance.new("Frame")
	loadingBox.Size = UDim2.new(0, 200, 0, 100)
	loadingBox.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingBox.Position = UDim2.new(0.5, 0, 0.5, 0)
	loadingBox.BackgroundColor3 = COLORS.surface
	loadingBox.BorderSizePixel = 0
	loadingBox.Parent = self.loadingOverlay
	
	local loadingCorner = Instance.new("UICorner")
	loadingCorner.CornerRadius = UDim.new(0, 12)
	loadingCorner.Parent = loadingBox
	
	self.loadingText = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 35),
		Text = "Loading...",
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		Parent = loadingBox
	})
	
	-- Spinning indicator
	local spinner = Instance.new("Frame")
	spinner.Size = UDim2.new(0, 40, 0, 40)
	spinner.AnchorPoint = Vector2.new(0.5, 0)
	spinner.Position = UDim2.new(0.5, 0, 0, 15)
	spinner.BackgroundTransparency = 1
	spinner.Parent = loadingBox
	
	for i = 1, 8 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.new(0.5, 0, 0.5, 0)
		dot.BackgroundColor3 = COLORS.primary
		dot.BorderSizePixel = 0
		dot.Parent = spinner
		
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
		
		local angle = (i - 1) * 45
		local rad = math.rad(angle)
		local x = math.sin(rad) * 15
		local y = -math.cos(rad) * 15
		dot.Position = UDim2.new(0.5, x, 0.5, y)
		
		task.spawn(function()
			while true do
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
end

-- Setup events
function WikiUI:_setupEvents()
	-- Close button
	self.closeButton.MouseButton1Click:Connect(function()
		self:destroy()
	end)
	
	-- Main search
	self.mainSearchButton.MouseButton1Click:Connect(function()
		self:performSearch(self.mainSearchBox.Text)
	end)
	
	self.mainSearchBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			self:performSearch(self.mainSearchBox.Text)
		end
	end)
	
	-- Header quick search
	self.headerSearchBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			self:performSearch(self.headerSearchBox.Text)
		end
	end)
	
	-- Random page
	self.randomButton.MouseButton1Click:Connect(function()
		self:loadRandomPage()
	end)
	
	-- Language selector
	self.langButton.MouseButton1Click:Connect(function()
		self:switchView("settings")
	end)
	
	-- Settings
	self.settingsButton.MouseButton1Click:Connect(function()
		self:switchView("settings")
	end)
	
	-- Article back button
	self.backButton.MouseButton1Click:Connect(function()
		self:switchView("search")
	end)
	
	-- Bookmark button
	self.bookmarkButton.MouseButton1Click:Connect(function()
		self:bookmarkCurrentPage()
	end)
	
	-- Clear history
	self.clearHistoryButton.MouseButton1Click:Connect(function()
		self:clearHistory()
	end)
	
	-- Search type buttons
	for type, btn in pairs(self.searchTypeButtons) do
		btn.MouseButton1Click:Connect(function()
			self:setSearchType(type)
		end)
	end
end

-- Helper: Create button
function WikiUI:_createButton(props)
	local btn = Instance.new("TextButton")
	btn.Size = props.Size or UDim2.new(0, 100, 0, 35)
	btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
	btn.BackgroundColor3 = props.BackgroundColor3 or COLORS.primary
	btn.Text = props.Text or ""
	btn.TextColor3 = props.TextColor3 or COLORS.text
	btn.TextSize = props.TextSize or 14
	btn.Font = props.Font or Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = props.Parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	-- Hover effect
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = self:_lightenColor(btn.BackgroundColor3, 1.2)
		}):Play()
	end)
	
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = props.BackgroundColor3 or COLORS.primary
		}):Play()
	end)
	
	return btn
end

-- Helper: Create text label
function WikiUI:_createTextLabel(props)
	local label = Instance.new("TextLabel")
	label.Size = props.Size or UDim2.new(1, 0, 0, 30)
	label.Position = props.Position or UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = props.BackgroundTransparency or 1
	label.Text = props.Text or ""
	label.TextColor3 = props.TextColor3 or COLORS.text
	label.TextSize = props.TextSize or 14
	label.Font = props.Font or Enum.Font.Gotham
	label.TextWrapped = props.TextWrapped ~= false
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	label.Parent = props.Parent
	
	if props.BackgroundColor3 then
		label.BackgroundColor3 = props.BackgroundColor3
		label.BackgroundTransparency = 0
	end
	
	return label
end

-- Helper: Lighten color
function WikiUI:_lightenColor(color, factor)
	return Color3.new(
		math.min(color.R * factor, 1),
		math.min(color.G * factor, 1),
		math.min(color.B * factor, 1)
	)
end

-- Update responsive scale
function WikiUI:_updateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local minDimension = math.min(viewport.X, viewport.Y)
	local scale = math.clamp(minDimension / 900, 0.5, 1.3)
	self.uiScale.Scale = scale
end

-- Switch view
function WikiUI:switchView(viewName)
	-- Hide all views
	self.searchView.Visible = false
	self.articleView.Visible = false
	self.categoryView.Visible = false
	self.imageView.Visible = false
	self.historyView.Visible = false
	self.settingsView.Visible = false
	
	-- Update menu buttons
	for view, btn in pairs(self.menuButtons) do
		btn.BackgroundColor3 = COLORS.surfaceLight
	end
	
	-- Show selected view
	self.currentView = viewName
	
	if viewName == "search" then
		self.searchView.Visible = true
		if self.menuButtons.search then
			self.menuButtons.search.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "trending" then
		self.searchView.Visible = true
		self:loadTrending()
		if self.menuButtons.trending then
			self.menuButtons.trending.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "category" then
		self.categoryView.Visible = true
		if self.menuButtons.category then
			self.menuButtons.category.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "images" then
		self.imageView.Visible = true
		if self.menuButtons.images then
			self.menuButtons.images.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "history" then
		self.historyView.Visible = true
		self:loadHistory()
		if self.menuButtons.history then
			self.menuButtons.history.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "saved" then
		self.historyView.Visible = true
		self:loadBookmarks()
		if self.menuButtons.saved then
			self.menuButtons.saved.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "nearby" then
		self:loadNearbyArticles()
		if self.menuButtons.nearby then
			self.menuButtons.nearby.BackgroundColor3 = COLORS.primary
		end
	elseif viewName == "settings" then
		self.settingsView.Visible = true
	end
end

-- Show loading
function WikiUI:showLoading(text)
	self.loadingText.Text = text or "Loading..."
	self.loadingOverlay.Visible = true
end

-- Hide loading
function WikiUI:hideLoading()
	self.loadingOverlay.Visible = false
end

-- Perform search
function WikiUI:performSearch(query)
	if query == "" then return end
	
	self:showLoading("Searching...")
	
	-- Add to history
	table.insert(self.searchHistory, 1, {
		query = query,
		timestamp = os.time()
	})
	
	-- Keep only last 50
	if #self.searchHistory > 50 then
		table.remove(self.searchHistory)
	end
	
	task.spawn(function()
		local results = self.wiki:search(query, 10)
		self:hideLoading()
		
		if results and results.query and results.query.search then
			self:displaySearchResults(results.query.search)
			self.searchEmptyState.Visible = false
		else
			self.searchEmptyState.Text = "❌\n\nNo results found"
			self.searchEmptyState.Visible = true
		end
	end)
end

-- Display search results
function WikiUI:displaySearchResults(results)
	-- Clear existing results
	for _, child in ipairs(self.searchResults:GetChildren()) do
		if child:IsA("Frame") and child.Name == "ResultCard" then
			child:Destroy()
		end
	end
	
	for i, result in ipairs(results) do
		local card = self:createResultCard(result)
		card.LayoutOrder = i
	end
	
	-- Update canvas size
	self.searchResults.CanvasSize = UDim2.new(0, 0, 0, self.searchResultsLayout.AbsoluteContentSize.Y + 30)
end

-- Create result card
function WikiUI:createResultCard(result)
	local card = Instance.new("Frame")
	card.Name = "ResultCard"
	card.Size = UDim2.new(1, -12, 0, 120)
	card.BackgroundColor3 = COLORS.surfaceLight
	card.BorderSizePixel = 0
	card.Parent = self.searchResults
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card
	
	-- Title
	local title = self:_createTextLabel({
		Size = UDim2.new(1, -20, 0, 28),
		Position = UDim2.new(0, 10, 0, 8),
		Text = result.title,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = COLORS.accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card
	})
	
	-- Snippet
	local snippet = self:_createTextLabel({
		Size = UDim2.new(1, -20, 0, 50),
		Position = UDim2.new(0, 10, 0, 40),
		Text = self.wiki:cleanSnippet(result.snippet),
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextColor3 = COLORS.textSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card
	})
	
	-- View button
	local viewBtn = self:_createButton({
		Size = UDim2.new(0, 90, 0, 32),
		Position = UDim2.new(1, -100, 1, -40),
		Text = "View " .. ICONS.forward,
		TextSize = 13,
		BackgroundColor3 = COLORS.primary,
		Parent = card
	})
	
	viewBtn.MouseButton1Click:Connect(function()
		self:loadArticle(result.title, result.pageid)
	end)
	
	-- Word count badge
	if result.wordcount then
		local badge = self:_createTextLabel({
			Size = UDim2.new(0, 80, 0, 22),
			Position = UDim2.new(0, 10, 1, -32),
			Text = result.wordcount .. " words",
			TextSize = 11,
			BackgroundColor3 = COLORS.surface,
			TextColor3 = COLORS.textMuted,
			Parent = card
		})
		
		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 6)
		badgeCorner.Parent = badge
	end
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			BackgroundColor3 = self:_lightenColor(COLORS.surfaceLight, 1.1)
		}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			BackgroundColor3 = COLORS.surfaceLight
		}):Play()
	end)
	
	return card
end

-- Load article
function WikiUI:loadArticle(title, pageId)
	self:showLoading("Loading article...")
	self.currentPage = {title = title, pageId = pageId}
	
	task.spawn(function()
		local result
		if pageId then
			result = self.wiki:getPageById(pageId)
		else
			result = self.wiki:getPage(title)
		end
		
		self:hideLoading()
		
		local page = self.wiki:extractPage(result)
		if page then
			self:displayArticle(page)
			self.articleView.Visible = true
			self.searchView.Visible = false
		end
	end)
end

-- Display article
function WikiUI:displayArticle(page)
	-- Clear existing content
	for _, child in ipairs(self.articleContent:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	
	-- Article title
	local titleLabel = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 0),
		Text = ICONS.book .. " " .. page.title,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.articleContent
	})
	
	-- Thumbnail image
	if page.thumbnail then
		local imageFrame = Instance.new("Frame")
		imageFrame.Size = UDim2.new(1, 0, 0, 250)
		imageFrame.BackgroundColor3 = COLORS.surfaceLight
		imageFrame.BorderSizePixel = 0
		imageFrame.Parent = self.articleContent
		
		local imageCorner = Instance.new("UICorner")
		imageCorner.CornerRadius = UDim.new(0, 10)
		imageCorner.Parent = imageFrame
		
		local image = Instance.new("ImageLabel")
		image.Size = UDim2.new(1, -10, 1, -10)
		image.Position = UDim2.new(0, 5, 0, 5)
		image.BackgroundTransparency = 1
		image.Image = page.thumbnail.source
		image.ScaleType = Enum.ScaleType.Fit
		image.Parent = imageFrame
	end
	
	-- Article extract
	if page.extract then
		local extractLabel = self:_createTextLabel({
			Size = UDim2.new(1, 0, 0, 0),
			Text = page.extract,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextColor3 = COLORS.textSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.articleContent
		})
		
		local extractPadding = Instance.new("UIPadding")
		extractPadding.PaddingTop = UDim.new(0, 10)
		extractPadding.PaddingBottom = UDim.new(0, 10)
		extractPadding.Parent = extractLabel
	end
	
	-- Categories section
	if page.categories and #page.categories > 0 then
		local catTitle = self:_createTextLabel({
			Size = UDim2.new(1, 0, 0, 30),
			Text = ICONS.category .. " Categories",
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.articleContent
		})
		
		local catContainer = Instance.new("Frame")
		catContainer.Size = UDim2.new(1, 0, 0, 0)
		catContainer.AutomaticSize = Enum.AutomaticSize.Y
		catContainer.BackgroundTransparency = 1
		catContainer.Parent = self.articleContent
		
		local catLayout = Instance.new("UIListLayout")
		catLayout.FillDirection = Enum.FillDirection.Horizontal
		catLayout.Padding = UDim.new(0, 8)
		catLayout.Wraps = true
		catLayout.Parent = catContainer
		
		for i = 1, math.min(#page.categories, 10) do
			local cat = page.categories[i]
			local catName = cat.title:gsub("Category:", "")
			
			local catBtn = self:_createButton({
				Size = UDim2.new(0, 0, 0, 28),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = catName,
				TextSize = 11,
				BackgroundColor3 = COLORS.surface,
				Parent = catContainer
			})
			
			local btnPadding = Instance.new("UIPadding")
			btnPadding.PaddingLeft = UDim.new(0, 10)
			btnPadding.PaddingRight = UDim.new(0, 10)
			btnPadding.Parent = catBtn
			
			catBtn.MouseButton1Click:Connect(function()
				self:loadCategoryMembers(catName)
			end)
		end
	end
	
	-- Article URL
	if page.fullurl then
		local urlLabel = self:_createTextLabel({
			Size = UDim2.new(1, 0, 0, 25),
			Text = ICONS.link .. " " .. page.fullurl,
			TextSize = 11,
			TextColor3 = COLORS.textMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.articleContent
		})
	end
	
	-- Action buttons
	local actionsFrame = Instance.new("Frame")
	actionsFrame.Size = UDim2.new(1, 0, 0, 45)
	actionsFrame.BackgroundTransparency = 1
	actionsFrame.Parent = self.articleContent
	
	local actionsLayout = Instance.new("UIListLayout")
	actionsLayout.FillDirection = Enum.FillDirection.Horizontal
	actionsLayout.Padding = UDim.new(0, 10)
	actionsLayout.Parent = actionsFrame
	
	local fullArticleBtn = self:_createButton({
		Size = UDim2.new(0, 150, 0, 40),
		Text = "Full Article " .. ICONS.book,
		TextSize = 13,
		BackgroundColor3 = COLORS.primary,
		Parent = actionsFrame
	})
	
	fullArticleBtn.MouseButton1Click:Connect(function()
		self:loadFullArticle(page.title)
	end)
	
	local relatedBtn = self:_createButton({
		Size = UDim2.new(0, 130, 0, 40),
		Text = "Related " .. ICONS.link,
		TextSize = 13,
		BackgroundColor3 = COLORS.success,
		Parent = actionsFrame
	})
	
	relatedBtn.MouseButton1Click:Connect(function()
		self:loadRelatedArticles(page.title)
	end)
	
	local imagesBtn = self:_createButton({
		Size = UDim2.new(0, 120, 0, 40),
		Text = "Images " .. ICONS.image,
		TextSize = 13,
		BackgroundColor3 = COLORS.warning,
		Parent = actionsFrame
	})
	
	imagesBtn.MouseButton1Click:Connect(function()
		self:loadArticleImages(page.title)
	end)
	
	-- Update scroll size
	task.wait(0.1)
	self.articleScroll.CanvasSize = UDim2.new(0, 0, 0, self.articleContent.AbsoluteSize.Y + 30)
end

-- Load full article
function WikiUI:loadFullArticle(title)
	self:showLoading("Loading full article...")
	
	task.spawn(function()
		local result = self.wiki:getFullPage(title)
		self:hideLoading()
		
		local page = self.wiki:extractPage(result)
		if page then
			self:displayArticle(page)
		end
	end)
end

-- Load related articles
function WikiUI:loadRelatedArticles(title)
	self:showLoading("Finding related articles...")
	
	task.spawn(function()
		local related = self.wiki:getRelated(title)
		self:hideLoading()
		
		if related and related.pages then
			-- Clear search results and display related
			for _, child in ipairs(self.searchResults:GetChildren()) do
				if child:IsA("Frame") and child.Name == "ResultCard" then
					child:Destroy()
				end
			end
			
			for i, page in ipairs(related.pages) do
				local result = {
					title = page.title,
					snippet = page.description or page.extract or "No description available",
					pageid = page.pageid or 0,
					wordcount = 0
				}
				local card = self:createResultCard(result)
				card.LayoutOrder = i
			end
			
			self.searchResults.CanvasSize = UDim2.new(0, 0, 0, self.searchResultsLayout.AbsoluteContentSize.Y + 30)
			self:switchView("search")
		end
	end)
end

-- Load article images
function WikiUI:loadArticleImages(title)
	self:showLoading("Loading images...")
	
	task.spawn(function()
		local result = self.wiki:getImages(title, 20)
		self:hideLoading()
		
		local page = self.wiki:extractPage(result)
		if page and page.images then
			self:displayImages(page.images)
			self:switchView("images")
		end
	end)
end

-- Display images
function WikiUI:displayImages(images)
	-- Clear existing images
	for _, child in ipairs(self.imageGrid:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	for i, image in ipairs(images) do
		task.spawn(function()
			local imageInfo = self.wiki:getImageInfo(image.title:gsub("File:", ""))
			
			if imageInfo then
				local page = self.wiki:extractPage(imageInfo)
				if page and page.imageinfo and page.imageinfo[1] then
					local info = page.imageinfo[1]
					self:createImageCard(info)
				end
			end
		end)
	end
	
	task.wait(0.2)
	self.imageGrid.CanvasSize = UDim2.new(0, 0, 0, self.imageGridLayout.AbsoluteContentSize.Y + 30)
end

-- Create image card
function WikiUI:createImageCard(imageInfo)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = COLORS.surfaceLight
	card.BorderSizePixel = 0
	card.Parent = self.imageGrid
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card
	
	local image = Instance.new("ImageLabel")
	image.Size = UDim2.new(1, -10, 1, -10)
	image.Position = UDim2.new(0, 5, 0, 5)
	image.BackgroundTransparency = 1
	image.Image = imageInfo.url
	image.ScaleType = Enum.ScaleType.Fit
	image.Parent = card
	
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = card
	
	button.MouseButton1Click:Connect(function()
		self:showImageFullscreen(imageInfo)
	end)
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 160, 0, 160)
		}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 150, 0, 150)
		}):Play()
	end)
	
	return card
end

-- Show image fullscreen
function WikiUI:showImageFullscreen(imageInfo)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 200
	overlay.Parent = self.mainFrame
	
	local imageFrame = Instance.new("ImageLabel")
	imageFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
	imageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	imageFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageFrame.BackgroundColor3 = COLORS.surface
	imageFrame.BorderSizePixel = 0
	imageFrame.Image = imageInfo.url
	imageFrame.ScaleType = Enum.ScaleType.Fit
	imageFrame.Parent = overlay
	
	local imgCorner = Instance.new("UICorner")
	imgCorner.CornerRadius = UDim.new(0, 15)
	imgCorner.Parent = imageFrame
	
	local closeBtn = self:_createButton({
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -60, 0, 10),
		Text = ICONS.close,
		TextSize = 24,
		BackgroundColor3 = COLORS.danger,
		Parent = overlay
	})
	
	closeBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)
	
	local clickToClose = Instance.new("TextButton")
	clickToClose.Size = UDim2.new(1, 0, 1, 0)
	clickToClose.BackgroundTransparency = 1
	clickToClose.Text = ""
	clickToClose.ZIndex = 199
	clickToClose.Parent = overlay
	
	clickToClose.MouseButton1Click:Connect(function()
		overlay:Destroy()
	end)
end

-- Load category members
function WikiUI:loadCategoryMembers(category)
	self:showLoading("Loading category...")
	
	task.spawn(function()
		local result = self.wiki:getCategoryMembers(category, 20)
		self:hideLoading()
		
		if result and result.query and result.query.categorymembers then
			self:displayCategoryMembers(result.query.categorymembers, category)
			self:switchView("category")
		end
	end)
end

-- Display category members
function WikiUI:displayCategoryMembers(members, categoryName)
	-- Clear existing results
	for _, child in ipairs(self.categoryResults:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Category header
	local header = self:_createTextLabel({
		Size = UDim2.new(1, 0, 0, 40),
		Text = "Category: " .. categoryName,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = COLORS.surfaceLight,
		Parent = self.categoryResults
	})
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 8)
	headerCorner.Parent = header
	
	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, 15)
	headerPadding.Parent = header
	
	-- Create cards for members
	for i, member in ipairs(members) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 50)
		card.BackgroundColor3 = COLORS.surfaceLight
		card.BorderSizePixel = 0
		card.Parent = self.categoryResults
		
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card
		
		local typeIcon = member.type == "subcat" and ICONS.category or ICONS.book
		
		local titleLabel = self:_createTextLabel({
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 15, 0, 0),
			Text = typeIcon .. " " .. member.title,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card
		})
		
		local viewBtn = self:_createButton({
			Size = UDim2.new(0, 90, 0, 35),
			Position = UDim2.new(1, -100, 0, 7.5),
			Text = "View",
			TextSize = 13,
			BackgroundColor3 = COLORS.primary,
			Parent = card
		})
		
		viewBtn.MouseButton1Click:Connect(function()
			if member.type == "subcat" then
				self:loadCategoryMembers(member.title:gsub("Category:", ""))
			else
				self:loadArticle(member.title, member.pageid)
			end
		end)
	end
	
	self.categoryResults.CanvasSize = UDim2.new(0, 0, 0, self.categoryResultsLayout.AbsoluteContentSize.Y + 30)
end

-- Load random page
function WikiUI:loadRandomPage()
	self:showLoading("Finding random article...")
	
	task.spawn(function()
		local result = self.wiki:getRandom(1)
		self:hideLoading()
		
		if result and result.query and result.query.random and result.query.random[1] then
			local page = result.query.random[1]
			self:loadArticle(page.title, page.id)
		end
	end)
end

-- Load trending articles
function WikiUI:loadTrending()
	self:showLoading("Loading trending articles...")
	
	task.spawn(function()
		local trending = self.wiki:getTrending()
		self:hideLoading()
		
		if trending then
			-- Clear results
			for _, child in ipairs(self.searchResults:GetChildren()) do
				if child:IsA("Frame") and child.Name == "ResultCard" then
					child:Destroy()
				end
			end
			
			-- Featured article
			if trending.tfa then
				local result = {
					title = trending.tfa.title,
					snippet = trending.tfa.extract or "Featured article of the day",
					pageid = trending.tfa.pageid or 0,
					wordcount = 0
				}
				local card = self:createResultCard(result)
				card.LayoutOrder = 1
			end
			
			-- Most read
			if trending.mostread and trending.mostread.articles then
				for i, article in ipairs(trending.mostread.articles) do
					if i <= 10 then
						local result = {
							title = article.title or article.displaytitle,
							snippet = article.extract or ("Views: " .. (article.views or 0)),
							pageid = article.pageid or 0,
							wordcount = 0
						}
						local card = self:createResultCard(result)
						card.LayoutOrder = i + 1
					end
				end
			end
			
			self.searchResults.CanvasSize = UDim2.new(0, 0, 0, self.searchResultsLayout.AbsoluteContentSize.Y + 30)
			self.searchEmptyState.Visible = false
		end
	end)
end

-- Load nearby articles
function WikiUI:loadNearbyArticles()
	self:showLoading("Finding nearby articles...")
	
	task.spawn(function()
		-- Example coordinates (San Francisco)
		-- In production, you'd get user's actual location
		local result = self.wiki:geosearch(37.7749, -122.4194, 5000, 15)
		self:hideLoading()
		
		if result and result.query and result.query.geosearch then
			-- Clear results
			for _, child in ipairs(self.searchResults:GetChildren()) do
				if child:IsA("Frame") and child.Name == "ResultCard" then
					child:Destroy()
				end
			end
			
			for i, place in ipairs(result.query.geosearch) do
				local dist = string.format("%.0fm away", place.dist or 0)
				local result = {
					title = place.title,
					snippet = ICONS.location .. " " .. dist,
					pageid = place.pageid,
					wordcount = 0
				}
				local card = self:createResultCard(result)
				card.LayoutOrder = i
			end
			
			self.searchResults.CanvasSize = UDim2.new(0, 0, 0, self.searchResultsLayout.AbsoluteContentSize.Y + 30)
			self:switchView("search")
			self.searchEmptyState.Visible = false
		end
	end)
end

-- Load history
function WikiUI:loadHistory()
	-- Clear existing
	for _, child in ipairs(self.historyList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	if #self.searchHistory == 0 then
		self.historyEmptyState.Visible = true
		return
	end
	
	self.historyEmptyState.Visible = false
	
	for i, entry in ipairs(self.searchHistory) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 50)
		card.BackgroundColor3 = COLORS.surfaceLight
		card.BorderSizePixel = 0
		card.Parent = self.historyList
		
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card
		
		local queryLabel = self:_createTextLabel({
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 15, 0, 0),
			Text = ICONS.search .. " " .. entry.query,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card
		})
		
		local searchBtn = self:_createButton({
			Size = UDim2.new(0, 90, 0, 35),
			Position = UDim2.new(1, -100, 0, 7.5),
			Text = "Search",
			TextSize = 13,
			BackgroundColor3 = COLORS.primary,
			Parent = card
		})
		
		searchBtn.MouseButton1Click:Connect(function()
			self.mainSearchBox.Text = entry.query
			self:performSearch(entry.query)
			self:switchView("search")
		end)
	end
	
	self.historyList.CanvasSize = UDim2.new(0, 0, 0, self.historyListLayout.AbsoluteContentSize.Y + 30)
end

-- Load bookmarks
function WikiUI:loadBookmarks()
	-- Clear existing
	for _, child in ipairs(self.historyList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	if #self.bookmarks == 0 then
		self.historyEmptyState.Text = ICONS.bookmark .. "\n\nNo bookmarks yet"
		self.historyEmptyState.Visible = true
		return
	end
	
	self.historyEmptyState.Visible = false
	
	for i, bookmark in ipairs(self.bookmarks) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 50)
		card.BackgroundColor3 = COLORS.surfaceLight
		card.BorderSizePixel = 0
		card.Parent = self.historyList
		
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = card
		
		local titleLabel = self:_createTextLabel({
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 15, 0, 0),
			Text = ICONS.bookmark .. " " .. bookmark.title,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card
		})
		
		local viewBtn = self:_createButton({
			Size = UDim2.new(0, 90, 0, 35),
			Position = UDim2.new(1, -100, 0, 7.5),
			Text = "View",
			TextSize = 13,
			BackgroundColor3 = COLORS.primary,
			Parent = card
		})
		
		viewBtn.MouseButton1Click:Connect(function()
			self:loadArticle(bookmark.title, bookmark.pageId)
		end)
	end
	
	self.historyList.CanvasSize = UDim2.new(0, 0, 0, self.historyListLayout.AbsoluteContentSize.Y + 30)
end

-- Bookmark current page
function WikiUI:bookmarkCurrentPage()
	if not self.currentPage then return end
	
	-- Check if already bookmarked
	for _, bookmark in ipairs(self.bookmarks) do
		if bookmark.title == self.currentPage.title then
			-- Remove bookmark
			table.remove(self.bookmarks, _)
			self.bookmarkButton.BackgroundColor3 = COLORS.surface
			return
		end
	end
	
	-- Add bookmark
	table.insert(self.bookmarks, {
		title = self.currentPage.title,
		pageId = self.currentPage.pageId,
		timestamp = os.time()
	})
	
	self.bookmarkButton.BackgroundColor3 = COLORS.warning
end

-- Clear history
function WikiUI:clearHistory()
	self.searchHistory = {}
	self:loadHistory()
end

-- Set language
function WikiUI:setLanguage(languageCode)
	self.currentLanguage = languageCode
	self.wiki:setLanguage(languageCode)
	
	-- Update button colors
	for code, btn in pairs(self.languageButtons) do
		if code == languageCode then
			btn.BackgroundColor3 = COLORS.primary
		else
			btn.BackgroundColor3 = COLORS.surfaceLight
		end
	end
	
	-- Show confirmation
	self:showLoading("Language changed to " .. languageCode)
	task.wait(1)
	self:hideLoading()
end

-- Set search type
function WikiUI:setSearchType(searchType)
	for type, btn in pairs(self.searchTypeButtons) do
		if type == searchType then
			btn.BackgroundColor3 = COLORS.primary
		else
			btn.BackgroundColor3 = COLORS.surfaceLight
		end
	end
end

-- Destroy UI
function WikiUI:destroy()
	ContextActionService:UnbindAction("DragWikiWindow")
	self.screenGui:Destroy()
end

return WikiUI